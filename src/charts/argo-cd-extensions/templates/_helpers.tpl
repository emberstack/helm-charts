{{- define "argo-cd-extensions.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "argo-cd-extensions.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}
