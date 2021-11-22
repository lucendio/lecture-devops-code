02 - Spin up a virtual machine locally
======================================


### Objective(s)

* successfully launch a virtual machine on your local system
* connect to the virtual machine via SSH


### Prerequisite(s)

* *Vagrant* is available on the local system
* a [supported hypervisor](https://www.vagrantup.com/docs/providers) is installed (e.g. VirtualBox)
* [QEMU](https://www.qemu.org/download/) or [UTM](https://mac.getutm.app/)


### Task(s)

1. Choose a reasonably up-to-date *box* (machine image) from the
   [Vagrant Cloud](https://app.vagrantup.com/boxes/search?order=desc&page=1&provider=virtualbox&sort=downloads)
   or [upstream](https://cloud-images.ubuntu.com/), and launch a virtual machine based on that image. After the
   instance has booted successfully, establish an SSH connection to that machine.
   
2. Install *Nginx* into a virtual machine, expose it to the host and confirm with your browser that
   the default page is being served.
