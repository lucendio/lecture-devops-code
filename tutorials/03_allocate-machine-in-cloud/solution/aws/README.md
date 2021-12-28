03 - Allocate a virtual machine in the cloud
============================================


### Solution

#### 1. Generate an SSH key pair

```bash
mkdir -p ./.ssh
ssh-keygen -t rsa -b 4096 -C "operator" -N "" -f ./.ssh/operator
chmod 600 ./.ssh/operator*
```

#### 2. Set up cloud provider and initialize the Terraform root module

*__NOTE:__ At this point, the necessary cloud provider credentials (e.g. [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs))
must have already been configured. For AWS, 

* set a *region* - in `provider.tf` or via environment `AWS_DEFAULT_REGION` (note that if AWS Academy Program account
  is being used, `region` must be set to `"us-east-1"`)
* obtain credentials:
  * if eligible see FAQ on [how to get credentials provided by AWS Academy](https://github.com/lucendio/lecture-devops-infos/blob/main/faq.md#7-how-do-i-get-access-to-aws-and-unlock-aws-academy-credits) 
  * you may want to
    [use environment variables or stick with the default location `~/aws/[config, credentials]`](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)*  

```bash
terraform init
```

#### 3. Write configuration code in order to create a machine

* determine the cheapest [instance type](https://aws.amazon.com/ec2/pricing/on-demand/)
* find the right image: [`aws ec2 describe-images`](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html)
  (in case of AWS Academy, check the *EC2* part in the section *Service usage and other restrictions* of the Readme
  mentioned [here](https://github.com/lucendio/lecture-devops-infos/blob/main/faq.md#7-how-do-i-get-access-to-aws-and-unlock-aws-academy-credits))

```bash
terraform apply \
  -var 'sshPublicKeyPath=./.ssh/operator.pub'
```

__NOTE:__ You may want to *output* the public IP of that machine

```bash
terraform output 'instanceIPv4'
```

#### 4. Connect to the machine via SSH

```bash
ssh -i ./.ssh/operator -l ubuntu $(terraform output -raw 'instanceIPv4')
```

#### 5. (optional) Install Nginx and verify that it's running 

*context: vm*
```bash
sudo apt update
sudo apt install -y nginx
```

*context: workstation*
```bash
curl -s http://$(terraform output -raw 'instanceIPv4'):80 | grep nginx
```
Result:
```
<title>Welcome to nginx!</title>
...
```

#### 6. Clean up afterwards (!)

*context: workstation*
```bash
terraform destroy
```
