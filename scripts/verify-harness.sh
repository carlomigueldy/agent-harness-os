#!/usr/bin/env bash
# verify-harness.sh — Single source of verification truth for the Agent Harness OS.
# Non-destructive, read-only. Run locally before a PR; CI runs the same script.
#
# Checks: required structure present, entry-file length limits, feature_list.json
# valid JSON, GitHub issue-form YAML valid, relative markdown links resolve,
# no AI/LLM attribution, no secrets, shell syntax valid, slash-command schema,
# skill schema, subagent schema, and context-map presence.
#
# Usage:  bash scripts/verify-harness.sh
# Exits non-zero if any check fails.

set -uo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

PASS=0
FAILED=0
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; RESET='\033[0m'
pass() { echo -e "  ${GREEN}✓${RESET} $*"; PASS=$((PASS+1)); }
fail() { echo -e "  ${RED}✗ $*${RESET}"; FAILED=$((FAILED+1)); }
warn() { echo -e "  ${YELLOW}!${RESET} $*"; }
hdr()  { echo -e "\n${BOLD}$*${RESET}"; }

# Files that legitimately contain the prohibited/secret-shaped strings on purpose
# (the design spec, and this script's own match patterns) — excluded from scans.
# Anchored to the path field (before the first ':') so it never hides a real hit
# that merely mentions these filenames in its content.
EXCLUDE='prompt\.md|verify-harness\.sh'
exclude_by_path() { grep -vE "^[^:]*(${EXCLUDE}):"; }

# Vendored/generated directories that must never be scanned by recursive greps.
GREP_EXCLUDE_DIRS=(
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=dist
  --exclude-dir=build --exclude-dir=vendor --exclude-dir=.next
  --exclude-dir=coverage --exclude-dir=.venv --exclude-dir=venv
  --exclude-dir=__pycache__
)

# ── 1. Required structure ─────────────────────────────────────────────────────
hdr "1. Required structure"
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
hdr "2. Entry-file length limits"
check_len() { local f="$1" max="$2"; local n
  [[ -f "$f" ]] || { fail "$f missing"; return; }
  n=$(wc -l < "$f" | tr -d ' ')
  [[ -n "$n" ]] || { fail "$f unreadable"; return; }
  if [[ "$n" -le "$max" ]]; then pass "$f = $n lines (<= $max)"; else fail "$f = $n lines (> $max)"; fi; }
check_len AGENTS.md 200
check_len CLAUDE.md 250

# ── 3. feature_list.json valid JSON ───────────────────────────────────────────
hdr "3. feature_list.json"
if python3 -c "import json,sys; d=json.load(open('feature_list.json')); assert isinstance(d.get('features'),list)" 2>/dev/null; then
  pass "feature_list.json is valid JSON with a features array"
else
  fail "feature_list.json is not valid JSON (or missing 'features' array)"
fi

# ── 4. GitHub issue-form YAML valid ───────────────────────────────────────────
hdr "4. GitHub issue-form YAML"
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

# ── 5. Relative markdown links resolve ────────────────────────────────────────
hdr "5. Markdown link resolution"
LINKOUT=$(python3 - <<'PY'
import os, re
# Directories that hold vendored/generated content — never scanned.
PRUNE = {'.git', 'node_modules', 'dist', 'build', 'vendor', '.next',
         'coverage', '.venv', 'venv', '__pycache__'}
# Inline links: [txt](dest), [txt](<dest>), [txt](dest "title") — capture dest only.
inline_re = re.compile(r'\][ \t]*\(\s*<?([^)\s>]+)>?(?:[ \t]+"[^"]*")?\s*\)')
# Reference definitions: [label]: dest ["title"]  — validate their dest too.
refdef_re = re.compile(r'(?m)^[ \t]*\[[^\]]+\]:[ \t]*<?(\S+?)>?[ \t]*(?:"[^"]*")?[ \t]*$')
broken = []; checked = 0
for root, dirs, files in os.walk('.'):
    dirs[:] = [d for d in dirs if d not in PRUNE]
    for f in files:
        if not f.endswith('.md'): continue
        p = os.path.join(root, f); base = os.path.dirname(p)
        txt = open(p, encoding='utf-8').read()
        targets = [m.group(1) for m in inline_re.finditer(txt)]
        targets += [m.group(1) for m in refdef_re.finditer(txt)]
        for h in targets:
            h = h.strip()
            if h.startswith(('http://','https://','mailto:','tel:','#')): continue
            t = h.split('#', 1)[0]
            if not t: continue
            checked += 1
            if not os.path.exists(os.path.normpath(os.path.join(base, t))):
                broken.append(f"{p} -> {h}")
print(checked)
for b in broken: print("BROKEN " + b)
PY
)
NCHECK=$(echo "$LINKOUT" | head -1)
BROKEN=$(echo "$LINKOUT" | grep -c '^BROKEN ' || true)
if [[ "$BROKEN" -eq 0 ]]; then pass "$NCHECK relative links resolve"; else
  fail "$BROKEN broken link(s):"; echo "$LINKOUT" | grep '^BROKEN ' | sed 's/^BROKEN /    /'; fi

# ── 6. No AI/LLM attribution ──────────────────────────────────────────────────
hdr "6. No AI/LLM attribution"
# Match real attribution forms, then drop lines that are prohibition rules.
ATTR=$(grep -rniE 'co-authored-by:[[:space:]]*(claude|chatgpt|gpt|codex|copilot|ai)|generated (with|by) (claude|chatgpt|copilot|ai)|🤖 generated|created by (claude|codex|chatgpt)' \
  "${GREP_EXCLUDE_DIRS[@]}" \
  --include='*.md' --include='*.sh' --include='*.yml' --include='*.yaml' --include='*.json' --include='*.ts' --include='*.js' . 2>/dev/null \
  | exclude_by_path \
  | grep -viE 'never|no `|do not|don.t|avoid|prohibit|without|equivalent|forbidden' || true)
if [[ -z "$ATTR" ]]; then pass "no AI/LLM attribution found"; else fail "attribution found:"; echo "$ATTR" | sed 's/^/    /'; fi

# ── 7. No secrets ─────────────────────────────────────────────────────────────
hdr "7. No secrets"
SEC=$(grep -rniE '(gh[pousr]_[A-Za-z0-9]{30,})|(AKIA[0-9A-Z]{16})|(-----BEGIN [A-Z ]*PRIVATE KEY-----)|(xox[baprs]-[A-Za-z0-9-]{10,})|(eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,})' \
  "${GREP_EXCLUDE_DIRS[@]}" \
  --include='*.md' --include='*.sh' --include='*.yml' --include='*.yaml' --include='*.json' --include='*.ts' --include='*.js' --include='*.env*' . 2>/dev/null \
  | exclude_by_path || true)
if [[ -z "$SEC" ]]; then pass "no secret patterns found"; else fail "possible secret(s):"; echo "$SEC" | sed 's/^/    /'; fi
# Guard: no env files staged or tracked
TRACKED_ENV=$(git ls-files | grep -E '(^|/)\.env($|\.)' | grep -v '\.env\.example$' || true)
if [[ -z "$TRACKED_ENV" ]]; then pass "no .env files tracked"; else fail "tracked env file(s):"; echo "$TRACKED_ENV" | sed 's/^/    /'; fi

# ── 8. init.sh syntax ─────────────────────────────────────────────────────────
hdr "8. Shell script syntax"
synfail=0
for s in init.sh scripts/*.sh; do
  [[ -e "$s" ]] || continue
  if bash -n "$s" 2>/dev/null; then pass "$s syntax OK"; else fail "$s syntax error"; synfail=1; fi
done

# ── 9. Slash command schema ───────────────────────────────────────────────────
hdr "9. Slash command schema"
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
hdr "10. Skill schema"
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
hdr "11. Context maps"
ctx_fail=0
for d in .github scripts .agents .agents/logs .claude/skills; do
  [[ -s "$d/AGENTS.md" ]] || { fail "missing context map: $d/AGENTS.md"; ctx_fail=1; }
done
[[ "$ctx_fail" -eq 0 ]] && pass "context maps present in key directories"

# ── 12. Subagent schema ───────────────────────────────────────────────────────
hdr "12. Subagent schema"
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

# ── Summary ───────────────────────────────────────────────────────────────────
hdr "Summary"
echo "  passed: $PASS   failed: $FAILED"
if [[ "$FAILED" -gt 0 ]]; then
  echo -e "${RED}${BOLD}Harness verification FAILED.${RESET}"
  exit 1
fi
echo -e "${GREEN}${BOLD}Harness verification passed.${RESET}"
exit 0
