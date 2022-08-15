# CHANGELOG

- From 0.3.x to 0.4.x - Defaults to use epi v1.3.1
  - Removed Seedsbackup (required for epi <= 1.2.0)
  - `values.yaml` has significant and breaking changes
  - Increased security by design: Run as non-root user, do not allow privilegeEscalation, remove all capabilites from container
  - Sensitive configuration data is stored in Kubernetes Secret instead of ConfigMaps.
  - Support for secret injection via *CSI Secrets Driver* instead of using Kubernetes Secret.
  - Option to use an existing PersistentVolumeClaim instead of creating a new one.

- From 0.2.x to 0.3.x - Default values for epi v1.2.0
  - For use with epi v1.1.2 or earlier, see comments at `config.apihub` in [values.yaml](values.yaml).
  - For SSO, see comments at `config.apihub`, `config.demiurgeMode` and `config.dsuFabricMode` in [values.yaml](values.yaml).

- From 0.1.x to 0.2.x - Technical release: Significant changes! Please uninstall old versions first! Upgrade from 0.1.x not tested and not guaranteed!
  - Uses Helm hooks for Init and Cleanup
  - Optimized Build process: SeedsBackup will only be created if the underlying Container image has changed, e.g. in case of an upgrade!
  - Readiness probe implemented. Application container is considered as *ready* after build process has been finished.
  - Value `config.ethadapterUrl` has changed from `https://ethadapter.my-company.com:3000` to `http://ethadapter.ethadapter:3000` in order to reflect changes in [ethadapter](https://github.com/PharmaLedger-IMI/helmchart-ethadapter/tree/epi-improve-build/charts/ethadapter).
  - Value `persistence.storageClassName` has changed from `gp2` to empty string `""` in order to remove pre-defined setting for AWS and to be cloud-agnostic by default.
  - Configurable sleep time between start of apihub and build process (`config.sleepTime`).
  - Configuration options for PersistentVolumeClaim
  - Configuration has been prepared for running as non-root user (commented out yet, see [values.yaml `podSecurityContext` and `securityContext`](./values.yaml)).
  - Minor optimizations at Kubernetes resources, e.g. set sizeLimit of temporary shared volume, explictly set readOnly flags at volumeMounts.
