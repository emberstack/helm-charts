{{/*
Thin wrappers that delegate to the common library chart.
These exist so that dependent charts can override them.
*/}}

{{- define "azurite.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{- define "azurite.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "azurite.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{- define "azurite.namespace" -}}
{{- include "common.names.namespace" . -}}
{{- end -}}

{{- define "azurite.labels.standard" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{- define "azurite.labels.matchLabels" -}}
{{- include "common.labels.matchLabels" . -}}
{{- end -}}

{{/*
Return the service account name. Supports global.serviceAccount override.
*/}}
{{- define "azurite.serviceAccountName" -}}
{{- $sa := default dict .Values.serviceAccount -}}
{{- $globalSA := dict }}
{{- if .Values.global }}
  {{- if .Values.global.serviceAccount }}
    {{- $globalSA = .Values.global.serviceAccount }}
  {{- end }}
{{- end }}
{{- if (include "azurite.serviceAccount.create" .) }}
  {{- default (include "common.names.fullname" .) $sa.name }}
{{- else }}
  {{- default (default "default" $globalSA.name) $sa.name }}
{{- end }}
{{- end -}}

{{/*
Return whether to create a ServiceAccount.
*/}}
{{- define "azurite.serviceAccount.create" -}}
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
{{- define "azurite.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "chart" .Chart) -}}
{{- end -}}

{{/*
Return the image pull policy for the main container.
*/}}
{{- define "azurite.imagePullPolicy" -}}
{{- include "common.images.pullPolicy" (dict "image" .Values.image) -}}
{{- end -}}

{{/*
Return merged pod annotations: global.podAnnotations + podAnnotations.
*/}}
{{- define "azurite.podAnnotations" -}}
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
{{- define "azurite.podLabels" -}}
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
*/}}
{{- define "azurite.extraEnvVars" -}}
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
Build the azurite command arguments from configuration.
Data directory is derived from persistence.mountPath.
Hosts are always 0.0.0.0, ports are fixed (10000/10001/10002).
*/}}
{{- define "azurite.args" -}}
{{- $config := default dict .Values.configuration }}
{{- $dataDir := default "/data" .Values.persistence.mountPath }}
{{- $args := list "azurite" }}
{{- $args = append $args "-l" }}
{{- $args = append $args $dataDir }}
{{- if $config.debugLog }}
{{- $args = append $args "-d" }}
{{- $args = append $args $config.debugLog }}
{{- end }}
{{- if $config.blobEnabled }}
{{- $args = append $args "--blobHost" }}
{{- $args = append $args "0.0.0.0" }}
{{- $args = append $args "--blobPort" }}
{{- $args = append $args "10000" }}
{{- end }}
{{- if $config.queueEnabled }}
{{- $args = append $args "--queueHost" }}
{{- $args = append $args "0.0.0.0" }}
{{- $args = append $args "--queuePort" }}
{{- $args = append $args "10001" }}
{{- end }}
{{- if $config.tableEnabled }}
{{- $args = append $args "--tableHost" }}
{{- $args = append $args "0.0.0.0" }}
{{- $args = append $args "--tablePort" }}
{{- $args = append $args "10002" }}
{{- end }}
{{- if $config.loose }}
{{- $args = append $args "--loose" }}
{{- end }}
{{- if $config.disableProductStyleUrl }}
{{- $args = append $args "--disableProductStyleUrl" }}
{{- end }}
{{- if $config.skipApiVersionCheck }}
{{- $args = append $args "--skipApiVersionCheck" }}
{{- end }}
{{- if $config.inMemoryPersistence }}
{{- $args = append $args "--inMemoryPersistence" }}
{{- end }}
{{- if $config.certPath }}
{{- $args = append $args "--cert" }}
{{- $args = append $args $config.certPath }}
{{- end }}
{{- if $config.keyPath }}
{{- $args = append $args "--key" }}
{{- $args = append $args $config.keyPath }}
{{- end }}
{{- if $config.oauth }}
{{- $args = append $args "--oauth" }}
{{- $args = append $args $config.oauth }}
{{- end }}
{{- if $config.silent }}
{{- $args = append $args "--silent" }}
{{- end }}
{{- if $config.disableTelemetry }}
{{- $args = append $args "--disableTelemetry" }}
{{- end }}
{{- if $config.extentMemoryLimit }}
{{- $args = append $args "--extentMemoryLimit" }}
{{- $args = append $args (toString $config.extentMemoryLimit) }}
{{- end }}
{{- if $config.certPassword }}
{{- $args = append $args "--pwd" }}
{{- $args = append $args $config.certPassword }}
{{- end }}
{{- range (default list $config.extraArgs) }}
{{- $args = append $args . }}
{{- end }}
{{- join " " $args }}
{{- end -}}
