{{/*
Expand the name of the chart.
*/}}
{{- define "springboot-app-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "springboot-app-chart.fullname" -}}
{{- if .Values.fullNameOverride }}
{{- .Values.fullNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "springboot-app-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "springboot-app-chart.labels" -}}
helm.sh/chart: {{ include "springboot-app-chart.chart" . }}
{{ include "springboot-app-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "springboot-app-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "springboot-app-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "springboot-app-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "springboot-app-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Vault role: explicit override or <team>-<namespace>.
*/}}
{{- define "onechart.vaultRole" -}}
{{- $vault := .Values.secrets.vault -}}
{{- $vault.role | default (printf "%s-%s" $vault.team .Release.Namespace) -}}
{{- end -}}

{{/*
Vault secret path for one file entry. Engine is inferred from the filename:
  database.properties -> DB dynamic creds at <team>-<namespace>/creds/<team>
  anything else       -> KV v2 at <team>-<namespace>-kv/data/<.Release.Name>
An explicit file.secretPath always wins. Call with:
  (dict "ctx" $ "file" $f)
*/}}
{{- define "onechart.vaultSecretPath" -}}
{{- $vault := .ctx.Values.secrets.vault -}}
{{- $file := .file -}}
{{- if $file.secretPath -}}
{{- $file.secretPath -}}
{{- else if eq $file.name "database.properties" -}}
{{- printf "%s-%s/creds/%s" $vault.team .ctx.Release.Namespace $vault.team -}}
{{- else -}}
{{- printf "%s-%s-kv/data/%s" $vault.team .ctx.Release.Namespace .ctx.Release.Name -}}
{{- end -}}
{{- end -}}

{{/*
Body of the vault-injected template for one file entry. database.properties
emits {{ .Data.<last-token-lower> }} (matches Vault DB engine output); any
other file emits {{ .Data.data.<KEY> }} (matches Vault KV v2 output).
Call with: (dict "ctx" $ "file" $f)
*/}}
{{- define "onechart.vaultSecretTemplate" -}}
{{- $file := .file -}}
{{- $secretPath := include "onechart.vaultSecretPath" (dict "ctx" .ctx "file" $file) -}}
{{ printf "{{- with secret %q }}" $secretPath }}
{{- range $env := $file.keys }}
{{- if eq $file.name "database.properties" }}
{{- $field := $env | splitList "_" | last | lower }}
{{ $env }}={{ printf "{{ .Data.%s }}" $field }}
{{- else }}
{{ $env }}={{ printf "{{ .Data.data.%s }}" $env }}
{{- end }}
{{- end }}
{{ "{{- end }}" }}
{{- end -}}
