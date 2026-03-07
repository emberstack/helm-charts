{{/*
Expand the name of the chart.
Usage:
  {{ include "common.names.name" . }}
*/}}
{{- define "common.names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
Usage:
  {{ include "common.names.chart" . }}
*/}}
{{- define "common.names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create a default fully qualified app name.
Truncated at 63 chars (DNS naming spec). Sanitizes release name for DNS compatibility.
Priority: fullnameOverride > release-contains-chart > releaseName-chartName
Usage:
  {{ include "common.names.fullname" . }}
*/}}
{{- define "common.names.fullname" -}}
{{- if .Values.fullnameOverride }}
  {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- $name := default .Chart.Name .Values.nameOverride }}
  {{- $releaseName := .Release.Name | regexReplaceAll "[^a-zA-Z0-9-]" "-" | lower }}
  {{- if contains $name $releaseName }}
    {{- $releaseName | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- printf "%s-%s" $releaseName $name | trunc 63 | trimSuffix "-" }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Create a fullname for a dependency/subchart from the parent chart's perspective.
Usage:
  {{ include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) }}
*/}}
{{- define "common.names.dependency.fullname" -}}
{{- if .chartValues.fullnameOverride }}
  {{- .chartValues.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- $name := default .chartName .chartValues.nameOverride }}
  {{- $releaseName := .context.Release.Name | regexReplaceAll "[^a-zA-Z0-9-]" "-" | lower }}
  {{- if contains $name $releaseName }}
    {{- $releaseName | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- printf "%s-%s" $releaseName $name | trunc 63 | trimSuffix "-" }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Return the namespace. Supports namespaceOverride.
Usage:
  {{ include "common.names.namespace" . }}
*/}}
{{- define "common.names.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return fullname-namespace for cross-namespace uniqueness.
Usage:
  {{ include "common.names.fullname.namespace" . }}
*/}}
{{- define "common.names.fullname.namespace" -}}
{{- printf "%s-%s" (include "common.names.fullname" .) (include "common.names.namespace" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the service account name.
Usage:
  {{ include "common.names.serviceAccountName" . }}
*/}}
{{- define "common.names.serviceAccountName" -}}
{{- $sa := default dict .Values.serviceAccount -}}
{{- if $sa.create }}
  {{- default (include "common.names.fullname" .) $sa.name }}
{{- else }}
  {{- default "default" $sa.name }}
{{- end }}
{{- end -}}

{{/*
Return a per-item fullname for extension-style charts.
Usage:
  {{ include "common.names.item.fullname" (dict "item" $item "context" $) }}
*/}}
{{- define "common.names.item.fullname" -}}
{{- if .item.fullnameOverride }}
  {{- .item.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- printf "%s-%s" (include "common.names.fullname" .context) .item.name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end -}}

{{/*
Return a per-item namespace for extension-style charts.
Usage:
  {{ include "common.names.item.namespace" (dict "item" $item "context" $) }}
*/}}
{{- define "common.names.item.namespace" -}}
{{- default (include "common.names.namespace" .context) .item.namespace | trunc 63 | trimSuffix "-" }}
{{- end -}}
