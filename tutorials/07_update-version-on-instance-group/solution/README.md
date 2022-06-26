07 - Deploy a new version to an instance group
==============================================


### Solution (A)

*Please note that this solution is based on a local approach utilizing Vagrant and
managing containerized process with the system's process manager*


#### 0. Preparations

Utilize a combination of previous tutorials to allocate a virtual machine locally with Vagrant.

* Vagrant HostManager
* pre-provisioned dedicated user (`operator`)

```bash
mkdir -p ./.ssh
ssh-keygen -t rsa -b 4096 -C "operator" -N "" -f ./.ssh/operator
chmod 600 ./.ssh/operator*
```

```bash
vagrant up
```

#### 1. Configure machine with Ansible

* install container runtime
* set up load balancer (Nginx) and configure instance group based on the list of
  instances defined in the [inventory](./inventory/instance_group.yaml)
* start a database container

```bash
ansible-playbook --inventory ./inventory ./play_configure.yaml
```

#### 2. Deploy the service as an instance group

Choose a service - in this case: [HedgeDoc](https://docs.hedgedoc.org/) and
deploy it in multiple containers as an instance group of 3 instances.

```bash
ansible-playbook --inventory ./inventory ./play_deploy.yaml
```

#### 3. Implement one of the deployment strategies

Utilize Ansible's [asynchronous](https://docs.ansible.com/ansible/latest/user_guide/playbooks_strategies.htmll)


#### 3. Change the version and re-deploy the service

Adjust `service_version` in  `./inventory/instance_group.yaml`

```bash
ansible-playbook --inventory ./inventory ./play_deploy.yaml
```
