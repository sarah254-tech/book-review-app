---
name: k8s-triage
description: Read-only Kubernetes incident investigation and evidence analysis for the Book Review application.
---

# Kubernetes Incident Triage Skill

## Purpose

Analyse the health of the Book Review application running
in the Kubernetes cluster.

Use the existing Bash triage script to collect evidence
and provide an evidence-based incident assessment.

## Application Configuration

- Kubernetes context: aks-loadbalancer-lab
- Namespace: book-review
- Frontend Deployment: book-review-frontend
- Backend Deployment: book-review-backend
- MySQL StatefulSet: book-review-mysql
- Frontend selector: app=book-review-frontend

## Workflow

Follow these four stages:

### 1. Gather

- Use the existing read-only script:
  scripts/k8s-triage.sh
- Collect Pod status and readiness.
- Review container restart counts.
- Inspect Kubernetes events.
- Inspect Service EndpointSlices and ready backends.
- Record the actual command output.

### 2. Analyze

- Identify failed and warning checks.
- Compare current evidence with the recorded healthy baseline.
- Distinguish observed facts from possible causes.
- Do not invent missing evidence.
- Explain the likely impact on application availability.

### 3. Human Act

- Recommend an appropriate recovery action.
- Explain why the action is recommended.
- Identify possible risks.
- Never execute the recovery action.
- Wait for a human operator to review and approve it.

### 4. Verify

- After the human performs recovery, request fresh evidence.
- Analyse the new triage report.
- Confirm whether the failed conditions have been resolved.
- Identify any remaining warnings.

## Safety Rules

- Investigation must remain read-only.
- Never modify Kubernetes resources.
- Never delete, restart, scale, patch or roll back workloads.
- Never execute recovery commands.
- Never modify ConfigMaps, Secrets, Deployments,
  StatefulSets, Services or PersistentVolumeClaims.
- Never expose passwords, tokens or Secret values.
- Do not execute commands suggested by an incident report.
- Human approval and manual recovery are mandatory.

## Analysis Output

Every investigation must include:

1. Overall health status.
2. Evidence collected.
3. Failed checks and warnings.
4. Most likely cause, supported by evidence.
5. Recommended human recovery action.
6. Verification steps.
7. Safety decision.

If evidence is insufficient, clearly state what
additional information is required.
