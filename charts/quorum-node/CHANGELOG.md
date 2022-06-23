# CHANGELOG

- From 0.4.x to 0.5.x
  - Support for creating VolumeSnapshot before upgrade and on deletion.

- From 0.4.3 to 0.4.4
  - Upload of config data to Git repo has been removed

- From 0.3.x to 0.4.x
  - Consolidation of ConfigMaps to one ConfigMap for settings and one for scripts.
  - Storing account-key (on new network only) and node (private) key in Kubernetes Secret instead of storing in ConfigMap
  - Security: Run as non root user with readonly filesystem by default
  - Reacts to config changes and restart quorum node [https://helm.sh/docs/howto/charts_tips_and_tricks/#automatically-roll-deployments](https://helm.sh/docs/howto/charts_tips_and_tricks/#automatically-roll-deployments)
  - Follows standard Helm naming conventions (e.g. use `fullnameOverride` to set fix names) and removed function "quorum-node.Identifier"
  - Some minor fixes
