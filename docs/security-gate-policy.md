# SecureFlow Security Gate Policy

## Purpose
This document defines the ownership matrix, gate behaviour,
and exception process for the SecureFlow DevSecOps pipeline.

---

## Ownership Matrix

### DevSecOps Team (hard-fail on CRITICAL/HIGH)
These findings block merge until resolved.

| Scanner   | Finding Type              | Severity Threshold | Action      |
|-----------|---------------------------|-------------------|-------------|
| Gitleaks  | Committed secrets         | Any               | Hard fail   |
| Trivy     | Container CVEs            | CRITICAL, HIGH    | Hard fail   |
| Trivy     | K8s misconfigurations     | CRITICAL, HIGH    | Hard fail   |
| Checkov   | Terraform misconfigurations| CRITICAL, HIGH   | Hard fail   |

### AppSec Team (soft-fail — route and notify)
These findings are reported but do not block merge.

| Scanner    | Finding Type              | Severity   | Action           |
|------------|---------------------------|------------|------------------|
| SonarQube  | SQL Injection             | Any        | PR comment + ticket |
| SonarQube  | XSS vulnerabilities       | Any        | PR comment + ticket |
| SonarQube  | Broken authentication     | Any        | PR comment + ticket |
| OWASP ZAP  | Runtime vulnerabilities   | Any        | PR comment + ticket |

---

## Gate Behaviour

### Hard Fail
Triggered when DevSecOps-owned scanner finds CRITICAL or HIGH finding.

Result:
- Pipeline fails immediately
- Merge blocked
- PR comment posted showing exact finding
- Developer must fix before re-pushing

### Soft Fail
Triggered when AppSec-owned scanner finds any finding.

Result:
- Pipeline continues
- Merge NOT blocked
- PR comment posted tagging AppSec team
- Ticket created for AppSec backlog
- Finding tracked in Grafana dashboard

---

## PR Comment Format

### Blocking Comment Example
## Exception Process
To request an exception post this PR comment:
/security-exception <finding-id> <reason>

Exceptions require team lead approval within 24 hours.
Exceptions expire after 7 days.

Never granted for committed secrets or AWS keys.

## Rationale

Stage 1 Gitleaks hard-fails on ANY finding because a
committed secret has zero acceptable severity levels.

Stage 2 SonarQube soft-fails because app layer bugs
belong to the AppSec team. Hard failing blocks delivery
while AppSec works their backlog.
