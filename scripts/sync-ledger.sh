#!/usr/bin/env bash
# sync-ledger.sh — Reconcile feature_list.json <-> GitHub Issues.
# Default mode: REPORT ONLY (no writes). Requires python3.
# Optional (degrades gracefully if missing or unauthenticated): gh (GitHub CLI).
#
# Usage:
#   bash scripts/sync-ledger.sh                  # report drift, no changes
#   bash scripts/sync-ledger.sh --fix            # cautiously update feature_list.json
#   bash scripts/sync-ledger.sh --epic 42        # list sub-issues for epic #42
#   bash scripts/sync-ledger.sh --epic 42 --fix  # combine flags
#
# --fix rules (conservative — never fabricates evidence):
#   Flips a feature status to "passing" ONLY when its github_issue is CLOSED
#   AND its evidence array is non-empty. All other drift is reported only.
#
# LOCAL TOOL ONLY — do not wire into verify-harness.sh or CI.
# Never prints secrets or .env values.

set -uo pipefail

LEDGER="${LEDGER:-feature_list.json}"
FIX=false
EPIC_ARG=""

# ── Colour helpers ────────────────────────────────────────────────────────────
_info()  { printf '\033[0;36m[INFO]\033[0m  %s\n' "$*"; }
_warn()  { printf '\033[0;33m[WARN]\033[0m  %s\n' "$*"; }
_ok()    { printf '\033[0;32m[OK]\033[0m    %s\n' "$*"; }
_err()   { printf '\033[0;31m[ERROR]\033[0m %s\n' "$*" >&2; }

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --fix)
      FIX=true
      shift
      ;;
    --epic)
      shift
      EPIC_ARG="${1-}"
      [[ $# -gt 0 ]] && shift
      ;;
    -h|--help)
      cat <<'EOF'
sync-ledger.sh — Reconcile feature_list.json <-> GitHub Issues.
Default mode: REPORT ONLY (no writes). Requires python3.
Optional (degrades gracefully if missing or unauthenticated): gh (GitHub CLI).

Usage:
  bash scripts/sync-ledger.sh                  # report drift, no changes
  bash scripts/sync-ledger.sh --fix            # cautiously update feature_list.json
  bash scripts/sync-ledger.sh --epic 42        # list sub-issues for epic #42
  bash scripts/sync-ledger.sh --epic 42 --fix  # combine flags

--fix rules (conservative — never fabricates evidence):
  Flips a feature status to "passing" ONLY when its github_issue is CLOSED
  AND its evidence array is non-empty. All other drift is reported only.

LOCAL TOOL ONLY — do not wire into verify-harness.sh or CI.
Never prints secrets or .env values.
EOF
      exit 0
      ;;
    *)
      _err "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# ── Prerequisites ─────────────────────────────────────────────────────────────
if [[ ! -f "$LEDGER" ]]; then
  _err "Ledger not found: $LEDGER"
  exit 1
fi

if ! python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$LEDGER" 2>/dev/null; then
  _err "Ledger is not valid JSON: $LEDGER"
  exit 1
fi

# Check gh availability and auth — degrade gracefully
GH_OK=false
if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    GH_OK=true
  else
    _warn "gh is installed but not authenticated — GitHub issue state cannot be queried."
    _warn "Run 'gh auth login' to enable GitHub sync."
  fi
else
  _warn "gh (GitHub CLI) not found — GitHub issue state cannot be queried."
  _warn "Install from https://cli.github.com/ and run 'gh auth login'."
fi

# ── Epic sub-issue listing ────────────────────────────────────────────────────
if [[ -n "$EPIC_ARG" ]]; then
  if ! $GH_OK; then
    _err "--epic requires gh to be installed and authenticated."
    exit 0
  fi
  EPIC_NUM="${EPIC_ARG#\#}"
  _info "Sub-issues referenced in epic #${EPIC_NUM}:"
  EPIC_BODY=$(gh issue view "$EPIC_NUM" --json body -q '.body' 2>/dev/null || true)
  if [[ -z "$EPIC_BODY" ]]; then
    _warn "Could not read epic #${EPIC_NUM}."
    exit 0
  fi
  SUB_NUMS=$(printf '%s\n' "$EPIC_BODY" \
    | grep -oE '#[0-9]+' | tr -d '#' | sort -nu 2>/dev/null || true)
  if [[ -z "$SUB_NUMS" ]]; then
    _info "No sub-issue references found in epic #${EPIC_NUM} body."
    exit 0
  fi
  printf '%-8s %-12s %s\n' 'ISSUE' 'STATE' 'TITLE'
  printf '%-8s %-12s %s\n' '-----' '-----' '-----'
  while IFS= read -r num; do
    STATE=$(gh issue view "$num" --json state -q '.state' 2>/dev/null || echo 'UNKNOWN')
    TITLE=$(gh issue view "$num" --json title -q '.title' 2>/dev/null || echo '(could not read)')
    printf '%-8s %-12s %s\n' "#${num}" "${STATE}" "${TITLE}"
  done <<< "$SUB_NUMS"
  exit 0
fi

# ── Main drift report ─────────────────────────────────────────────────────────
_info "Checking ledger: $LEDGER"
if $FIX; then
  _info "Mode: FIX (cautious — flips to 'passing' only when issue is closed + evidence present)"
else
  _info "Mode: REPORT ONLY (pass --fix to apply cautious updates)"
fi
echo ""

# Run analysis via python3; capture exit code without set -e interference.
PY_EXIT=0
python3 - "$LEDGER" "$GH_OK" "$FIX" <<'PYEOF'
import json, subprocess, sys

ledger_path = sys.argv[1]
gh_ok       = sys.argv[2] == "true"
fix_mode    = sys.argv[3] == "true"

with open(ledger_path) as fh:
    ledger = json.load(fh)

features    = ledger.get("features", [])
dirty       = False
drift_count = 0


def gh_issue(num):
    """Return (STATE, title) or (None, None) on any failure."""
    try:
        r = subprocess.run(
            ["gh", "issue", "view", str(num), "--json", "state,title"],
            capture_output=True, text=True, timeout=15,
        )
        if r.returncode != 0:
            return None, None
        d = json.loads(r.stdout)
        return d.get("state", "").upper(), d.get("title", "")
    except Exception:
        return None, None


for feat in features:
    fid      = feat.get("id", "?")
    status   = feat.get("status", "?")
    ghi      = feat.get("github_issue")
    evidence = feat.get("evidence", [])

    if ghi is None:
        if status == "in_progress":
            print(f"[DRIFT] {fid}: status=in_progress but github_issue is null"
                  f" -- create a GH issue and set github_issue")
            drift_count += 1
        continue

    if not gh_ok:
        print(f"[SKIP]  {fid}: github_issue=#{ghi} (gh unavailable or unauthenticated)")
        continue

    state, title = gh_issue(ghi)
    if state is None:
        print(f"[WARN]  {fid}: github_issue=#{ghi} could not be read"
              f" (issue missing or repo private?)")
        drift_count += 1
        continue

    label = f"{fid} (#{ghi} '{title}')"

    if state == "CLOSED" and status != "passing":
        if evidence:
            print(f"[DRIFT] {label}: issue CLOSED + evidence present"
                  f" -- status='{status}' should be 'passing'")
            if fix_mode:
                feat["status"] = "passing"
                dirty = True
                print(f"[FIX]   {label}: set status -> passing")
        else:
            print(f"[DRIFT] {label}: issue CLOSED but evidence=[]"
                  f" -- add evidence before flipping to 'passing'")
        drift_count += 1
    elif state == "OPEN" and status == "passing":
        print(f"[DRIFT] {label}: status=passing but issue is still OPEN"
              f" -- verify and close the issue or revert status")
        drift_count += 1
    else:
        print(f"[OK]    {label}: status='{status}' consistent with issue state={state}")

if dirty:
    ledger["features"] = features
    with open(ledger_path, "w") as fh:
        json.dump(ledger, fh, indent=2)
        fh.write("\n")
    print(f"\n[FIXED] Wrote updated ledger -> {ledger_path}")

print(f"\nDrift: {drift_count} item(s)")
sys.exit(2 if drift_count > 0 else 0)
PYEOF
PY_EXIT=$?

if [[ $PY_EXIT -eq 0 ]]; then
  _ok "Ledger is in sync -- no drift found."
elif [[ $PY_EXIT -eq 2 ]]; then
  _warn "Drift detected. Review the [DRIFT] lines above."
  if ! $FIX; then
    _info "Re-run with --fix to apply cautious updates."
  fi
fi

exit 0

# _Part of the {{PROJECT_NAME}} Agent Harness OS — see the harness index (../.agents/README.md) and AGENTS.md (../AGENTS.md)._
