#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF' >&2
usage: run_cluster_workflow.sh --cluster-dir <path> --artifact-dir <path> --mode <validate|plan|apply> [--backend true|false] [--backend-config-file <path>] [--terraform-bin <path>]
EOF
}

CLUSTER_DIR=""
ARTIFACT_DIR=""
MODE=""
BACKEND="false"
BACKEND_CONFIG_FILE=""
TERRAFORM_BIN="${TERRAFORM_BIN:-terraform}"
SKIP_TOOL_CHECK="${OCP_GCP_FACTORY_SKIP_TOOL_CHECK:-false}"
ALLOW_APPLY="${OCP_GCP_FACTORY_ALLOW_APPLY:-false}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cluster-dir)
      CLUSTER_DIR="${2:-}"
      shift 2
      ;;
    --artifact-dir)
      ARTIFACT_DIR="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --backend)
      BACKEND="${2:-}"
      shift 2
      ;;
    --backend-config-file)
      BACKEND_CONFIG_FILE="${2:-}"
      shift 2
      ;;
    --terraform-bin)
      TERRAFORM_BIN="${2:-}"
      shift 2
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$CLUSTER_DIR" || -z "$ARTIFACT_DIR" || -z "$MODE" ]]; then
  usage
  exit 2
fi

if [[ ! -d "$CLUSTER_DIR" ]]; then
  echo "cluster directory not found: $CLUSTER_DIR" >&2
  exit 1
fi

case "$MODE" in
  validate|plan|apply)
    ;;
  *)
    echo "unsupported mode: $MODE" >&2
    exit 1
    ;;
esac

if [[ "$SKIP_TOOL_CHECK" != "true" ]]; then
  bash "${REPO_ROOT}/scripts/check_required_ci_tools.sh" bash git jq python3 "$TERRAFORM_BIN" helm rg oc gcloud
fi

CLUSTER_DIR="$(cd "$CLUSTER_DIR" && pwd)"
ARTIFACT_DIR="$(mkdir -p "$ARTIFACT_DIR" && cd "$ARTIFACT_DIR" && pwd)"
TFVARS_FILE="${ARTIFACT_DIR}/terraform.auto.tfvars.json"
PLAN_FILE="${ARTIFACT_DIR}/terraform.tfplan"

python3 "${REPO_ROOT}/scripts/render_effective_config.py" \
  --cluster "$CLUSTER_DIR/cluster.yaml" \
  --gitops "$CLUSTER_DIR/gitops.yaml" \
  --output-dir "$ARTIFACT_DIR"

python3 "${REPO_ROOT}/scripts/validate_stack_inputs.py" \
  --rendered "$ARTIFACT_DIR/effective-config.json"

if [[ "$BACKEND" == "true" ]]; then
  if [[ -n "$BACKEND_CONFIG_FILE" ]]; then
    "$TERRAFORM_BIN" -chdir="$CLUSTER_DIR" init -input=false -reconfigure -backend-config="$BACKEND_CONFIG_FILE"
  else
    "$TERRAFORM_BIN" -chdir="$CLUSTER_DIR" init -input=false -reconfigure
  fi
else
  "$TERRAFORM_BIN" -chdir="$CLUSTER_DIR" init -input=false -backend=false
fi

"$TERRAFORM_BIN" -chdir="$CLUSTER_DIR" validate -no-color

case "$MODE" in
  validate)
    ;;
  plan)
    "$TERRAFORM_BIN" -chdir="$CLUSTER_DIR" plan -input=false -no-color -var-file="$TFVARS_FILE" -out="$PLAN_FILE"
    "$TERRAFORM_BIN" -chdir="$CLUSTER_DIR" show -json "$PLAN_FILE" > "$ARTIFACT_DIR/terraform-plan.json"
    "$TERRAFORM_BIN" -chdir="$CLUSTER_DIR" show -no-color "$PLAN_FILE" > "$ARTIFACT_DIR/terraform-plan.txt"
    ;;
  apply)
    if [[ "$ALLOW_APPLY" != "true" ]]; then
      echo "apply mode requires OCP_GCP_FACTORY_ALLOW_APPLY=true" >&2
      exit 1
    fi
    "$TERRAFORM_BIN" -chdir="$CLUSTER_DIR" plan -input=false -no-color -var-file="$TFVARS_FILE" -out="$PLAN_FILE"
    "$TERRAFORM_BIN" -chdir="$CLUSTER_DIR" show -json "$PLAN_FILE" > "$ARTIFACT_DIR/terraform-plan.json"
    "$TERRAFORM_BIN" -chdir="$CLUSTER_DIR" show -no-color "$PLAN_FILE" > "$ARTIFACT_DIR/terraform-plan.txt"
    "$TERRAFORM_BIN" -chdir="$CLUSTER_DIR" apply -input=false -auto-approve "$PLAN_FILE"
    "$TERRAFORM_BIN" -chdir="$CLUSTER_DIR" output -json > "$ARTIFACT_DIR/terraform-outputs.json"
    ;;
esac
