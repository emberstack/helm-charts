{{/*
Thin wrappers that delegate to the common library chart.
These exist so that dependent charts can override them.
*/}}

{{- define "generic.name" -}}
{{- include "common.names.name" . -}}
{{- end -}}

{{- define "generic.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "generic.chart" -}}
{{- include "common.names.chart" . -}}
{{- end -}}

{{- define "generic.namespace" -}}
{{- include "common.names.namespace" . -}}
{{- end -}}

{{- define "generic.labels.standard" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{- define "generic.labels.matchLabels" -}}
{{- include "common.labels.matchLabels" . -}}
{{- end -}}

{{/*
Return the service account name. Supports global.serviceAccount override.
Priority: serviceAccount.name > global.serviceAccount.name > generated/default.
*/}}
{{- define "generic.serviceAccountName" -}}
{{- $sa := default dict .Values.serviceAccount -}}
{{- $globalSA := dict }}
{{- if .Values.global }}
  {{- if .Values.global.serviceAccount }}
    {{- $globalSA = .Values.global.serviceAccount }}
  {{- end }}
{{- end }}
{{- if (include "generic.serviceAccount.create" .) }}
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
{{- define "generic.serviceAccount.create" -}}
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
{{- define "generic.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "chart" .Chart) -}}
{{- end -}}

{{/*
Return the image pull policy for the main container.
*/}}
{{- define "generic.imagePullPolicy" -}}
{{- include "common.images.pullPolicy" (dict "image" .Values.image) -}}
{{- end -}}

{{/*
Return merged pod annotations: global.podAnnotations + podAnnotations.
*/}}
{{- define "generic.podAnnotations" -}}
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
{{- define "generic.podLabels" -}}
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
{{- define "generic.extraEnvVars" -}}
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
