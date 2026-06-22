#!/usr/bin/env bash
# scripts/provision.sh — One-shot harness provisioning CLI.
#
# Fills {{PLACEHOLDER}} tokens across tracked files, auto-detects the stack,
# and validates the result with scripts/verify-harness.sh.
#
# Input modes (priority: flags > config file > auto-detect > interactive):
#   (a) --config <file>    KEY=VALUE file, safely parsed — no eval/source
#   (b) Individual flags   --name, --type, --language, etc.
#   (c) Interactive prompts (only in a real TTY; disabled by --non-interactive)
#
# See .agents/workflows/adoption.md for the full adoption workflow.
# Quick preview (safe on the template itself — writes nothing):
#   bash scripts/provision.sh --dry-run

set -euo pipefail

# ── Shared helpers ────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck source=scripts/lib/stack-detection.sh
source "${SCRIPT_DIR}/lib/stack-detection.sh"

info() { echo -e "${CYAN}[provision]${RESET} $*"; }
err()  { echo -e "${RED}[error]${RESET}  $*" >&2; }

# ── Usage ─────────────────────────────────────────────────────────────────────
usage() {
  cat <<'EOF'
USAGE
  bash scripts/provision.sh [options]

OPTIONS
  --config <file>         Load KEY=VALUE config (see harness.config.example)
  --name <value>          PROJECT_NAME
  --type <value>          PROJECT_TYPE  (e.g. "web app", "CLI", "API")
  --language <value>      PRIMARY_LANGUAGE
  --package-manager <v>   PACKAGE_MANAGER
  --default-branch <v>    DEFAULT_BRANCH (default: main)
  --deployment <value>    DEPLOYMENT_TARGET
  --repo <value>          REPO_NAME
  --owner <value>         GITHUB_OWNER
  --install-cmd <cmd>     INSTALL_CMD   (auto-detected when omitted)
  --dev-cmd <cmd>         DEV_CMD
  --build-cmd <cmd>       BUILD_CMD
  --lint-cmd <cmd>        LINT_CMD
  --typecheck-cmd <cmd>   TYPECHECK_CMD
  --test-cmd <cmd>        TEST_CMD
  --e2e-cmd <cmd>         E2E_CMD
  --format-cmd <cmd>      FORMAT_CMD
  --runtime <mode>        Adapter: claude|codex|both|generic  (default: claude)
  --dry-run               Preview only — write nothing (safe on the template)
  --force                 Re-provision even when no placeholders remain
  --non-interactive       Fail instead of prompting for missing required values
  -h, --help              Show this help

EXAMPLES
  # Token analysis — what files have placeholders (no values required)
  bash scripts/provision.sh --dry-run

  # Preview what specific values WOULD replace
  bash scripts/provision.sh --dry-run --name "Acme API" --owner acme --repo acme-api

  # Non-interactive (token-free agent path)
  bash scripts/provision.sh --non-interactive \
    --name "Acme API" --type "API" --language Go \
    --owner acme --repo acme-api --default-branch main

  # Config file (copy, edit, run)
  cp harness.config.example harness.config
  # edit harness.config
  bash scripts/provision.sh --config harness.config
EOF
}

# ── Defaults ──────────────────────────────────────────────────────────────────
DRY_RUN=false
FORCE=false
NON_INTERACTIVE=false
CONFIG_FILE=""
OPT_RUNTIME="claude"
OPT_NAME="" OPT_TYPE="" OPT_LANGUAGE="" OPT_PM="" OPT_BRANCH="" OPT_DEPLOY=""
OPT_REPO="" OPT_OWNER=""
OPT_INSTALL_CMD="" OPT_DEV_CMD="" OPT_BUILD_CMD="" OPT_LINT_CMD=""
OPT_TYPECHECK_CMD="" OPT_TEST_CMD="" OPT_E2E_CMD="" OPT_FORMAT_CMD=""

# ── Flag parsing ──────────────────────────────────────────────────────────────
# Pattern: one inner shift for two-arg flags, outer shift handles the flag name.
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)               usage; exit 0 ;;
    --dry-run)               DRY_RUN=true ;;
    --force)                 FORCE=true ;;
    --non-interactive|--yes) NON_INTERACTIVE=true ;;
    --config)
      val="${2:-}"; [[ -z "$val" ]] && { err "--config requires a file path"; exit 1; }
      CONFIG_FILE="$val"; shift ;;
    --name)
      val="${2:-}"; [[ -z "$val" ]] && { err "--name requires a value"; exit 1; }
      OPT_NAME="$val"; shift ;;
    --type)
      val="${2:-}"; [[ -z "$val" ]] && { err "--type requires a value"; exit 1; }
      OPT_TYPE="$val"; shift ;;
    --language)
      val="${2:-}"; [[ -z "$val" ]] && { err "--language requires a value"; exit 1; }
      OPT_LANGUAGE="$val"; shift ;;
    --package-manager)
      val="${2:-}"; [[ -z "$val" ]] && { err "--package-manager requires a value"; exit 1; }
      OPT_PM="$val"; shift ;;
    --default-branch)
      val="${2:-}"; [[ -z "$val" ]] && { err "--default-branch requires a value"; exit 1; }
      OPT_BRANCH="$val"; shift ;;
    --deployment)
      val="${2:-}"; [[ -z "$val" ]] && { err "--deployment requires a value"; exit 1; }
      OPT_DEPLOY="$val"; shift ;;
    --repo)
      val="${2:-}"; [[ -z "$val" ]] && { err "--repo requires a value"; exit 1; }
      OPT_REPO="$val"; shift ;;
    --owner)
      val="${2:-}"; [[ -z "$val" ]] && { err "--owner requires a value"; exit 1; }
      OPT_OWNER="$val"; shift ;;
    --install-cmd)
      val="${2:-}"; [[ -z "$val" ]] && { err "--install-cmd requires a value"; exit 1; }
      OPT_INSTALL_CMD="$val"; shift ;;
    --dev-cmd)
      val="${2:-}"; [[ -z "$val" ]] && { err "--dev-cmd requires a value"; exit 1; }
      OPT_DEV_CMD="$val"; shift ;;
    --build-cmd)
      val="${2:-}"; [[ -z "$val" ]] && { err "--build-cmd requires a value"; exit 1; }
      OPT_BUILD_CMD="$val"; shift ;;
    --lint-cmd)
      val="${2:-}"; [[ -z "$val" ]] && { err "--lint-cmd requires a value"; exit 1; }
      OPT_LINT_CMD="$val"; shift ;;
    --typecheck-cmd)
      val="${2:-}"; [[ -z "$val" ]] && { err "--typecheck-cmd requires a value"; exit 1; }
      OPT_TYPECHECK_CMD="$val"; shift ;;
    --test-cmd)
      val="${2:-}"; [[ -z "$val" ]] && { err "--test-cmd requires a value"; exit 1; }
      OPT_TEST_CMD="$val"; shift ;;
    --e2e-cmd)
      val="${2:-}"; [[ -z "$val" ]] && { err "--e2e-cmd requires a value"; exit 1; }
      OPT_E2E_CMD="$val"; shift ;;
    --format-cmd)
      val="${2:-}"; [[ -z "$val" ]] && { err "--format-cmd requires a value"; exit 1; }
      OPT_FORMAT_CMD="$val"; shift ;;
    --runtime)
      val="${2:-}"; [[ -z "$val" ]] && { err "--runtime requires a value"; exit 1; }
      OPT_RUNTIME="$val"; shift ;;
    *) err "Unknown flag: $1"; echo "" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

# ── Validate --runtime ────────────────────────────────────────────────────────
case "$OPT_RUNTIME" in
  claude|codex|both|generic) ;;
  *) err "--runtime must be one of: claude | codex | both | generic"; exit 1 ;;
esac

# ── Require git repo root ─────────────────────────────────────────────────────
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  err "Not inside a git repository. Run this script from the repo root."
  exit 1
fi
REPO_ROOT="$(git rev-parse --show-toplevel)"
if [[ "$(pwd)" != "$REPO_ROOT" ]]; then
  err "Run this script from the repo root: $REPO_ROOT"
  exit 1
fi

# ── Load config file (safe parse, no eval/source) ────────────────────────────
# Config values fill gaps left by flags (flags have higher priority).
if [[ -n "$CONFIG_FILE" ]]; then
  [[ -f "$CONFIG_FILE" ]] || { err "Config file not found: $CONFIG_FILE"; exit 1; }
  info "Loading config: $CONFIG_FILE"
  while IFS= read -r _line || [[ -n "$_line" ]]; do
    # Trim leading whitespace
    _line="${_line#"${_line%%[! $'\t']*}"}"
    # Skip comments and empty lines
    [[ "${_line:0:1}" == "#" || -z "$_line" ]] && continue
    # Skip lines without =
    [[ "$_line" != *=* ]] && continue
    _key="${_line%%=*}"; _val="${_line#*=}"
    # Trim whitespace from key
    _key="${_key%"${_key##*[! $'\t']}"}"; _key="${_key#"${_key%%[! $'\t']*}"}"
    # Strip surrounding quotes from value
    if [[ "${_val:0:1}" == '"' && "${_val: -1}" == '"' ]]; then
      _val="${_val:1:${#_val}-2}"
    elif [[ "${_val:0:1}" == "'" && "${_val: -1}" == "'" ]]; then
      _val="${_val:1:${#_val}-2}"
    fi
    # Safe assignment: config fills only what flags left empty
    case "$_key" in
      PROJECT_NAME)      [[ -z "$OPT_NAME"          ]] && OPT_NAME="$_val" ;;
      PROJECT_TYPE)      [[ -z "$OPT_TYPE"          ]] && OPT_TYPE="$_val" ;;
      PRIMARY_LANGUAGE)  [[ -z "$OPT_LANGUAGE"      ]] && OPT_LANGUAGE="$_val" ;;
      PACKAGE_MANAGER)   [[ -z "$OPT_PM"            ]] && OPT_PM="$_val" ;;
      DEFAULT_BRANCH)    [[ -z "$OPT_BRANCH"        ]] && OPT_BRANCH="$_val" ;;
      DEPLOYMENT_TARGET) [[ -z "$OPT_DEPLOY"        ]] && OPT_DEPLOY="$_val" ;;
      REPO_NAME)         [[ -z "$OPT_REPO"          ]] && OPT_REPO="$_val" ;;
      GITHUB_OWNER)      [[ -z "$OPT_OWNER"         ]] && OPT_OWNER="$_val" ;;
      INSTALL_CMD)       [[ -z "$OPT_INSTALL_CMD"   ]] && OPT_INSTALL_CMD="$_val" ;;
      DEV_CMD)           [[ -z "$OPT_DEV_CMD"       ]] && OPT_DEV_CMD="$_val" ;;
      BUILD_CMD)         [[ -z "$OPT_BUILD_CMD"     ]] && OPT_BUILD_CMD="$_val" ;;
      LINT_CMD)          [[ -z "$OPT_LINT_CMD"      ]] && OPT_LINT_CMD="$_val" ;;
      TYPECHECK_CMD)     [[ -z "$OPT_TYPECHECK_CMD" ]] && OPT_TYPECHECK_CMD="$_val" ;;
      TEST_CMD)          [[ -z "$OPT_TEST_CMD"      ]] && OPT_TEST_CMD="$_val" ;;
      E2E_CMD)           [[ -z "$OPT_E2E_CMD"       ]] && OPT_E2E_CMD="$_val" ;;
      FORMAT_CMD)        [[ -z "$OPT_FORMAT_CMD"    ]] && OPT_FORMAT_CMD="$_val" ;;
      RUNTIME)           [[ -z "$OPT_RUNTIME"       ]] && OPT_RUNTIME="$_val" ;;
    esac
  done < "$CONFIG_FILE"
fi

# ── Stack detection (pre-fill command defaults) ───────────────────────────────
section "Stack detection"

detect_stack   # sets _STACK_NAME, _STACK_PM, _STACK_INSTALL, _STACK_DEV,
               #      _STACK_BUILD, _STACK_LINT, _STACK_TYPECHECK, _STACK_TEST,
               #      _STACK_FORMAT  (see scripts/lib/stack-detection.sh)

# Merge detected values into OPT_* (only fill gaps not set by flags or config)
[[ -z "$OPT_LANGUAGE"      && -n "$_STACK_NAME"      ]] && OPT_LANGUAGE="$_STACK_NAME"
[[ -z "$OPT_PM"            && -n "$_STACK_PM"         ]] && OPT_PM="$_STACK_PM"
[[ -z "$OPT_INSTALL_CMD"   && -n "$_STACK_INSTALL"    ]] && OPT_INSTALL_CMD="$_STACK_INSTALL"
[[ -z "$OPT_DEV_CMD"       && -n "$_STACK_DEV"        ]] && OPT_DEV_CMD="$_STACK_DEV"
[[ -z "$OPT_BUILD_CMD"     && -n "$_STACK_BUILD"      ]] && OPT_BUILD_CMD="$_STACK_BUILD"
[[ -z "$OPT_LINT_CMD"      && -n "$_STACK_LINT"       ]] && OPT_LINT_CMD="$_STACK_LINT"
[[ -z "$OPT_TYPECHECK_CMD" && -n "$_STACK_TYPECHECK"  ]] && OPT_TYPECHECK_CMD="$_STACK_TYPECHECK"
[[ -z "$OPT_TEST_CMD"      && -n "$_STACK_TEST"       ]] && OPT_TEST_CMD="$_STACK_TEST"
[[ -z "$OPT_FORMAT_CMD"    && -n "$_STACK_FORMAT"     ]] && OPT_FORMAT_CMD="$_STACK_FORMAT"

# Fixed auto-values
[[ -z "$OPT_BRANCH" ]] && OPT_BRANCH="main"
OPT_DATE="$(date +%Y-%m-%d)"
OPT_VERSION="0.1.0"

# ── Interactive prompts ───────────────────────────────────────────────────────
# Only runs when: NOT --non-interactive, NOT --dry-run, AND stdin/stdout are TTYs.
_is_interactive() {
  [[ "$NON_INTERACTIVE" == false ]] && [[ "$DRY_RUN" == false ]] && [[ -t 0 ]] && [[ -t 1 ]]
}

_prompt() {
  local label="$1" default="${2:-}"
  if ! _is_interactive; then
    # In non-interactive or non-TTY mode: silently use the default (may be empty).
    echo "$default"
    return
  fi
  local response
  if [[ -n "$default" ]]; then
    printf "${CYAN}  %s${RESET} [%s]: " "$label" "$default" >&2
  else
    printf "${CYAN}  %s${RESET}: " "$label" >&2
  fi
  read -r response
  echo "${response:-$default}"
}

section "Value resolution"
[[ -z "$OPT_NAME"   ]] && OPT_NAME=$(_prompt   "PROJECT_NAME (e.g. Acme Web)"             "")
[[ -z "$OPT_TYPE"   ]] && OPT_TYPE=$(_prompt   "PROJECT_TYPE (web app/API/CLI/mobile)"     "web app")
[[ -z "$OPT_OWNER"  ]] && OPT_OWNER=$(_prompt  "GITHUB_OWNER (GitHub org or user)"         "")
[[ -z "$OPT_REPO"   ]] && OPT_REPO=$(_prompt   "REPO_NAME"                                 "")
[[ -z "$OPT_DEPLOY" ]] && OPT_DEPLOY=$(_prompt "DEPLOYMENT_TARGET (Vercel/Docker/—)"       "—")

# ── Validate required values (skipped in --dry-run for safe template testing) ─
section "Validation"

if [[ "$DRY_RUN" == false ]]; then
  _val_errors=0
  [[ -z "$OPT_NAME"  ]] && { err "PROJECT_NAME is required — use --name"; _val_errors=$((_val_errors+1)); }
  [[ -z "$OPT_OWNER" ]] && { err "GITHUB_OWNER is required — use --owner"; _val_errors=$((_val_errors+1)); }
  [[ -z "$OPT_REPO"  ]] && { err "REPO_NAME is required — use --repo"; _val_errors=$((_val_errors+1)); }
  if [[ "$NON_INTERACTIVE" == true && "$_val_errors" -gt 0 ]]; then
    err "--non-interactive is set; provide all required values via flags or --config."
    exit 1
  fi
  [[ "$_val_errors" -gt 0 ]] && exit 1
  ok "All required values present."
else
  info "Dry-run: skipping required-value validation."
fi

# ── Resolved value map ────────────────────────────────────────────────────────
section "Resolved values"
echo "  PROJECT_NAME       = ${OPT_NAME:-(not set)}"
echo "  PROJECT_TYPE       = ${OPT_TYPE:-web app}"
echo "  PRIMARY_LANGUAGE   = ${OPT_LANGUAGE:-unknown}"
echo "  PACKAGE_MANAGER    = ${OPT_PM:-unknown}"
echo "  DEFAULT_BRANCH     = ${OPT_BRANCH}"
echo "  DEPLOYMENT_TARGET  = ${OPT_DEPLOY:-—}"
echo "  GITHUB_OWNER       = ${OPT_OWNER:-(not set)}"
echo "  REPO_NAME          = ${OPT_REPO:-(not set)}"
echo "  INSTALL_CMD        = ${OPT_INSTALL_CMD:-(not detected)}"
echo "  DEV_CMD            = ${OPT_DEV_CMD:-(not detected)}"
echo "  BUILD_CMD          = ${OPT_BUILD_CMD:-(not detected)}"
echo "  LINT_CMD           = ${OPT_LINT_CMD:-(not detected)}"
echo "  TYPECHECK_CMD      = ${OPT_TYPECHECK_CMD:-(not detected)}"
echo "  TEST_CMD           = ${OPT_TEST_CMD:-(not detected)}"
echo "  E2E_CMD            = ${OPT_E2E_CMD:-(not set)}"
echo "  FORMAT_CMD         = ${OPT_FORMAT_CMD:-(not detected)}"
echo "  DATE               = ${OPT_DATE}"
echo "  VERSION            = ${OPT_VERSION}"
echo "  Runtime adapter    = ${OPT_RUNTIME}"

# ── File list — tracked text files, excluding protected files ─────────────────
section "File list"

# Files excluded because they legitimately contain template-shaped or regex strings:
#   scripts/verify-harness.sh — contains grep patterns matching token forms
#   scripts/provision.sh      — this script itself
#   harness.config*           — local config files (example stays as documentation)
#   .env* files               — secrets, never touched
#   .claude/worktrees/        — runtime worktree copies
#   dist/, build/, .next/     — generated output (rarely tracked, but guard anyway)
# Note: prompt.md was removed here; it no longer exists (bootstrapped from a
#       meta-prompt — see git history if context is needed).
EXCLUDE_PATTERN='(^|/)\.env($|[._])|^scripts/verify-harness\.sh$|^scripts/provision\.sh$|^harness\.config$|^\.claude/worktrees/|^dist/|^build/|^\.next/'

FILE_LIST=$(git ls-files 2>/dev/null | grep -vE "$EXCLUDE_PATTERN" || true)
FILE_COUNT=$(printf '%s\n' "$FILE_LIST" | grep -c . || true)
info "Eligible tracked files: ${FILE_COUNT}"

# ── Already-provisioned check ─────────────────────────────────────────────────
REMAINING=0
if [[ -n "$FILE_LIST" ]]; then
  REMAINING=$(printf '%s\n' "$FILE_LIST" | \
    xargs grep -l '{{PROJECT_NAME}}\|{{GITHUB_OWNER}}\|{{REPO_NAME}}' 2>/dev/null | \
    wc -l | tr -d ' ') || REMAINING=0
fi

if [[ "$REMAINING" -eq 0 && "$FORCE" == false && "$DRY_RUN" == false ]]; then
  warn "No core placeholder tokens (PROJECT_NAME / GITHUB_OWNER / REPO_NAME) found."
  warn "The harness may already be provisioned. Use --force to re-run anyway."
  exit 0
fi

if [[ "$DRY_RUN" == true && "$REMAINING" -eq 0 ]]; then
  info "No placeholder tokens found in tracked files — harness appears provisioned."
  info "Use --force with apply mode to re-provision."
fi

# ── Build replacement map ─────────────────────────────────────────────────────
REPLACE_ARGS=()
[[ -n "$OPT_NAME"    ]] && REPLACE_ARGS+=("PROJECT_NAME=${OPT_NAME}")
[[ -n "$OPT_TYPE"    ]] && REPLACE_ARGS+=("PROJECT_TYPE=${OPT_TYPE}")
[[ -n "$OPT_LANGUAGE" ]] && REPLACE_ARGS+=("PRIMARY_LANGUAGE=${OPT_LANGUAGE}")
[[ -n "$OPT_PM"      ]] && REPLACE_ARGS+=("PACKAGE_MANAGER=${OPT_PM}")
[[ -n "$OPT_BRANCH"  ]] && REPLACE_ARGS+=("DEFAULT_BRANCH=${OPT_BRANCH}")
[[ -n "$OPT_DEPLOY"  ]] && REPLACE_ARGS+=("DEPLOYMENT_TARGET=${OPT_DEPLOY}")
[[ -n "$OPT_OWNER"   ]] && REPLACE_ARGS+=("GITHUB_OWNER=${OPT_OWNER}")
[[ -n "$OPT_REPO"    ]] && REPLACE_ARGS+=("REPO_NAME=${OPT_REPO}")
REPLACE_ARGS+=("DATE=${OPT_DATE}" "VERSION=${OPT_VERSION}")
[[ -n "$OPT_INSTALL_CMD"   ]] && REPLACE_ARGS+=("INSTALL_CMD=${OPT_INSTALL_CMD}")
[[ -n "$OPT_DEV_CMD"       ]] && REPLACE_ARGS+=("DEV_CMD=${OPT_DEV_CMD}")
[[ -n "$OPT_BUILD_CMD"     ]] && REPLACE_ARGS+=("BUILD_CMD=${OPT_BUILD_CMD}")
[[ -n "$OPT_LINT_CMD"      ]] && REPLACE_ARGS+=("LINT_CMD=${OPT_LINT_CMD}")
[[ -n "$OPT_TYPECHECK_CMD" ]] && REPLACE_ARGS+=("TYPECHECK_CMD=${OPT_TYPECHECK_CMD}")
[[ -n "$OPT_TEST_CMD"      ]] && REPLACE_ARGS+=("TEST_CMD=${OPT_TEST_CMD}" "TEST_COMMAND=${OPT_TEST_CMD}")
[[ -n "$OPT_E2E_CMD"       ]] && REPLACE_ARGS+=("E2E_CMD=${OPT_E2E_CMD}")
[[ -n "$OPT_FORMAT_CMD"    ]] && REPLACE_ARGS+=("FORMAT_CMD=${OPT_FORMAT_CMD}")

# ── Write python3 replacer to a temp file ────────────────────────────────────
TMP_PY=$(mktemp "${TMPDIR:-/tmp}/provision_XXXXXXXX.py")
# shellcheck disable=SC2064
trap "rm -f '$TMP_PY'" EXIT INT TERM

cat >"$TMP_PY" <<'PYEOF'
"""Harness provisioner — replace {{PLACEHOLDER}} tokens across tracked files.

Reads file paths from stdin (one per line).
argv[1]: --dry-run | --apply
argv[2:]: KEY=value replacement pairs

Prints CHANGED/SKIP/SUMMARY lines; caller formats the report.
"""
import sys
import os


def main():
    args = sys.argv[1:]
    dry_run = len(args) > 0 and args[0] == '--dry-run'
    if args and args[0] in ('--dry-run', '--apply'):
        args = args[1:]

    replacements = {}
    for arg in args:
        if '=' in arg:
            k, v = arg.split('=', 1)
            replacements[k] = v

    changed = []
    skipped = []
    total_tokens = 0

    for raw in sys.stdin:
        path = raw.rstrip('\n')
        if not path or not os.path.isfile(path):
            continue
        try:
            with open(path, 'r', encoding='utf-8', errors='strict') as fh:
                original = fh.read()
        except (UnicodeDecodeError, OSError):
            skipped.append(path)
            continue

        updated = original
        file_tokens = 0
        for key, val in replacements.items():
            token = '{{' + key + '}}'
            n = updated.count(token)
            if n:
                updated = updated.replace(token, val)
                file_tokens += n

        if updated != original:
            if not dry_run:
                try:
                    with open(path, 'w', encoding='utf-8') as fh:
                        fh.write(updated)
                except OSError as exc:
                    sys.stderr.write('ERR {} {}\n'.format(path, exc))
                    continue
            changed.append((path, file_tokens))
            total_tokens += file_tokens

    mode = 'DRY-RUN' if dry_run else 'APPLIED'
    for fp, n in changed:
        print('{} {} {}'.format(mode, n, fp))
    for fp in skipped:
        print('SKIP {}'.format(fp))
    print('SUMMARY {} {} {}'.format(len(changed), len(skipped), total_tokens))


main()
PYEOF

# ── Run replacement (or dry-run) ──────────────────────────────────────────────
section "$( [[ "$DRY_RUN" == true ]] && echo 'Dry-run preview' || echo 'Applying replacements' )"

PY_MODE="--apply"
[[ "$DRY_RUN" == true ]] && PY_MODE="--dry-run"

PY_OUT=$(printf '%s\n' "$FILE_LIST" | python3 "$TMP_PY" "$PY_MODE" "${REPLACE_ARGS[@]+"${REPLACE_ARGS[@]}"}")

CHANGED_COUNT=$(printf '%s\n' "$PY_OUT" | grep -cE '^(DRY-RUN|APPLIED) ' || true)
SKIP_COUNT=$(printf '%s\n' "$PY_OUT" | grep -c '^SKIP ' || true)
SUMMARY_LINE=$(printf '%s\n' "$PY_OUT" | grep '^SUMMARY ' || true)
TOTAL_TOKENS=$(printf '%s\n' "$SUMMARY_LINE" | awk '{print $4}' || echo 0)

printf '%s\n' "$PY_OUT" | grep -E '^(DRY-RUN|APPLIED) ' | while IFS= read -r _line; do
  echo "  $_line"
done

echo ""
if [[ "$DRY_RUN" == true ]]; then
  info "Dry-run: ${CHANGED_COUNT} file(s) would change, ${TOTAL_TOKENS} token(s) replaced, ${SKIP_COUNT} binary/unreadable skipped."
  info "Run without --dry-run to apply."
  exit 0
fi
ok "Applied: ${CHANGED_COUNT} file(s) changed, ${TOTAL_TOKENS} token(s) replaced, ${SKIP_COUNT} binary/unreadable skipped."

# ── Run harness verification ───────────────────────────────────────────────────
section "Harness verification"

if [[ -f "scripts/verify-harness.sh" ]]; then
  info "Running: bash scripts/verify-harness.sh"
  if bash scripts/verify-harness.sh; then
    ok "Harness verification passed."
    VERIFY_STATUS="PASSED"
  else
    warn "Harness verification reported failures (see above)."
    VERIFY_STATUS="FAILED — see output above"
  fi
else
  warn "scripts/verify-harness.sh not found — skipping."
  VERIFY_STATUS="SKIPPED (script not found)"
fi

# ── Summary & next steps ──────────────────────────────────────────────────────
section "Provisioning complete"

echo ""
echo "  Project:       ${OPT_NAME}"
echo "  Repo:          ${OPT_OWNER}/${OPT_REPO}"
echo "  Runtime:       ${OPT_RUNTIME}"
echo "  Verification:  ${VERIFY_STATUS}"
echo ""
info "Next steps:"
echo "  1. Read AGENTS.md — the entry point for all agents."
echo "  2. Fill remaining <!-- FILL --> sections:"
echo "       .agents/context/commands.md     (verify / update command list)"
echo "       .agents/context/environment.md  (runtimes, env vars)"
echo "       .agents/context/project-brief.md (what / why / who)"
echo "  3. Replace example features in feature_list.json with real ones."
echo "  4. Reset claude-progress.md and session-handoff.md to project state."
echo "  5. Run: bash init.sh  (then VERIFY=1 bash init.sh) to confirm setup."
if [[ "$OPT_RUNTIME" == "codex" || "$OPT_RUNTIME" == "both" ]]; then
  echo "  6. Codex runtime: the .codex/ adapter ships with the harness — read"
  echo "       .codex/README.md and .agents/context/runtimes.md to wire it up."
fi
echo ""
ok "scripts/provision.sh done."

# _Part of the {{PROJECT_NAME}} Agent Harness OS — see the harness index
# (../.agents/README.md) and AGENTS.md (../AGENTS.md)._
