{{- define "namespace-onboarding.featureLabels" -}}
{{- $root := .root -}}
{{- $ns := .namespace -}}
{{- $labels := dict -}}
{{- $features := default dict $ns.features -}}
{{- range $featureName, $featureConfig := $root.Values.featureCatalog }}
{{- $tenantFeature := index $features $featureName | default dict -}}
{{- if and (kindIs "map" $tenantFeature) (default false $tenantFeature.enabled) }}
{{- if and $featureConfig.namespaceLabelKey $featureConfig.namespaceLabelValue }}
{{- $_ := set $labels $featureConfig.namespaceLabelKey $featureConfig.namespaceLabelValue -}}
{{- end }}
{{- end }}
{{- end }}
{{- toYaml $labels -}}
{{- end -}}

{{- define "namespace-onboarding.featureAnnotations" -}}
{{- $root := .root -}}
{{- $ns := .namespace -}}
{{- $annotations := dict -}}
{{- $features := default dict $ns.features -}}
{{- range $featureName, $_ := $root.Values.featureCatalog }}
{{- $tenantFeature := index $features $featureName | default dict -}}
{{- if and (kindIs "map" $tenantFeature) (default false $tenantFeature.enabled) }}
{{- $_ := set $annotations (printf "factory.gitops/feature-%s" $featureName) "enabled" -}}
{{- end }}
{{- end }}
{{- toYaml $annotations -}}
{{- end -}}
