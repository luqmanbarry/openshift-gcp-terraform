# factory-stack

Top-level composition module for a single OCP-on-GCP cluster.

Inputs come from the rendered `stack` object produced by `scripts/render_effective_config.py`.

The structure intentionally mirrors the ROSA factory pattern:

- `stack` is the primary contract
- provider-specific behavior is derived from `stack` locals inside the module
- child wrappers adapt `stack` into the legacy implementation modules
