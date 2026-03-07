{{- define "cert-manager-extensions.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "cert-manager-extensions.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}
