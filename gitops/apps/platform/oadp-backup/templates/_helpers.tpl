{{/*
Expand the name of the chart.fullname
*/}}
{{- define "oadp-backup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "oadp-backup.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "oadp-backup.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
GitOps Labels
*/}}
{{- define "oadp-backup.gitopsLabels" -}}
app.kubernetes.io/part-of: oadp-oadp-backup-restore
argocd.argoproj.io/managed-by: openshift-gitops
{{- end }}

{{/*
Common labels
*/}}
{{- define "oadp-backup.labels" -}}
helm.sh/chart: {{ include "oadp-backup.chart" . }}
{{ include "oadp-backup.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "oadp-backup.selectorLabels" -}}
app.kubernetes.io/name: {{ include "oadp-backup.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "oadp-backup.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "oadp-backup.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "oadp-backup.namespace" }}
{{- .Release.Namespace | trunc 63 | trimSuffix "-" }}
{{- end }}
