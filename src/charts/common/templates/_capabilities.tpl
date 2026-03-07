{{/*
Return the Kubernetes version. Supports global override for CI/air-gapped environments.
Usage:
  {{ include "common.capabilities.kubeVersion" . }}
*/}}
{{- define "common.capabilities.kubeVersion" -}}
{{- $kubeVersion := .Capabilities.KubeVersion.Version -}}
{{- if .Values.kubeVersion -}}
  {{- $kubeVersion = .Values.kubeVersion -}}
{{- end -}}
{{- if .Values.global -}}
  {{- if .Values.global.kubeVersion -}}
    {{- $kubeVersion = .Values.global.kubeVersion -}}
  {{- end -}}
{{- end -}}
{{- $kubeVersion -}}
{{- end -}}

{{/*
Check if an API version is available. Supports global override.
Usage:
  {{ include "common.capabilities.apiVersions.has" (dict "version" "gateway.networking.k8s.io/v1" "context" $) }}
*/}}
{{- define "common.capabilities.apiVersions.has" -}}
{{- $providedVersions := list -}}
{{- if .context.Values.global -}}
  {{- if .context.Values.global.apiVersions -}}
    {{- $providedVersions = .context.Values.global.apiVersions -}}
  {{- end -}}
{{- end -}}
{{- if not $providedVersions -}}
  {{- if .context.Values.apiVersions -}}
    {{- $providedVersions = .context.Values.apiVersions -}}
  {{- end -}}
{{- end -}}
{{- if $providedVersions -}}
  {{- if has .version $providedVersions -}}
    {{- true -}}
  {{- end -}}
{{- else -}}
  {{- if .context.Capabilities.APIVersions.Has .version -}}
    {{- true -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/* API version constants - centralized for easy updates on deprecations */}}

{{- define "common.capabilities.deployment.apiVersion" -}}apps/v1{{- end -}}
{{- define "common.capabilities.statefulset.apiVersion" -}}apps/v1{{- end -}}
{{- define "common.capabilities.daemonset.apiVersion" -}}apps/v1{{- end -}}
{{- define "common.capabilities.job.apiVersion" -}}batch/v1{{- end -}}
{{- define "common.capabilities.cronjob.apiVersion" -}}batch/v1{{- end -}}
{{- define "common.capabilities.ingress.apiVersion" -}}networking.k8s.io/v1{{- end -}}
{{- define "common.capabilities.networkPolicy.apiVersion" -}}networking.k8s.io/v1{{- end -}}
{{- define "common.capabilities.policy.apiVersion" -}}policy/v1{{- end -}}
{{- define "common.capabilities.rbac.apiVersion" -}}rbac.authorization.k8s.io/v1{{- end -}}
{{- define "common.capabilities.crd.apiVersion" -}}apiextensions.k8s.io/v1{{- end -}}
{{- define "common.capabilities.hpa.apiVersion" -}}autoscaling/v2{{- end -}}
{{- define "common.capabilities.httpRoute.apiVersion" -}}gateway.networking.k8s.io/v1{{- end -}}
