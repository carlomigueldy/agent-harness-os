#!/usr/bin/env bash
# scripts/worktree.sh — safe git worktree helper for the Agent Harness OS
#
# Subcommands:
#   create <branch> [--sibling|--in-repo] [--base <ref>]
#   list
#   remove <branch> [--force]
#   prune
#
# Branch prefixes required: feat/ fix/ docs/ chore/ refactor/ test/ harness/ epic/
#
# Environment-file copy rules mirror .agents/context/environment.md:
#   - Verify gitignored before copying (abort the individual file if not)
#   - Never print values; never stage; skip if already present in destination
#   - Copy, never symlink; skip silently if absent in source

set -euo pipefail

# ── Shared helpers (colour vars: RED GREEN YELLOW CYAN BOLD RESET) ────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# ── Helpers ──────────────────────────────────────────────────────────────────

usage() {
  cat >&2 <<'USAGE'
Usage: bash scripts/worktree.sh <subcommand> [options]

Subcommands:
  create <branch> [--sibling|--in-repo] [--base <ref>]
      Create a new git worktree.
      --sibling   (default) Place at ../<repo>-worktrees/<branch>
      --in-repo             Place at ./worktrees/<branch>; path is added to
                            .git/info/exclude if not already gitignored
      --base <ref>          Create branch from <ref> (default: HEAD)

  list
      List all current git worktrees.

  remove <branch> [--force]
      Remove the worktree for <branch>. Aborts if uncommitted changes or
      unmerged commits are detected unless --force is given.

  prune
      Run git worktree prune (removes stale metadata for deleted worktrees).

  sync-exclude
      Scan all current worktrees and add every IN-REPO one (any name, even a
      hand-made `git worktree add ./claire`) to .git/info/exclude so it can
      never be staged or committed. Run after creating worktrees by hand.

Branch name must begin with one of:
  feat/  fix/  docs/  chore/  refactor/  test/  harness/  epic/

Examples:
  bash scripts/worktree.sh create feat/my-feature
  bash scripts/worktree.sh create harness/portability --in-repo --base main
  bash scripts/worktree.sh list
  bash scripts/worktree.sh remove feat/my-feature
  bash scripts/worktree.sh remove feat/old-wip --force
  bash scripts/worktree.sh prune
USAGE
}

die()  { echo -e "${RED}ERROR:${RESET} $*" >&2; exit 1; }
warn() { echo -e "${YELLOW}WARN:${RESET}  $*" >&2; }
info() { echo -e "${CYAN}INFO:${RESET}  $*"; }

validate_branch() {
  local branch="$1"
  case "$branch" in
    feat/*|fix/*|docs/*|chore/*|refactor/*|test/*|harness/*|epic/*)
      return 0 ;;
    *)
      die "Branch '$branch' does not use a valid prefix. Allowed: feat/ fix/ docs/ chore/ refactor/ test/ harness/ epic/" ;;
  esac
}

repo_root() { git rev-parse --show-toplevel; }
repo_name() { basename "$(repo_root)"; }

# ── Safe env-file copy ───────────────────────────────────────────────────────
#
# Copies known env files from $src worktree to $dst worktree.
# Rules: gitignore-verified first; no value printing; no staging; no overwrite.

# Internal helper — called from copy_env_files; relies on dynamic scoping for
# the variables src, dst, copied, skipped declared in copy_env_files.
_try_copy() {
  local f_rel="$1"
  local f_src="${src}/${f_rel}"
  local f_dst="${dst}/${f_rel}"

  [ -f "$f_src" ] || return 0   # absent in source — skip silently

  if [ -f "$f_dst" ]; then
    info "  skip ${f_rel} — already present in destination"
    skipped=$((skipped + 1))
    return 0
  fi

  # Verify the file would be gitignored in the destination worktree.
  # git check-ignore exits 0 if ignored, 1 if not ignored.
  # The 'if' construct prevents set -e from triggering on exit code 1.
  if git -C "$dst" check-ignore -q "$f_rel" 2>/dev/null; then
    mkdir -p "$(dirname "$f_dst")"
    cp "$f_src" "$f_dst"
    info "  copied ${f_rel} (gitignored — will not be staged)"
    copied=$((copied + 1))
  else
    warn "  skip ${f_rel} — NOT gitignored in $dst; fix .gitignore before copying"
    skipped=$((skipped + 1))
  fi
}

copy_env_files() {
  local src="$1" dst="$2"
  local copied=0 skipped=0
  local rel prefix found_file found_rel

  # Root-level standard env files
  for rel in .env .env.local .env.development .env.test .env.production.local; do
    _try_copy "$rel"
  done

  # Monorepo-style: apps/*/.env  packages/*/.env
  for prefix in apps packages; do
    if [ -d "${src}/${prefix}" ]; then
      while IFS= read -r -d '' found_file; do
        found_rel="${found_file#${src}/}"
        _try_copy "$found_rel"
      done < <(find "${src}/${prefix}" -name ".env" -not -path "*/.git/*" -print0 2>/dev/null || true)
    fi
  done

  if [ "$copied" -eq 0 ] && [ "$skipped" -eq 0 ]; then
    info "  no env files found in source — continuing without them"
  else
    info "  env copy complete: $copied copied, $skipped skipped"
  fi

  # Safety check: confirm nothing env-related ended up staged.
  local staged_env
  staged_env=$(git -C "$dst" diff --cached --name-only 2>/dev/null | grep -E '(^|/)\.env' || true)
  if [ -n "$staged_env" ]; then
    warn "env file(s) appear staged in $dst:"
    echo "$staged_env" | head -10 >&2
    die "SAFETY ABORT — un-stage all env files before proceeding"
  fi
}

# ── Ensure in-repo worktree path is excluded from git ────────────────────────
#
# If the given path is inside the repo and not already gitignored, appends it
# to .git/info/exclude (local, per-clone, never committed or staged).

ensure_git_excluded() {
  local worktree_path="$1"
  local root
  root=$(repo_root)
  local rel_path="${worktree_path#${root}/}"
  local exclude_file="${root}/.git/info/exclude"

  # If .gitignore already covers this path, nothing to do.
  if git -C "$root" check-ignore -q "$rel_path" 2>/dev/null; then
    info "  $rel_path already covered by .gitignore"
    return 0
  fi

  # If exclude already has this entry, nothing to do.
  if [ -f "$exclude_file" ] && grep -qF "${rel_path}/" "$exclude_file" 2>/dev/null; then
    info "  $rel_path/ already in .git/info/exclude"
    return 0
  fi

  # Append to .git/info/exclude — local file, never committed.
  mkdir -p "$(dirname "$exclude_file")"
  printf '\n# in-repo worktree — added by scripts/worktree.sh\n%s/\n' "$rel_path" >> "$exclude_file"
  info "  added ${rel_path}/ to .git/info/exclude (local, not committed)"
}

# ── Subcommand: create ───────────────────────────────────────────────────────

cmd_create() {
  local branch="" mode="sibling" base="HEAD"

  while [ $# -gt 0 ]; do
    case "$1" in
      --sibling)  mode="sibling"; shift ;;
      --in-repo)  mode="in-repo"; shift ;;
      --base)
        shift
        [ $# -gt 0 ] || die "--base requires a <ref> argument"
        base="$1"; shift ;;
      -*)         die "Unknown option: $1" ;;
      *)
        [ -z "$branch" ] || die "Unexpected argument: $1"
        branch="$1"; shift ;;
    esac
  done

  [ -n "$branch" ] || { usage; exit 1; }
  validate_branch "$branch"

  local root; root=$(repo_root)
  local repo;  repo=$(repo_name)

  local worktree_path
  if [ "$mode" = "sibling" ]; then
    worktree_path="${root}/../${repo}-worktrees/${branch}"
  else
    worktree_path="${root}/worktrees/${branch}"
  fi

  info "Creating worktree: branch='$branch', mode='$mode', base='$base'"
  info "  path: $worktree_path"

  mkdir -p "$(dirname "$worktree_path")"

  # Create the worktree. Branch from $base if the branch does not yet exist.
  if git show-ref --verify --quiet "refs/heads/${branch}" 2>/dev/null; then
    git worktree add "$worktree_path" "$branch"
  else
    git worktree add -b "$branch" "$worktree_path" "$base"
  fi

  info "Worktree created at $worktree_path"

  # For in-repo worktrees, ensure the path is excluded from git tracking.
  if [ "$mode" = "in-repo" ]; then
    info "Ensuring exclusion from git tracking..."
    ensure_git_excluded "$worktree_path"
  fi

  # Copy env files safely from the main worktree.
  info "Copying env files..."
  copy_env_files "$root" "$worktree_path"

  echo ""
  info "Done. Next steps:"
  info "  cd $worktree_path"
  info "  git status   # confirm clean"
  info "  # install dependencies and run verification before writing code"
}

# ── Subcommand: list ─────────────────────────────────────────────────────────

cmd_list() {
  git worktree list
}

# ── Subcommand: remove ───────────────────────────────────────────────────────

cmd_remove() {
  local branch="" force=0

  while [ $# -gt 0 ]; do
    case "$1" in
      --force)  force=1; shift ;;
      -*)       die "Unknown option: $1" ;;
      *)
        [ -z "$branch" ] || die "Unexpected argument: $1"
        branch="$1"; shift ;;
    esac
  done

  [ -n "$branch" ] || { usage; exit 1; }

  # Resolve worktree path from git's own list (handles slashes in branch names).
  local worktree_path
  worktree_path=$(git worktree list | awk -v b="[$branch]" '$NF == b { print $1 }')
  [ -n "$worktree_path" ] || die "No worktree found for branch '$branch'. Run 'bash scripts/worktree.sh list' to see current worktrees."

  # Guard: never allow removing the main worktree.
  local main_wt
  main_wt=$(git worktree list | head -1 | awk '{print $1}')
  [ "$worktree_path" != "$main_wt" ] || die "Cannot remove the main worktree."

  if [ "$force" -eq 0 ]; then
    # Refuse if uncommitted changes exist.
    local dirty
    dirty=$(git -C "$worktree_path" status --porcelain 2>/dev/null || true)
    if [ -n "$dirty" ]; then
      warn "Uncommitted changes in $worktree_path:"
      echo "$dirty" | head -10 >&2
      die "Refusing to remove worktree with uncommitted changes. Use --force to override."
    fi

    # Refuse if the branch has commits not yet reachable from HEAD.
    if ! git merge-base --is-ancestor "$branch" HEAD 2>/dev/null; then
      die "Branch '$branch' has commits not yet merged into HEAD. Use --force to remove anyway."
    fi
  fi

  info "Removing worktree at $worktree_path"
  if [ "$force" -eq 1 ]; then
    git worktree remove --force "$worktree_path"
  else
    git worktree remove "$worktree_path"
  fi
  info "Worktree removed."
  info "If the branch is fully merged, run: git branch -d $branch"
}

# ── Subcommand: prune ────────────────────────────────────────────────────────

cmd_prune() {
  git worktree prune
  info "Stale worktree metadata pruned."
}

# ── Subcommand: sync-exclude ─────────────────────────────────────────────────
#
# Catch-all for worktrees created OUTSIDE this helper (e.g. a manual
# `git worktree add ./claire`). Adds every in-repo worktree path to
# .git/info/exclude so arbitrary names can never be staged or committed.

cmd_sync_exclude() {
  local root main_wt count=0 path
  root=$(repo_root)
  main_wt=$(git worktree list | head -1 | awk '{print $1}')
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    [ "$path" = "$main_wt" ] && continue          # never exclude the main worktree
    case "$path" in
      "$root"/*) ensure_git_excluded "$path"; count=$((count + 1)) ;;
    esac
  done < <(git worktree list | awk '{print $1}')
  if [ "$count" -eq 0 ]; then
    info "No in-repo worktrees found — nothing to exclude."
  else
    info "Synced $count in-repo worktree(s) into .git/info/exclude."
  fi
}

# ── Entry point ──────────────────────────────────────────────────────────────

if [ $# -eq 0 ]; then
  usage
  exit 0
fi

subcmd="$1"; shift

case "$subcmd" in
  create)         cmd_create "$@" ;;
  list)           cmd_list ;;
  remove)         cmd_remove "$@" ;;
  prune)          cmd_prune ;;
  sync-exclude)   cmd_sync_exclude ;;
  help|--help|-h) usage; exit 0 ;;
  *)
    echo "Unknown subcommand: $subcmd" >&2
    echo "" >&2
    usage
    exit 1 ;;
esac

# _Part of the {{PROJECT_NAME}} Agent Harness OS — see the harness index
# (../.agents/README.md) and AGENTS.md (../AGENTS.md)._
