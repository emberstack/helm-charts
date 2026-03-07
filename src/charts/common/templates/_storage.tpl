{{/*
Return the storageClass for a PVC.
Cascade: global.storageClass > persistence.storageClass > global.defaultStorageClass.
Setting to "-" yields empty string (use default provisioner).
Usage:
  {{ include "common.storage.class" (dict "persistence" .Values.persistence "global" .Values.global) }}
*/}}
{{- define "common.storage.class" -}}
{{- $storageClass := "" -}}
{{- $global := default dict .global -}}
{{- if $global.storageClass -}}
  {{- $storageClass = $global.storageClass -}}
{{- else if .persistence.storageClass -}}
  {{- $storageClass = .persistence.storageClass -}}
{{- else if $global.defaultStorageClass -}}
  {{- $storageClass = $global.defaultStorageClass -}}
{{- end -}}
{{- if $storageClass -}}
  {{- if eq $storageClass "-" -}}
storageClassName: ""
  {{- else -}}
storageClassName: {{ $storageClass | quote }}
  {{- end -}}
{{- end -}}
{{- end -}}
