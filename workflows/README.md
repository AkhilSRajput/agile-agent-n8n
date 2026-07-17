# Workflows

This directory contains the n8n workflow JSON exports for Phase 1.

## Files

| File | Feature | Trigger |
|------|---------|---------|
| `scope-creep-sentinel.json` | Scope creep sentinel | Jira webhook — ticket_updated |
| `daily-digest.json` | High-signal daily digest | CRON — weekdays 8:00 AM |
| `blocker-router.json` | Automated blocker routing | Jira webhook — status_changed / label_added |

## How to generate these files

These workflow JSONs are exported from n8n and committed here so contributors can import them directly.

To contribute a new workflow:
1. Build and test it in your local n8n instance
2. Export via **⋮ → Download**
3. Place the JSON here and update this table
4. Add a fixture to `tests/fixtures/` and update `tests/validate-workflows.sh`

## Import instructions

In n8n: **Settings → Import Workflow → select the JSON file**

Then map the credential placeholders (see `config/n8n-credentials.example.json`) and activate the workflow.
