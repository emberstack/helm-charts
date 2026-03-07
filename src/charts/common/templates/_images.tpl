{{/*
Return the proper Docker image name.
Supports global.image.registry, global.image.tag override, digest, and tag fallback to chart appVersion.
Usage:
  {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "chart" .Chart) }}
*/}}
{{- define "common.images.image" -}}
{{- $registryName := .imageRoot.registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $separator := ":" -}}
{{- $termination := .imageRoot.tag | default "" | toString -}}
{{- if .global }}
  {{- if .global.image }}
    {{- if .global.image.registry }}
      {{- $registryName = .global.image.registry -}}
    {{- end -}}
    {{- if .global.image.tag }}
      {{- $termination = .global.image.tag | toString -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- if .imageRoot.digest }}
  {{- $separator = "@" -}}
  {{- $termination = .imageRoot.digest | toString -}}
{{- else if not $termination }}
  {{- if .chart }}
    {{- $termination = .chart.AppVersion | toString -}}
  {{- end -}}
{{- end -}}
{{- if $registryName }}
  {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
{{- else -}}
  {{- printf "%s%s%s" $repositoryName $separator $termination -}}
{{- end -}}
{{- end -}}

{{/*
Return the image pull policy. Supports legacy imagePullPolicy alias.
Usage:
  {{ include "common.images.pullPolicy" (dict "image" .Values.image) }}
*/}}
{{- define "common.images.pullPolicy" -}}
{{- .image.imagePullPolicy | default .image.pullPolicy | default "IfNotPresent" -}}
{{- end -}}

{{/*
Return the image pull secrets. Merges global + per-image + chart-level secrets.
Supports both string and {name: x} formats. Deduplicates. Renders template expressions.
Usage:
  {{ include "common.images.renderPullSecrets" (dict "images" (list .Values.image) "context" $) }}
*/}}
{{- define "common.images.renderPullSecrets" -}}
{{- $pullSecrets := list }}
{{- $context := .context }}

{{- if $context.Values.global }}
  {{- if $context.Values.global.image }}
    {{- range $context.Values.global.image.pullSecrets }}
      {{- if kindIs "map" . }}
        {{- $pullSecrets = append $pullSecrets .name }}
      {{- else }}
        {{- $pullSecrets = append $pullSecrets . }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{- range .images }}
  {{- range .pullSecrets }}
    {{- if kindIs "map" . }}
      {{- $pullSecrets = append $pullSecrets .name }}
    {{- else }}
      {{- $pullSecrets = append $pullSecrets . }}
    {{- end }}
  {{- end }}
{{- end }}

{{- $pullSecrets = $pullSecrets | uniq }}
{{- if $pullSecrets }}
imagePullSecrets:
  {{- range $pullSecrets }}
  - name: {{ include "common.tplvalues.render" (dict "value" . "context" $context) }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Extract semver version from image tag. Falls back to chart appVersion.
Usage:
  {{ include "common.images.version" (dict "imageRoot" .Values.image "chart" .Chart) }}
*/}}
{{- define "common.images.version" -}}
{{- $tag := .imageRoot.tag | default "" -}}
{{- if regexMatch `^[0-9]+\.[0-9]+\.[0-9]+` $tag -}}
  {{- regexFind `^[0-9]+\.[0-9]+\.[0-9]+` $tag -}}
{{- else if .chart -}}
  {{- .chart.AppVersion | toString -}}
{{- end -}}
{{- end -}}
