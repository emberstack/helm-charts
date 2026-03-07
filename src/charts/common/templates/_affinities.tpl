{{/*
Return a soft node affinity (preferredDuringSchedulingIgnoredDuringExecution).
Usage:
  {{ include "common.affinities.nodes.soft" (dict "key" "kubernetes.io/os" "values" (list "linux")) }}
*/}}
{{- define "common.affinities.nodes.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    preference:
      matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            - {{ . | quote }}
            {{- end }}
{{- end -}}

{{/*
Return a hard node affinity (requiredDuringSchedulingIgnoredDuringExecution).
Usage:
  {{ include "common.affinities.nodes.hard" (dict "key" "kubernetes.io/os" "values" (list "linux")) }}
*/}}
{{- define "common.affinities.nodes.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
    - matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            - {{ . | quote }}
            {{- end }}
{{- end -}}

{{/*
Return a node affinity. Dispatches to soft or hard.
Usage:
  {{ include "common.affinities.nodes" (dict "type" "soft" "key" "kubernetes.io/os" "values" (list "linux")) }}
*/}}
{{- define "common.affinities.nodes" -}}
{{- if eq .type "soft" }}
  {{- include "common.affinities.nodes.soft" . }}
{{- else if eq .type "hard" }}
  {{- include "common.affinities.nodes.hard" . }}
{{- end -}}
{{- end -}}

{{/*
Return the topology key, defaulting to kubernetes.io/hostname.
*/}}
{{- define "common.affinities.topologyKey" -}}
{{- default "kubernetes.io/hostname" .topologyKey -}}
{{- end -}}

{{/*
Return a soft pod anti-affinity (preferredDuringSchedulingIgnoredDuringExecution).
Usage:
  {{ include "common.affinities.pods.soft" (dict "component" "master" "customLabels" .Values.podLabels "topologyKey" "" "context" $) }}
*/}}
{{- define "common.affinities.pods.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    podAffinityTerm:
      topologyKey: {{ include "common.affinities.topologyKey" . }}
      labelSelector:
        matchLabels:
          {{- include "common.labels.matchLabels" (dict "customLabels" .customLabels "context" .context) | nindent 10 }}
          {{- if .component }}
          app.kubernetes.io/component: {{ .component }}
          {{- end }}
{{- end -}}

{{/*
Return a hard pod anti-affinity (requiredDuringSchedulingIgnoredDuringExecution).
Usage:
  {{ include "common.affinities.pods.hard" (dict "component" "master" "customLabels" .Values.podLabels "topologyKey" "" "context" $) }}
*/}}
{{- define "common.affinities.pods.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - topologyKey: {{ include "common.affinities.topologyKey" . }}
    labelSelector:
      matchLabels:
        {{- include "common.labels.matchLabels" (dict "customLabels" .customLabels "context" .context) | nindent 8 }}
        {{- if .component }}
        app.kubernetes.io/component: {{ .component }}
        {{- end }}
{{- end -}}

{{/*
Return a pod affinity. Dispatches to soft or hard.
Usage:
  {{ include "common.affinities.pods" (dict "type" "soft" "component" "" "customLabels" dict "topologyKey" "" "context" $) }}
*/}}
{{- define "common.affinities.pods" -}}
{{- if eq .type "soft" }}
  {{- include "common.affinities.pods.soft" . }}
{{- else if eq .type "hard" }}
  {{- include "common.affinities.pods.hard" . }}
{{- end -}}
{{- end -}}
