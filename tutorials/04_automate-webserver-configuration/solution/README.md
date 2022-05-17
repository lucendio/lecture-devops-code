s04 - Automate web-server installation and apply configuration to a VM
=====================================================================


### Solution

#### 1. Generate an SSH key pair

```bash
mkdir -p ./.ssh
ssh-keygen -t rsa -b 4096 -C "operator" -N "" -f ./.ssh/operator
chmod 600 ./.ssh/operator*
```

#### 2. Bring up a new virtual machine

__NOTE:__ You may choose to allocate a local one (Tutorial 02) or in the cloud (Tutorial 03). Make sure,
you have SSH access with a user that has sudo capabilities. If needed, create a user and add the public
part of the SSH key (`./.ssh/operator.pub`) to the list of `.ssh/authorized_keys`. This solution uses
the local approach.  

```bash
vagrant up
```

#### 3. Write Ansible code

* inventory, defining host information and variables
* playbook, installing Nginx and adjusting its configuration
* (optional) placing Nginx-specific code in a role


#### 4. Apply the configuration using the Ansible tool chain

```bash
ansible-playbook -i ./inventory ./playbook.yml
```

__NOTE:__ If you want Vagrant to take care of the inventory, you may [invoke Ansible
directly from Vagrant](https://www.vagrantup.com/docs/provisioning/ansible)

__NOTE:__ If you are on Windows, which is not supported as Ansible control host and
[WSL](https://docs.microsoft.com/windows/wsl/install) is not an option, you may
[invoke Ansible locally within the virtual machine via Vagrant](https://www.vagrantup.com/docs/provisioning/ansible_local)


#### 5. Open your browser and confirm whether your changes where successful

```
http://10.0.42.23
```
