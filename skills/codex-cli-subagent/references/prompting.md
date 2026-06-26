# Prompting Codex for Docs Research

Use a prompt like this when delegating research to Codex:

```text
You are helping Pi as a read-only research subagent.

Task:
<what to research>

Context:
- Repo/project context: <optional>
- Why this matters: <optional>
- Constraints: prefer official docs, recent sources, and concrete examples

Questions to answer:
1. <question one>
2. <question two>
3. <question three>

Output requirements:
- Keep it concise.
- Include a short Summary section.
- Include Findings as bullets.
- Include Open questions if anything is ambiguous.
- Include Sources with absolute URLs.
- Do not edit files.
```

## Good Example

```text
You are helping Pi as a read-only research subagent.

Task:
Research the latest dbt documentation for incremental models.

Context:
- We need current guidance, not old blog posts.
- Prefer dbt Labs documentation and release notes.

Questions to answer:
1. What incremental strategies are supported?
2. Which configs are required vs optional?
3. What caveats matter most in practice?

Output requirements:
- Summary
- Findings
- Open questions
- Sources with absolute URLs
```

## Tips

- Ask for source URLs every time.
- Ask for official docs first.
- Ask for concrete examples if Pi will implement something next.
- Keep the prompt scoped; split large topics into multiple runs.
