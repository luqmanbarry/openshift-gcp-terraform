#!/usr/bin/env bash

set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "usage: $0 <tool> [tool ...]" >&2
  exit 2
fi

missing=()

for tool in "$@"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    missing+=("$tool")
    continue
  fi

  version_output="$("$tool" --version 2>/dev/null || "$tool" version 2>/dev/null || "$tool" -v 2>/dev/null || true)"
  first_line="$(printf '%s\n' "$version_output" | sed -n '1p')"
  if [[ -n "$first_line" ]]; then
    echo "$tool: $first_line"
  else
    echo "$tool: found"
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  printf 'missing required CI tools: %s\n' "${missing[*]}" >&2
  exit 1
fi
