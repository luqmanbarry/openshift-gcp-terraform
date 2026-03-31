#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: list_changed_clusters_json.sh [--base-ref <ref>] [--head-ref <ref>] [--cluster-dir <path>]
EOF
}

base_ref="origin/main"
head_ref="HEAD"
cluster_dir=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-ref)
      base_ref="${2:-}"
      shift 2
      ;;
    --head-ref)
      head_ref="${2:-}"
      shift 2
      ;;
    --cluster-dir)
      cluster_dir="${2:-}"
      shift 2
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

if [[ -n "$cluster_dir" ]]; then
  if [[ ! -d "$cluster_dir" ]]; then
    echo "cluster directory not found: $cluster_dir" >&2
    exit 1
  fi

  printf '%s\n' "$cluster_dir" \
    | jq -R -s '
        split("\n")
        | map(select(length > 0))
        | {
            include: map({
              cluster_dir: .,
              cluster_name: (split("/") | last),
              cluster_slug: (gsub("/"; "_"))
            })
          }
      '
  exit 0
fi

scripts/detect_changed_clusters.sh "$base_ref" "$head_ref" \
  | jq -R -s '
      split("\n")
      | map(select(length > 0))
      | {
          include: map({
            cluster_dir: .,
            cluster_name: (split("/") | last),
            cluster_slug: (gsub("/"; "_"))
          })
        }
    '
