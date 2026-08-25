{{- define "external-dns-extensions.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "external-dns-extensions.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{/*
Render one external-dns Endpoint body. Shared by DNSEndpoint.spec.endpoints[] and DNSRecord.spec.endpoint,
which use an identical Endpoint schema.
Usage:
  {{- include "external-dns-extensions.endpoint" (dict "endpoint" $e "context" $ "path" "dnsEndpoints[0].endpoints[0]") }}
*/}}
{{- define "external-dns-extensions.endpoint" -}}
{{- $e := .endpoint -}}
{{- $ctx := .context -}}
{{- $path := .path -}}
{{- if not $e.dnsName }}{{- fail (printf "%s: dnsName is required" $path) }}{{- end -}}
{{- if not $e.recordType }}{{- fail (printf "%s: recordType is required" $path) }}{{- end -}}
{{- if not $e.targets }}{{- fail (printf "%s: targets is required" $path) }}{{- end -}}
dnsName: {{ include "common.tplvalues.render" (dict "value" $e.dnsName "context" $ctx) | quote }}
recordType: {{ include "common.tplvalues.render" (dict "value" $e.recordType "context" $ctx) | quote }}
targets:
  {{- include "common.tplvalues.render" (dict "value" $e.targets "context" $ctx) | nindent 2 }}
{{- if $e.recordTTL }}
recordTTL: {{ $e.recordTTL | int64 }}
{{- end }}
{{- with $e.setIdentifier }}
setIdentifier: {{ include "common.tplvalues.render" (dict "value" . "context" $ctx) | quote }}
{{- end }}
{{- with $e.labels }}
labels:
  {{- include "common.tplvalues.render" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with $e.providerSpecific }}
providerSpecific:
  {{- range . }}
  - name: {{ .name | quote }}
    value: {{ .value | quote }}
  {{- end }}
{{- end }}
{{- end -}}
