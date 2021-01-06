04 - Install and set up a CI/CD system
======================================


### Solution

*Please note that this solution is based on a local approach utilizing Vagrant and
managing containerized process with the system's process manager*


#### 0. Preparations

We need a target machine to host our instance group. Take a look at one of the previous
tutorials and take your pick - local (Vagrant) or remote (AWS).

Please note, that The `Vagrantfile` in this folder requires an additional plugin to
be installed:

```bash
vagrant plugin install vagrant-hostmanager
```

__NOTE:__ The plugin maintains entries in your host's `/etc/hosts` and thus may ask
for a local administrator password local during initial start up as well as when
destroying the machine again.

#### 1. Prepare the machine

```bash
mkdir -p ./.ssh
ssh-keygen -t rsa -b 4096 -C "operator" -N "" -f ./.ssh/operator
chmod 600 ./.ssh/operator*
```

```bash
vagrant up
```

```bash
ansible-playbook --inventory ./inventory ./playbook_prepare.yaml
```

#### 2. Deploy the application

```bash
ansible-playbook --inventory ./inventory ./playbook_deploy.yaml
```

#### 3. Change the version and re-Deploy the application

Adjust `version``in  `./inventory/instance_group.yaml`

```bash
ansible-playbook --inventory ./inventory ./playbook_deploy.yaml
```
