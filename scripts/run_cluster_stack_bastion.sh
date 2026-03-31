#!/usr/bin/env bash
set -euo pipefail

export TF_IN_AUTOMATION=1
export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-.artifacts/.terraform.d/plugin-cache}"

mkdir -p "${TF_PLUGIN_CACHE_DIR}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cluster_dir="${1:-clusters/dev/gcp-classic-101}"
mode="${2:-plan}"
artifact_dir="${3:-.artifacts/$(printf '%s' "$cluster_dir" | tr '/' '_')/${mode}}"

shift $(( $# > 0 ? 1 : 0 ))
shift $(( $# > 0 ? 1 : 0 ))
shift $(( $# > 0 ? 1 : 0 ))

exec bash "${SCRIPT_DIR}/run_cluster_workflow.sh" \
  --cluster-dir "$cluster_dir" \
  --artifact-dir "$artifact_dir" \
  --mode "$mode" \
  "$@"
