{{/*
RabbitMQ chart helpers.

Design notes:
- Thin wrappers delegate to the common library chart for naming, labels, images, and security.
- The init container (rabbitmq-init) prepares config in an emptyDir that gets mounted at /etc/rabbitmq:
    - conf.d/     : RabbitMQ config files (base from ConfigMap + dynamic config appended)
    - enabled_plugins : generated from .Values.plugins (+ LDAP plugin if ldap.enabled)
    - advanced.config : optional Erlang terms config
  The ConfigMap is NOT mounted at conf.d in the main container — the init container copies and
  processes it into the emptyDir so dynamic values (watermarks, TLS, LDAP, etc.) are included.
- The Docker entrypoint (docker-entrypoint.sh) is NOT overridden — it handles .erlang.cookie,
  RABBITMQ_FORCE_BOOT, and other initialization the chart shouldn't duplicate.
- Scheduler tuning uses RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS (+S, +stbt) instead of non-existent
  env vars. Feature flags and queue rebalancing require post-startup CLI commands (use initScripts).
- The graceful shutdown preStop first sleeps (drainDelay) to let endpoint updates propagate,
  then uses stop_app to gracefully leave the cluster, then sleeps (timeout) to keep PID 1
  alive while other nodes update cluster state before Kubernetes sends SIGTERM.
*/}}

{{- define "rabbitmq.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{- define "rabbitmq.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "rabbitmq.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{- define "rabbitmq.namespace" -}}
{{- include "common.names.namespace" . -}}
{{- end -}}

{{- define "rabbitmq.labels.standard" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{- define "rabbitmq.labels.matchLabels" -}}
{{- include "common.labels.matchLabels" . -}}
{{- end -}}

{{- define "rabbitmq.serviceAccountName" -}}
{{- if and .Values.global .Values.global.serviceAccount .Values.global.serviceAccount.name }}
  {{- .Values.global.serviceAccount.name -}}
{{- else if .Values.serviceAccount.name }}
  {{- .Values.serviceAccount.name -}}
{{- else }}
  {{- include "rabbitmq.fullname" . -}}
{{- end }}
{{- end -}}

{{- define "rabbitmq.serviceAccount.create" -}}
{{- if and .Values.global .Values.global.serviceAccount (eq (.Values.global.serviceAccount.create | toString) "false") }}
  {{- false -}}
{{- else }}
  {{- .Values.serviceAccount.create -}}
{{- end }}
{{- end -}}

{{- define "rabbitmq.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) -}}
{{- end -}}

{{- define "rabbitmq.imagePullPolicy" -}}
{{- include "common.images.pullPolicy" (dict "image" .Values.image "global" .Values.global) -}}
{{- end -}}

{{/* ConfigMap name (supports existingConfigMap) */}}
{{- define "rabbitmq.configMapName" -}}
{{- if .Values.config.existingConfigMap -}}
  {{- .Values.config.existingConfigMap -}}
{{- else -}}
  {{- printf "%s-config" (include "rabbitmq.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "rabbitmq.podAnnotations" -}}
{{- $global := default dict .Values.global -}}
{{- $globalPodAnnotations := default dict $global.podAnnotations -}}
{{- $merged := merge (default dict .Values.podAnnotations) $globalPodAnnotations -}}
{{- if $merged }}
{{- include "common.tplvalues.render" (dict "value" $merged "context" $) -}}
{{- end }}
{{- end -}}

{{- define "rabbitmq.podLabels" -}}
{{- $global := default dict .Values.global -}}
{{- $globalPodLabels := default dict $global.podLabels -}}
{{- $merged := merge (default dict .Values.podLabels) $globalPodLabels -}}
{{- if $merged }}
{{- include "common.tplvalues.render" (dict "value" $merged "context" $) -}}
{{- end }}
{{- end -}}

{{- define "rabbitmq.extraEnvVars" -}}
{{- $global := default dict .Values.global -}}
{{- $globalExtraEnvVars := default list $global.extraEnvVars -}}
{{- $merged := concat (default list .Values.extraEnvVars) $globalExtraEnvVars -}}
{{- if $merged }}
{{- include "common.tplvalues.render" (dict "value" $merged "context" $) -}}
{{- end }}
{{- end -}}

{{/* Secret name for RabbitMQ password */}}
{{- define "rabbitmq.secretName" -}}
{{- if .Values.auth.existingSecret -}}
  {{- .Values.auth.existingSecret -}}
{{- else -}}
  {{- include "rabbitmq.fullname" . -}}
{{- end -}}
{{- end -}}

{{/* Secret key for RabbitMQ password */}}
{{- define "rabbitmq.secretPasswordKey" -}}
{{- if .Values.auth.existingSecretPasswordKey -}}
  {{- .Values.auth.existingSecretPasswordKey -}}
{{- else -}}
  {{- "rabbitmq-password" -}}
{{- end -}}
{{- end -}}

{{/* Secret key for RabbitMQ Erlang cookie */}}
{{- define "rabbitmq.secretErlangCookieKey" -}}
{{- if .Values.auth.existingSecretErlangCookieKey -}}
  {{- .Values.auth.existingSecretErlangCookieKey -}}
{{- else -}}
  {{- "rabbitmq-erlang-cookie" -}}
{{- end -}}
{{- end -}}

{{/* Headless service FQDN */}}
{{- define "rabbitmq.headlessSvcFqdn" -}}
{{- printf "%s-headless.%s.svc.%s" (include "rabbitmq.fullname" .) (include "rabbitmq.namespace" .) .Values.clusterDomain -}}
{{- end -}}

{{/* RabbitMQ node name using headless service FQDN.
     Uses $(MY_POD_NAME) — Kubernetes env var substitution syntax — which requires
     MY_POD_NAME to be defined before RABBITMQ_NODENAME in the env array. */}}
{{- define "rabbitmq.nodeName" -}}
{{- printf "rabbit@$(MY_POD_NAME).%s" (include "rabbitmq.headlessSvcFqdn" .) -}}
{{- end -}}

{{/* AMQP port (TLS-aware) */}}
{{- define "rabbitmq.amqpPort" -}}
{{- if .Values.tls.enabled -}}
{{- .Values.tls.port -}}
{{- else -}}
{{- .Values.service.amqpPort -}}
{{- end -}}
{{- end -}}

{{/* Management port (TLS-aware) */}}
{{- define "rabbitmq.managementPort" -}}
{{- if .Values.tls.enabled -}}
{{- .Values.tls.managementPort -}}
{{- else -}}
{{- .Values.service.managementPort -}}
{{- end -}}
{{- end -}}

{{/* Test image */}}
{{- define "rabbitmq.testImage" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.testImage "global" .Values.global) -}}
{{- end -}}

{{/* TLS CLI args for RabbitMQ */}}
{{- define "rabbitmq.tls.cliArgs" -}}
{{- if .Values.tls.enabled }} --ssl --ssl-cert-file /etc/rabbitmq/tls/{{ .Values.tls.certFilename }} --ssl-key-file /etc/rabbitmq/tls/{{ .Values.tls.certKeyFilename }} --ssl-ca-cert-file /etc/rabbitmq/tls/{{ .Values.tls.certCAFilename }}{{- end -}}
{{- end -}}

{{/* Build RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS from scheduler tuning + extraFlags */}}
{{- define "rabbitmq.serverAdditionalErlArgs" -}}
{{- $args := list -}}
{{- if and .Values.maxAvailableSchedulers .Values.onlineSchedulers -}}
  {{- $args = append $args (printf "+S %s:%s" (toString .Values.maxAvailableSchedulers) (toString .Values.onlineSchedulers)) -}}
{{- else if .Values.maxAvailableSchedulers -}}
  {{- $args = append $args (printf "+S %s" (toString .Values.maxAvailableSchedulers)) -}}
{{- end -}}
{{- if .Values.maxAvailableSchedulers -}}
  {{- $args = append $args "+stbt db" -}}
{{- end -}}
{{- if .Values.extraFlags -}}
  {{- $args = append $args .Values.extraFlags -}}
{{- end -}}
{{- join " " $args -}}
{{- end -}}
