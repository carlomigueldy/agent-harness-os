#!/usr/bin/env bash
# test-verify-harness.sh — hermetic regression test for verify-harness.sh.
#
# Formally closes bug #5 ("content scans false-positive on node_modules/build
# output") WITHOUT depending on the nondeterministic repo-wide filesystem walk.
# It drives verify-harness.sh in --scans-only mode against throwaway fixture
# roots via HARNESS_VERIFY_ROOT, so the result is deterministic regardless of
# which worktrees happen to exist locally.
#
# Fixtures:
#   A — poison files seeded under EVERY excluded dir; the scans MUST stay silent
#       (proves the exclusions hold → bug #5 closed).
#   B — a real broken link at the fixture root; the scans MUST flag it with a
#       line number (negative control: scanning is not merely disabled, and the
#       new "path:line -> target" format is emitted).
# Plus a --json smoke test asserting the machine-readable output parses.
#
# Usage:  bash scripts/test-verify-harness.sh   (exit 0 = all assertions pass)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY="$SCRIPT_DIR/verify-harness.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

[[ -f "$VERIFY" ]] || { echo "FATAL: verify-harness.sh not found at $VERIFY" >&2; exit 1; }

# Source verify-harness.sh to obtain EXCLUDE_DIRS (single source of truth).
# The BASH_SOURCE guard in verify-harness.sh makes it return early when sourced,
# so no checks run and no working-directory side-effects occur.
# shellcheck source=scripts/verify-harness.sh
source "$VERIFY"

FAILS=0
ok()   { echo "PASS: $*"; }
bad()  { echo "FAIL: $*" >&2; FAILS=$((FAILS+1)); }

TMP_A="$(mktemp -d)"
TMP_B="$(mktemp -d)"
trap 'rm -rf "$TMP_A" "$TMP_B"' EXIT

# Secret- and attribution-shaped strings, assembled at runtime by concatenation
# so this test's own source contains no contiguous secret/attribution pattern.
tok="ghp_""$(printf 'A%.0s' {1..36})"      # -> ghp_AAAA...  (matches gh[pousr]_[A-Za-z0-9]{30,})
attr="Co-authored""-by: Claude <noreply>"  # -> Co-authored-by: Claude <noreply>

# Seed one poison file: a broken link, a secret token, and an attribution line.
write_poison() {
  local f="$1"
  mkdir -p "$(dirname "$f")"
  {
    printf '# poison fixture\n'
    printf '[x](./does-not-exist.md)\n'
    printf '%s\n' "$tok"
    printf '%s\n' "$attr"
  } > "$f"
}

# ── FIXTURE A: exclusions hold across every excluded dir ──────────────────────
# Seed one poison file per entry in EXCLUDE_DIRS (sourced from verify-harness.sh
# above) so the test is automatically in sync when the list grows.
for _excl in "${EXCLUDE_DIRS[@]}"; do
  [[ "$_excl" == ".git" ]] && continue  # .git is skipped by all tools; skip here too
  write_poison "${TMP_A}/${_excl}/poison.md"
done

out_a="$(HARNESS_VERIFY_ROOT="$TMP_A" bash "$VERIFY" --scans-only 2>&1)"; rc_a=$?

if [[ "$rc_a" -eq 0 ]]; then ok "fixture A scans exit 0 (exclusions hold)"
else bad "fixture A expected exit 0 but got $rc_a"; printf '%s\n' "$out_a" >&2; fi

# A failing scan prints the '✗' glyph and a bracketed category tag ([link],
# [attribution], [secret]); neither ever appears on a pass line or header.
if printf '%s' "$out_a" | grep -qE '✗|\[(link|attribution|secret)\]'; then
  bad "fixture A produced a scan hit inside an excluded dir (bug #5 regression)"
  printf '%s\n' "$out_a" >&2
else
  ok "fixture A produced zero broken-link/secret/attribution hits"
fi

# ── FIXTURE B: real broken link at the root is still caught, with a line no. ──
printf '# real doc\n[y](./missing.md)\n' > "$TMP_B/real.md"

out_b="$(HARNESS_VERIFY_ROOT="$TMP_B" bash "$VERIFY" --scans-only 2>&1)"; rc_b=$?

if [[ "$rc_b" -ne 0 ]]; then ok "fixture B scans exit non-zero (real issue detected)"
else bad "fixture B expected non-zero exit but got 0 (scanning appears disabled)"; printf '%s\n' "$out_b" >&2; fi

if printf '%s' "$out_b" | grep -qE 'real\.md:[0-9]+'; then
  ok "fixture B reports real.md with a line number (path:line format)"
else
  bad "fixture B did not report 'real.md:<line>' (line-number format missing)"
  printf '%s\n' "$out_b" >&2
fi

# ── --json smoke: machine-readable output parses ──────────────────────────────
json_out="$(cd "$REPO_ROOT" && bash "$VERIFY" --json 2>/dev/null)"
if printf '%s' "$json_out" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert "checks" in d and isinstance(d["passed"],int)' 2>/dev/null; then
  ok "--json output is valid JSON with a checks array and integer passed count"
else
  bad "--json output did not parse as the expected JSON shape"
  printf '%s\n' "$json_out" >&2
fi

# ── Verdict ───────────────────────────────────────────────────────────────────
if [[ "$FAILS" -eq 0 ]]; then
  echo "ALL PASS: verify-harness.sh exclusions + scan behavior verified (bug #5 closed)."
  exit 0
fi
echo "FAILED: $FAILS assertion(s) did not hold." >&2
exit 1
