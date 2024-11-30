output "instanceIPv4" {
  value = aws_instance.vm.*.public_ip
}
