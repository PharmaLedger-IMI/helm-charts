{{- /*
Template for Configmap. Arguments to be passed are $ . suffix and an dictionary for annotations used for defining helm hooks.
See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "eco.configmap-environment" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
{{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "eco.fullname" . }}-environment{{ $suffix | default "" }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "eco.labels" . | nindent 4 }}
data:
  sponsor-environment.js: |-
    export default {
      appName: 'sponsor-wallet',
      vault: 'server',
      agent: 'browser',
      system: 'any',
      browser: 'any',
      mode: 'dev-secure',
      domain: {{ required "config.domain must be set" .Values.config.domain | quote}},
      didDomain: {{ required "config.domain must be set" .Values.config.domain | quote}},
      vaultDomain: {{ required "config.domain must be set" .Values.config.vaultDomain | quote}},
      enclaveType:"WalletDBEnclave",
      sw: false,
      pwa: false,
      workspace: "eco",
      'legenda for properties':
        ' vault:(server, browser) agent:(mobile,  browser)  system:(iOS, Android, any) browser:(Chrome, Firefox, any) mode:(autologin,dev-autologin, secure, dev-secure) sw:(true, false) pwa:(true, false)',
    }

  hco-environment.js: |-
    export default {
          appName: 'clinical-site-wallet',
          vault: 'server',
          agent: 'browser',
          system: 'any',
          browser: 'any',
          mode: {{ .Values.config.demiurgeMode | quote }},
          didDomain:{{ required "config.domain must be set" .Values.config.domain | quote}},
          domain: {{ required "config.domain must be set" .Values.config.domain | quote}},
          vaultDomain: {{ required "config.domain must be set" .Values.config.vaultDomain | quote}},
          enclaveType:"WalletDBEnclave",
          sw: false,
          pwa: false,
          workspace: "eco",
          'legenda for properties':
            ' vault:(server, browser) agent:(mobile,  browser)  system:(iOS, Android, any) browser:(Chrome, Firefox, any) mode:(autologin,dev-autologin, secure, dev-secure) sw:(true, false) pwa:(true, false)',
    }

  trial-participant-environment.js: |-
    export default {
          appName: 'trial-participant-wallet',
          vault: 'server',
          agent: 'browser',
          system: 'any',
          browser: 'any',
          mode: {{ .Values.config.demiurgeMode | quote }},
          domain: {{ required "config.domain must be set" .Values.config.domain | quote}},
          vaultDomain: {{ required "config.domain must be set" .Values.config.vaultDomain | quote}},
          didDomain: {{ required "config.domain must be set" .Values.config.domain | quote}},
          enclaveType:"WalletDBEnclave",
          sw: false,
          pwa: false,
          workspace: "eco",
          'legenda for properties':
            ' vault:(server, browser) agent:(mobile,  browser)  system:(iOS, Android, any) browser:(Chrome, Firefox, any) mode:(autologin,dev-autologin, secure, dev-secure) sw:(true, false) pwa:(true, false)',
    }

  dsu-explorer-environment.js: |-
    export default {
          "appName": "DSU Explorer",
          "appVersion": "0.1.1",
          "vault": "server",
          "agent": "browser",
          "system":   "any",
          "browser":  "any",
          "mode":  "dev-autologin",
          "domain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
          "sw": true,
          "pwa": false,
          "legenda for properties": " vault:(server, browser) agent:(mobile,  browser)  system:(iOS, Android, any) browser:(Chrome, Firefox, any) stage:(development, release) sw:(true, false) pwa:(true, false)"
    }

{{- end }}
{{- end }}
