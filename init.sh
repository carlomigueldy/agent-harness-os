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

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}[init]${RESET} $*"; }
ok()      { echo -e "${GREEN}[ok]${RESET}   $*"; }
warn()    { echo -e "${YELLOW}[warn]${RESET} $*"; }
fail()    { echo -e "${RED}[fail]${RESET} $*" >&2; }
section() { echo -e "\n${BOLD}── $* ──────────────────────────────────────────${RESET}"; }

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

DETECTED_PM=""
DETECTED_STACK=""
INSTALL_CMD=""
BUILD_CMD=""
DEV_CMD=""
LINT_CMD=""
TYPECHECK_CMD=""
TEST_CMD=""
FORMAT_CMD=""

# Node.js / JS ecosystem
if [[ -f "package.json" ]]; then
  DETECTED_STACK="node"
  if [[ -f "pnpm-lock.yaml" ]]; then
    DETECTED_PM="pnpm"
    INSTALL_CMD="pnpm install"
  elif [[ -f "yarn.lock" ]]; then
    DETECTED_PM="yarn"
    INSTALL_CMD="yarn install"
  elif [[ -f "bun.lockb" ]] || [[ -f "bun.lock" ]]; then
    DETECTED_PM="bun"
    INSTALL_CMD="bun install"
  else
    DETECTED_PM="npm"
    INSTALL_CMD="npm install"
  fi

  # Detect scripts from package.json
  _scripts() { node -e "const p=require('./package.json'); console.log(Object.keys(p.scripts||{}).join(' '))" 2>/dev/null || true; }
  SCRIPTS=$(_scripts)

  [[ "$SCRIPTS" == *"build"*     ]] && BUILD_CMD="${DETECTED_PM} run build"
  [[ "$SCRIPTS" == *"dev"*       ]] && DEV_CMD="${DETECTED_PM} run dev"
  [[ "$SCRIPTS" == *"start"*     ]] && DEV_CMD="${DEV_CMD:-${DETECTED_PM} run start}"
  [[ "$SCRIPTS" == *"lint"*      ]] && LINT_CMD="${DETECTED_PM} run lint"
  [[ "$SCRIPTS" == *"typecheck"* ]] && TYPECHECK_CMD="${DETECTED_PM} run typecheck"
  [[ "$SCRIPTS" == *"type-check"* ]] && TYPECHECK_CMD="${TYPECHECK_CMD:-${DETECTED_PM} run type-check}"
  [[ "$SCRIPTS" == *"test"*      ]] && TEST_CMD="${DETECTED_PM} run test"
  [[ "$SCRIPTS" == *"format"*    ]] && FORMAT_CMD="${DETECTED_PM} run format"

  info "Stack: Node.js | Package manager: $DETECTED_PM"

# Python
elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]]; then
  DETECTED_STACK="python"
  if command -v poetry &>/dev/null && [[ -f "pyproject.toml" ]]; then
    DETECTED_PM="poetry"
    INSTALL_CMD="poetry install"
  elif command -v uv &>/dev/null; then
    DETECTED_PM="uv"
    INSTALL_CMD="uv sync"
  elif [[ -f "requirements.txt" ]]; then
    DETECTED_PM="pip"
    INSTALL_CMD="pip install -r requirements.txt"
  else
    DETECTED_PM="pip"
    INSTALL_CMD="pip install -e ."
  fi
  # Detect installed Python tooling; leave blank (not a placeholder) if absent.
  command -v ruff   &>/dev/null && LINT_CMD="ruff check ."
  [[ -z "$LINT_CMD" ]]      && command -v flake8 &>/dev/null && LINT_CMD="flake8"
  command -v mypy   &>/dev/null && TYPECHECK_CMD="mypy ."
  [[ -z "$TYPECHECK_CMD" ]] && command -v pyright &>/dev/null && TYPECHECK_CMD="pyright"
  command -v pytest &>/dev/null && TEST_CMD="pytest"
  command -v ruff   &>/dev/null && FORMAT_CMD="ruff format ."
  [[ -z "$FORMAT_CMD" ]]    && command -v black  &>/dev/null && FORMAT_CMD="black ."
  # DEV_CMD/BUILD_CMD are project-specific for Python; set them in commands.md.
  info "Stack: Python | Package manager: $DETECTED_PM"
  [[ -z "$LINT_CMD$TYPECHECK_CMD$TEST_CMD" ]] && \
    warn "Python: no lint/typecheck/test tool detected — set commands in .agents/context/commands.md"

# Rust
elif [[ -f "Cargo.toml" ]]; then
  DETECTED_STACK="rust"
  DETECTED_PM="cargo"
  INSTALL_CMD="# Rust: no separate install step — cargo handles deps on build"
  BUILD_CMD="cargo build"
  TEST_CMD="cargo test"
  LINT_CMD="cargo clippy"
  DEV_CMD="cargo run"
  info "Stack: Rust | Package manager: cargo"

# Go
elif [[ -f "go.mod" ]]; then
  DETECTED_STACK="go"
  DETECTED_PM="go"
  INSTALL_CMD="go mod download"
  BUILD_CMD="go build ./..."
  TEST_CMD="go test ./..."
  if command -v golangci-lint &>/dev/null; then LINT_CMD="golangci-lint run"; else LINT_CMD="go vet ./..."; fi
  # DEV_CMD entrypoint varies (e.g. go run ./cmd/<app>); set it in commands.md.
  info "Stack: Go | Package manager: go modules"
  warn "Go: set the dev/run command (e.g. go run ./cmd/app) in .agents/context/commands.md"

# Ruby
elif [[ -f "Gemfile" ]]; then
  DETECTED_STACK="ruby"
  DETECTED_PM="bundler"
  if command -v bundle &>/dev/null; then
    INSTALL_CMD="bundle install"
    command -v rubocop &>/dev/null && LINT_CMD="bundle exec rubocop"
    command -v rspec   &>/dev/null && TEST_CMD="bundle exec rspec"
    [[ -z "$TEST_CMD" ]] && TEST_CMD="bundle exec rake test"
  else
    warn "Ruby: bundler not found — set commands manually in .agents/context/commands.md"
    INSTALL_CMD="gem install bundler && bundle install"
  fi
  # DEV_CMD/BUILD_CMD are project-specific for Ruby; set them in commands.md.
  info "Stack: Ruby | Package manager: bundler"

# PHP
elif [[ -f "composer.json" ]]; then
  DETECTED_STACK="php"
  DETECTED_PM="composer"
  if command -v composer &>/dev/null; then
    INSTALL_CMD="composer install"
    command -v phpcs    &>/dev/null && LINT_CMD="vendor/bin/phpcs"
    command -v phpstan  &>/dev/null && TYPECHECK_CMD="vendor/bin/phpstan analyse"
    [[ -f "vendor/bin/phpunit" ]] && TEST_CMD="vendor/bin/phpunit"
    command -v php-cs-fixer &>/dev/null && FORMAT_CMD="vendor/bin/php-cs-fixer fix"
  else
    warn "PHP: composer not found — set commands manually in .agents/context/commands.md"
    INSTALL_CMD="composer install"
  fi
  info "Stack: PHP | Package manager: composer"

# Java — Maven
elif [[ -f "pom.xml" ]]; then
  DETECTED_STACK="java"
  DETECTED_PM="maven"
  if command -v mvn &>/dev/null; then
    INSTALL_CMD="mvn dependency:resolve"
    BUILD_CMD="mvn package -DskipTests"
    TEST_CMD="mvn test"
    LINT_CMD="mvn checkstyle:check"
  else
    warn "Java/Maven: mvn not found — set commands manually in .agents/context/commands.md"
    INSTALL_CMD="mvn dependency:resolve"
  fi
  info "Stack: Java | Package manager: Maven"

# Java/Kotlin — Gradle
elif [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
  DETECTED_STACK="java"
  DETECTED_PM="gradle"
  _gcmd="gradle"
  [[ -f "./gradlew" ]] && _gcmd="./gradlew"
  BUILD_CMD="${_gcmd} build -x test"
  TEST_CMD="${_gcmd} test"
  LINT_CMD="${_gcmd} check"
  info "Stack: Java/Kotlin | Package manager: Gradle"

# .NET
elif compgen -G "*.csproj" &>/dev/null || compgen -G "*.sln" &>/dev/null; then
  DETECTED_STACK="dotnet"
  DETECTED_PM="dotnet"
  if command -v dotnet &>/dev/null; then
    INSTALL_CMD="dotnet restore"
    BUILD_CMD="dotnet build"
    TEST_CMD="dotnet test"
    FORMAT_CMD="dotnet format"
  else
    warn ".NET: dotnet SDK not found — set commands manually in .agents/context/commands.md"
    INSTALL_CMD="dotnet restore"
  fi
  info "Stack: .NET | Package manager: dotnet"

# Elixir
elif [[ -f "mix.exs" ]]; then
  DETECTED_STACK="elixir"
  DETECTED_PM="mix"
  if command -v mix &>/dev/null; then
    INSTALL_CMD="mix deps.get"
    BUILD_CMD="mix compile"
    TEST_CMD="mix test"
    LINT_CMD="mix credo"
    DEV_CMD="mix phx.server"
    FORMAT_CMD="mix format"
    warn "Elixir: DEV_CMD set to 'mix phx.server' (Phoenix) — update in .agents/context/commands.md if different"
  else
    warn "Elixir: mix not found — set commands manually in .agents/context/commands.md"
    INSTALL_CMD="mix deps.get"
  fi
  info "Stack: Elixir | Package manager: mix"

else
  DETECTED_STACK="unknown"
  DETECTED_PM="unknown"
  warn "Could not detect a known stack. Manually set commands in .agents/context/commands.md"
  warn "Supported: package.json, pyproject.toml/requirements.txt, Cargo.toml, go.mod,"
  warn "           Gemfile, composer.json, pom.xml, build.gradle, *.csproj/*.sln, mix.exs"
fi

echo ""
echo "  Stack:          ${DETECTED_STACK:-unknown}"
echo "  Package mgr:    ${DETECTED_PM:-unknown}"
echo "  Install cmd:    ${INSTALL_CMD:-(not detected)}"
echo "  Dev cmd:        ${DEV_CMD:-(not detected)}"
echo "  Build cmd:      ${BUILD_CMD:-(not detected)}"
echo "  Lint cmd:       ${LINT_CMD:-(not detected)}"
echo "  Typecheck cmd:  ${TYPECHECK_CMD:-(not detected)}"
echo "  Test cmd:       ${TEST_CMD:-(not detected)}"
echo "  Format cmd:     ${FORMAT_CMD:-(not detected)}"

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
  if [[ -n "$INSTALL_CMD" && "$INSTALL_CMD" != \#* ]]; then
    info "Running: $INSTALL_CMD"
    eval "$INSTALL_CMD"
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

  _run_check "Lint"       "$LINT_CMD"
  _run_check "Typecheck"  "$TYPECHECK_CMD"
  _run_check "Tests"      "$TEST_CMD"
  _run_check "Build"      "$BUILD_CMD"

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
echo "  Dev/start:  ${DEV_CMD:-(not detected — see .agents/context/commands.md)}"
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
