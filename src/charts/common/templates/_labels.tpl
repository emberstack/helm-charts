{{/*
Standard Kubernetes labels.
Usage:
  {{ include "common.labels.standard" (dict "customLabels" .Values.commonLabels "context" $) }}
  {{ include "common.labels.standard" . }}
*/}}
{{- define "common.labels.standard" -}}
{{- $context := default . .context -}}
{{- $customLabels := default dict .customLabels -}}
{{- $defaultLabels := dict
  "helm.sh/chart" (include "common.names.chart" $context)
  "app.kubernetes.io/managed-by" $context.Release.Service
-}}
{{- if $context.Chart.AppVersion }}
  {{- $_ := set $defaultLabels "app.kubernetes.io/version" $context.Chart.AppVersion }}
{{- end }}
{{- $selectorLabels := include "common.labels.matchLabels" (dict "customLabels" $customLabels "context" $context) | fromYaml }}
{{- $renderedCustomLabels := dict }}
{{- if $customLabels }}
  {{- $renderedCustomLabels = include "common.tplvalues.render" (dict "value" $customLabels "context" $context) | fromYaml | default dict }}
{{- end }}
{{- $labels := merge $renderedCustomLabels $selectorLabels $defaultLabels }}
{{- $labels | toYaml }}
{{- end -}}

{{/*
Selector/match labels. Only app.kubernetes.io/name and app.kubernetes.io/instance.
Safely picks only those two keys from customLabels to prevent breaking immutable selectors.
Usage:
  {{ include "common.labels.matchLabels" (dict "customLabels" .Values.podLabels "context" $) }}
  {{ include "common.labels.matchLabels" . }}
*/}}
{{- define "common.labels.matchLabels" -}}
{{- $context := default . .context -}}
{{- $customLabels := default dict .customLabels -}}
{{- $defaultLabels := dict
  "app.kubernetes.io/name" (include "common.names.name" $context)
  "app.kubernetes.io/instance" $context.Release.Name
-}}
{{- $renderedCustom := dict }}
{{- if $customLabels }}
  {{- $renderedCustom = include "common.tplvalues.render" (dict "value" $customLabels "context" $context) | fromYaml | default dict }}
{{- end }}
{{- $overrides := pick $renderedCustom "app.kubernetes.io/name" "app.kubernetes.io/instance" }}
{{- merge $overrides $defaultLabels | toYaml }}
{{- end -}}

{{/*
Labels for extension-style chart items. Merges standard labels with per-item labels.
Usage:
  {{ include "common.labels.item" (dict "item" $item "customLabels" .Values.commonLabels "context" $) }}
*/}}
{{- define "common.labels.item" -}}
{{- $standardLabels := include "common.labels.standard" (dict "customLabels" .customLabels "context" .context) | fromYaml }}
{{- $itemLabels := default dict .item.labels }}
{{- merge $itemLabels $standardLabels | toYaml }}
{{- end -}}
