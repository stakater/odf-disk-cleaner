#!/usr/bin/python
"""
Script to cleanup disks after an ODF uninstall
"""

import argparse
import subprocess

ap = argparse.ArgumentParser()
ap.add_argument("--disks",
                default="",
                required=True,
                help='disks to clean, space separated (default: %(default)s)')
ap.add_argument("--final_clean",
                default="y",
                required=False,
                choices=['y', 'n'],
                help='do a final overall clean (default: %(default)s)')
args = ap.parse_args()


def run_command(command):
    result = subprocess.run(command,
                            capture_output=True,
                            check=True,
                            text=True,
                            shell=True)
    print(result.stdout)


def clean_disk(disk):
    print("Cleaning disk:", disk)
    run_command("/usr/sbin/sgdisk --zap-all " + disk)
    run_command("dd if=/dev/zero of=" + disk + " bs=1M count=1000")
    run_command("blkdiscard " + disk)


def final_cleaning():
    print("Final cleaning starting")
    run_command("rm -rf /dev/disk/by-id/*")
    run_command("rm -rf /mnt/local-storage/")
    run_command("rm -rf /var/lib/rook")
    run_command("rm -rf /dev/ceph-*")
    run_command("rm -rf /dev/mapper/ceph-*")


if __name__ == "__main__":
    try:
        for disk in args.disks.split(' '):
            clean_disk(disk)
        if args.final_clean == "y":
            final_cleaning()
    except Exception as e:
        print("An error occurred: ", str(e))
