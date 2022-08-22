{{- /*
Template for Configmap. Arguments to be passed are $ . suffix and an dictionary for annotations used for defining helm hooks.
See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "fgt.configmap-environment" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
{{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "fgt.fullname" . }}-environment{{ $suffix | default "" }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "fgt.labels" . | nindent 4 }}
data:
  dsu-explorer-environment.js: |-
    export default {
        "appName": "DSU Explorer",
        "appVersion": "0.1.1",
        "vault": "server",
        "agent": "browser",
        "system":   "any",
        "browser":  "any",
        "mode":  "dev-autologin",
        "domain":  "vault",
        "sw": true,
        "pwa": false,
        "legenda for properties": " vault:(server, browser) agent:(mobile,  browser)  system:(iOS, Android, any) browser:(Chrome, Firefox, any) stage:(development, release) sw:(true, false) pwa:(true, false)"
    }

  fgt-mah-wallet-environment.js: |-
    export default {
        "appName": "dashboard",
        "appVersion": "0.1.1",
        "vault": "server",
        "agent": "browser",
        "system": "any",
        "browser": "any",
        "mode": "dev-secure",
        "vaultDomain":  {{ .Values.config.domain | quote }},
        "didDomain":  {{ .Values.config.domain | quote }},
        "domain": {{ .Values.config.domain | quote }},
        "enclaveType":"WalletDBEnclave",
        "sw": true,
        "pwa": true,
        "basePath": "/dashboard",
        "stripBasePathOnInstall": true,
        "theme": "pdm-theme",
        "legenda for properties": " vault:(server, browser) agent:(mobile,  browser)  system:(iOS, Android, any) browser:(Chrome, Firefox, any) mode:(autologin,dev-autologin, secure, dev-secure) sw:(true, false) pwa:(true, false)"
    }

  fgt-pharmacy-wallet-environment.js: |-
    export default {
        "appName": "dashboard",
        "appVersion": "0.1.1",
        "vault": "server",
        "agent": "browser",
        "system": "any",
        "browser": "any",
        "mode": "dev-secure",
        "vaultDomain":  {{ .Values.config.domain | quote }},
        "didDomain":  {{ .Values.config.domain | quote }},
        "domain": {{ .Values.config.domain | quote }},
        "enclaveType":"WalletDBEnclave",
        "sw": true,
        "pwa": true,
        "basePath": "/dashboard",
        "stripBasePathOnInstall": true,
        "theme": "pdm-theme",
        "legenda for properties": " vault:(server, browser) agent:(mobile,  browser)  system:(iOS, Android, any) browser:(Chrome, Firefox, any) mode:(autologin,dev-autologin, secure, dev-secure) sw:(true, false) pwa:(true, false)"
    }

  fgt-wholesaler-wallet-environment.js: |-
    export default {
        "appName": "dashboard",
        "appVersion": "0.1.1",
        "vault": "server",
        "agent": "browser",
        "system": "any",
        "browser": "any",
        "mode": "dev-secure",
        "vaultDomain":  {{ .Values.config.domain | quote }},
        "didDomain":  {{ .Values.config.domain | quote }},
        "domain": {{ .Values.config.domain | quote }},
        "enclaveType":"WalletDBEnclave",
        "sw": true,
        "pwa": true,
        "basePath": "/dashboard",
        "stripBasePathOnInstall": true,
        "theme": "pdm-theme",
        "legenda for properties": " vault:(server, browser) agent:(mobile,  browser)  system:(iOS, Android, any) browser:(Chrome, Firefox, any) mode:(autologin,dev-autologin, secure, dev-secure) sw:(true, false) pwa:(true, false)"
    }

{{- end }}
{{- end }}