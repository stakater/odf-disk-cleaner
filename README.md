# ODF disk-cleaner

Python script packaged as a Docker image to clean up disks after an ODF (OpenShift Data Foundation) uninstall.

## To run the script

1. Authenticate against the OpenShift-cluster
1. Start a debug pod: `oc debug node/<node>`
1. Change root to host to access all binaries and files: `chroot /host`
1. Run the script as a container: `podman run ghcr.io/stakater/odf-disk-cleaner:vX.Y.Z --disks "/path/to/disk1 /path/to/disk2 ..."`
