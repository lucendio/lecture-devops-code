02 - Spin up a virtual machine locally
======================================


### Solutions

#### 1. Start a virtual machine with `vagrant` and connect via SSH

```bash
mkdir -p my-virtual-machine && cd "${_}"
vagrant init ubuntu/focal64 && vagrant up --provider virtualbox
```

__NOTE:__ This way, the chosen image is downloaded implicitly, if it is not already available
locally. To do it manually: `vagrant box add generic/fedora28`

```bash
vagrant ssh
```

__NOTE:__ You may want to stop and delete the virtual machine, after successfully logging out again:

```bash
vagrant halt
vagrant destroy
```


#### 2. Create a virtual machine that runs Nginx inside

(A) Provision a virtual machine, install Nginx and configure port forwarding for `8080` (host) to `80` (virtual machine)

```bash
export VAGRANT_CWD=./webserver
vagrant up
```

(B) Verify that Nginx is running and is returning its default page

```bash
curl -s http://localhost:8080 | grep nginx
```

Result:
```
<title>Welcome to nginx!</title>
...
```

*A more complex example of a `Vagrantfile` can be found [here](./../../environments/local/Vagrantfile).*
