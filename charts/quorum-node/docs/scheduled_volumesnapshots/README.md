# Scheduled VolumeSnapshots

It is recommended to do regular backups of your data. This can be achieved by regularly creating a VolumeSnapshot. One option is to use [snapscheduler](https://backube.github.io/snapscheduler/usage.html).

## Cluster prerequisites

1. You need to install an appropriate [CSI Driver](https://kubernetes-csi.github.io/docs/drivers.html) for your Kubernetes distro to make use of VolumeSnapshots. You also may need to install the [external-snapshotter](https://github.com/kubernetes-csi/external-snapshotter), e.g. for AWS EKS.

    - [AWS EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) and [AWS EBS CSI Driver for Volume Snapshots](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/examples/kubernetes/snapshot/README.md)

2. Create `StorageClass` and `VolumeSnapshotClass`; here a sample for [AWS EKS](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/examples/kubernetes/snapshot/README.md#create-snapshot).

3. Install [snapscheduler](https://backube.github.io/snapscheduler/usage.html)

## Example

This example demonstrates how to

- create daily VolumeSnapshots of all PVCs in the namespace and keeping the latest 30 snapshots
- create hourly VolumeSnapshots of all PVCs in the namespace and keeping the latest 24 snapshots

This means, you will have a daily backup for the last 30 days and an hourly backup reaching back 24 hours.

In addition to other helm values, set these configuration values:

```yaml
extraResources:
- |
  apiVersion: snapscheduler.backube/v1
  kind: SnapshotSchedule
  metadata:
    name: daily
    namespace: ${var.namespace}
  spec:
    retention:
      maxCount: 30
    schedule: 30 0 * * *

- |
  apiVersion: snapscheduler.backube/v1
  kind: SnapshotSchedule
  metadata:
    name: hourly
    namespace: ${var.namespace}
  spec:
    retention:
      maxCount: 24
    schedule: 15 * * * *

```
