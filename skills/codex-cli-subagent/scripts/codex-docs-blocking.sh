#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  codex-docs-blocking.sh [prompt words...]
  codex-docs-blocking.sh < prompt.txt

Runs `codex exec` in read-only mode with web search enabled.
Writes the final response to a temp file and prints its path.
EOF
}

read_prompt() {
    if [[ $# -gt 0 ]]; then
        printf '%s' "$*"
        if [[ ! -t 0 ]]; then
            printf '\n\n<stdin>\n'
            cat
            printf '\n</stdin>\n'
        fi
    elif [[ ! -t 0 ]]; then
        cat
    else
        usage >&2
        exit 1
    fi
}

PROMPT="$(read_prompt "$@")"
OUT_DIR="${TMPDIR:-/tmp}/codex-subagent"
mkdir -p "$OUT_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_FILE="$OUT_DIR/blocking-$STAMP.md"

codex exec \
    --search \
    --sandbox read-only \
    --skip-git-repo-check \
    --ephemeral \
    --cd "$PWD" \
    --output-last-message "$OUT_FILE" \
    "$PROMPT"

printf 'final_message=%s\n' "$OUT_FILE"
