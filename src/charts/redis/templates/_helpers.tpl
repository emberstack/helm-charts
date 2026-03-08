{{/*
Thin wrappers that delegate to the common library chart.
*/}}

{{- define "redis.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{- define "redis.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "redis.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{- define "redis.namespace" -}}
{{- include "common.names.namespace" . -}}
{{- end -}}

{{- define "redis.labels.standard" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{- define "redis.labels.matchLabels" -}}
{{- include "common.labels.matchLabels" . -}}
{{- end -}}

{{- define "redis.serviceAccountName" -}}
{{- if and .Values.global .Values.global.serviceAccount .Values.global.serviceAccount.name }}
  {{- .Values.global.serviceAccount.name -}}
{{- else if .Values.serviceAccount.name }}
  {{- .Values.serviceAccount.name -}}
{{- else }}
  {{- include "redis.fullname" . -}}
{{- end }}
{{- end -}}

{{- define "redis.serviceAccount.create" -}}
{{- if and .Values.global .Values.global.serviceAccount (eq (.Values.global.serviceAccount.create | toString) "false") }}
  {{- false -}}
{{- else }}
  {{- .Values.serviceAccount.create -}}
{{- end }}
{{- end -}}

{{- define "redis.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) -}}
{{- end -}}

{{- define "redis.imagePullPolicy" -}}
{{- include "common.images.pullPolicy" (dict "image" .Values.image "global" .Values.global) -}}
{{- end -}}

{{- define "redis.sentinel.image" -}}
{{- $sentinelImage := dict "registry" (default .Values.image.registry .Values.sentinel.image.registry) "repository" (default .Values.image.repository .Values.sentinel.image.repository) "tag" (default .Values.image.tag .Values.sentinel.image.tag) "digest" (default .Values.image.digest .Values.sentinel.image.digest) "pullPolicy" (default .Values.image.pullPolicy .Values.sentinel.image.pullPolicy) -}}
{{- include "common.images.image" (dict "imageRoot" $sentinelImage "global" .Values.global) -}}
{{- end -}}

{{- define "redis.metrics.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) -}}
{{- end -}}

{{- define "redis.podAnnotations" -}}
{{- $global := default dict .Values.global -}}
{{- $globalPodAnnotations := default dict $global.podAnnotations -}}
{{- $merged := merge (default dict .Values.podAnnotations) $globalPodAnnotations -}}
{{- if $merged }}
{{- include "common.tplvalues.render" (dict "value" $merged "context" $) -}}
{{- end }}
{{- end -}}

{{- define "redis.podLabels" -}}
{{- $global := default dict .Values.global -}}
{{- $globalPodLabels := default dict $global.podLabels -}}
{{- $merged := merge (default dict .Values.podLabels) $globalPodLabels -}}
{{- if $merged }}
{{- include "common.tplvalues.render" (dict "value" $merged "context" $) -}}
{{- end }}
{{- end -}}

{{- define "redis.extraEnvVars" -}}
{{- $global := default dict .Values.global -}}
{{- $globalExtraEnvVars := default list $global.extraEnvVars -}}
{{- $merged := concat (default list .Values.extraEnvVars) $globalExtraEnvVars -}}
{{- if $merged }}
{{- include "common.tplvalues.render" (dict "value" $merged "context" $) -}}
{{- end }}
{{- end -}}

{{/* Secret name for Redis password */}}
{{- define "redis.secretName" -}}
{{- if .Values.auth.existingSecret -}}
  {{- .Values.auth.existingSecret -}}
{{- else -}}
  {{- include "redis.fullname" . -}}
{{- end -}}
{{- end -}}

{{/* Secret key for Redis password */}}
{{- define "redis.secretKey" -}}
{{- if .Values.auth.existingSecret -}}
  {{- default "redis-password" .Values.auth.existingSecretKey -}}
{{- else -}}
  {{- "redis-password" -}}
{{- end -}}
{{- end -}}

{{/* Headless service FQDN */}}
{{- define "redis.headlessSvcFqdn" -}}
{{- printf "%s-headless.%s.svc.%s" (include "redis.fullname" .) (include "redis.namespace" .) .Values.clusterDomain -}}
{{- end -}}

{{/* Pod FQDN template */}}
{{- define "redis.podFqdn" -}}
{{- printf "${HOSTNAME}.%s" (include "redis.headlessSvcFqdn" .) -}}
{{- end -}}

{{/* Redis port (TLS-aware) */}}
{{- define "redis.port" -}}
{{- if .Values.tls.enabled -}}
{{- .Values.tls.port -}}
{{- else -}}
{{- .Values.service.port -}}
{{- end -}}
{{- end -}}

{{/* Redis loopback address (IPv6-aware) */}}
{{- define "redis.loopback" -}}
{{- if eq .Values.ipFamily "ipv6" -}}::1{{- else -}}127.0.0.1{{- end -}}
{{- end -}}

{{/* TLS args for redis-cli probes */}}
{{- define "redis.tls.cliArgs" -}}
{{- if .Values.tls.enabled }} --tls --cert /etc/redis/tls/{{ .Values.tls.certFilename }} --key /etc/redis/tls/{{ .Values.tls.certKeyFilename }} --cacert /etc/redis/tls/{{ .Values.tls.certCAFilename }}{{- end -}}
{{- end -}}

{{/* Effective replica count based on architecture */}}
{{- define "redis.replicaCount" -}}
{{- if eq .Values.architecture "standalone" -}}
1
{{- else -}}
{{- .Values.replicaCount -}}
{{- end -}}
{{- end -}}
