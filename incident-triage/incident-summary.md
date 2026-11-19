# DMI Assignment 11: Kubernetes Incident Summary

## 1. Reported Symptom

The Book Review frontend experienced an ImagePullBackOff
condition during a Kubernetes Deployment rollout.

## 2. Evidence Collected

- Baseline: See reports/baseline-report.txt
- Incident: See reports/incident-failure-report.txt
- Recovery: See reports/recovery-report.txt

The replacement frontend Pod could not pull its
container image. Kubernetes reported ErrImagePull
and ImagePullBackOff.

The previous frontend Pod remained available during
the failed rollout.

## 3. Most Likely Cause

The frontend Deployment was configured with an invalid
container image tag:

ghcr.io/sarah254-tech/book-review-frontend:assignment11-invalid-image

The image registry returned a NotFound error.

## 4. Human-Approved Recovery Action

The human operator manually restored the original
frontend image:

ghcr.io/sarah254-tech/book-review-frontend:assignment10

The Kubernetes Deployment was updated and its rollout
was monitored.

## 5. Verification

The recovery was verified using:

- Kubernetes Pod status and readiness.
- Deployment rollout status.
- Frontend Service EndpointSlices.
- Restored frontend container image.
- Recovery triage report.
- Claude's recovery analysis.

Record the actual recovery results and any remaining
warnings here.

## 6. Safety Decision

Claude analysed the evidence and recommended recovery.
It did not execute recovery commands or modify
Kubernetes resources.

The human operator reviewed and manually executed
the recovery action.

## 7. Agentic Loop Mapping

- Gather: Bash collected Kubernetes health evidence.
- Analyze: Claude interpreted the triage reports.
- Human Act: The human operator restored the original image.
- Verify: Bash collected fresh evidence and Claude
  assessed whether recovery was successful.
