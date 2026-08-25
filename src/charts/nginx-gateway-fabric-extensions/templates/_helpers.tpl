{{- define "nginx-gateway-fabric-extensions.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "nginx-gateway-fabric-extensions.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{/*
Render gateway.nginx.org targetRefs list items. Every policy kind uses the same
{group, kind, name} shape, all three required by the CRDs.
Usage:
  {{- include "nginx-gateway-fabric-extensions.targetRefs" (dict "refs" $item.targetRefs "defaultGroup" "gateway.networking.k8s.io" "defaultKind" "HTTPRoute") | trim | nindent 4 }}
*/}}
{{- define "nginx-gateway-fabric-extensions.targetRefs" -}}
{{- $dg := .defaultGroup -}}
{{- $dk := .defaultKind -}}
{{- range .refs }}
- group: {{ .group | default $dg | quote }}
  kind: {{ .kind | default $dk | quote }}
  name: {{ .name | quote }}
{{- end }}
{{- end -}}
