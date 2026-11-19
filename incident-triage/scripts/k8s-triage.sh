#!/usr/bin/env bash

# DMI Assignment 11
# AI-Assisted Kubernetes Incident Triage
# Read-only health check script

set -uo pipefail

# --------------------------------------------------
# 1. PROJECT CONFIGURATION
# --------------------------------------------------

NAMESPACE="book-review"
CONTEXT="aks-loadbalancer-lab"
FRONTEND_SELECTOR="app=book-review-frontend"

# Expected original frontend images
EXPECTED_FRONTEND_IMAGE="ghcr.io/sarah254-tech/book-review-frontend:assignment10"
EXPECTED_NGINX_IMAGE="nginx:alpine"

# --------------------------------------------------
# 2. HEALTH CHECKS
# --------------------------------------------------

CHECKS=(
  "Pod discovery and status"
  "Container readiness"
  "Container restart counts"
  "Kubernetes events"
  "Service ready backends"
)

# --------------------------------------------------
# 3. REPORT VARIABLES
# --------------------------------------------------

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

# --------------------------------------------------
# 4. HELPER FUNCTIONS
# --------------------------------------------------

print_section() {
  echo
  echo "=================================================="
  echo "$1"
  echo "=================================================="
}

record_result() {
  local status="$1"
  local message="$2"

  echo "[$status] $message"

  case "$status" in
    PASS) ((PASS_COUNT+=1)) ;;
    WARN) ((WARN_COUNT+=1)) ;;
    FAIL) ((FAIL_COUNT+=1)) ;;
  esac
}

# --------------------------------------------------
# 5. POD DISCOVERY AND STATUS
# --------------------------------------------------

check_pods() {
  print_section "1. POD DISCOVERY AND STATUS"

  kubectl --context "$CONTEXT" -n "$NAMESPACE" \
    get pods -l "$FRONTEND_SELECTOR" -o wide

  local pod_count
  pod_count=$(kubectl --context "$CONTEXT" -n "$NAMESPACE" \
    get pods -l "$FRONTEND_SELECTOR" -o name | wc -l)

  if (( pod_count == 0 )); then
    record_result FAIL "No Pods match selector: $FRONTEND_SELECTOR"
    return
  fi

  record_result PASS "$pod_count frontend Pod(s) match the configured selector"
}

# --------------------------------------------------
# 6. CONTAINER READINESS
# --------------------------------------------------

check_readiness() {
  print_section "2. CONTAINER READINESS"

  kubectl --context "$CONTEXT" -n "$NAMESPACE" \
    get pods \
    -o custom-columns='POD:.metadata.name,READY:.status.containerStatuses[*].ready,PHASE:.status.phase'

  local not_ready
  not_ready=$(kubectl --context "$CONTEXT" -n "$NAMESPACE" \
    get pods -o jsonpath='{range .items[*]}{.metadata.name}{" "}{range .status.containerStatuses[*]}{.ready}{" "}{end}{"\n"}{end}' \
    | awk '$0 ~ /false/ {print}')

  if [[ -n "$not_ready" ]]; then
    record_result FAIL "One or more containers are not ready"
    echo "$not_ready"
  else
    record_result PASS "All discovered containers are ready"
  fi
}

# --------------------------------------------------
# 7. CONTAINER RESTART COUNTS
# --------------------------------------------------

check_restarts() {
  print_section "3. CONTAINER RESTART COUNTS"

  kubectl --context "$CONTEXT" -n "$NAMESPACE" \
    get pods \
    -o custom-columns='POD:.metadata.name,CONTAINERS:.status.containerStatuses[*].name,RESTARTS:.status.containerStatuses[*].restartCount'

  local restarts
  restarts=$(kubectl --context "$CONTEXT" -n "$NAMESPACE" \
    get pods -o jsonpath='{range .items[*]}{range .status.containerStatuses[*]}{.restartCount}{"\n"}{end}{end}' \
    | awk '$1 > 0 {count++} END {print count+0}')

  if (( restarts > 0 )); then
    record_result WARN "$restarts container(s) have restart counts above zero"
  else
    record_result PASS "No container restarts detected"
  fi
}

# --------------------------------------------------
# 8. KUBERNETES EVENTS
# --------------------------------------------------

check_events() {
  print_section "4. KUBERNETES EVENTS"

  kubectl --context "$CONTEXT" -n "$NAMESPACE" \
    get events --sort-by='.lastTimestamp'

  record_result PASS "Kubernetes events collected"
}

# --------------------------------------------------
# 9. SERVICE READY BACKENDS
# --------------------------------------------------

check_service_backends() {
  print_section "5. SERVICE READY BACKENDS"

  local service
  local ready_count

  for service in book-review-frontend book-review-backend book-review-mysql; do

    echo
    echo "Checking Service: $service"

    kubectl --context "$CONTEXT" -n "$NAMESPACE" \
      get endpointslices \
      -l "kubernetes.io/service-name=$service" \
      -o wide

    ready_count=$(kubectl --context "$CONTEXT" -n "$NAMESPACE" \
      get endpointslices \
      -l "kubernetes.io/service-name=$service" \
      -o jsonpath='{range .items[*].endpoints[*]}{.conditions.ready}{"\n"}{end}' \
      | grep -c '^true$' || true)

    if (( ready_count == 0 )); then
      record_result FAIL "Service $service has no ready backends"
    else
      record_result PASS "Service $service has $ready_count ready backend(s)"
    fi
  done
}

# --------------------------------------------------
# 10. PREFLIGHT VALIDATION
# --------------------------------------------------

preflight_check() {
  print_section "PREFLIGHT VALIDATION"

  if ! command -v kubectl >/dev/null 2>&1; then
    echo "[ERROR] kubectl is not installed or not in PATH"
    return 1
  fi

  if ! kubectl config get-contexts "$CONTEXT" --no-headers \
      2>/dev/null | grep -q .; then
    echo "[ERROR] Kubernetes context not found: $CONTEXT"
    return 1
  fi

  if ! kubectl --context "$CONTEXT" \
      get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "[ERROR] Cannot access namespace: $NAMESPACE"
    return 1
  fi

  echo "[PASS] kubectl is available"
  echo "[PASS] Kubernetes context is accessible"
  echo "[PASS] Namespace is accessible"

  return 0
}

# --------------------------------------------------
# 11. FINAL SUMMARY
# --------------------------------------------------

print_summary() {
  print_section "TRIAGE SUMMARY"

  echo "PASS: $PASS_COUNT"
  echo "WARN: $WARN_COUNT"
  echo "FAIL: $FAIL_COUNT"

  echo
  echo "Workflow: Gather -> Analyze -> Human Act -> Verify"
  echo "Safety: Read-only investigation. No recovery actions executed."
}

# --------------------------------------------------
# 12. MAIN EXECUTION
# --------------------------------------------------

main() {
  print_section "KUBERNETES INCIDENT TRIAGE"

  echo "Namespace: $NAMESPACE"
  echo "Context: $CONTEXT"
  echo "Started: $(date)"

  if ! preflight_check; then
    echo "[ERROR] Preflight validation failed."
    echo "Exit code: 2"
    exit 2
  fi

  check_pods
  check_readiness
  check_restarts
  check_events
  check_service_backends

  print_summary

  if (( FAIL_COUNT > 0 )); then
    echo "Overall result: FAIL"
    echo "Exit code: 1"
    exit 1
  fi

  if (( WARN_COUNT > 0 )); then
    echo "Overall result: WARN"
  else
    echo "Overall result: PASS"
  fi

  echo "Exit code: 0"
  exit 0
}

main "$@"
