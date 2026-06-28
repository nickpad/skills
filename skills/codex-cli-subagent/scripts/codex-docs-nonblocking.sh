#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  codex-docs-nonblocking.sh [prompt words...]
  codex-docs-nonblocking.sh < prompt.txt

Starts `codex exec` in the background in read-only mode with web search enabled.
Prints the run directory and pid.
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
BASE_DIR="${TMPDIR:-/tmp}/codex-subagent"
mkdir -p "$BASE_DIR"
# mktemp -d makes the run dir atomically, so concurrent launches in the same
# second never collide or clobber each other's files.
RUN_DIR="$(mktemp -d "${BASE_DIR}/run-$(date +%Y%m%d-%H%M%S)-XXXXXX")"
PROMPT_FILE="$RUN_DIR/prompt.txt"
FINAL_FILE="$RUN_DIR/final.md"
EVENTS_FILE="$RUN_DIR/events.jsonl"
STDERR_FILE="$RUN_DIR/stderr.log"
PID_FILE="$RUN_DIR/pid"

printf '%s\n' "$PROMPT" > "$PROMPT_FILE"

nohup codex --search exec \
    --sandbox read-only \
    --skip-git-repo-check \
    --ephemeral \
    --cd "$PWD" \
    --output-last-message "$FINAL_FILE" \
    --json \
    "$PROMPT" \
    > "$EVENTS_FILE" 2> "$STDERR_FILE" < /dev/null &

PID="$!"
printf '%s\n' "$PID" > "$PID_FILE"

cat <<EOF
run_dir=$RUN_DIR
pid=$PID
final_message=$FINAL_FILE
events=$EVENTS_FILE
stderr=$STDERR_FILE
EOF
