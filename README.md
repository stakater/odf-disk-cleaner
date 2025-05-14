# ODF disk-cleaner

Python and Shell script packaged as Docker images to clean up disks after an ODF (OpenShift Data Foundation) uninstall.

## Recovering ODF node with OSD and MON pods in CrashLoopBackOff due to improper disk cleanup

An OpenShift Data Foundation (ODF) installation can fail with one or multiple nodes in the cluster failing to enter the `Ready` state. Associated Ceph `osd` and `mon` pods get stuck in `CrashLoopBackOff`. The suspected root cause is improper or incomplete disk cleanup of the node.

### Root cause

Incorrect or incomplete cleanup of local disks causes issues with Ceph OSD/MON pods and node readiness.

### Resolution steps

1. Remove the node from Local Storage Operator
    * Edit the `LocalVolumeDiscovery` and `LocalVolumeSet` CRs to remove the affected node
1. Drain and cordon the node:

    ```bash
    oc adm drain <node-name> --ignore-daemonsets --delete-emptydir-data
    oc adm cordon <node-name>
    ```

1. Remove `PersistentVolumes` by identifying and deleting `PersistentVolume` objects related to the node in `openshift-storage` namespace:

    ```bash
    oc get pv | grep <node-name>
    oc delete pv <pv-name>
    ```

1. Manual disk cleanup on node by running the scripts:
    1. Authenticate against the OpenShift-cluster
    1. Start a debug pod: `oc debug node/<node>`
    1. Change root to host to access all binaries and files: `chroot /host`
    1. Run the script as a container: `podman run ghcr.io/stakater/odf-disk-cleaner:vX.Y.Z --disks "/path/to/disk1 /path/to/disk2 ..."`
1. Reboot the node: `sudo reboot`
1. Re-add node to Local Storage Operator:
    * Revert the PR or update the `LocalVolumeDiscovery` and `LocalVolumeSet` CRs to add the node back
    * This will cause discovery pods to start running again on the node
1. Delete all pods in `openshift-storage` namespace to force recreation: `oc delete pod --all -n openshift-storage`
1. Verify ODF health
    * Check Ceph cluster health: `oc get cephcluster -n openshift-storage`
    * Confirm all pods are running and the node is back in `Ready` state:

        ```bash
        oc get nodes
        oc get pods -n openshift-storage
        ```

### Expected outcome

* Node successfully rejoined the cluster
* All OSD and MON pods are stabilized
* ODF cluster health returned to healthy
