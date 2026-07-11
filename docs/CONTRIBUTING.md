# Contributing

Thanks for improving Agile Agent. Here's how to do it without breaking things.

## What you can contribute

- New or improved prompt templates (most impactful — iterate fast)
- Additional n8n workflow variants (e.g. Linear instead of Jira)
- New routing rule categories in `config/routing-rules.json`
- Bug fixes and documentation improvements
- New test fixtures

## Local dev setup

```bash
git clone https://github.com/your-org/agile-agent.git
cd agile-agent
cp config/.env.example .env
# Fill in at minimum: ANTHROPIC_API_KEY, SLACK_BOT_TOKEN, SLACK_CHANNEL_ID
docker compose up
```

n8n will be available at `http://localhost:5678`.

## Changing prompt templates

Prompts live in `prompts/`. They are plain Markdown files with `{{variable}}` placeholders substituted by n8n "Set" nodes before the LLM call.

When editing a prompt:

1. Describe the change and why in your PR description
2. Include before/after example outputs (run the prompt manually via the Anthropic Workbench or similar)
3. Confirm PII masking is still enforced (engineer names → `[Engineer]`)
4. Confirm raw code blocks are still excluded from LLM input

## Changing workflow JSON

1. Make your changes in the n8n UI
2. Export the workflow: **⋮ → Download**
3. Replace the relevant file in `workflows/`
4. Run `bash tests/validate-workflows.sh` — all fixture payloads must succeed
5. Commit the exported JSON alongside your PR

## PR checklist

- [ ] Prompt diff included (if prompts changed)
- [ ] No hardcoded credentials or API keys
- [ ] `validate-workflows.sh` passes
- [ ] `config/n8n-credentials.example.json` updated if new credentials are required
- [ ] ARCHITECTURE.md updated if data flow changed
- [ ] KPI notes added if the change affects execution rate or latency

## Reporting issues

Open a GitHub issue with:
- n8n version
- Which workflow failed
- The n8n execution ID (from the Executions panel)
- Sanitised payload (no real ticket data)
