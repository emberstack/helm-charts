{{/*
Fail if a required value is empty/nil.
Usage:
  {{ include "common.validation.required" (dict "value" .Values.foo "field" "foo" "chart" "my-chart") }}
*/}}
{{- define "common.validation.required" -}}
{{- if not .value -}}
  {{- fail (printf "%s: %s is required" .chart .field) -}}
{{- end -}}
{{- end -}}

{{/*
Walk .Values by a dot-separated key path and return the value.
Usage:
  {{ include "common.utils.getValueFromKey" (dict "key" "auth.password" "context" $) }}
*/}}
{{- define "common.utils.getValueFromKey" -}}
{{- $splitKey := splitList "." .key -}}
{{- $value := "" -}}
{{- $latestObj := $.context.Values -}}
{{- range $splitKey -}}
  {{- if not $latestObj -}}
    {{- printf "ERROR: key %q not found" $.key | fail -}}
  {{- else if kindIs "map" $latestObj -}}
    {{- $value = (get $latestObj .) | default "" -}}
    {{- $latestObj = $value -}}
  {{- end -}}
{{- end -}}
{{- $value | printf "%v" -}}
{{- end -}}

{{/*
Return the last key from a list whose value is non-empty in .Values. Falls back to the first key.
Usage:
  {{ include "common.utils.getKeyFromList" (dict "keys" (list "auth.password" "password") "context" $) }}
*/}}
{{- define "common.utils.getKeyFromList" -}}
{{- $result := first .keys -}}
{{- range .keys -}}
  {{- $val := include "common.utils.getValueFromKey" (dict "key" . "context" $.context) -}}
  {{- if $val -}}
    {{- $result = . -}}
  {{- end -}}
{{- end -}}
{{- $result -}}
{{- end -}}

{{/*
Generate a SHA256 checksum of a template's rendered output (excluding metadata).
For use in pod annotations to trigger rolling updates on config changes.
Usage:
  checksum/config: {{ include "common.utils.checksumTemplate" (dict "path" "/configmap.yaml" "context" $) }}
*/}}
{{- define "common.utils.checksumTemplate" -}}
{{- $rendered := include (print .context.Template.BasePath .path) .context -}}
{{- $rendered | sha256sum -}}
{{- end -}}

{{/*
Render annotations block only if annotations dict is non-empty.
Supports template expressions in annotation values.
Usage:
  {{- include "common.annotations.render" (dict "annotations" .Values.commonAnnotations "context" $) | nindent 2 }}
*/}}
{{- define "common.annotations.render" -}}
{{- if .annotations }}
annotations:
  {{- include "common.tplvalues.render" (dict "value" .annotations "context" .context) | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Check if an extension-chart item is enabled. Returns "true" if item.enabled is true.
Usage:
  {{- if eq (include "common.item.enabled" (dict "item" $item)) "true" }}
*/}}
{{- define "common.item.enabled" -}}
{{- if .item.enabled -}}
  {{- true -}}
{{- end -}}
{{- end -}}
