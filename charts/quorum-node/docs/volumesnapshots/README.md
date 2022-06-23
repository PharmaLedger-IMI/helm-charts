# VolumeSnapshot

This helm chart provides the option to create a [VolumeSnapshot](https://kubernetes.io/docs/concepts/storage/volume-snapshots/) before doing an helm upgrade and on deletion of the helm release.

## Cluster prerequisites

1. You need to install an appropriate [CSI Driver](https://kubernetes-csi.github.io/docs/drivers.html) for your Kubernetes distro to make use of VolumeSnapshots. You also may need to install the [external-snapshotter](https://github.com/kubernetes-csi/external-snapshotter), e.g. for AWS EKS.

    - [AWS EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) and [AWS EBS CSI Driver for Volume Snapshots](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/examples/kubernetes/snapshot/README.md)

2. Create `StorageClass` and `VolumeSnapshotClass`; here a sample for [AWS EKS](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/examples/kubernetes/snapshot/README.md#create-snapshot).

## Example

This example demonstrates how to

- auto-create a VolumeSnapshot of the data PVC on a helm upgrade operation.
- auto-create a VolumeSnapshot of the data PVC in case the helm release will be deleted.

In addition to other helm values, set these configuration values:

```yaml
persistence:
  data:
    (...)
    volumeSnapshots:
      preUpgradeEnabled: true
      finalSnapshotEnabled: true
      className: "<Name of the VolumeSnapshotClass>"

```
