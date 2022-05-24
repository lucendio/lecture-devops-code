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

* [choose a zone](https://cloud.google.com/compute/docs/regions-zones)
* find out the id of your default project or create one
* obtain credentials:
  * create a Google Account if you don't have one yet
  * log in and add your coupon to [Google Cloud](https://console.cloud.google.com/education)
  * enable billing for [*Compute Engine*](https://console.cloud.google.com/compute) API
  * it's recommended to [create a service account](https://cloud.google.com/docs/authentication/production#create_service_account)
    instead of authenticating your personal account through the `gcloud` CLI (for this tutorial, the role
    *Compute Engine > Compute Admin* must be assigned to the service account 

```bash
terraform init \
  -var 'gcpCredentialsFilePath={{ REPLACE_WITH_KEY_FILE_PATH }}'
```

#### 3. Write configuration code in order to create a machine

* determine the cheapest [machine type](https://cloud.google.com/compute/docs/machine-types)
* find the right image: `gcloud compute images list` (log in if needed: `gcloud auth login --no-launch-browser`)

```bash
terraform apply \
  -var 'sshPublicKeyPath=./.ssh/operator.pub' \
  -var 'gcpCredentialsFilePath={{ REPLACE_WITH_KEY_FILE_PATH }}'
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
terraform destroy \
  -var 'gcpCredentialsFilePath={{ REPLACE_WITH_KEY_FILE_PATH }}'
```
