#!/usr/bin/env python3

import argparse
import json
from pathlib import Path
import re
import sys


REQUIRED_PATHS = [
    ("cluster_name",),
    ("environment",),
    ("gcp_project_id",),
    ("gcp_region",),
    ("infrastructure", "create_gcp_resources"),
    ("network", "base_dns_domain"),
    ("cluster", "details_secret_name"),
    ("gitops", "bootstrap_enabled"),
    ("gitops", "gcp_auth", "mode"),
]

OPENSHIFT_VERSION_PATTERN = re.compile(r"^\d+\.\d+$")
PLACEHOLDER_PATTERNS = (
    re.compile(r"(^|[-_/])changeme($|[-_/])", re.IGNORECASE),
    re.compile(r"example\.com", re.IGNORECASE),
    re.compile(r"your-org", re.IGNORECASE),
    re.compile(r"issuer\.example\.com", re.IGNORECASE),
    re.compile(r"cluster-admin@example\.com", re.IGNORECASE),
)
NONEMPTY_PATHS = [
    ("cluster_name",),
    ("environment",),
    ("gcp_project_id",),
    ("gcp_region",),
    ("network", "base_dns_domain"),
    ("secrets", "pull_secret_secret_project"),
    ("secrets", "git_token_secret_project"),
]


def get_required(data, path):
    current = data
    for key in path:
        if key not in current:
            raise ValueError(f"missing required key: {'.'.join(path)}")
        current = current[key]
    return current


def get_string(data, path):
    value = get_required(data, path)
    if not isinstance(value, str):
        raise ValueError(f"{'.'.join(path)} must be a string")
    if not value.strip():
        raise ValueError(f"{'.'.join(path)} must not be empty")
    for pattern in PLACEHOLDER_PATTERNS:
        if pattern.search(value):
            raise ValueError(f"{'.'.join(path)} contains a placeholder value: {value}")
    return value


def main():
    parser = argparse.ArgumentParser(description="Validate rendered OCP-on-GCP stack config.")
    parser.add_argument("--rendered", required=True, help="Path to rendered effective-config.json")
    args = parser.parse_args()

    rendered_path = Path(args.rendered)
    data = json.loads(rendered_path.read_text(encoding="utf-8"))

    for path in REQUIRED_PATHS:
        get_required(data, path)
    for path in NONEMPTY_PATHS:
        get_string(data, path)

    openshift_version = str(data.get("openshift_version", ""))
    if not OPENSHIFT_VERSION_PATTERN.fullmatch(openshift_version):
        raise ValueError("openshift_version must use x.y format, for example 4.18")

    if data["gitops"]["bootstrap_enabled"]:
        get_string(data, ("gitops", "repository_url"))

    if not data["infrastructure"]["create_gcp_resources"]:
        for key in ["vpc_name", "master_subnet_name", "worker_subnet_name"]:
            value = str(data["network"].get(key, "")).strip()
            if not value:
                raise ValueError(f"network.{key} must be set when infrastructure.create_gcp_resources is false")
            for pattern in PLACEHOLDER_PATTERNS:
                if pattern.search(value):
                    raise ValueError(f"network.{key} contains a placeholder value: {value}")

    psc_enabled = bool(data["cluster"].get("private_service_connect_enabled", False))
    private_cluster = bool(data["cluster"].get("private", False))
    if psc_enabled:
        if not private_cluster:
            raise ValueError("cluster.private must be true when cluster.private_service_connect_enabled is true")
        if data["infrastructure"]["create_gcp_resources"]:
            raise ValueError("infrastructure.create_gcp_resources must be false when cluster.private_service_connect_enabled is true")
        get_string(data, ("network", "psc_subnet_name"))

    if data["acm"]["enabled"] and not data["acm"].get("hub_cluster_secret_name"):
        raise ValueError("acm.hub_cluster_secret_name must be set when acm.enabled is true")

    gitops_auth_mode = data["gitops"]["gcp_auth"]["mode"]
    if gitops_auth_mode not in {"workload_identity_federation", "service_account_key"}:
        raise ValueError("gitops.gcp_auth.mode must be one of: workload_identity_federation, service_account_key")

    if data["gitops"]["bootstrap_enabled"] and len(data["gitops"].get("service_accounts", [])) == 0:
        raise ValueError("gitops.service_accounts must contain at least one binding when gitops.bootstrap_enabled is true")

    print(f"validated {data['cluster_name']} for project {data['gcp_project_id']}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"validation failed: {exc}", file=sys.stderr)
        raise
