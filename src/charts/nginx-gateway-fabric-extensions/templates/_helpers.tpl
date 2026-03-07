{{- define "nginx-gateway-fabric-extensions.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "nginx-gateway-fabric-extensions.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}
