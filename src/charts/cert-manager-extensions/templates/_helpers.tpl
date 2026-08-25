{{- define "cert-manager-extensions.fullname" -}}
{{- include "common.names.fullname" . -}}
{{- end -}}

{{- define "cert-manager-extensions.labels" -}}
{{- include "common.labels.standard" . -}}
{{- end -}}

{{/*
Render the shared cert-manager IssuerSpec body (identical for Issuer and ClusterIssuer).
Usage:
  {{- include "cert-manager-extensions.issuerSpec" (dict "item" $item "context" $ "privateKeySecretRefName" $privateKeySecretRefName) }}
*/}}
{{- define "cert-manager-extensions.issuerSpec" -}}
{{- $item := .item -}}
{{- $ctx := .context -}}
{{- $pkName := .privateKeySecretRefName -}}
  {{- if $item.acme }}
  acme:
    {{- if $item.acme.email }}
    email: {{ $item.acme.email | quote }}
    {{- end }}
    {{- if $item.acme.profile }}
    # Profile allows requesting a certificate profile from the ACME server
    # Supported profiles are listed by the server's ACME directory URL
    profile: {{ $item.acme.profile | quote }}
    {{- end }}
    server: {{ $item.acme.server | default "https://acme-v02.api.letsencrypt.org/directory" | quote }}
    {{- if $item.acme.caBundle }}
    # Base64-encoded bundle of PEM CAs to validate the ACME server certificate
    caBundle: {{ $item.acme.caBundle | quote }}
    {{- end }}
    {{- if hasKey $item.acme "skipTLSVerify" }}
    # INSECURE: Skip TLS certificate validation
    skipTLSVerify: {{ $item.acme.skipTLSVerify }}
    {{- end }}
    {{- if $item.acme.preferredChain }}
    # Preferred certificate chain (e.g., "ISRG Root X1" for Let's Encrypt)
    preferredChain: {{ $item.acme.preferredChain | quote }}
    {{- end }}
    {{- if hasKey $item.acme "disableAccountKeyGeneration" }}
    # Disable automatic ACME account key generation
    disableAccountKeyGeneration: {{ $item.acme.disableAccountKeyGeneration }}
    {{- end }}
    {{- if hasKey $item.acme "enableDurationFeature" }}
    # Request Not After date matching certificate duration
    enableDurationFeature: {{ $item.acme.enableDurationFeature }}
    {{- end }}
    {{- if $item.acme.externalAccountBinding }}
    # External Account Binding for ACME servers that require it
    externalAccountBinding:
      {{- if and $item.acme.externalAccountBinding.keyID $item.acme.externalAccountBinding.keySecretRef }}
      keyID: {{ $item.acme.externalAccountBinding.keyID | quote }}
      keySecretRef:
        {{- if $item.acme.externalAccountBinding.keySecretRef.name }}
        name: {{ $item.acme.externalAccountBinding.keySecretRef.name | quote }}
        {{- else }}
        {{- fail "externalAccountBinding.keySecretRef.name is required" }}
        {{- end }}
        {{- if $item.acme.externalAccountBinding.keySecretRef.key }}
        key: {{ $item.acme.externalAccountBinding.keySecretRef.key | quote }}
        {{- end }}
      {{- else }}
      {{- fail "externalAccountBinding requires both keyID and keySecretRef" }}
      {{- end }}
      {{- if $item.acme.externalAccountBinding.keyAlgorithm }}
      keyAlgorithm: {{ $item.acme.externalAccountBinding.keyAlgorithm | quote }}
      {{- end }}
    {{- end }}
    privateKeySecretRef:
      name: {{ if $item.acme.privateKeySecretRef }}{{ $item.acme.privateKeySecretRef.name | default $pkName | quote }}{{ else }}{{ $pkName | quote }}{{ end }}
      {{- if and $item.acme.privateKeySecretRef $item.acme.privateKeySecretRef.key }}
      key: {{ $item.acme.privateKeySecretRef.key | quote }}
      {{- end }}
    {{- if $item.acme.solvers }}
    solvers:
      {{- include "common.tplvalues.render" (dict "value" $item.acme.solvers "context" $ctx) | nindent 6 }}
    {{- end }}
  {{- end }}
  {{- if $item.ca }}
  ca:
    {{- if $item.ca.secretName }}
    secretName: {{ $item.ca.secretName | quote }}
    {{- else }}
    {{- fail "ca.secretName is required when CA issuer is configured" }}
    {{- end }}
    {{- if $item.ca.ocspServers }}
    # OCSP server URLs for revocation checking
    ocspServers:
      {{- $item.ca.ocspServers | toYaml | nindent 6 }}
    {{- end }}
    {{- if $item.ca.issuingCertificateURLs }}
    # URLs to embed in certificates (e.g., http://ca.domain.com/ca.crt)
    issuingCertificateURLs:
      {{- $item.ca.issuingCertificateURLs | toYaml | nindent 6 }}
    {{- end }}
    {{- if $item.ca.crlDistributionPoints }}
    crlDistributionPoints:
      {{- $item.ca.crlDistributionPoints | toYaml | nindent 6 }}
    {{- end }}
  {{- end }}
  {{- if hasKey $item "selfSigned" }}
  {{- $selfSigned := default dict $item.selfSigned }}
  {{- if $selfSigned.crlDistributionPoints }}
  selfSigned:
    crlDistributionPoints:
      {{- $selfSigned.crlDistributionPoints | toYaml | nindent 6 }}
  {{- else }}
  selfSigned: {}
  {{- end }}
  {{- end }}
  {{- if $item.vault }}
  vault:
    {{- if $item.vault.server }}
    server: {{ $item.vault.server | quote }}
    {{- else }}
    {{- fail "vault.server is required when vault is configured" }}
    {{- end }}
    {{- if $item.vault.path }}
    path: {{ $item.vault.path | quote }}
    {{- else }}
    {{- fail "vault.path is required when vault is configured" }}
    {{- end }}
    {{- if $item.vault.namespace }}
    # Vault Enterprise namespace
    namespace: {{ $item.vault.namespace | quote }}
    {{- end }}
    {{- if $item.vault.serverName }}
    # TLS SNI override
    serverName: {{ $item.vault.serverName | quote }}
    {{- end }}
    {{- if $item.vault.caBundle }}
    # Base64-encoded PEM CAs for validating Vault's certificate
    caBundle: {{ $item.vault.caBundle | quote }}
    {{- end }}
    {{- if $item.vault.caBundleSecretRef }}
    # Reference to Secret with PEM CAs for validating Vault's certificate
    caBundleSecretRef:
      {{- if $item.vault.caBundleSecretRef.name }}
      name: {{ $item.vault.caBundleSecretRef.name | quote }}
      {{- else }}
      {{- fail "vault.caBundleSecretRef.name is required when caBundleSecretRef is configured" }}
      {{- end }}
      {{- if $item.vault.caBundleSecretRef.key }}
      key: {{ $item.vault.caBundleSecretRef.key | quote }}
      {{- end }}
    {{- end }}
    {{- if $item.vault.clientCertSecretRef }}
    # Client certificate for mTLS
    clientCertSecretRef:
      {{- if $item.vault.clientCertSecretRef.name }}
      name: {{ $item.vault.clientCertSecretRef.name | quote }}
      {{- else }}
      {{- fail "vault.clientCertSecretRef.name is required when clientCertSecretRef is configured" }}
      {{- end }}
      {{- if $item.vault.clientCertSecretRef.key }}
      key: {{ $item.vault.clientCertSecretRef.key | quote }}
      {{- end }}
    {{- end }}
    {{- if $item.vault.clientKeySecretRef }}
    # Client key for mTLS
    clientKeySecretRef:
      {{- if $item.vault.clientKeySecretRef.name }}
      name: {{ $item.vault.clientKeySecretRef.name | quote }}
      {{- else }}
      {{- fail "vault.clientKeySecretRef.name is required when clientKeySecretRef is configured" }}
      {{- end }}
      {{- if $item.vault.clientKeySecretRef.key }}
      key: {{ $item.vault.clientKeySecretRef.key | quote }}
      {{- end }}
    {{- end }}
    {{- if $item.vault.auth }}
    auth:
      {{- if $item.vault.auth.tokenSecretRef }}
      tokenSecretRef:
        {{- if $item.vault.auth.tokenSecretRef.name }}
        name: {{ $item.vault.auth.tokenSecretRef.name | quote }}
        {{- else }}
        {{- fail "vault.auth.tokenSecretRef.name is required" }}
        {{- end }}
        {{- if $item.vault.auth.tokenSecretRef.key }}
        key: {{ $item.vault.auth.tokenSecretRef.key | quote }}
        {{- end }}
      {{- end }}
      {{- if $item.vault.auth.appRole }}
      appRole:
        {{- if and $item.vault.auth.appRole.path $item.vault.auth.appRole.roleId $item.vault.auth.appRole.secretRef }}
        path: {{ $item.vault.auth.appRole.path | quote }}
        roleId: {{ $item.vault.auth.appRole.roleId | quote }}
        secretRef:
          {{- if $item.vault.auth.appRole.secretRef.name }}
          name: {{ $item.vault.auth.appRole.secretRef.name | quote }}
          {{- else }}
          {{- fail "vault.auth.appRole.secretRef.name is required" }}
          {{- end }}
          {{- if $item.vault.auth.appRole.secretRef.key }}
          key: {{ $item.vault.auth.appRole.secretRef.key | quote }}
          {{- end }}
        {{- else }}
        {{- fail "vault.auth.appRole requires path, roleId, and secretRef" }}
        {{- end }}
      {{- end }}
      {{- if $item.vault.auth.kubernetes }}
      kubernetes:
        {{- if $item.vault.auth.kubernetes.role }}
        role: {{ $item.vault.auth.kubernetes.role | quote }}
        {{- else }}
        {{- fail "vault.auth.kubernetes.role is required" }}
        {{- end }}
        {{- if $item.vault.auth.kubernetes.secretRef }}
        secretRef:
          {{- if $item.vault.auth.kubernetes.secretRef.name }}
          name: {{ $item.vault.auth.kubernetes.secretRef.name | quote }}
          {{- else }}
          {{- fail "vault.auth.kubernetes.secretRef.name is required" }}
          {{- end }}
          {{- if $item.vault.auth.kubernetes.secretRef.key }}
          key: {{ $item.vault.auth.kubernetes.secretRef.key | quote }}
          {{- end }}
        {{- end }}
        {{- if $item.vault.auth.kubernetes.serviceAccountRef }}
        # Service account for projected tokens (alternative to secretRef)
        serviceAccountRef:
          {{- if $item.vault.auth.kubernetes.serviceAccountRef.name }}
          name: {{ $item.vault.auth.kubernetes.serviceAccountRef.name | quote }}
          {{- else }}
          {{- fail "vault.auth.kubernetes.serviceAccountRef.name is required" }}
          {{- end }}
          {{- if $item.vault.auth.kubernetes.serviceAccountRef.audiences }}
          audiences:
            {{- toYaml $item.vault.auth.kubernetes.serviceAccountRef.audiences | nindent 12 }}
          {{- end }}
        {{- end }}
        {{- if $item.vault.auth.kubernetes.mountPath }}
        mountPath: {{ $item.vault.auth.kubernetes.mountPath | quote }}
        {{- end }}
      {{- end }}
      {{- if $item.vault.auth.aws }}
      # AWS IAM authentication (cert-manager >= 1.21)
      aws:
        {{- if $item.vault.auth.aws.role }}
        role: {{ $item.vault.auth.aws.role | quote }}
        {{- else }}
        {{- fail "vault.auth.aws.role is required" }}
        {{- end }}
        {{- if $item.vault.auth.aws.region }}
        region: {{ $item.vault.auth.aws.region | quote }}
        {{- end }}
        {{- if $item.vault.auth.aws.iamRoleArn }}
        iamRoleArn: {{ $item.vault.auth.aws.iamRoleArn | quote }}
        {{- end }}
        {{- if $item.vault.auth.aws.mountPath }}
        mountPath: {{ $item.vault.auth.aws.mountPath | quote }}
        {{- end }}
        {{- if $item.vault.auth.aws.vaultHeaderValue }}
        vaultHeaderValue: {{ $item.vault.auth.aws.vaultHeaderValue | quote }}
        {{- end }}
        {{- if $item.vault.auth.aws.serviceAccountRef }}
        serviceAccountRef:
          {{- if $item.vault.auth.aws.serviceAccountRef.name }}
          name: {{ $item.vault.auth.aws.serviceAccountRef.name | quote }}
          {{- else }}
          {{- fail "vault.auth.aws.serviceAccountRef.name is required" }}
          {{- end }}
          {{- if $item.vault.auth.aws.serviceAccountRef.audiences }}
          audiences:
            {{- toYaml $item.vault.auth.aws.serviceAccountRef.audiences | nindent 12 }}
          {{- end }}
        {{- end }}
      {{- end }}
      {{- if $item.vault.auth.clientCertificate }}
      # TLS client certificate authentication
      clientCertificate:
        {{- if $item.vault.auth.clientCertificate.secretName }}
        secretName: {{ $item.vault.auth.clientCertificate.secretName | quote }}
        {{- end }}
        {{- if $item.vault.auth.clientCertificate.name }}
        name: {{ $item.vault.auth.clientCertificate.name | quote }}
        {{- end }}
        {{- if $item.vault.auth.clientCertificate.mountPath }}
        mountPath: {{ $item.vault.auth.clientCertificate.mountPath | quote }}
        {{- end }}
      {{- end }}
    {{- else }}
    {{- fail "vault.auth is required when vault is configured" }}
    {{- end }}
  {{- end }}
  {{- if $item.venafi }}
  venafi:
    {{- if $item.venafi.zone }}
    zone: {{ $item.venafi.zone | quote }}
    {{- else }}
    {{- fail "venafi.zone is required when venafi is configured" }}
    {{- end }}
    {{- if $item.venafi.tpp }}
    tpp:
      {{- if $item.venafi.tpp.url }}
      url: {{ $item.venafi.tpp.url | quote }}
      {{- else }}
      {{- fail "venafi.tpp.url is required when tpp is configured" }}
      {{- end }}
      {{- if $item.venafi.tpp.caBundle }}
      # Base64-encoded PEM CA bundle used to validate the TPP server certificate
      caBundle: {{ $item.venafi.tpp.caBundle | quote }}
      {{- end }}
      {{- if $item.venafi.tpp.caBundleSecretRef }}
      caBundleSecretRef:
        {{- if $item.venafi.tpp.caBundleSecretRef.name }}
        name: {{ $item.venafi.tpp.caBundleSecretRef.name | quote }}
        {{- else }}
        {{- fail "venafi.tpp.caBundleSecretRef.name is required" }}
        {{- end }}
        {{- if $item.venafi.tpp.caBundleSecretRef.key }}
        key: {{ $item.venafi.tpp.caBundleSecretRef.key | quote }}
        {{- end }}
      {{- end }}
      {{- if $item.venafi.tpp.credentialsRef }}
      credentialsRef:
        {{- if $item.venafi.tpp.credentialsRef.name }}
        name: {{ $item.venafi.tpp.credentialsRef.name | quote }}
        {{- else }}
        {{- fail "venafi.tpp.credentialsRef.name is required" }}
        {{- end }}
        {{- if $item.venafi.tpp.credentialsRef.key }}
        key: {{ $item.venafi.tpp.credentialsRef.key | quote }}
        {{- end }}
      {{- else }}
      {{- fail "venafi.tpp.credentialsRef is required" }}
      {{- end }}
    {{- end }}
    {{- if $item.venafi.cloud }}
    cloud:
      {{- if $item.venafi.cloud.url }}
      url: {{ $item.venafi.cloud.url | quote }}
      {{- end }}
      {{- if $item.venafi.cloud.apiTokenSecretRef }}
      apiTokenSecretRef:
        {{- if $item.venafi.cloud.apiTokenSecretRef.name }}
        name: {{ $item.venafi.cloud.apiTokenSecretRef.name | quote }}
        {{- else }}
        {{- fail "venafi.cloud.apiTokenSecretRef.name is required" }}
        {{- end }}
        {{- if $item.venafi.cloud.apiTokenSecretRef.key }}
        key: {{ $item.venafi.cloud.apiTokenSecretRef.key | quote }}
        {{- end }}
      {{- else }}
      {{- fail "venafi.cloud.apiTokenSecretRef is required" }}
      {{- end }}
    {{- end }}
    {{- if $item.venafi.ngts }}
    # Venafi Next-Gen Trust Services (cert-manager >= 1.21)
    ngts:
      {{- if $item.venafi.ngts.tsgID }}
      tsgID: {{ $item.venafi.ngts.tsgID | quote }}
      {{- else }}
      {{- fail "venafi.ngts.tsgID is required when ngts is configured" }}
      {{- end }}
      {{- if $item.venafi.ngts.credentialsRef }}
      credentialsRef:
        {{- if $item.venafi.ngts.credentialsRef.name }}
        name: {{ $item.venafi.ngts.credentialsRef.name | quote }}
        {{- else }}
        {{- fail "venafi.ngts.credentialsRef.name is required" }}
        {{- end }}
      {{- else }}
      {{- fail "venafi.ngts.credentialsRef is required when ngts is configured" }}
      {{- end }}
      {{- if $item.venafi.ngts.url }}
      url: {{ $item.venafi.ngts.url | quote }}
      {{- end }}
      {{- if $item.venafi.ngts.tokenEndpoint }}
      tokenEndpoint: {{ $item.venafi.ngts.tokenEndpoint | quote }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
