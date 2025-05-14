#!/bin/bash
set -euo pipefail

usage () {
  echo "script syntax:    -d       disks to clean, space separated (default: \"\")
                  -f       do a final overall clean (default: \"y\")
                  -h       this help text";
}

options=':d:f:h'
while getopts $options option
do
    case $option in
        d  ) DISKS=$OPTARG;;
        f  ) FINAL_CLEANUP=$OPTARG;;
        h  ) usage; exit;;
        \? ) echo "ERROR: Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "ERROR: Missing argument value for -$OPTARG" >&2; exit 1;;
    esac
done

shift $(($OPTIND - 1))

if [ "${DISKS+set}" != set ]; then
  echo "ERROR: Missing required argument - please provide the disks to clean"
  exit 1
fi

DISKS=${DISKS:-""}
FINAL_CLEANUP=${FINAL_CLEANUP:-"y"}

for DISK in $DISKS; do
  echo "Cleaning $DISK"
  sgdisk --zap-all $DISK
  dd if=/dev/zero of=$DISK bs=1M count=1000
  blkdiscard $DISK
done

if [ "${FINAL_CLEANUP}" == 'y' ]; then
  echo "Final cleanup"
  rm -rf /dev/disk/by-id/*
  rm -rf /mnt/local-storage/
  rm -rf /var/lib/rook
  rm -rf /dev/ceph-*
  rm -rf /dev/mapper/ceph-*
fi
