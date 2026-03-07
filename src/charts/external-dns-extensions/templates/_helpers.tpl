{{- define "external-dns-extensions.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "external-dns-extensions.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}
