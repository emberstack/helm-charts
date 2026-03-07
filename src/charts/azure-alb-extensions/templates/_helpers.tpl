{{- define "azure-alb-extensions.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "azure-alb-extensions.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}
