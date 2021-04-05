resource "aws_key_pair" "ssh" {
  public_key = file(var.sshPublicKeyPath)
}


resource "aws_instance" "controlplane" {
  for_each = { for _, v in var.controlplane : v.name => v }

  instance_type = each.value.size
  ami = data.aws_ami.image.id

  key_name = aws_key_pair.ssh.key_name

  associate_public_ip_address = true
  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.firewall.id
  ]
}

resource "aws_instance" "nodes" {
  for_each = { for _, v in var.nodes : v.name => v }

  instance_type = each.value.size
  ami = data.aws_ami.image.id

  key_name = aws_key_pair.ssh.key_name

  associate_public_ip_address = true
  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.firewall.id
  ]
}
