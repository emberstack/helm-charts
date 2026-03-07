{{/*
Renders a value that may contain template expressions.
Usage:
  {{ include "common.tplvalues.render" (dict "value" .Values.foo "context" $) }}
  {{ include "common.tplvalues.render" (dict "value" .Values.foo "context" $ "scope" .Values.bar) }}
*/}}
{{- define "common.tplvalues.render" -}}
{{- $value := typeIs "string" .value | ternary .value (.value | toYaml) }}
{{- if contains "{{" (toJson .value) }}
  {{- if .scope }}
    {{- tpl (cat "{{- with $.scope -}}" $value "{{- end }}") (merge (dict "scope" .scope) .context) }}
  {{- else }}
    {{- tpl $value .context }}
  {{- end }}
{{- else }}
  {{- $value }}
{{- end }}
{{- end -}}

{{/*
Merge multiple values with template rendering. First-wins semantics (sprig merge).
Usage:
  {{ include "common.tplvalues.merge" (dict "values" (list .Values.a .Values.b) "context" $) }}
*/}}
{{- define "common.tplvalues.merge" -}}
{{- $dst := dict }}
{{- range .values -}}
  {{- $rendered := include "common.tplvalues.render" (dict "value" . "context" $.context "scope" (default nil $.scope)) }}
  {{- $dst = merge $dst (fromYaml $rendered) }}
{{- end -}}
{{ $dst | toYaml }}
{{- end -}}

{{/*
Merge multiple values with template rendering. Last-wins semantics (sprig mergeOverwrite).
Usage:
  {{ include "common.tplvalues.merge-overwrite" (dict "values" (list .Values.a .Values.b) "context" $) }}
*/}}
{{- define "common.tplvalues.merge-overwrite" -}}
{{- $dst := dict }}
{{- range .values -}}
  {{- $rendered := include "common.tplvalues.render" (dict "value" . "context" $.context "scope" (default nil $.scope)) }}
  {{- $dst = mergeOverwrite $dst (fromYaml $rendered) }}
{{- end -}}
{{ $dst | toYaml }}
{{- end -}}
