#!/usr/bin/env bash

set -euo pipefail

base_ref="${1:-origin/main}"
head_ref="${2:-HEAD}"

git diff --name-only "$base_ref" "$head_ref" \
  | awk -F/ '/^clusters\// && NF >= 3 {print $1 "/" $2 "/" $3}' \
  | sort -u
