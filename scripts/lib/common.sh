#!/usr/bin/env bash
# scripts/lib/common.sh — shared colour variables and output helpers.
#
# Source from scripts/*.sh:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   # shellcheck source=scripts/lib/common.sh
#   source "${SCRIPT_DIR}/lib/common.sh"
#
# Source from repo-root scripts (e.g. init.sh):
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   # shellcheck source=scripts/lib/common.sh
#   source "${SCRIPT_DIR}/scripts/lib/common.sh"
#
# Provides: RED GREEN YELLOW CYAN BOLD RESET (colour vars)
#           section()  ok()  warn()
# Callers define their own info()/fail()/err() with context-specific tags.

# ── Colour variables ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Output helpers ────────────────────────────────────────────────────────────

# section <title> — bold horizontal-rule section header.
section() { echo -e "\n${BOLD}── $* ──────────────────────────────────────────${RESET}"; }

# ok <msg> — green success line.
ok()   { echo -e "${GREEN}[ok]${RESET}  $*"; }

# warn <msg> — yellow advisory line.
warn() { echo -e "${YELLOW}[warn]${RESET} $*"; }
