#!/bin/bash
# SecureFlow Security Gate

GATE_STATUS="PASS"

echo "=== SecureFlow Security Gate ==="
echo "Commit: ${GITHUB_SHA:-local}"

if [ "${GITLEAKS_RESULT:-success}" = "failure" ]; then
  echo "BLOCKING: Secrets found by Gitleaks"
  GATE_STATUS="FAIL"
fi

if [ "${TRIVY_IMAGE_RESULT:-pass}" = "fail" ]; then
  echo "BLOCKING: Critical CVEs found by Trivy"
  GATE_STATUS="FAIL"
fi

if [ "${IAC_RESULT:-pass}" = "fail" ]; then
  echo "BLOCKING: IaC misconfigurations found"
  GATE_STATUS="FAIL"
fi

echo "SonarQube findings routed to AppSec team"

if [ "$GATE_STATUS" = "FAIL" ]; then
  echo "GATE RESULT: FAIL — merge blocked"
  exit 1
else
  echo "GATE RESULT: PASS"
  exit 0
fi
