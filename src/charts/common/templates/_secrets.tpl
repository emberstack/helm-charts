{{/*
Resolve a secret name. Uses existingSecret if provided, otherwise builds from fullname + suffix.
Usage:
  {{ include "common.secrets.name" (dict "existingSecret" .Values.auth.existingSecret "defaultNameSuffix" "credentials" "context" $) }}
*/}}
{{- define "common.secrets.name" -}}
{{- if .existingSecret -}}
  {{- if kindIs "map" .existingSecret -}}
    {{- default (printf "%s-%s" (include "common.names.fullname" .context) (default "" .defaultNameSuffix)) .existingSecret.name -}}
  {{- else -}}
    {{- .existingSecret -}}
  {{- end -}}
{{- else -}}
  {{- if .defaultNameSuffix -}}
    {{- printf "%s-%s" (include "common.names.fullname" .context) .defaultNameSuffix -}}
  {{- else -}}
    {{- include "common.names.fullname" .context -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Resolve a secret key. Supports keyMapping for remapping key names.
Usage:
  {{ include "common.secrets.key" (dict "existingSecret" .Values.auth.existingSecret "key" "password") }}
*/}}
{{- define "common.secrets.key" -}}
{{- if .existingSecret -}}
  {{- if kindIs "map" .existingSecret -}}
    {{- if .existingSecret.keyMapping -}}
      {{- default .key (get .existingSecret.keyMapping .key) -}}
    {{- else -}}
      {{- .key -}}
    {{- end -}}
  {{- else -}}
    {{- .key -}}
  {{- end -}}
{{- else -}}
  {{- .key -}}
{{- end -}}
{{- end -}}

{{/*
Lookup an existing secret value. Returns base64-encoded value if found, otherwise base64-encodes defaultValue.
Usage:
  {{ include "common.secrets.lookup" (dict "secret" "my-secret" "key" "password" "defaultValue" (randAlphaNum 10) "context" $) }}
*/}}
{{- define "common.secrets.lookup" -}}
{{- $namespace := include "common.names.namespace" .context -}}
{{- $secretObj := (lookup "v1" "Secret" $namespace .secret) -}}
{{- if $secretObj -}}
  {{- if hasKey $secretObj.data .key -}}
    {{- index $secretObj.data .key -}}
  {{- else -}}
    {{- .defaultValue | b64enc -}}
  {{- end -}}
{{- else -}}
  {{- .defaultValue | b64enc -}}
{{- end -}}
{{- end -}}

{{/*
Check if a secret exists. Returns "true" if found.
Usage:
  {{ if eq (include "common.secrets.exists" (dict "secret" "my-secret" "context" $)) "true" }}
*/}}
{{- define "common.secrets.exists" -}}
{{- $namespace := include "common.names.namespace" .context -}}
{{- $secretObj := (lookup "v1" "Secret" $namespace .secret) -}}
{{- if $secretObj -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Manage a secret value: lookup existing, check provided values, or generate random.
Returns base64-encoded value.
Usage:
  {{ include "common.secrets.manage" (dict "secret" "my-secret" "key" "password" "providedValues" (list "auth.password") "length" 16 "strong" true "context" $) }}
*/}}
{{- define "common.secrets.manage" -}}
{{- $namespace := include "common.names.namespace" .context -}}
{{- $secretObj := (lookup "v1" "Secret" $namespace .secret) -}}
{{- $length := int (default 10 .length) -}}
{{- $strong := default false .strong -}}

{{/* Priority 1: existing secret value */}}
{{- if $secretObj -}}
  {{- if hasKey $secretObj.data .key -}}
    {{- index $secretObj.data .key -}}
  {{- else -}}
    {{/* Key not in existing secret - fall through */}}
    {{- $providedValue := "" -}}
    {{- range $valueKey := (default (list) .providedValues) -}}
      {{- if not $providedValue -}}
        {{- $providedValue = include "common.utils.getValueFromKey" (dict "key" $valueKey "context" $.context) -}}
      {{- end -}}
    {{- end -}}
    {{- if $providedValue -}}
      {{- $providedValue | b64enc -}}
    {{- else if $strong -}}
      {{- randAlpha $length | b64enc -}}
    {{- else -}}
      {{- randAlphaNum $length | b64enc -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{/* Priority 2: provided values */}}
  {{- $providedValue := "" -}}
  {{- range $valueKey := (default (list) .providedValues) -}}
    {{- if not $providedValue -}}
      {{- $providedValue = include "common.utils.getValueFromKey" (dict "key" $valueKey "context" $.context) -}}
    {{- end -}}
  {{- end -}}
  {{- if $providedValue -}}
    {{- $providedValue | b64enc -}}
  {{/* Priority 3: random generation */}}
  {{- else if $strong -}}
    {{- randAlpha $length | b64enc -}}
  {{- else -}}
    {{- randAlphaNum $length | b64enc -}}
  {{- end -}}
{{- end -}}
{{- end -}}
