02 - Spin up a virtual machine locally
======================================


### Solution: Vagrant

#### 1. Start a virtual machine with `vagrant` and connect via SSH

*context: host/workstation*
```bash
mkdir -p my-virtual-machine && cd "${_}"
vagrant init ubuntu/focal64 && vagrant up --provider virtualbox
```

__NOTE:__ This way, the chosen image is downloaded implicitly, if it's not already available
locally. To fetch the image manually: `vagrant box add ubuntu/focal64`

*context: host/workstation*
```bash
vagrant ssh
```

__NOTE:__ You may want to stop and delete the virtual machine, after successfully logging out again:

*context: host/workstation*
```bash
vagrant halt
vagrant destroy
```

*A more comprehensive example of a `Vagrantfile` can be found [here](./../../../../scenarios/ansible/environments/local/Vagrantfile).*


#### 2. Create a virtual machine that runs Nginx inside

Provision a virtual machine, install Nginx and configure port forwarding for `8080` (host) to `80` (virtual machine)

*context: host/workstation*
```bash
cd ./webserver
vagrant up
```

Verify that Nginx is running and returns its default page

*context: host/workstation*
```bash
curl -s http://localhost:8080 | grep nginx
```

Result:
```
<title>Welcome to nginx!</title>
...
```
