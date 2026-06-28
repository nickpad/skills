---
name: codex-cli-subagent
description: Use the Codex CLI as a read-only research subagent for documentation-heavy tasks, especially searching the web, reading official docs, changelogs, and API pages. Use when Pi should delegate external-doc research to Codex, either in blocking mode or in the background.
---

# Codex CLI Subagent

Use this skill when the task is primarily **research** rather than local editing.

## Best Use Cases

Prefer Codex when you need to:

- search the web for official documentation
- read long docs pages and summarize them
- compare versions, migration guides, or release notes
- collect source URLs for later verification
- answer questions that depend on up-to-date external docs

Do **not** use this as the first choice for:

- searching the local repo
- editing project files
- running write-heavy automation

For this skill's recommended use case, keep Codex in **read-only** mode and enable web search.

## Prerequisites

Verify Codex is installed and authenticated:

```bash
codex --version
codex login
```

Useful references:

- `codex --help`
- `codex exec --help`
- `references/prompting.md`

## Prompting Guidance

Tell Codex all of the following:

1. the research goal
2. any repo or product context it should know
3. the exact questions to answer
4. the output shape you want
5. that it must include source URLs

Recommended output sections:

- `Summary`
- `Findings`
- `Open questions`
- `Sources`

A good prompt template is in `references/prompting.md`.

## Blocking Invocation

Use blocking mode when Pi needs the answer before continuing.

### Preferred helper

```bash
scripts/codex-docs-blocking.sh <<'PROMPT'
Research the latest dbt documentation for incremental models.
Focus on supported strategies, required configs, and common caveats.
Return:
- Summary
- Findings
- Source URLs
PROMPT
```

This runs `codex exec` in read-only mode with web search enabled, waits for completion, and prints the final response path.

### Raw command

```bash
codex --search exec \
  --sandbox read-only \
  --skip-git-repo-check \
  --ephemeral \
  --cd "$PWD" \
  --output-last-message /tmp/codex-result.md \
  "Research the topic and return concise findings with source URLs."
```

Then read the result file.

## Nonblocking Invocation

Use nonblocking mode when research may take a while and Pi can continue doing other work.

### Preferred helper

```bash
scripts/codex-docs-nonblocking.sh <<'PROMPT'
Research the latest Looker documentation on native derived tables.
Return a concise summary, key limits, and source URLs.
PROMPT
```

The helper starts Codex in the background and creates a run directory containing:

- `final.md` — final answer
- `events.jsonl` — streamed Codex events
- `stderr.log` — stderr output
- `pid` — background process id

### Monitor a background run

```bash
tail -f <run-dir>/events.jsonl
```

When finished, read:

```bash
<run-dir>/final.md
```

### Raw background command

```bash
mkdir -p /tmp/codex-subagent
RUN_DIR="/tmp/codex-subagent/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR"
nohup codex --search exec \
  --sandbox read-only \
  --skip-git-repo-check \
  --ephemeral \
  --cd "$PWD" \
  --output-last-message "$RUN_DIR/final.md" \
  --json \
  "Research the topic and return concise findings with source URLs." \
  > "$RUN_DIR/events.jsonl" 2> "$RUN_DIR/stderr.log" < /dev/null &
echo $! > "$RUN_DIR/pid"
```

## Recommended Defaults

For docs research, prefer these Codex flags:

- `--search` — lets Codex search the web. This is a **global** flag and must come **before** the `exec` subcommand (e.g. `codex --search exec ...`), not after it; `codex exec --search ...` fails with `unexpected argument '--search'`. It is listed under `codex --help`, not `codex exec --help`.
- `--sandbox read-only` — prevents edits
- `--ephemeral` — avoids cluttering saved sessions
- `--output-last-message <file>` — makes result capture easy
- `--json` — useful for background runs and progress logs

## Operating Rules

- Ask Codex to cite URLs.
- Prefer official docs over forum posts.
- Treat Codex output as research notes; verify important claims before editing code.
- If the task changes from research to implementation, return to Pi and do the edits locally.

## Files

- `scripts/codex-docs-blocking.sh`
- `scripts/codex-docs-nonblocking.sh`
- `references/prompting.md`
