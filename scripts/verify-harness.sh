#!/usr/bin/env bash
# verify-harness.sh — Single source of verification truth for the Agent Harness OS.
# Non-destructive, read-only. Run locally before a PR; CI runs the same script.
#
# Checks: required structure present, entry-file length limits, feature_list.json
# valid JSON, GitHub issue-form YAML valid, relative markdown links resolve,
# no AI/LLM attribution, no secrets, shell syntax valid, slash-command schema,
# skill schema, subagent schema, and context-map presence.
#
# Usage:  bash scripts/verify-harness.sh [--json] [--scans-only] [--help]
#   --json        Machine-readable JSON instead of colored human text. The JSON
#                 has shape {"ok":bool,"passed":int,"failed":int,"checks":[...]}
#                 where each check is {group,category,status,detail}. Agents can
#                 parse this; the exit code is identical to human mode.
#   --scans-only  Run ONLY the content scans (markdown links, attribution, secret
#                 patterns) and skip the structural/schema checks. Pair with
#                 HARNESS_VERIFY_ROOT to scan an arbitrary fixture tree (used by
#                 scripts/test-verify-harness.sh).
#   --help        Print this usage and exit 0.
#
# Env:
#   HARNESS_VERIFY_ROOT   Directory the checks run against (default: git repo
#                         root, else current directory). Lets tests point the
#                         scans at a hermetic fixture root.
#
# Exits non-zero iff any check fails (same in human and --json modes).

set -uo pipefail

# ── Argument parsing ──────────────────────────────────────────────────────────
JSON_MODE=0
SCANS_ONLY=0
usage() {
  cat <<'USAGE'
verify-harness.sh — single source of harness verification truth.

Usage: bash scripts/verify-harness.sh [--json] [--scans-only] [--help]

Flags (combinable, order-independent):
  --json        Emit machine-readable JSON instead of human-readable text.
  --scans-only  Run only the content scans (markdown links, attribution,
                secret patterns); skip structural and schema checks.
  --help        Show this help and exit 0.

Env:
  HARNESS_VERIFY_ROOT   Override the directory the checks run against
                        (default: git repo root, else current directory).

Exit code: non-zero iff any check failed (identical in both output modes).
USAGE
}
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_MODE=1 ;;
    --scans-only) SCANS_ONLY=1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "error: unknown flag '$1'" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

cd "${HARNESS_VERIFY_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo .)}"

PASS=0
FAILED=0
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; RESET='\033[0m'

# Per-check result rows, captured for both human output and --json emission.
CURRENT_GROUP=""
CURRENT_CAT=""
ROWS_FILE=$(mktemp 2>/dev/null || echo "/tmp/verify-harness.$$.rows")
trap 'rm -f "$ROWS_FILE"' EXIT
record_row() { printf '%s\x1f%s\x1f%s\x1f%s\n' "$CURRENT_GROUP" "$CURRENT_CAT" "$1" "$2" >> "$ROWS_FILE"; }

# hdr <category> <title...> — opens a check group; sets the machine category that
# every pass/fail in the group inherits, and prints the human header.
hdr()  { CURRENT_CAT="$1"; shift; CURRENT_GROUP="$*"; [[ "$JSON_MODE" -eq 1 ]] || echo -e "\n${BOLD}$*${RESET}"; }
pass() { record_row pass "$*"; [[ "$JSON_MODE" -eq 1 ]] || echo -e "  ${GREEN}✓${RESET} $*"; PASS=$((PASS+1)); }
# fail() auto-prefixes the detail with its category so failures are self-locating.
fail() { local d="[${CURRENT_CAT}] $*"; record_row fail "$d"; [[ "$JSON_MODE" -eq 1 ]] || echo -e "  ${RED}✗ ${d}${RESET}"; FAILED=$((FAILED+1)); }
warn() { [[ "$JSON_MODE" -eq 1 ]] || echo -e "  ${YELLOW}!${RESET} $*"; }
# fail_list <summary> <items-newline-string> — a failure whose detail is an
# enumerated list (broken links, attribution hits, secret hits, tracked env
# files). Human mode prints the red summary then each item indented; --json mode
# folds the items into the single-line `detail` (joined with "; ") so agents get
# the file:line locations directly, without having to re-run in human mode.
fail_list() {
  local summary="$1" items="$2" joined="" line
  while IFS= read -r line; do
    line="${line#"${line%%[![:space:]]*}"}"   # left-trim indentation
    [[ -z "$line" ]] && continue
    joined+="${joined:+; }${line}"
  done <<< "$items"
  record_row fail "[${CURRENT_CAT}] ${summary}${joined:+ }${joined}"
  FAILED=$((FAILED+1))
  if [[ "$JSON_MODE" -ne 1 ]]; then
    echo -e "  ${RED}✗ [${CURRENT_CAT}] ${summary}${RESET}"
    printf '%s\n' "$items" | sed '/^[[:space:]]*$/d; s/^/    /'
  fi
}

# Files that legitimately contain the prohibited/secret-shaped strings on purpose
# (the design spec, this script's own match patterns, and the regression test's
# concatenated fixtures) — excluded from scans.
# Anchored to the path field (before the first ':') so it never hides a real hit
# that merely mentions these filenames in its content.
EXCLUDE='prompt\.md|verify-harness\.sh|test-verify-harness\.sh'
exclude_by_path() { grep -vE "^[^:]*(${EXCLUDE}):"; }

# ── Single source of truth: directories that must never be scanned ────────────
# Vendored/generated/build output plus nested git-worktree copies. Pruning the
# basename 'worktrees' catches BOTH ./worktrees/ and ./.claude/worktrees/, which
# is also a DETERMINISM fix: the verifier walks the filesystem, so a stray local
# worktree would otherwise inflate the scan counts.
EXCLUDE_DIRS=( .git node_modules dist build vendor out .next .turbo .cache .vite coverage .venv venv __pycache__ worktrees )
GREP_EXCLUDE_DIRS=()
for d in "${EXCLUDE_DIRS[@]}"; do GREP_EXCLUDE_DIRS+=(--exclude-dir="$d"); done

if [[ "$SCANS_ONLY" -eq 0 ]]; then
# ── 1. Required structure ─────────────────────────────────────────────────────
hdr missing "1. Required structure"
REQUIRED_FILES=(
  AGENTS.md CLAUDE.md init.sh feature_list.json
  claude-progress.md session-handoff.md clean-state-checklist.md evaluator-rubric.md
  .agents/README.md .agents/proposals/README.md .agents/artifacts/README.md
  .agents/context/slash-commands.md .agents/context/failure-modes.md
  .agents/context/subagents.md
  .agents/workflows/autonomous-loops.md .agents/workflows/context-mapping.md
  .claude/README.md .claude/skills/AGENTS.md
  .github/pull_request_template.md
  .github/ISSUE_TEMPLATE/epic.yml .github/ISSUE_TEMPLATE/epic-subissue.yml
  .github/ISSUE_TEMPLATE/bug_report.yml .github/ISSUE_TEMPLATE/feature_request.yml
)
REQUIRED_DIRS=( .agents/context .agents/workflows .agents/logs .github/ISSUE_TEMPLATE .claude/commands .claude/skills .claude/agents )
miss=0
for f in "${REQUIRED_FILES[@]}"; do [[ -s "$f" ]] || { fail "missing/empty: $f"; miss=1; }; done
for d in "${REQUIRED_DIRS[@]}"; do [[ -d "$d" ]] || { fail "missing dir: $d"; miss=1; }; done
# Each subsystem dir should hold a reasonable number of docs.
for d in .agents/context .agents/workflows .agents/logs; do
  n=$(find "$d" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')
  [[ "$n" -ge 3 ]] || { fail "$d has only $n markdown files (expected >= 3)"; miss=1; }
done
[[ "$miss" -eq 0 ]] && pass "all required files and directories present"

# ── 2. Entry-file length limits ───────────────────────────────────────────────
hdr length "2. Entry-file length limits"
check_len() { local f="$1" max="$2"; local n
  [[ -f "$f" ]] || { fail "$f missing"; return; }
  n=$(wc -l < "$f" | tr -d ' ')
  [[ -n "$n" ]] || { fail "$f unreadable"; return; }
  if [[ "$n" -le "$max" ]]; then pass "$f = $n lines (<= $max)"; else fail "$f = $n lines (> $max)"; fi; }
check_len AGENTS.md 200
check_len CLAUDE.md 250

# ── 3. feature_list.json valid JSON ───────────────────────────────────────────
hdr json "3. feature_list.json"
if python3 -c "import json,sys; d=json.load(open('feature_list.json')); assert isinstance(d.get('features'),list)" 2>/dev/null; then
  pass "feature_list.json is valid JSON with a features array"
else
  fail "feature_list.json is not valid JSON (or missing 'features' array)"
fi

# ── 4. GitHub issue-form YAML valid ───────────────────────────────────────────
hdr yaml "4. GitHub issue-form YAML"
yaml_ok() {
  if python3 -c "import yaml" 2>/dev/null; then python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$1" 2>/dev/null
  elif command -v ruby >/dev/null 2>&1; then ruby -ryaml -e "YAML.load_file(ARGV[0])" "$1" 2>/dev/null
  else return 2; fi
}
yfail=0; ycount=0; yran=0
for y in .github/ISSUE_TEMPLATE/*.yml .github/workflows/*.yml; do
  [[ -e "$y" ]] || continue; ycount=$((ycount+1))
  yaml_ok "$y"; rc=$?
  if [[ $rc -eq 2 ]]; then warn "no YAML parser (python-yaml/ruby) available — skipping $y"
  elif [[ $rc -ne 0 ]]; then fail "invalid YAML: $y"; yfail=1
  else yran=$((yran+1)); fi
done
if [[ "$ycount" -eq 0 ]]; then warn "no YAML files found"
elif [[ "$yran" -eq 0 ]]; then fail "no YAML parser available — $ycount file(s) left unvalidated"
elif [[ "$yfail" -eq 0 ]]; then pass "$yran/$ycount YAML file(s) valid"; fi
fi  # end structural checks 1-4

# ── 5. Relative markdown links resolve ────────────────────────────────────────
hdr link "5. Markdown link resolution"
LINKOUT=$(HARNESS_EXCLUDE_DIRS="${EXCLUDE_DIRS[*]}" python3 - <<'PY'
import os, re
# Directories that hold vendored/generated content — single-sourced from bash.
PRUNE = set(os.environ.get('HARNESS_EXCLUDE_DIRS', '').split())
# Inline links: [txt](dest), [txt](<dest>), [txt](dest "title") — capture dest only.
inline_re = re.compile(r'\][ \t]*\(\s*<?([^)\s>]+)>?(?:[ \t]+"[^"]*")?\s*\)')
# Reference definitions: [label]: dest ["title"]  — validate their dest too.
refdef_re = re.compile(r'^[ \t]*\[[^\]]+\]:[ \t]*<?(\S+?)>?[ \t]*(?:"[^"]*")?[ \t]*$')
broken = []; checked = 0
for root, dirs, files in os.walk('.'):
    dirs[:] = [d for d in dirs if d not in PRUNE]
    for f in files:
        if not f.endswith('.md'): continue
        p = os.path.join(root, f); base = os.path.dirname(p)
        with open(p, encoding='utf-8') as fh:
            text = fh.read()
        # Scan per line so each broken link reports the line it occurs on.
        for lineno, line in enumerate(text.splitlines(), 1):
            targets = [m.group(1) for m in inline_re.finditer(line)]
            targets += [m.group(1) for m in refdef_re.finditer(line)]
            for h in targets:
                h = h.strip()
                if h.startswith(('http://', 'https://', 'mailto:', 'tel:', '#')): continue
                t = h.split('#', 1)[0]
                if not t: continue
                checked += 1
                if not os.path.exists(os.path.normpath(os.path.join(base, t))):
                    broken.append(f"{p}:{lineno} -> {h}")
print(checked)
for b in broken: print("BROKEN " + b)
PY
)
NCHECK=$(echo "$LINKOUT" | head -1)
BROKEN=$(echo "$LINKOUT" | grep -c '^BROKEN ' || true)
if [[ "$BROKEN" -eq 0 ]]; then pass "$NCHECK relative links resolve"; else
  fail_list "$BROKEN broken link(s):" "$(echo "$LINKOUT" | grep '^BROKEN ' | sed 's/^BROKEN //')"; fi

# ── 6. No AI/LLM attribution ──────────────────────────────────────────────────
hdr attribution "6. No AI/LLM attribution"
# Match real attribution forms, then drop lines that are prohibition rules.
ATTR=$(grep -rniE 'co-authored-by:[[:space:]]*(claude|chatgpt|gpt|codex|copilot|ai)|generated (with|by) (claude|chatgpt|copilot|ai)|🤖 generated|created by (claude|codex|chatgpt)' \
  "${GREP_EXCLUDE_DIRS[@]}" \
  --include='*.md' --include='*.sh' --include='*.yml' --include='*.yaml' --include='*.json' --include='*.ts' --include='*.js' . 2>/dev/null \
  | exclude_by_path \
  | grep -viE 'never|no `|do not|don.t|avoid|prohibit|without|equivalent|forbidden' || true)
if [[ -z "$ATTR" ]]; then pass "no AI/LLM attribution found"; else fail_list "attribution found:" "$ATTR"; fi

# ── 7. No secrets ─────────────────────────────────────────────────────────────
hdr secret "7. No secrets"
SEC=$(grep -rniE '(gh[pousr]_[A-Za-z0-9]{30,})|(AKIA[0-9A-Z]{16})|(-----BEGIN [A-Z ]*PRIVATE KEY-----)|(xox[baprs]-[A-Za-z0-9-]{10,})|(eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,})' \
  "${GREP_EXCLUDE_DIRS[@]}" \
  --include='*.md' --include='*.sh' --include='*.yml' --include='*.yaml' --include='*.json' --include='*.ts' --include='*.js' --include='*.env*' . 2>/dev/null \
  | exclude_by_path || true)
if [[ -z "$SEC" ]]; then pass "no secret patterns found"; else fail_list "possible secret(s):" "$SEC"; fi
# Guard: no env files staged or tracked (needs a real git repo; skip in scans-only).
if [[ "$SCANS_ONLY" -eq 0 ]]; then
  TRACKED_ENV=$(git ls-files | grep -E '(^|/)\.env($|\.)' | grep -v '\.env\.example$' || true)
  if [[ -z "$TRACKED_ENV" ]]; then pass "no .env files tracked"; else fail_list "tracked env file(s):" "$TRACKED_ENV"; fi
fi

if [[ "$SCANS_ONLY" -eq 0 ]]; then
# ── 8. init.sh syntax ─────────────────────────────────────────────────────────
hdr syntax "8. Shell script syntax"
synfail=0
for s in init.sh scripts/*.sh; do
  [[ -e "$s" ]] || continue
  if bash -n "$s" 2>/dev/null; then pass "$s syntax OK"; else fail "$s syntax error"; synfail=1; fi
done

# ── 9. Slash command schema ───────────────────────────────────────────────────
hdr command "9. Slash command schema"
shopt -s nullglob
cmd_fail=0; cmd_n=0
# No stray non-command files: every .md under .claude/commands/ registers as a command.
for bad in .claude/commands/AGENTS.md .claude/commands/README.md; do
  [[ -e "$bad" ]] && { fail "$bad would register as a slash command — move it to .agents/context/"; cmd_fail=1; }
done
for f in .claude/commands/*; do
  case "$f" in *.md) ;; *) fail "non-command file in .claude/commands/: $f"; cmd_fail=1 ;; esac
done
CMD_HEADINGS=( '## Purpose' '## Usage' '## Procedure' '## Stop Conditions' '## Safety' '## Output' '## Related' )
for f in .claude/commands/*.md; do
  cmd_n=$((cmd_n+1))
  [[ "$(head -1 "$f")" == '---' ]] || { fail "$f: missing YAML frontmatter"; cmd_fail=1; }
  head -12 "$f" | grep -qE '^description:[[:space:]]*[^[:space:]]' || { fail "$f: missing frontmatter 'description:'"; cmd_fail=1; }
  for h in "${CMD_HEADINGS[@]}"; do
    grep -qE "^${h}[[:space:]]*$" "$f" || { fail "$f: missing heading '$h'"; cmd_fail=1; }
  done
done
if [[ "$cmd_n" -eq 0 ]]; then fail "no slash commands found in .claude/commands/"; cmd_fail=1; fi
[[ "$cmd_fail" -eq 0 ]] && pass "$cmd_n slash command(s) conform to schema"

# ── 10. Skill schema ──────────────────────────────────────────────────────────
hdr skill "10. Skill schema"
sk_fail=0; sk_n=0
SK_HEADINGS=( '## Purpose' '## When to Use' '## When Not to Use' '## Procedure' '## Checks' '## Related Commands' )
for d in .claude/skills/*/; do
  [[ -d "$d" ]] || continue
  name=$(basename "$d")
  sf="${d}SKILL.md"
  [[ -f "$sf" ]] || { fail "$d has no SKILL.md"; sk_fail=1; continue; }
  sk_n=$((sk_n+1))
  [[ "$(head -1 "$sf")" == '---' ]] || { fail "$sf: missing YAML frontmatter"; sk_fail=1; }
  fmname=$(grep -m1 -E '^name:' "$sf" | sed -E 's/^name:[[:space:]]*//' | tr -d '"'\''[:space:]')
  [[ "$fmname" == "$name" ]] || { fail "$sf: frontmatter name '$fmname' != directory '$name'"; sk_fail=1; }
  head -12 "$sf" | grep -qE '^description:[[:space:]]*[^[:space:]]' || { fail "$sf: missing frontmatter 'description:'"; sk_fail=1; }
  for h in "${SK_HEADINGS[@]}"; do
    grep -qE "^${h}[[:space:]]*$" "$sf" || { fail "$sf: missing heading '$h'"; sk_fail=1; }
  done
done
if [[ "$sk_n" -eq 0 ]]; then fail "no skills found in .claude/skills/"; sk_fail=1; fi
[[ "$sk_fail" -eq 0 ]] && pass "$sk_n skill(s) conform to schema"

# ── 11. Context maps present ───────────────────────────────────────────────────
hdr context-map "11. Context maps"
ctx_fail=0
for d in .github scripts .agents .agents/logs .claude/skills; do
  [[ -s "$d/AGENTS.md" ]] || { fail "missing context map: $d/AGENTS.md"; ctx_fail=1; }
done
[[ "$ctx_fail" -eq 0 ]] && pass "context maps present in key directories"

# ── 12. Subagent schema ───────────────────────────────────────────────────────
hdr subagent "12. Subagent schema"
ag_fail=0; ag_n=0
for bad in .claude/agents/AGENTS.md .claude/agents/README.md; do
  [[ -e "$bad" ]] && { fail "$bad would register as a subagent — document the surface in .agents/context/subagents.md"; ag_fail=1; }
done
for f in .claude/agents/*; do
  case "$f" in *.md) ;; *) fail "non-agent file in .claude/agents/: $f"; ag_fail=1 ;; esac
done
AG_HEADINGS=( '## Role' '## When to Use' '## Operating Rules' '## Harness Skills & Commands' '## Output' )
for f in .claude/agents/*.md; do
  ag_n=$((ag_n+1))
  base=$(basename "$f" .md)
  [[ "$(head -1 "$f")" == '---' ]] || { fail "$f: missing YAML frontmatter"; ag_fail=1; }
  agname=$(grep -m1 -E '^name:' "$f" | sed -E 's/^name:[[:space:]]*//' | tr -d '"'\''[:space:]')
  [[ "$agname" == "$base" ]] || { fail "$f: frontmatter name '$agname' != filename '$base'"; ag_fail=1; }
  head -12 "$f" | grep -qE '^description:[[:space:]]*[^[:space:]]' || { fail "$f: missing frontmatter 'description:'"; ag_fail=1; }
  model=$(grep -m1 -E '^model:' "$f" | sed -E 's/^model:[[:space:]]*//' | tr -d '"'\''[:space:]')
  case "$model" in haiku|sonnet|opus) ;; *) fail "$f: model '$model' must be one of haiku|sonnet|opus"; ag_fail=1 ;; esac
  # Read-only contract: an agent that restricts tools AND calls itself read-only must not grant write/exec tools.
  toolsline=$(grep -m1 -E '^tools:' "$f" || true)
  if [[ -n "$toolsline" ]] && grep -qiE 'read[ -]only' "$f"; then
    printf '%s' "$toolsline" | grep -qiE '(^|[,: ])(Bash|Edit|Write|NotebookEdit)([,]|[[:space:]]|$)' \
      && { fail "$f: declares read-only but its 'tools:' grants a write/exec tool — $toolsline"; ag_fail=1; }
  fi
  for h in "${AG_HEADINGS[@]}"; do
    grep -qE "^${h}[[:space:]]*$" "$f" || { fail "$f: missing heading '$h'"; ag_fail=1; }
  done
done
if [[ "$ag_n" -eq 0 ]]; then fail "no subagents found in .claude/agents/"; ag_fail=1; fi
[[ "$ag_fail" -eq 0 ]] && pass "$ag_n subagent(s) conform to schema"
fi  # end structural checks 8-12

# ── Summary / output ──────────────────────────────────────────────────────────
if [[ "$JSON_MODE" -eq 1 ]]; then
  ROWS_FILE="$ROWS_FILE" PASS_N="$PASS" FAILED_N="$FAILED" python3 - <<'PY'
import json, os
rows = []
with open(os.environ['ROWS_FILE'], encoding='utf-8') as fh:
    for line in fh:
        line = line.rstrip('\n')
        if not line: continue
        parts = line.split('\x1f')
        if len(parts) != 4: continue
        g, c, s, d = parts
        rows.append({"group": g, "category": c, "status": s, "detail": d})
failed = int(os.environ['FAILED_N']); passed = int(os.environ['PASS_N'])
print(json.dumps({"ok": failed == 0, "passed": passed, "failed": failed, "checks": rows}))
PY
  [[ "$FAILED" -gt 0 ]] && exit 1
  exit 0
fi

echo -e "\n${BOLD}Summary${RESET}"
echo "  passed: $PASS   failed: $FAILED"
if [[ "$FAILED" -gt 0 ]]; then
  echo -e "${RED}${BOLD}Harness verification FAILED.${RESET}"
  exit 1
fi
echo -e "${GREEN}${BOLD}Harness verification passed.${RESET}"
exit 0
