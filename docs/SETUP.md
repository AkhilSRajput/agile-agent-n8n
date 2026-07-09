# Setup guide

Goal: running Agile Agent in under 30 minutes.

## 1. Prerequisites

- n8n instance (self-hosted recommended; n8n Cloud works too)
- Jira Cloud admin access (to create webhooks)
- Slack workspace with permission to install apps
- Anthropic API key (or OpenAI key if swapping models)

## 2. Environment variables

```bash
cp config/.env.example .env
```

Open `.env` and fill in:

| Variable | Description |
|----------|-------------|
| `JIRA_WEBHOOK_SECRET` | Secret token set when creating the Jira webhook |
| `ANTHROPIC_API_KEY` | From console.anthropic.com |
| `SLACK_BOT_TOKEN` | `xoxb-...` token from your Slack app |
| `SLACK_CHANNEL_ID` | Channel ID for #engineering digest posts |
| `SPRINT_START_DATE` | ISO date — used by scope creep sentinel to detect mid-sprint changes |
| `TOKEN_THRESHOLD` | Number of tokens above which a ticket thread triggers scope analysis (default: 800) |
| `CRON_SCHEDULE` | Daily digest schedule in cron syntax (default: `0 8 * * 1-5`) |

## 3. Jira webhook

1. Go to **Jira Settings → System → WebHooks → Create a WebHook**
2. URL: `https://your-n8n.domain/webhook/agile-agent`
3. Events: **Issue updated**, **Issue commented**
4. Paste your `JIRA_WEBHOOK_SECRET` into the Secret field

## 4. Slack app

1. Go to [api.slack.com/apps](https://api.slack.com/apps) → **Create New App → From scratch**
2. Under **OAuth & Permissions**, add scopes: `chat:write`, `users:read`
3. Install the app to your workspace
4. Copy the **Bot User OAuth Token** → `SLACK_BOT_TOKEN` in `.env`
5. Invite the bot to your #engineering channel: `/invite @agile-agent`

## 5. n8n credentials

Create these credential entries in n8n (**Settings → Credentials**):

| n8n credential name | Type | Notes |
|--------------------|------|-------|
| `Jira API` | Jira (API token) | See `config/n8n-credentials.example.json` |
| `Slack OAuth` | Slack OAuth2 | Paste Bot Token |
| `Anthropic` | HTTP Header Auth | Header: `x-api-key`, Value: your API key |

## 6. Import and activate workflows

1. In n8n: **Settings → Import Workflow**
2. Import in this order:
   - `workflows/scope-creep-sentinel.json`
   - `workflows/daily-digest.json`
   - `workflows/blocker-router.json`
3. Open each workflow, map credentials to the names above
4. Toggle **Active** on each workflow

## 7. Verify

Send a test webhook payload:

```bash
bash tests/validate-workflows.sh
```

Expected: Slack messages appear in your configured channels within 10 seconds.

## Optional: Docker local dev

```bash
docker compose up
```

This starts n8n at `http://localhost:5678` with env vars pre-loaded from `.env`.
