02 - Spin up a virtual machine locally
======================================


### Solutions

#### 1. Start a virtual machine with `vagrant` and connect via SSH

```bash
mkdir -p my-virtual-machine && cd "${_}"
vagrant init generic/fedora28 && vagrant up --provider virtualbox
```

__NOTE:__ This way, the image that was chosen is implicitly downloaded, in case it is not already available
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

(A) Provision a virtual machine, install Nginx and expose the port

```bash
export VAGRANT_CWD=./webserver
vagrant up
```

(B) Verify that Nginx is running and return its default page

```bash
curl -s http://localhost:8080 | grep nginx
```

Result:
```
<title>Welcome to nginx!</title>
...
```

*A more complex example of a `Vagrantfile` can be found [here](./../../environments/local/Vagrantfile).*
