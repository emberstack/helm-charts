{{- define "gateway-api-extensions.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "gateway-api-extensions.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}
