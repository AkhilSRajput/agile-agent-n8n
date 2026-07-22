#!/usr/bin/env bash
# validate-workflows.sh
# Sends fixture payloads to a local n8n instance and verifies successful execution.
# Tracks the >99.9% execution success rate KPI.
#
# Usage: bash tests/validate-workflows.sh
# Requires: n8n running at N8N_BASE_URL (default: http://localhost:5678)

set -euo pipefail

N8N_BASE_URL="${N8N_BASE_URL:-http://localhost:5678}"
WEBHOOK_PATH="/webhook/agile-agent"
PASS=0
FAIL=0
RESULTS=()

echo "=== Agile Agent — workflow validation ==="
echo "n8n: $N8N_BASE_URL"
echo ""

send_fixture() {
  local name="$1"
  local fixture="$2"
  local description="$3"

  echo -n "  [$name] $description ... "

  response=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$N8N_BASE_URL$WEBHOOK_PATH" \
    -H "Content-Type: application/json" \
    -H "X-Jira-Webhook-Secret: ${JIRA_WEBHOOK_SECRET:-test-secret}" \
    -d @"$fixture")

  if [[ "$response" -ge 200 && "$response" -lt 300 ]]; then
    echo "✓ ($response)"
    PASS=$((PASS + 1))
    RESULTS+=("PASS: $name")
  else
    echo "✗ ($response)"
    FAIL=$((FAIL + 1))
    RESULTS+=("FAIL: $name — HTTP $response")
  fi
}

echo "--- Scope creep sentinel ---"
send_fixture "scope-creep" \
  "tests/fixtures/jira-ticket-updated.json" \
  "Ticket with scope expansion in comments"

echo ""
echo "--- Blocker router ---"
send_fixture "blocker-router" \
  "tests/fixtures/jira-blocked.json" \
  "Ticket status changed to Blocked (DevOps route expected)"

echo ""
echo "=== Results ==="
for r in "${RESULTS[@]}"; do
  echo "  $r"
done
echo ""
TOTAL=$((PASS + FAIL))
SUCCESS_RATE=$(awk "BEGIN { printf \"%.1f\", ($PASS/$TOTAL)*100 }")
echo "  Passed: $PASS / $TOTAL  ($SUCCESS_RATE%)"

if [[ $FAIL -gt 0 ]]; then
  echo ""
  echo "  ✗ Validation failed. Check n8n execution logs at $N8N_BASE_URL/executions"
  exit 1
else
  echo "  ✓ All workflows validated."
  exit 0
fi
