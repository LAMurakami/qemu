## QEMU (Quick Emulator) cloud-init repository

This repo is based on the
[Core tutorial with QEMU](https://cloudinit.readthedocs.io/en/latest/tutorial/qemu.html)
document of the cloud-init documentation at https://cloudinit.readthedocs.io

Each branch contains a version of the meta-data, user-data, and vendor-data
files although the vendor-data file is always empty as in the tutorial.

These files are served up by the ad hoc IMDS webserver using Python built-in
webserver.  The IMDS webserver URL is specified in the launch command.

### The user-data file launches a LAM Alaska clone based on an Ubuntu 24.04 image

I was cloned from the master branch for Ubuntu 22.04 on May 2 2024
and probably will be merged back into the master branch after
Ubuntu 24.04 appears in the AWS Quick Launch page as an OS choice
and I have switched the main aws instance to Ubuntu 24.04 Noble Numbat.

The user-data files are patterned after the cloud-init files in the
[aws repo](https://github.com/LAMurakami/aws#readme)
that launch a LAM Alaska clone on an AWS instance.  There are cloud-init files
to launch a LAM Alaska clone on an AWS instance on either x86 or ARM with
Debian 12,
Ubuntu Server 22.04, Amazon Linux 2023 or Amazon Linux 2 as the OS.

I use QEMU with the KVM Hypervisor.Framework to allow the guest to run
directly on the host CPU.  I run the instances on ak19 which has 6 x86 cores
(12 threads) and give it 2 threads (a whole core).  The user-data for the
master branch is for an Ubuntu cloud image as specified in the tutorial.
The fedora, debian, and opensuse branches are for the respective OS.

With 512 MiB of memory specified along with two cores I have a QEMU instance
with similar capabilities as the AWS EC2 t3.nano and t4g.nano type instances.

A second drive with a swap partition is specified in the launch command
along with the drive with the bootable OS image and is used to allow a
512 MiB memory QEMU instance to use fedora dnf.  A separate drive is used
instead of creating a swap file in the root filesystem like on the
AWS LAM cloud-init becasue I am using a cow2 (Copy On Write) image
with the bootable OS.

The user-data has a private resources section that mounts ak20 nfs drives
like the Elastic File System (EFS) I use in AWS LAM cloud-init files.
The mounted filesystems include a backup of the AWS EFS cloud-init
resources which can be used by the QEMU instances.  A fedora system can
use a program compiled on Amazon Linux 2023 and a QEMU Ubuntu 22.04
instance can use a program compiled on an Amazon instance running
Ubuntu 22.04 with the same architecture.

Both the RAW swap drive image and the cow2 OS bootable image files
are on the ak19 SSD drive for better performance.

I use QEMU with a bridge configuraton that allows the instance to
get it's own IP address on the LAN.