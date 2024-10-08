output "instanceIPv4" {
  value = aws_instance.vm.*.public_ip
}

output "hosts-inventory" {
  value = {
    all = {
      hosts = {
        instance1 = {
          ansible_host = aws_instance.vm.*.public_ip
        }
      }
      vars = {}
    }
  }
}
