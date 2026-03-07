{{- define "core-extensions.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "core-extensions.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}
