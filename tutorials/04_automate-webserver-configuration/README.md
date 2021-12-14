04 - Automate web-server installation and apply configuration to a machine
==========================================================================


### Objective(s)

* install and configure Nginx on a virtual machine in an automated fashion
* tell Nginx to serve a custom landing page


### Prerequisite(s)

* Ansible is installed ([on Windows, it's only supported to run in WSL](https://docs.ansible.com/ansible/latest/user_guide/windows_faq.html#can-ansible-run-on-windows))
* a running virtual machine with SSH access - either locally (Vagrant) or in the cloud


### Task(s)

1. Write Ansible code (*playbook*, *inventory*, possibly a *role*) to automate the installation and
   configuration of Nginx. Required steps:

   + install Nginx (probably via OS package manager)
   + create a custom landing page (static file somewhere in the filesystem)
   + configure Nginx so that it knows where that file resides and how to serve it (You can either create your own
     *vhost* by defining a
     [`server` directive](https://docs.nginx.com/nginx/admin-guide/web-server/web-server/#setting-up-virtual-servers)
     to serve your custom landing page, or you override the existing default page)
   + restart Nginx or reload its configuration

2. Apply the configuration to the virtual machine

3. Verify if your own custom landing page shows up in the browser  
