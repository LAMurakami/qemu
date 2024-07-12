## QEMU (Quick Emulator) cloud-init repository

This repo is based on the
[Core tutorial with QEMU](https://cloudinit.readthedocs.io/en/latest/tutorial/qemu.html)
document of the cloud-init documentation at https://cloudinit.readthedocs.io

Each branch contains a version of the meta-data, user-data, and vendor-data
files although the vendor-data file is always empty as in the tutorial.

These files are served up by the ad hoc IMDS webserver using Python built-in
webserver.  The IMDS webserver URL is specified in the launch command.

### This branch is not intended to be merged into the master branch

This QEMU (Quick Emulator) repository branch is for the Fedora OS and is not intended to me merged into the master branch for Ubuntu.

In Git, a branch is a new/separate version of the main repository.

GitHub and git in general assume you want to merge any other branches with the main or master branch of the repository at some point.  There are a lot of strategies for use of git branching for feature development and release or hotfix management with some also using git tags.  They generally try to make naming an intuitive part of the change flow control.

[Git considers itself a Distributed Version Control System](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control) which is better than both Centralized version control and Local Version Control.  It considers every change a version and branches and commits are all part of this approach to version control.

This allows a great amount of flexibility including this branch for this purpose.

### The user-data files launch a LAM Alaska clone

The user-data files are patterned after the cloud-init files in the
[aws repo](https://github.com/LAMurakami/aws#readme)
that launch a LAM Alaska clone on an AWS instance.  There are cloud-init files
to launch a LAM Alaska clone on an AWS instance on either x86 or ARM with
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

### The fedora-packages branch uses packages:

The fedora-packages branch was created from the fedora branch to reintroduce
packages: package_update: and package_upgrade: cloud-config YAML sections
to test
[Bug 1907030](https://bugzilla.redhat.com/show_bug.cgi?id=1907030)
- "dnf update" runs out of memory on swapless machines with 1G or less of RAM
recent requests for information.

I found Bug 1907030 when investigating Amazon Linux 2023 changes from
Amazon Linux 2 and the change to dnf from yum for package management.
The bug was years old when I found it over a year ago.
I tested Fedora 38 QEMU instances to reporduce the bug and found that
I needed a minimum of 896 M specified for virtual memory for a x86_64 qemu
instance running with machine kvm acceleration to successfully use the
package management cloud-config YAML sections instead of the workaround
of doing this in the runcmd: section after configuring swap.

The 3/27/2024 request asked if Fedora 40 Beta resolves the issue.
I tested against the
Fedora Cloud 40 RELEASE DATE: Tuesday, April 23, 2024
Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2 image from
[Download Fedora Cloud](https://fedoraproject.org/cloud/download)

With Fedora Cloud 40 Starting at 500M I see
"Under memory pressure, flushing caches." messages but can still succeed
the cloud-config Initialization with 491M of virtual memory with the
packages: package_update: and package_upgrade: cloud-config YAML sections
and not using the runcmd workaround.

At 490M of virtual memory I get cloud-final.service: Failed with result 'oom-kill'.

fedora kernel: Out of memory: Killed process 9134 (dnf) total-vm:526020kB,
anon-rss:200kB, file-rss:144kB, shmem-rss:0kB, UID:0 pgtables:672kB
oom_score_adj:0
