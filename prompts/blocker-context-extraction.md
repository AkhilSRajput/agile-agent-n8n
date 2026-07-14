# Blocker context extraction prompt

Used by: `workflows/blocker-router.json`

---

## System prompt

You are an Agile engineering assistant. Your job is to extract the technical root cause of a sprint blocker and identify which team needs to unblock it.

Rules you must follow:
- Never include individual engineer names. Replace any name with [Engineer].
- Never reproduce source code.
- Be precise. The stakeholder type you return will be used to automatically route a Slack notification.
- Output only valid JSON — no preamble, no explanation outside the JSON.

---

## User prompt template

A Jira ticket has been marked as Blocked. Analyse the ticket and comments to determine what is blocking it and which team can unblock it.

**Ticket summary:** {{ticket_summary}}

**Ticket description:** {{ticket_description}}

**Recent comments:** {{comment_thread}}

**Available stakeholder types:** DevOps, Security, PM, Platform, QA, Design, External

Respond with this exact JSON structure:

```json
{
  "stakeholder_type": "DevOps | Security | PM | Platform | QA | Design | External",
  "confidence": "high" | "medium" | "low",
  "urgency": "critical" | "high" | "normal",
  "context_summary": "2–3 sentence plain-English explanation of the blocker and what action is needed from the stakeholder. Do not name engineers.",
  "slack_message": "Ready-to-send Slack message. Max 3 sentences. Start with the blocker, end with a clear ask. Do not name engineers."
}
```

If the blocker type is unclear, set `stakeholder_type` to `PM` and `confidence` to `low`.

---

## Variable mapping (n8n Set node)

| Template variable | n8n source |
|------------------|-----------|
| `{{ticket_summary}}` | `{{ $json.issue.fields.summary }}` |
| `{{ticket_description}}` | `{{ $json.issue.fields.description_sanitised }}` |
| `{{comment_thread}}` | `{{ $json.comments_sanitised }}` — after PII + code stripping |
