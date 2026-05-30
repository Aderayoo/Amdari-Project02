# Week 1 Progress Report
## SecureFlow DevSecOps Pipeline

Date: 29 May 2026
Author: Aderayoo

---

## Executive Summary

Week 1 established the complete detection foundation
for the SecureFlow DevSecOps pipeline. All 5 pipeline
stages are operational. The pipeline automatically
detects secrets, application vulnerabilities, container
CVEs, and infrastructure misconfigurations on every push.

---

## Pipeline Architecture

Stage 1 - Gitleaks:    Secrets detection - hard fail
Stage 2 - SonarQube:   SAST scanning - soft fail
Stage 3 - Trivy:       CVE scanning - hard fail
Stage 4 - Checkov:     IaC scanning - hard fail
Stage 5 - Gate:        Aggregates all - final verdict

---

## Findings Summary

| Category           | Count | Owner     |
|--------------------|-------|-----------|
| Committed secrets  | 3     | DevSecOps |
| App vulnerabilities| 11    | AppSec    |
| Container CVEs     | 5     | DevSecOps |
| K8s misconfigs     | 90    | DevSecOps |
| Terraform issues   | 50    | DevSecOps |

---

## Exploits Confirmed

1. SQL Injection - admin'-- bypasses login
2. IDOR - any user sees any balance
3. Negative transfer - money stolen backwards
4. Reflected XSS - script executes in browser
5. Session forgery - admin session from known secret

---

## Tools Configured

Gitleaks - secret detection - working
SonarQube - SAST - working
Trivy - CVE and IaC scanning - working
Checkov - Terraform scanning - working
GitHub Actions - pipeline - working

---

## Challenges Encountered

1. Flask/Werkzeug version conflict
   Fixed by pinning werkzeug==2.3.7

2. Port 5000 conflict with macOS AirPlay
   Fixed by changing port to 5080

3. SonarCloud organisation key case sensitivity
   Fixed by using lowercase aderayoo

4. SonarCloud token newline character
   Fixed by regenerating and carefully pasting token

5. Automatic Analysis conflicting with CI
   Fixed by disabling in SonarCloud settings

---

## Open Questions for Week 2

1. How to rotate committed secrets safely?
2. How to rewrite git history correctly?
3. How does Vault Kubernetes auth work?
4. Can OPA Gatekeeper be tested locally?
5. How does Falco detect post-exploitation shells?

---

## Week 2 Plan

Day 6:  Secrets remediation and Vault deployment
Day 7:  Container hardening
Day 8:  Kubernetes manifest hardening
Day 9:  OPA Gatekeeper policies
Day 10: Terraform IaC remediation
