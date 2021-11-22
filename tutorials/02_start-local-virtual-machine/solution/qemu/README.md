02 - Spin up a virtual machine locally
======================================


### Solution: QEMU

#### 1. Start a virtual machine with `qemu` and connect via SSH

(A) Download a disk image containing an installed OS, e.g. [Ubuntu](https://cloud-images.ubuntu.com/releases/) and look for
a file like `ubuntu-${VERSION-server-cloudimg-amd64.img`.
*context: host/workstation*
```bash
curl --remote-name https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img
```

(B) Create two files that will be used to configure the machine via [cloud-init](https://cloudinit.readthedocs.io/en/latest/)
during initial boot

*context: host/workstation*
```bash
mkdir -p ./cloud-init
cat <<EOF > ./cloud-init/meta-data
instance-id: my-instance
local-hostname: my-hostname
EOF
cat <<EOF > ./cloud-init/user-data
#cloud-config

users:
  - name: '${CHOOSE_A_USERNAME}'
    shell: '/usr/bin/bash'
    lock_passwd: false
    sudo: 'ALL=(ALL) NOPASSWD:ALL'
    ssh_authorized_keys:
      - '${YOUR_SSH_PUBLIC_KEY}'
EOF
```

(C) Create a disk to bundle the files that are later used as cloud-init datasource: [NoCloud](https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html#nocloud)

__NOTE:__ Please refer to the datasource docs for information on supported filesystems, and to the internet search engine
of your least distrust for other tooling to create such disk image.

*context: host/workstation (macOS)*
```bash
 hdiutil makehybrid -o ./datasource.iso ./cloud-init -iso -joliet -joliet-volume-name cidata -iso-volume-name cidata
```
OR
*context: host/workstation (Linux)*
```bash
(cd ./cloud-init && genisoimage -output ./../datasource.iso -volid cidata -joliet -rock ./user-data ./meta-data)
```

(D) Start the machine with QEMU

*context: host/workstation*
```bash
qemu-system-x86_64 \
  -machine type=q35 \
  -smp 2 \
  -m 4G \
  -nic user,hostfwd=tcp::2222-:22 \
  -hda ./ubuntu-20.04-server-cloudimg-amd64.img \
  -cdrom ./datasource.iso
```

__NOTE:__ to stop the machine press *Ctrl+C*

(E) Open up another terminal session and connect via SSH to the machine

*context: host/workstation*
```bash
ssh -p 2222 ${CHOOSE_A_USERNAME}@0.0.0.0
```


#### 2. Create a virtual machine that runs Nginx inside

(A) Download the disk image again to reset the state of the machine

(B) Extend the cloud-init configuration file

*context: host/workstation*
```bash
cat <<EOF >> ./cloud-init/user-data

write_files:
  - path: '/etc/systemd/resolved.conf.d/qemu-enable-dns.conf'
    content: |
      [Resolve]
      DNS=9.9.9.9
      FallbackDNS=8.8.8.8

runcmd:
  - [ systemctl, restart, systemd-resolved ]

EOF
```

(C) Delete the existing datasource image and rebuild it again to include the adjusted configuration file

(D) Start the machine with QEMU

*context: host/workstation*
```bash
qemu-system-x86_64 \
  -machine type=q35 \
  -smp 2 \
  -m 4G \
  -nic user,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80 \
  -hda ./ubuntu-20.04-server-cloudimg-amd64.img \
  -cdrom ./cloud-config.iso
```

(E) Connect via SSH to the machine like before

(F) Install Nginx

*context: guest*
```bash
sudo apt update
sudo apt install -y nginx
```

(G) Verify that Nginx runs and is returning its default page

*context: host/workstation*
```bash
curl -s http://localhost:8080 | grep nginx
```

Result:
```
<title>Welcome to nginx!</title>
...
```
