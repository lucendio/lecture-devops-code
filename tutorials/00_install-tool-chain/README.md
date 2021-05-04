00 - Installing tool chain
==========================


### Objective(s)

* successfully install the tools used in the upcoming tutorials
* verify that your credentials of your AWS Educate account work


### Notes

* you may want consult your favourite package manager to search and install any of the tools


### Task(s)

1. Install the *Amazon Web Service* or *Google Cloud Platform* CLI and verify that you can log in

    * [`awscli`](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) (v1 is also available via [pip](https://pypi.org/project/awscli/))
      Consult the [FAQ section](https://github.com/lucendio/lecture-devops-materials/blob/master/faq.md#4-how-do-i-get-access-to-aws-and-unlock-aws-educate-credits)
      for how to obtain credentials

      ```bash
      aws sts get-caller-identity
      ```

    * [`glcoud`](https://cloud.google.com/sdk/docs/install)

      ```bash
      gcloud auth login ${BEUTH_EMAIL} --no-launch-browser 
      ```

2. Install a container runtime of your choice (e.g. Podman, Docker)

    * depending on your host system, you might want to run containers in a virtual machine


3. Install a virtualization software (aka Hypervisor) [compatible with Vagrant and that is not named Docker)](https://www.vagrantup.com/docs/providers)

    * [VirtualBox](https://www.virtualbox.org/wiki/Downloads) is recommended, because it is supported across all major
      operating systems (on x86)


6. Install the [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli)

    * since it's a static binary, there are no prerequisites and you can pick the latest version


5. Install Ansible

    * choose the latest [community package](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-the-ansible-community-package)
      (not `ansible-[core,base]`)
    * it is recommended to use `pip` the Python package manager (and latest Python 3 version)


6. Install the Kubernetes CLI [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl)

    * since it's a static binary, there are no prerequisites and you can pick the latest version


7. Install [Helm CLI](https://helm.sh/docs/intro/install/)

    * since it's a static binary, there are no prerequisites and you can pick the latest version
