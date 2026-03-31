#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: write_backend_config.sh --cluster-dir <path> --output <path>

Environment:
  TF_BACKEND_BUCKET                          Required GCS state bucket name
  TF_BACKEND_PREFIX                          Optional state prefix; defaults to the cluster path
  TF_BACKEND_IMPERSONATE_SERVICE_ACCOUNT     Optional backend impersonation service account
  TF_BACKEND_KMS_ENCRYPTION_KEY              Optional CMEK key for the GCS backend
  TF_BACKEND_CREDENTIALS_FILE                Optional credentials file path
  TF_BACKEND_STORAGE_CUSTOM_ENDPOINT         Optional PSC/custom endpoint for the GCS Storage API
EOF
}

cluster_dir=""
output_file=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cluster-dir)
      cluster_dir="${2:-}"
      shift 2
      ;;
    --output)
      output_file="${2:-}"
      shift 2
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$cluster_dir" || -z "$output_file" ]]; then
  usage
  exit 2
fi

if [[ ! -d "$cluster_dir" ]]; then
  echo "cluster directory not found: $cluster_dir" >&2
  exit 1
fi

bucket="${TF_BACKEND_BUCKET:?TF_BACKEND_BUCKET is required}"
prefix="${TF_BACKEND_PREFIX:-${cluster_dir#./}}"

mkdir -p "$(dirname "$output_file")"

{
  printf 'bucket = "%s"\n' "$bucket"
  printf 'prefix = "%s"\n' "$prefix"

  if [[ -n "${TF_BACKEND_IMPERSONATE_SERVICE_ACCOUNT:-}" ]]; then
    printf 'impersonate_service_account = "%s"\n' "$TF_BACKEND_IMPERSONATE_SERVICE_ACCOUNT"
  fi

  if [[ -n "${TF_BACKEND_KMS_ENCRYPTION_KEY:-}" ]]; then
    printf 'kms_encryption_key = "%s"\n' "$TF_BACKEND_KMS_ENCRYPTION_KEY"
  fi

  if [[ -n "${TF_BACKEND_CREDENTIALS_FILE:-}" ]]; then
    printf 'credentials = "%s"\n' "$TF_BACKEND_CREDENTIALS_FILE"
  fi

  if [[ -n "${TF_BACKEND_STORAGE_CUSTOM_ENDPOINT:-}" ]]; then
    printf 'storage_custom_endpoint = "%s"\n' "$TF_BACKEND_STORAGE_CUSTOM_ENDPOINT"
  fi
} > "$output_file"

echo "$output_file"
