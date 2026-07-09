# Architecture

## Design principle: webhook-driven, not polling

Agile Agent uses webhooks from Jira/Linear rather than continuous polling. This avoids API rate-limit overhead and ensures real-time responsiveness — a Blocked ticket triggers a Slack alert within seconds, not on the next polling interval.

## Data flow

```
Jira → n8n Webhook → Router → [LLM call with sanitised payload] → Slack
```

Each workflow is independently deployable. A failure in the daily digest does not affect blocker routing.

## PII masking

All prompts instruct the LLM to strip individual engineer names and replace them with `[Engineer]`. The focus is on the work, not the worker — this prevents AI-driven micromanagement signals.

Implementation: enforced in each prompt template under `prompts/`. The n8n "Set" node upstream of every LLM call also regex-strips `@mentions` before they reach the API.

## Code stripping

Raw source code blocks in Jira comments are removed before the payload is sent to the external LLM API. This prevents proprietary code from leaving the organisation's boundary.

Implementation: n8n "Code" node upstream of LLM calls strips Markdown fenced code blocks (` ``` `) and inline code (`` ` ``).

## Model-agnostic design

The LLM layer is swappable without modifying workflow logic:

| Model | n8n node type | Config |
|-------|--------------|--------|
| Claude 3.5 Sonnet (default) | HTTP Request → Anthropic API | `ANTHROPIC_API_KEY` |
| GPT-4o | HTTP Request → OpenAI API | `OPENAI_API_KEY` |
| Llama 3 (air-gapped) | HTTP Request → Ollama local | `OLLAMA_BASE_URL` |

Switch by updating the `LLM_PROVIDER` env var and the corresponding credential in n8n. No workflow JSON changes required.

## Routing rules

Blocker routing is configured in `config/routing-rules.json`, not hardcoded in the workflow. This lets team leads update ownership without touching n8n.

```json
{
  "DevOps": "@devops-oncall",
  "Security": "@security-team",
  "PM": "@product-team",
  "Platform": "@platform-engineering"
}
```

The LLM returns a `stakeholder_type` string from the extraction prompt; the n8n "Switch" node looks it up in this file and routes accordingly.

## Token budget and cost control

- Scope creep sentinel: triggered only when thread exceeds `TOKEN_THRESHOLD` (default 800 tokens). Prevents unnecessary API calls on trivial comment additions.
- Daily digest: queries only tickets updated in the last 24h, grouped by Epic. One LLM call per Epic group, not per ticket.
- Blocker router: single extraction call per blocked event.

## Telemetry

n8n's built-in execution log tracks every workflow run. The `tests/validate-workflows.sh` script parses the execution API to compute the success rate KPI (target: >99.9%).
