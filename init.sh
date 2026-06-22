#!/usr/bin/env bash
# init.sh — Session bootstrapper for {{PROJECT_NAME}}
# Non-destructive. Safe to run at any time.
# Run with INSTALL=1 to install dependencies.
# Run with VERIFY=1 to run baseline lint/typecheck/tests.
#
# Usage:
#   bash init.sh
#   INSTALL=1 bash init.sh
#   VERIFY=1 bash init.sh
#   INSTALL=1 VERIFY=1 bash init.sh

set -euo pipefail

# ── Shared helpers ────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "${SCRIPT_DIR}/scripts/lib/common.sh"
# shellcheck source=scripts/lib/stack-detection.sh
source "${SCRIPT_DIR}/scripts/lib/stack-detection.sh"

info() { echo -e "${CYAN}[init]${RESET} $*"; }
fail() { echo -e "${RED}[fail]${RESET} $*" >&2; }

# ── 1. Confirm we are at a git repo root ──────────────────────────────────────
section "Repo root check"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  fail "Not inside a git repository. Run this script from the repo root."
  fail "Expected location: the directory containing AGENTS.md and init.sh"
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
CURRENT_DIR="$(pwd)"

if [[ "$CURRENT_DIR" != "$REPO_ROOT" ]]; then
  fail "Run this script from the repo root: $REPO_ROOT"
  fail "Current directory: $CURRENT_DIR"
  exit 1
fi

ok "Repo root confirmed: $REPO_ROOT"

# ── 2. Detect package manager / stack ─────────────────────────────────────────
section "Stack detection"

detect_stack   # sets _STACK_NAME, _STACK_PM, _STACK_INSTALL, _STACK_DEV,
               #      _STACK_BUILD, _STACK_LINT, _STACK_TYPECHECK, _STACK_TEST,
               #      _STACK_FORMAT  (see scripts/lib/stack-detection.sh)

echo ""
echo "  Stack:          ${_STACK_NAME:-unknown}"
echo "  Package mgr:    ${_STACK_PM:-unknown}"
echo "  Install cmd:    ${_STACK_INSTALL:-(not detected)}"
echo "  Dev cmd:        ${_STACK_DEV:-(not detected)}"
echo "  Build cmd:      ${_STACK_BUILD:-(not detected)}"
echo "  Lint cmd:       ${_STACK_LINT:-(not detected)}"
echo "  Typecheck cmd:  ${_STACK_TYPECHECK:-(not detected)}"
echo "  Test cmd:       ${_STACK_TEST:-(not detected)}"
echo "  Format cmd:     ${_STACK_FORMAT:-(not detected)}"

# ── 3. Git branch and worktrees ────────────────────────────────────────────────
section "Git state"

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'detached HEAD')"
ok "Current branch: $CURRENT_BRANCH"

echo ""
info "Active git worktrees:"
git worktree list 2>/dev/null || warn "Could not list worktrees"

# ── 4. Env file status (no values printed) ────────────────────────────────────
section "Env file status"

ENV_FILES=(
  ".env"
  ".env.local"
  ".env.development"
  ".env.development.local"
  ".env.test"
  ".env.test.local"
  ".env.production.local"
)

FOUND_ENV=0
for f in "${ENV_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    ok "Found: $f (contents not printed)"
    FOUND_ENV=1
  fi
done

# Also scan apps/* and packages/* one level deep
for pattern in "apps/*/.env" "packages/*/.env" "apps/*/.env.local" "packages/*/.env.local"; do
  for f in $pattern; do
    if [[ -f "$f" ]]; then
      ok "Found: $f (contents not printed)"
      FOUND_ENV=1
    fi
  done
done

if [[ $FOUND_ENV -eq 0 ]]; then
  warn "No .env files found. Check .agents/context/environment.md for setup instructions."
fi

# Check for staged env files (safety guard)
STAGED_ENV="$(git diff --cached --name-only 2>/dev/null | grep -E '\.env' || true)"
if [[ -n "$STAGED_ENV" ]]; then
  fail "DANGER: The following env files are staged — unstage them immediately:"
  echo "$STAGED_ENV"
  exit 1
fi

# ── 5. Dependency installation (opt-in) ───────────────────────────────────────
section "Dependency installation"

if [[ "${INSTALL:-0}" == "1" ]]; then
  if [[ -n "$_STACK_INSTALL" && "$_STACK_INSTALL" != \#* ]]; then
    info "Running: $_STACK_INSTALL"
    eval "$_STACK_INSTALL"
    ok "Dependencies installed."
  else
    warn "No install command detected or command is manual. Skipping."
  fi
else
  info "Skipped (set INSTALL=1 to install dependencies)"
fi

# ── 6. Baseline verification (opt-in) ────────────────────────────────────────
section "Baseline verification"

VERIFY_FAILED=0

if [[ "${VERIFY:-0}" == "1" ]]; then
  _run_check() {
    local label="$1"
    local cmd="$2"
    if [[ -z "$cmd" || "$cmd" == *"{{"* || "$cmd" == \#* ]]; then
      warn "$label: command not set, skipping (configure in .agents/context/commands.md)"
      return
    fi
    info "Running $label: $cmd"
    if eval "$cmd"; then
      ok "$label passed"
    else
      fail "$label FAILED"
      VERIFY_FAILED=1
    fi
  }

  _run_check "Lint"       "$_STACK_LINT"
  _run_check "Typecheck"  "$_STACK_TYPECHECK"
  _run_check "Tests"      "$_STACK_TEST"
  _run_check "Build"      "$_STACK_BUILD"

  echo ""
  if [[ $VERIFY_FAILED -eq 1 ]]; then
    fail "One or more verification checks failed. See output above."
    fail "Record failures in .agents/logs/failures.md before proceeding."
    exit 1
  else
    ok "All detected verification checks passed."
  fi
else
  info "Skipped (set VERIFY=1 to run lint/typecheck/tests/build)"
fi

# ── 7. Summary ────────────────────────────────────────────────────────────────
section "Ready"

echo ""
echo "  Dev/start:  ${_STACK_DEV:-(not detected — see .agents/context/commands.md)}"
echo ""
info "Next steps:"
echo "  0. First time? Provision: bash scripts/provision.sh --help  (fills {{placeholders}})"
echo "  1. Read AGENTS.md and CLAUDE.md"
echo "  2. Read claude-progress.md for current state"
echo "  3. Read session-handoff.md for the last handover"
echo "  4. Check feature_list.json for the next task"
echo "  5. Create or select a worktree before implementing"
echo ""
ok "init.sh complete."
