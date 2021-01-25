output "hosts" {
  value = {
    all = {
      hosts = merge(
        {
          for name, machine in aws_instance.controlplane : name => {
            ansible_host = machine.public_ip
            ip = machine.private_ip
            etcd_member_name = name
          }
        },
        {
          for name, machine in aws_instance.nodes : name => {
            ansible_host = machine.public_ip
            ip = machine.private_ip
          }
        },
      )
    }

    kube-master = {
      hosts = { for name, _ in aws_instance.controlplane : name => {} }
      vars = {
        # NOTE: ensure that the x509 cert used in KUBECONFIG also includes all control-plane machines
        supplementary_addresses_in_ssl_keys = [ for _, machine in aws_instance.controlplane : machine.public_ip ]
      }
    }

    etcd = {
      hosts = { for name, _ in aws_instance.controlplane : name => {} }
    }

    kube-node = {
      hosts = { for name, _ in aws_instance.nodes : name => {} }
    }
  }
}
