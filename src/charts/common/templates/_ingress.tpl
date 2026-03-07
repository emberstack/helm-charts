{{/*
Render an ingress backend for networking.k8s.io/v1.
Handles both string (port name) and numeric (port number) service ports.
Usage:
  {{ include "common.ingress.backend" (dict "serviceName" $fullName "servicePort" $svcPort "context" $) }}
*/}}
{{- define "common.ingress.backend" -}}
service:
  name: {{ .serviceName }}
  port:
    {{- if typeIs "string" .servicePort }}
    name: {{ .servicePort }}
    {{- else }}
    number: {{ .servicePort | int }}
    {{- end }}
{{- end -}}

{{/*
Check if ingress annotations indicate cert-manager TLS is configured.
Returns "true" if cert-manager annotations are present.
Usage:
  {{ if eq (include "common.ingress.certManagerRequest" (dict "annotations" .Values.ingress.annotations)) "true" }}
*/}}
{{- define "common.ingress.certManagerRequest" -}}
{{- if .annotations -}}
  {{- if or (hasKey .annotations "cert-manager.io/cluster-issuer") (hasKey .annotations "cert-manager.io/issuer") (hasKey .annotations "kubernetes.io/tls-acme") -}}
    {{- true -}}
  {{- end -}}
{{- end -}}
{{- end -}}
