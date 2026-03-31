#!/usr/bin/env python3

import argparse
import json
from pathlib import Path
import sys

import yaml


REQUIRED_CLUSTER_KEYS = [
    "cluster_name",
    "class_name",
    "gcp_region",
    "gcp_project_id",
    "gcp_default_zone",
    "network",
    "infrastructure",
    "cluster",
    "identity",
    "secrets",
    "gitops",
]


def deep_merge(base, override):
    if isinstance(base, dict) and isinstance(override, dict):
        merged = dict(base)
        for key, value in override.items():
            if key in merged:
                merged[key] = deep_merge(merged[key], value)
            else:
                merged[key] = value
        return merged
    return override


def load_yaml(path):
    with open(path, "r", encoding="utf-8") as handle:
        return yaml.safe_load(handle) or {}


def cluster_layout_parts(cluster_path):
    try:
      clusters_index = cluster_path.parts.index("clusters")
    except ValueError as exc:
      raise ValueError(f"{cluster_path} must live under the clusters/ directory") from exc

    relative_parts = cluster_path.parts[clusters_index + 1 :]
    if len(relative_parts) < 2:
      raise ValueError("cluster files must use the layout clusters/<group-path>/<cluster-name>/")

    return relative_parts


def validate_cluster(cluster):
    missing = [key for key in REQUIRED_CLUSTER_KEYS if key not in cluster]
    if missing:
        raise ValueError(f"missing required cluster keys: {', '.join(missing)}")

    network = cluster["network"]
    infrastructure = cluster["infrastructure"]
    cluster_cfg = cluster["cluster"]

    required_network = [
        "vpc_cidr_block",
        "base_dns_domain",
        "base_dns_zone_project",
        "availability_zones",
    ]
    missing_network = [key for key in required_network if key not in network]
    if missing_network:
        raise ValueError(f"missing required network keys: {', '.join(missing_network)}")

    required_infra = ["create_gcp_resources", "vpc_routing_mode"]
    missing_infra = [key for key in required_infra if key not in infrastructure]
    if missing_infra:
        raise ValueError(f"missing required infrastructure keys: {', '.join(missing_infra)}")

    required_cluster = ["private", "machine_type", "worker_node_replicas", "pod_cidr", "service_cidr"]
    missing_cluster = [key for key in required_cluster if key not in cluster_cfg]
    if missing_cluster:
        raise ValueError(f"missing required cluster keys: {', '.join(missing_cluster)}")


def main():
    parser = argparse.ArgumentParser(description="Render effective OCP-on-GCP stack config.")
    parser.add_argument("--cluster", required=True, help="Path to cluster.yaml")
    parser.add_argument("--gitops", required=True, help="Path to gitops.yaml")
    parser.add_argument("--catalog-root", default="catalog/cluster-classes", help="Path to cluster class catalog")
    parser.add_argument("--output-dir", required=True, help="Directory for generated artifacts")
    args = parser.parse_args()

    cluster_path = Path(args.cluster)
    gitops_path = Path(args.gitops)
    catalog_root = Path(args.catalog_root)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    cluster = load_yaml(cluster_path)
    validate_cluster(cluster)
    cluster_parts = cluster_layout_parts(cluster_path.parent)

    if cluster["cluster_name"] != cluster_parts[-1]:
        raise ValueError(
            f"cluster_name '{cluster['cluster_name']}' must match the cluster directory name '{cluster_parts[-1]}'"
        )

    class_path = catalog_root / f"{cluster['class_name']}.yaml"
    if not class_path.exists():
        raise FileNotFoundError(f"cluster class not found: {class_path}")

    cluster_class = load_yaml(class_path)
    gitops = load_yaml(gitops_path)

    effective = deep_merge(cluster_class, cluster)
    effective["gitops"] = deep_merge(effective.get("gitops", {}), gitops)
    effective["cluster_layout"] = {
        "group_path": "/".join(cluster_parts[:-1]),
        "cluster_directory_name": cluster_parts[-1],
    }
    effective["source"] = {
        "cluster_file": str(cluster_path),
        "class_file": str(class_path),
        "gitops_file": str(gitops_path),
    }

    build_metadata = {
        "cluster_name": effective["cluster_name"],
        "class_name": effective["class_name"],
        "environment": effective.get("environment"),
        "group_path": effective["cluster_layout"]["group_path"],
        "gcp_project": effective["gcp_project_id"],
        "gcp_region": effective["gcp_region"],
        "openshift_version": effective.get("openshift_version"),
    }

    with open(output_dir / "effective-config.json", "w", encoding="utf-8") as handle:
        json.dump(effective, handle, indent=2, sort_keys=True)
        handle.write("\n")

    with open(output_dir / "build-metadata.json", "w", encoding="utf-8") as handle:
        json.dump(build_metadata, handle, indent=2, sort_keys=True)
        handle.write("\n")

    with open(output_dir / "terraform.auto.tfvars.json", "w", encoding="utf-8") as handle:
        json.dump({"stack": effective}, handle, indent=2, sort_keys=True)
        handle.write("\n")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"render failed: {exc}", file=sys.stderr)
        raise
