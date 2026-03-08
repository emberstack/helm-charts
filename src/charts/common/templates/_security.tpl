{{/*
Detect OpenShift. Returns "true" if detected.
Detection: global force/disabled config, then API group auto-detection.
Usage:
  {{ include "common.security.isOpenshift" . }}
*/}}
{{- define "common.security.isOpenshift" -}}
{{- $adaptSC := "" -}}
{{- if .Values.global }}
  {{- if .Values.global.compatibility }}
    {{- if .Values.global.compatibility.openshift }}
      {{- $adaptSC = .Values.global.compatibility.openshift.adaptSecurityContext | default "" }}
    {{- end }}
  {{- end }}
{{- end }}
{{- if eq $adaptSC "force" -}}
  {{- true -}}
{{- else if eq $adaptSC "disabled" -}}
  {{/* disabled - not openshift */ -}}
{{- else -}}
  {{- if or (.Capabilities.APIVersions.Has "security.openshift.io/v1") (.Capabilities.APIVersions.Has "route.openshift.io/v1") -}}
    {{- true -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Render pod security context. On OpenShift, omits fsGroup, runAsUser, runAsGroup, empty seLinuxOptions.
Always strips the "enabled" key (used as a toggle, not a Kubernetes field).
If enabled is explicitly false, returns empty (no security context rendered).
Usage:
  {{ include "common.security.renderPodSecurityContext" (dict "secContext" .Values.podSecurityContext "context" $) }}
*/}}
{{- define "common.security.renderPodSecurityContext" -}}
{{- if .secContext -}}
  {{- if and (hasKey .secContext "enabled") (not .secContext.enabled) -}}
    {{/* enabled: false — skip rendering */ -}}
  {{- else -}}
  {{- $sc := omit .secContext "enabled" -}}
  {{- if include "common.security.isOpenshift" .context -}}
    {{- $sc = omit $sc "fsGroup" "runAsUser" "runAsGroup" -}}
    {{- if and (hasKey $sc "seLinuxOptions") (empty (get $sc "seLinuxOptions")) -}}
      {{- $sc = omit $sc "seLinuxOptions" -}}
    {{- end -}}
    {{- if and (hasKey $sc "privileged") (get $sc "privileged") -}}
      {{- $sc = omit $sc "capabilities" -}}
    {{- end -}}
  {{- else -}}
    {{- $omitEmpty := false -}}
    {{- if .context.Values.global }}
      {{- if .context.Values.global.compatibility }}
        {{- $omitEmpty = .context.Values.global.compatibility.omitEmptySeLinuxOptions | default false }}
      {{- end }}
    {{- end }}
    {{- if $omitEmpty -}}
      {{- if and (hasKey $sc "seLinuxOptions") (empty (get $sc "seLinuxOptions")) -}}
        {{- $sc = omit $sc "seLinuxOptions" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $sc }}
    {{- $sc | toYaml }}
  {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Render container security context. On OpenShift, omits runAsUser, runAsGroup, empty seLinuxOptions.
Does NOT omit fsGroup (pod-level only). Always strips the "enabled" key.
If enabled is explicitly false, returns empty (no security context rendered).
Usage:
  {{ include "common.security.renderContainerSecurityContext" (dict "secContext" .Values.containerSecurityContext "context" $) }}
*/}}
{{- define "common.security.renderContainerSecurityContext" -}}
{{- if .secContext -}}
  {{- if and (hasKey .secContext "enabled") (not .secContext.enabled) -}}
    {{/* enabled: false — skip rendering */ -}}
  {{- else -}}
  {{- $sc := omit .secContext "enabled" -}}
  {{- if include "common.security.isOpenshift" .context -}}
    {{- $sc = omit $sc "runAsUser" "runAsGroup" -}}
    {{- if and (hasKey $sc "seLinuxOptions") (empty (get $sc "seLinuxOptions")) -}}
      {{- $sc = omit $sc "seLinuxOptions" -}}
    {{- end -}}
    {{- if and (hasKey $sc "privileged") (get $sc "privileged") -}}
      {{- $sc = omit $sc "capabilities" -}}
    {{- end -}}
  {{- else -}}
    {{- $omitEmpty := false -}}
    {{- if .context.Values.global }}
      {{- if .context.Values.global.compatibility }}
        {{- $omitEmpty = .context.Values.global.compatibility.omitEmptySeLinuxOptions | default false }}
      {{- end }}
    {{- end }}
    {{- if $omitEmpty -}}
      {{- if and (hasKey $sc "seLinuxOptions") (empty (get $sc "seLinuxOptions")) -}}
        {{- $sc = omit $sc "seLinuxOptions" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $sc }}
    {{- $sc | toYaml }}
  {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}
