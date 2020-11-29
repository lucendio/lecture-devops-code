03 - Allocate a virtual machine in the cloud
============================================


### Solution

#### 1. Generate an SSH key pair

```bash
mkdir -p ./.ssh
ssh-keygen -t rsa -b 4096 -C "operator" -N "" -f ./.ssh/operator
chmod 600 ./.ssh/operator*
```

#### 2. Initialize Terraform project and write configuration code in order to create a machine (aka server, instance, etc.)

__NOTE:__ At this point, the necessary cloud provider credentials must have already been configured

```bash
terraform init
```

* find the cheapest instance type: https://aws.amazon.com/ec2/pricing/on-demand/
* if using AWS Education Program account, `region` must be set to `"us-east-1"`, additionally
  available resources and services can be found [here](https://awseducate-starter-account-services.s3.amazonaws.com/AWS_Educate_Starter_Account_Services_Supported.pdf):

```bash
terraform apply -var 'sshPublicKeyPath=./.ssh/operator.pub'
```

__NOTE:__ You may want to *output* the public IP of that machine

```bash
terraform output 'instanceIPv4'
```

#### 3. Connect to the machine via SSH

```bash
ssh -i ./.ssh/operator -l ubuntu $(terraform output 'instanceIPv4')
```

__NOTE:__ Depending on what kind of image the provider supplies or has been chosen, the username may vary
