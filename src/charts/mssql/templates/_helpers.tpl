{{/*
Thin wrappers that delegate to the common library chart.
These exist so that dependent charts can override them.
*/}}

{{- define "mssql.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{- define "mssql.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "mssql.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{- define "mssql.namespace" -}}
{{- include "common.names.namespace" . -}}
{{- end -}}

{{- define "mssql.labels.standard" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{- define "mssql.labels.matchLabels" -}}
{{- include "common.labels.matchLabels" . -}}
{{- end -}}

{{/*
Return the service account name. Supports global.serviceAccount override.
Priority: serviceAccount.name > global.serviceAccount.name > generated/default.
*/}}
{{- define "mssql.serviceAccountName" -}}
{{- $sa := default dict .Values.serviceAccount -}}
{{- $globalSA := dict }}
{{- if .Values.global }}
  {{- if .Values.global.serviceAccount }}
    {{- $globalSA = .Values.global.serviceAccount }}
  {{- end }}
{{- end }}
{{- if (include "mssql.serviceAccount.create" .) }}
  {{- default (include "common.names.fullname" .) $sa.name }}
{{- else }}
  {{- default (default "default" $globalSA.name) $sa.name }}
{{- end }}
{{- end -}}

{{/*
Return whether to create a ServiceAccount.
If global.serviceAccount.create is explicitly false, suppress creation.
Per-chart serviceAccount.create is the baseline (default true).
*/}}
{{- define "mssql.serviceAccount.create" -}}
{{- $sa := default dict .Values.serviceAccount -}}
{{- $create := true }}
{{- if hasKey $sa "create" }}
  {{- $create = $sa.create }}
{{- end }}
{{- if .Values.global }}
  {{- if .Values.global.serviceAccount }}
    {{- if hasKey .Values.global.serviceAccount "create" }}
      {{- if not .Values.global.serviceAccount.create }}
        {{- $create = false }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- if $create }}true{{- end }}
{{- end -}}

{{/*
Return the image string for the main container.
*/}}
{{- define "mssql.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "chart" .Chart) -}}
{{- end -}}

{{/*
Return the image pull policy for the main container.
*/}}
{{- define "mssql.imagePullPolicy" -}}
{{- include "common.images.pullPolicy" (dict "image" .Values.image) -}}
{{- end -}}

{{/*
Return merged pod annotations: global.podAnnotations + podAnnotations.
*/}}
{{- define "mssql.podAnnotations" -}}
{{- $globalPodAnnotations := dict }}
{{- if .Values.global }}
  {{- if .Values.global.podAnnotations }}
    {{- $globalPodAnnotations = .Values.global.podAnnotations }}
  {{- end }}
{{- end }}
{{- $merged := merge (default dict .Values.podAnnotations) $globalPodAnnotations }}
{{- if $merged }}
  {{- include "common.tplvalues.render" (dict "value" $merged "context" .) }}
{{- end }}
{{- end -}}

{{/*
Return merged pod labels: global.podLabels + podLabels.
*/}}
{{- define "mssql.podLabels" -}}
{{- $globalPodLabels := dict }}
{{- if .Values.global }}
  {{- if .Values.global.podLabels }}
    {{- $globalPodLabels = .Values.global.podLabels }}
  {{- end }}
{{- end }}
{{- $merged := merge (default dict .Values.podLabels) $globalPodLabels }}
{{- if $merged }}
  {{- include "common.tplvalues.render" (dict "value" $merged "context" .) }}
{{- end }}
{{- end -}}

{{/*
Return merged env vars: global.extraEnvVars + extraEnvVars.
Global env vars come first, per-chart env vars can override by appearing later.
*/}}
{{- define "mssql.extraEnvVars" -}}
{{- $envVars := list }}
{{- if .Values.global }}
  {{- if .Values.global.extraEnvVars }}
    {{- $envVars = .Values.global.extraEnvVars }}
  {{- end }}
{{- end }}
{{- if .Values.extraEnvVars }}
  {{- $envVars = concat $envVars .Values.extraEnvVars }}
{{- end }}
{{- if $envVars }}
  {{- include "common.tplvalues.render" (dict "value" $envVars "context" .) }}
{{- end }}
{{- end -}}

{{/*
Return the SA password secret name.
*/}}
{{- define "mssql.secretName" -}}
{{- $config := default dict .Values.configuration -}}
{{- if $config.existingSecret -}}
  {{- $config.existingSecret -}}
{{- else -}}
  {{- include "mssql.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Return the SA password secret key.
*/}}
{{- define "mssql.secretKey" -}}
{{- $config := default dict .Values.configuration -}}
{{- if $config.existingSecret -}}
  {{- default "saPassword" $config.existingSecretKey -}}
{{- else -}}
  sa-password
{{- end -}}
{{- end -}}

{{/*
Render MSSQL env vars from configuration.
*/}}
{{- define "mssql.envVars" -}}
{{- $config := default dict .Values.configuration }}
- name: ACCEPT_EULA
  value: {{ ternary "Y" "N" (default false $config.acceptEula) | quote }}
- name: MSSQL_PID
  value: {{ default "Developer" $config.edition | quote }}
- name: MSSQL_SA_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "mssql.secretName" . }}
      key: {{ include "mssql.secretKey" . }}
{{- if $config.collation }}
- name: MSSQL_COLLATION
  value: {{ $config.collation | quote }}
{{- end }}
{{- if $config.lcid }}
- name: MSSQL_LCID
  value: {{ $config.lcid | toString | quote }}
{{- end }}
{{- if $config.memoryLimitMb }}
- name: MSSQL_MEMORY_LIMIT_MB
  value: {{ $config.memoryLimitMb | toString | quote }}
{{- end }}
{{- if $config.tcpPort }}
- name: MSSQL_TCP_PORT
  value: {{ $config.tcpPort | toString | quote }}
{{- end }}
{{- if $config.agentEnabled }}
- name: MSSQL_AGENT_ENABLED
  value: "true"
{{- end }}
{{- if $config.hadrEnabled }}
- name: MSSQL_ENABLE_HADR
  value: "1"
{{- end }}
{{- if $config.dataDir }}
- name: MSSQL_DATA_DIR
  value: {{ $config.dataDir | quote }}
{{- end }}
{{- if $config.logDir }}
- name: MSSQL_LOG_DIR
  value: {{ $config.logDir | quote }}
{{- end }}
{{- if $config.backupDir }}
- name: MSSQL_BACKUP_DIR
  value: {{ $config.backupDir | quote }}
{{- end }}
{{- if $config.dumpDir }}
- name: MSSQL_DUMP_DIR
  value: {{ $config.dumpDir | quote }}
{{- end }}
{{- end -}}
