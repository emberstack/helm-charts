{{/*
Return a resource preset (requests + limits) by t-shirt size.
Not meant for production - use explicit resources instead.
Usage:
  {{ include "common.resources.preset" (dict "type" "small") }}
*/}}
{{- define "common.resources.preset" -}}
{{- $presets := dict
  "nano" (dict
    "requests" (dict "cpu" "100m" "memory" "128Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "150m" "memory" "192Mi" "ephemeral-storage" "2Gi")
  )
  "micro" (dict
    "requests" (dict "cpu" "250m" "memory" "256Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "375m" "memory" "384Mi" "ephemeral-storage" "2Gi")
  )
  "small" (dict
    "requests" (dict "cpu" "500m" "memory" "512Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "750m" "memory" "768Mi" "ephemeral-storage" "2Gi")
  )
  "medium" (dict
    "requests" (dict "cpu" "500m" "memory" "1024Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "750m" "memory" "1536Mi" "ephemeral-storage" "2Gi")
  )
  "large" (dict
    "requests" (dict "cpu" "1.0" "memory" "2048Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "1.5" "memory" "3072Mi" "ephemeral-storage" "2Gi")
  )
  "xlarge" (dict
    "requests" (dict "cpu" "1.0" "memory" "3072Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "3.0" "memory" "6144Mi" "ephemeral-storage" "2Gi")
  )
  "2xlarge" (dict
    "requests" (dict "cpu" "1.0" "memory" "3072Mi" "ephemeral-storage" "50Mi")
    "limits" (dict "cpu" "6.0" "memory" "12288Mi" "ephemeral-storage" "2Gi")
  )
-}}
{{- if hasKey $presets .type -}}
  {{- get $presets .type | toYaml -}}
{{- else -}}
  {{- fail (printf "Unknown resource preset type: %s. Valid types: nano, micro, small, medium, large, xlarge, 2xlarge" .type) -}}
{{- end -}}
{{- end -}}
