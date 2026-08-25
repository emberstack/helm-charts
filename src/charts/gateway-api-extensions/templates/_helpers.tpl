{{- define "gateway-api-extensions.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "gateway-api-extensions.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{/*
Render Gateway API parentRefs list items. Shared by HTTPRoute, GRPCRoute, TLSRoute, TCPRoute and UDPRoute.
Usage:
  {{- include "gateway-api-extensions.parentRefs" (dict "refs" $item.parentRefs) | trim | nindent 4 }}
*/}}
{{- define "gateway-api-extensions.parentRefs" -}}
{{- range .refs }}
- name: {{ .name | quote }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
  {{- end }}
  {{- if .group }}
  group: {{ .group | quote }}
  {{- end }}
  {{- if .kind }}
  kind: {{ .kind | quote }}
  {{- end }}
  {{- if .sectionName }}
  sectionName: {{ .sectionName | quote }}
  {{- end }}
  {{- if .port }}
  port: {{ .port }}
  {{- end }}
{{- end }}
{{- end -}}
