# 🤖 Agile Agent: n8n & LLM-Powered Sprint Orchestration

**Status:** `v1.0.0 (MVP)` | **Type:** `Technical Product Requirements Document (PRD) & Workflow Implementation`

> **Executive Summary:** A blueprint and functional n8n workflow designed to automate agile ceremonies, reduce engineering administrative overhead, and proactively detect sprint scope creep using LLM summarization.

---

## 🎯 1. The Problem: Engineering "Signal vs. Noise"
In scaling engineering teams, Technical Program Managers (TPMs) and Engineering Managers spend up to 30% of their week chasing ticket statuses, running prolonged daily standups, and manually cross-referencing Jira with Slack to find delivery bottlenecks. 
* **Scope Creep is Silent:** Ticket requirements expand in comment threads without PM approval.
* **Standups Lack Signal:** Daily updates devolve into reading Jira boards rather than unblocking technical dependencies.
* **Context Switching:** Engineers lose deep-work focus updating multiple stakeholders.

## 💡 2. The Solution
**Agile Agent** is an event-driven automation pipeline built on **n8n**. It ingests issue tracker events (Jira/Linear), uses an **LLM** (Claude 3.5 Sonnet / GPT-4o) to synthesize complex comment threads, and routes actionable insights directly to the team's communication channels (Slack/Teams).

---

## 🏗 3. System Architecture

The architecture uses a webhook-driven design to ensure real-time responsiveness without the API rate-limit overhead of continuous polling.

```mermaid
graph TD
    A[Issue Tracker: Jira/Linear] -->|Webhook: Ticket Updated| B(n8n Webhook Endpoint)
    B --> C{n8n Switch/Router}
    
    C -->|Minor Update| D[Drop Event]
    C -->|Status = Blocked| E[LLM: Extract Blocker Context]
    C -->|EOD Summary Trigger| F[LLM: Summarize Daily Delta]
    
    E --> G[Slack API: Alert TPM/EM]
    F --> H[Slack API: Post Daily Standup Digest]
    
    subgraph Data Governance
    I[Prompt Template: Mask PII & Code] --> E
    I --> F
    end
