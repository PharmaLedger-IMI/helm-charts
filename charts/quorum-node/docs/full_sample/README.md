# Full sample for Join Network and Update PartnerInfo

This full sample demonstrates how to use

- Network Policies for securing the ingress and egress.
- Auto-Create VolumeSnapshot on helm upgrade/delete
- Create scheduled VolumeSnapshots for regular backing up the PVCs
- Enable [SecComp Profile](https://medium.com/@LachlanEvenson/how-to-enable-kubernetes-container-runtimedefault-seccomp-profile-for-all-workloads-6795624fcbcc) in addition to existing security context setting
- Use AWS Secrets Manager for mounting the secret private node key.
- Expose P2P Service at AWS NLB with static IP address.

## Cluster prerequisites

1. [CSI Driver, provider and IAM solution](./../../../../docs/secrets_store_csi_driver_provider/README.md)
2. You need to install an appropriate [CSI Driver](https://kubernetes-csi.github.io/docs/drivers.html) for your Kubernetes distro to make use of VolumeSnapshots. You also may need to install the [external-snapshotter](https://github.com/kubernetes-csi/external-snapshotter), e.g. for AWS EKS.

    - [AWS EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) and [AWS EBS CSI Driver for Volume Snapshots](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/examples/kubernetes/snapshot/README.md)

3. Create `StorageClass` and `VolumeSnapshotClass`; here a sample for [AWS EKS](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/examples/kubernetes/snapshot/README.md#create-snapshot).

4. Install [snapscheduler](https://backube.github.io/snapscheduler/usage.html)

## Example for AWS

**[Full terraform example](aws.tf)**
