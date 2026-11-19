# Book Review Application - Kubernetes Incident Triage

## Project Configuration

- Application: Book Review App
- Kubernetes namespace: book-review
- Kubernetes context: aks-loadbalancer-lab
- Frontend Deployment: book-review-frontend
- Frontend selector: app=book-review-frontend
- Backend Deployment: book-review-backend
- MySQL StatefulSet: book-review-mysql
- Frontend Service: book-review-frontend
- Backend Service: book-review-backend
- Database Service: book-review-mysql
- Original frontend image:
  ghcr.io/sarah254-tech/book-review-frontend:assignment10
- Original Nginx image: nginx:alpine

## Incident Triage Workflow

Follow this sequence for every incident:

1. Gather: Collect Kubernetes evidence using read-only commands.
2. Analyze: Interpret the collected evidence and identify likely causes.
3. Human Act: Recommend a recovery action for human review and execution.
4. Verify: Collect fresh evidence after the human performs recovery.

## Safety Rules

- All initial investigation must be read-only.
- Never modify Kubernetes resources.
- Never delete, restart, scale, patch, or roll back workloads.
- Never execute recovery commands.
- Never modify ConfigMaps, Secrets, Deployments, StatefulSets, Services, or PVCs.
- Do not expose passwords, tokens, or Secret values.
- Do not assume a Pod failure has a single cause.
- Base conclusions on collected evidence.
- Clearly distinguish observed facts from possible causes.
- Recommend recovery actions, but leave execution to the human operator.
- Human approval and manual execution are mandatory.

## Application-Specific Rules

- Always investigate resources in the book-review namespace.
- Check Pod status and readiness.
- Check container restart counts.
- Inspect relevant Kubernetes events.
- Check Service EndpointSlices to establish whether ready backends exist.
- Compare current container images with the recorded original configuration.
- Do not assume that a Running Pod is necessarily Ready.
- Do not assume that a healthy Pod automatically means its Service has working backends.

## Analysis Output

Every incident analysis must include:

1. Overall health status.
2. Evidence collected.
3. Failed or warning checks.
4. Most likely cause, supported by evidence.
5. Recommended human recovery action.
6. Verification steps.
7. Safety decision.

If evidence is insufficient, state what additional evidence is needed instead of inventing a diagnosis.
