##############################################################################
# Terraform Code to deploy 4 servers for Vault PoV 
#
# This Terraform configuration will create the following:
# 3 Linux servers running Vault 
# 1 Jumphost with Ansible installed and pre-configured
# ############################################################################

/* This is the provider block. We recommend pinning the provider version to
a known working version. If you leave this out you'll get the latest
version. */

provider "aws" {
  version = "= 2.17.0"
  region  = var.region
}

resource "aws_vpc" "pov" {
  cidr_block       = var.address_space
#  enable_dns_hostnames = "true"
  tags = {
    Name = "${var.prefix}-pov-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.pov.id
  availability_zone = "us-east-1a"
  cidr_block = var.subnet_prefix

  tags = {
    Name = "${var.prefix}-pov-subnet"
  }
}

resource "aws_internet_gateway" "main-gw" {
    vpc_id = aws_vpc.pov.id
}

resource "aws_route_table" "main-public" {
    vpc_id = aws_vpc.pov.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main-gw.id
    }
}

resource "aws_route_table_association" "main-public-1-a" {
    subnet_id = aws_subnet.subnet.id
    route_table_id = aws_route_table.main-public.id
}

resource "aws_security_group" "pov-sg" {
  name        = "${var.prefix}-sg"
  description = "Vault Security Group"
  vpc_id      = aws_vpc.pov.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

/*
module "ssh-keypair-aws" {
  source = "github.com/scarolan/ssh-keypair-aws"
  name   = "${var.prefix}-pov"
}
*/

resource tls_private_key "serverkey" {
  algorithm = "RSA"
}

locals {
  private_key_filename = "${var.prefix}-ssh-key.pem"
}

resource aws_key_pair "serverkey" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.serverkey.public_key_openssh
}

resource "aws_instance" "vault1" {
  ami           = var.awsami
  instance_type = var.vm_size
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.pov-sg.id]
  associate_public_ip_address = "true"
#  key_name = module.ssh-keypair-aws.name
  key_name = aws_key_pair.serverkey.key_name
  tags = {
    Name = "${var.prefix}-vault1"
    TTL = "720"
    owner = "jerome"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
#    private_key = module.ssh-keypair-aws.private_key_pem
    private_key = tls_private_key.serverkey.private_key_pem
    host = aws_instance.vault1.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname vault1.ec2.internal",
      "echo ${var.id_rsapub} >> /home/ubuntu/.ssh/authorized_keys",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update",
      "sudo apt install unzip",
      "sudo apt install dnsmasq",
    ]
  }
}

resource "aws_instance" "vault2" {
  ami           = var.awsami
  instance_type = var.vm_size
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.pov-sg.id]
  associate_public_ip_address = "true"
#  key_name = module.ssh-keypair-aws.name
  key_name = aws_key_pair.serverkey.key_name
  tags = {
    Name = "${var.prefix}-vault2"
    TTL = "720"
    owner = "jerome"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
#    private_key = module.ssh-keypair-aws.private_key_pem
    private_key = tls_private_key.serverkey.private_key_pem
    host = aws_instance.vault2.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname vault2.ec2.internal",
      "echo ${var.id_rsapub} >> /home/ubuntu/.ssh/authorized_keys",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update",
      "sudo apt install unzip",
      "sudo apt install dnsmasq",
    ]
  }
}

resource "aws_instance" "vault3" {
  ami           = var.awsami
  instance_type = var.vm_size
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.pov-sg.id]
  associate_public_ip_address = "true"
#  key_name = module.ssh-keypair-aws.name
  key_name = aws_key_pair.serverkey.key_name
  tags = {
    Name = "${var.prefix}-vault3"
    TTL = "720"
    owner = "jerome"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
#    private_key = module.ssh-keypair-aws.private_key_pem
    private_key = tls_private_key.serverkey.private_key_pem
    host = aws_instance.vault3.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname vault3.ec2.internal",
      "echo ${var.id_rsapub} >> /home/ubuntu/.ssh/authorized_keys",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update",
      "sudo apt install unzip",
      "sudo apt install dnsmasq",
    ]
  }
}

resource "aws_instance" "jumphost" {
  ami           = var.awsami
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.pov-sg.id]
  associate_public_ip_address = "true"
#  key_name = module.ssh-keypair-aws.name
  key_name = aws_key_pair.serverkey.key_name
  tags = {
    Name = "${var.prefix}-jumphost"
    TTL = "720"
    owner = "jerome"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
#    private_key = module.ssh-keypair-aws.private_key_pem
    private_key = tls_private_key.serverkey.private_key_pem
    host = aws_instance.jumphost.public_ip
  }
  provisioner "file" {
    source      = "ansible_playbook/.ssh"
    destination = "/home/ubuntu"
  }
  provisioner "file" {
    source      = "ansible_playbook/files"
    destination = "/home/ubuntu"
  }
  provisioner "file" {
    source      = "ansible_playbook/hosts"
    destination = "/home/ubuntu/hosts"
  }
  provisioner "file" {
    source      = "ansible_playbook/site.yml"
    destination = "/home/ubuntu/site.yml"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname jumphost.ec2.internal",
      "echo ${var.jba_key_pub} >> /home/ubuntu/.ssh/authorized_keys",
      "echo ${var.gdo_key_pub} >> /home/ubuntu/.ssh/authorized_keys",
      "echo ${var.jpa_key_pub} >> /home/ubuntu/.ssh/authorized_keys",
      "echo ${var.jye_key_pub} >> /home/ubuntu/.ssh/authorized_keys",
      "echo ${var.aso_key_pub} >> /home/ubuntu/.ssh/authorized_keys",
      "mkdir ~/roles",
      "git clone https://github.com/skulblaka24/ansible-vault.git /home/ubuntu/roles/ansible-vault",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt-get update",
      "sudo apt-get install ansible -y",
      "sudo apt install unzip",
      "sudo apt install python-pip -y",
      "pip install netaddr",
      "chmod 400 /home/ubuntu/.ssh/id_rsa",
    ]
  }
}

resource "aws_route53_record" "vault1_private" {
  zone_id = var.hostedzoneid
  name    = "vault1.private.jerome.aws.hashidemos.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.vault1.private_ip]
}


resource "aws_route53_record" "vault2_private" {
  zone_id = var.hostedzoneid
  name    = "vault2.private.jerome.aws.hashidemos.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.vault2.private_ip]
}

resource "aws_route53_record" "vault3_private" {
  zone_id = var.hostedzoneid
  name    = "vault3.private.jerome.aws.hashidemos.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.vault3.private_ip]
}

resource "aws_route53_record" "jumphost_private" {
  zone_id = var.hostedzoneid
  name    = "jumphost.private.jerome.aws.hashidemos.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.jumphost.private_ip]
}

resource "aws_route53_record" "vault1" {
  zone_id = var.hostedzoneid
  name    = "vault1.jerome.aws.hashidemos.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.vault1.public_ip]
}

resource "aws_route53_record" "vault2" {
  zone_id = var.hostedzoneid
  name    = "vault2.jerome.aws.hashidemos.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.vault2.public_ip]
}

resource "aws_route53_record" "vault3" {
  zone_id = var.hostedzoneid
  name    = "vault3.jerome.aws.hashidemos.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.vault3.public_ip]
}

resource "aws_route53_record" "jumphost" {
  zone_id = var.hostedzoneid
  name    = "jumphost.jerome.aws.hashidemos.io"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.jumphost.public_ip]
}

