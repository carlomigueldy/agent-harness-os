#!/usr/bin/env bash
# scripts/lib/stack-detection.sh — detect project stack and tooling commands.
#
# Source from scripts/*.sh:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   # shellcheck source=scripts/lib/stack-detection.sh
#   source "${SCRIPT_DIR}/lib/stack-detection.sh"
#
# Source from repo-root scripts (e.g. init.sh):
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   # shellcheck source=scripts/lib/stack-detection.sh
#   source "${SCRIPT_DIR}/scripts/lib/stack-detection.sh"
#
# Provides: detect_stack()
#   Initialises and sets these variables:
#     _STACK_NAME  _STACK_PM  _STACK_INSTALL  _STACK_DEV  _STACK_BUILD
#     _STACK_LINT  _STACK_TYPECHECK  _STACK_TEST  _STACK_FORMAT
#   Undetected values are left empty (never placeholder strings).
#   Calls info() and warn() from the sourcing script's scope so output carries
#   the caller's context tag (e.g. [init], [provision]).

detect_stack() {
  _STACK_NAME="" _STACK_PM=""
  _STACK_INSTALL="" _STACK_DEV="" _STACK_BUILD=""
  _STACK_LINT="" _STACK_TYPECHECK="" _STACK_TEST="" _STACK_FORMAT=""

  # Node.js / JS ecosystem
  if [[ -f "package.json" ]]; then
    _STACK_NAME="node"
    if [[ -f "pnpm-lock.yaml" ]]; then
      _STACK_PM="pnpm"; _STACK_INSTALL="pnpm install"
    elif [[ -f "yarn.lock" ]]; then
      _STACK_PM="yarn"; _STACK_INSTALL="yarn install"
    elif [[ -f "bun.lockb" ]] || [[ -f "bun.lock" ]]; then
      _STACK_PM="bun"; _STACK_INSTALL="bun install"
    else
      _STACK_PM="npm"; _STACK_INSTALL="npm install"
    fi
    _scr=$(node -e "const p=require('./package.json');console.log(Object.keys(p.scripts||{}).join(' '))" 2>/dev/null || true)
    [[ "$_scr" == *"build"*      ]] && _STACK_BUILD="${_STACK_PM} run build"
    [[ "$_scr" == *"dev"*        ]] && _STACK_DEV="${_STACK_PM} run dev"
    [[ "$_scr" == *"start"*      ]] && _STACK_DEV="${_STACK_DEV:-${_STACK_PM} run start}"
    [[ "$_scr" == *"lint"*       ]] && _STACK_LINT="${_STACK_PM} run lint"
    [[ "$_scr" == *"typecheck"*  ]] && _STACK_TYPECHECK="${_STACK_PM} run typecheck"
    [[ "$_scr" == *"type-check"* ]] && _STACK_TYPECHECK="${_STACK_TYPECHECK:-${_STACK_PM} run type-check}"
    [[ "$_scr" == *"test"*       ]] && _STACK_TEST="${_STACK_PM} run test"
    [[ "$_scr" == *"format"*     ]] && _STACK_FORMAT="${_STACK_PM} run format"
    info "Stack: Node.js | Package manager: ${_STACK_PM}"

  # Python
  elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]]; then
    _STACK_NAME="python"
    if command -v poetry &>/dev/null && [[ -f "pyproject.toml" ]]; then
      _STACK_PM="poetry"; _STACK_INSTALL="poetry install"
    elif command -v uv &>/dev/null; then
      _STACK_PM="uv"; _STACK_INSTALL="uv sync"
    elif [[ -f "requirements.txt" ]]; then
      _STACK_PM="pip"; _STACK_INSTALL="pip install -r requirements.txt"
    else
      _STACK_PM="pip"; _STACK_INSTALL="pip install -e ."
    fi
    command -v ruff    &>/dev/null && _STACK_LINT="ruff check ."
    [[ -z "$_STACK_LINT"      ]] && command -v flake8  &>/dev/null && _STACK_LINT="flake8"
    command -v mypy    &>/dev/null && _STACK_TYPECHECK="mypy ."
    [[ -z "$_STACK_TYPECHECK" ]] && command -v pyright &>/dev/null && _STACK_TYPECHECK="pyright"
    command -v pytest  &>/dev/null && _STACK_TEST="pytest"
    command -v ruff    &>/dev/null && _STACK_FORMAT="ruff format ."
    [[ -z "$_STACK_FORMAT"    ]] && command -v black   &>/dev/null && _STACK_FORMAT="black ."
    info "Stack: Python | Package manager: ${_STACK_PM}"
    [[ -z "${_STACK_LINT}${_STACK_TYPECHECK}${_STACK_TEST}" ]] && \
      warn "Python: no lint/typecheck/test tool detected — set commands in .agents/context/commands.md"

  # Rust
  elif [[ -f "Cargo.toml" ]]; then
    _STACK_NAME="rust"; _STACK_PM="cargo"
    _STACK_INSTALL="# Rust: no separate install step — cargo handles deps on build"
    _STACK_BUILD="cargo build"; _STACK_TEST="cargo test"
    _STACK_LINT="cargo clippy"; _STACK_DEV="cargo run"
    info "Stack: Rust | Package manager: cargo"

  # Go
  elif [[ -f "go.mod" ]]; then
    _STACK_NAME="go"; _STACK_PM="go"
    _STACK_INSTALL="go mod download"; _STACK_BUILD="go build ./..."; _STACK_TEST="go test ./..."
    if command -v golangci-lint &>/dev/null; then
      _STACK_LINT="golangci-lint run"
    else
      _STACK_LINT="go vet ./..."
    fi
    info "Stack: Go | Package manager: go modules"
    warn "Go: set the dev/run command (e.g. go run ./cmd/app) in .agents/context/commands.md"

  # Ruby
  elif [[ -f "Gemfile" ]]; then
    _STACK_NAME="ruby"; _STACK_PM="bundler"
    if command -v bundle &>/dev/null; then
      _STACK_INSTALL="bundle install"
      command -v rubocop &>/dev/null && _STACK_LINT="bundle exec rubocop"
      command -v rspec   &>/dev/null && _STACK_TEST="bundle exec rspec"
      [[ -z "$_STACK_TEST" ]] && _STACK_TEST="bundle exec rake test"
    else
      warn "Ruby: bundler not found — set commands manually in .agents/context/commands.md"
      _STACK_INSTALL="gem install bundler && bundle install"
    fi
    info "Stack: Ruby | Package manager: bundler"

  # PHP
  elif [[ -f "composer.json" ]]; then
    _STACK_NAME="php"; _STACK_PM="composer"
    if command -v composer &>/dev/null; then
      _STACK_INSTALL="composer install"
      command -v phpcs    &>/dev/null && _STACK_LINT="vendor/bin/phpcs"
      command -v phpstan  &>/dev/null && _STACK_TYPECHECK="vendor/bin/phpstan analyse"
      [[ -f "vendor/bin/phpunit" ]] && _STACK_TEST="vendor/bin/phpunit"
      command -v php-cs-fixer &>/dev/null && _STACK_FORMAT="vendor/bin/php-cs-fixer fix"
    else
      warn "PHP: composer not found — set commands manually in .agents/context/commands.md"
      _STACK_INSTALL="composer install"
    fi
    info "Stack: PHP | Package manager: composer"

  # Java — Maven
  elif [[ -f "pom.xml" ]]; then
    _STACK_NAME="java"; _STACK_PM="maven"
    if command -v mvn &>/dev/null; then
      _STACK_INSTALL="mvn dependency:resolve"
      _STACK_BUILD="mvn package -DskipTests"
      _STACK_TEST="mvn test"
      _STACK_LINT="mvn checkstyle:check"
    else
      warn "Java/Maven: mvn not found — set commands manually in .agents/context/commands.md"
      _STACK_INSTALL="mvn dependency:resolve"
    fi
    info "Stack: Java | Package manager: Maven"

  # Java/Kotlin — Gradle
  elif [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
    _STACK_NAME="java"; _STACK_PM="gradle"
    local _gcmd="gradle"
    [[ -f "./gradlew" ]] && _gcmd="./gradlew"
    _STACK_BUILD="${_gcmd} build -x test"
    _STACK_TEST="${_gcmd} test"
    _STACK_LINT="${_gcmd} check"
    info "Stack: Java/Kotlin | Package manager: Gradle"

  # .NET
  elif compgen -G "*.csproj" &>/dev/null || compgen -G "*.sln" &>/dev/null; then
    _STACK_NAME="dotnet"; _STACK_PM="dotnet"
    if command -v dotnet &>/dev/null; then
      _STACK_INSTALL="dotnet restore"; _STACK_BUILD="dotnet build"
      _STACK_TEST="dotnet test"; _STACK_FORMAT="dotnet format"
    else
      warn ".NET: dotnet SDK not found — set commands manually in .agents/context/commands.md"
      _STACK_INSTALL="dotnet restore"
    fi
    info "Stack: .NET | Package manager: dotnet"

  # Elixir
  elif [[ -f "mix.exs" ]]; then
    _STACK_NAME="elixir"; _STACK_PM="mix"
    if command -v mix &>/dev/null; then
      _STACK_INSTALL="mix deps.get"; _STACK_BUILD="mix compile"; _STACK_TEST="mix test"
      _STACK_LINT="mix credo"; _STACK_DEV="mix phx.server"; _STACK_FORMAT="mix format"
      warn "Elixir: DEV_CMD set to 'mix phx.server' (Phoenix) — update in .agents/context/commands.md if different"
    else
      warn "Elixir: mix not found — set commands manually in .agents/context/commands.md"
      _STACK_INSTALL="mix deps.get"
    fi
    info "Stack: Elixir | Package manager: mix"

  else
    _STACK_NAME="unknown"; _STACK_PM="unknown"
    warn "Could not detect a known stack."
    warn "Supported: package.json, pyproject.toml/requirements.txt, Cargo.toml, go.mod,"
    warn "           Gemfile, composer.json, pom.xml, build.gradle, *.csproj/*.sln, mix.exs"
  fi
}
