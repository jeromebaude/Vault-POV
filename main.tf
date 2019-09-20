##############################################################################
# Jerome's IaC deployment of the 6 servers for Vault PoV for Airbus 
#
# This Terraform configuration will create the following:
#
# AWS VPC with a subnet
# 2 Linux servers running Vault 
# 3 Linux servers running Consul
# 1 Linux server running Ansible

/* This is the provider block. We recommend pinning the provider version to
a known working version. If you leave this out you'll get the latest
version. */

provider "aws" {
  version = "= 2.17.0"
  region  = "${var.region}"
}

resource "aws_vpc" "pov" {
  cidr_block       = "${var.address_space}"
#  enable_dns_hostnames = "true"
  tags = {
    Name = "${var.prefix}-pov-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.pov.id}"
  availability_zone = "us-east-1a"
  cidr_block = "${var.subnet_prefix}"

  tags = {
    Name = "${var.prefix}-pov-subnet"
  }
}

resource "aws_internet_gateway" "main-gw" {
    vpc_id = "${aws_vpc.pov.id}"
}

resource "aws_route_table" "main-public" {
    vpc_id = "${aws_vpc.pov.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main-gw.id}"
    }
}

resource "aws_route_table_association" "main-public-1-a" {
    subnet_id = "${aws_subnet.subnet.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}

resource "aws_security_group" "pov-sg" {
  name        = "${var.prefix}-sg"
  description = "Vault Security Group"
  vpc_id      = "${aws_vpc.pov.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks_ingress
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

module "ssh-keypair-aws" {
  source = "github.com/scarolan/ssh-keypair-aws"
  name   = "${var.prefix}-pov"
}

resource "aws_instance" "vault1" {
  ami           = "${var.awsami}"
  instance_type = "${var.vm_size}"
  subnet_id     = "${aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.pov-sg.id}"]
  associate_public_ip_address = "true"
  key_name = "${module.ssh-keypair-aws.name}"
  tags = {
    Name = "${var.prefix}-vault1"
    TTL = "720"
    owner = "jerome"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${module.ssh-keypair-aws.private_key_pem}"
    host = "${aws_instance.vault1.public_ip}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostname vault1",
      "echo ${var.id_rsapub} >> /home/ubuntu/.ssh/authorized_keys",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update",
      "sudo apt install unzip",
      "sudo apt install dnsmasq",
    ]
  }
}

resource "aws_instance" "vault2" {
  ami           = "${var.awsami}"
  instance_type = "${var.vm_size}"
  subnet_id     = "${aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.pov-sg.id}"]
  associate_public_ip_address = "true"
  key_name = "${module.ssh-keypair-aws.name}"
  tags = {
    Name = "${var.prefix}-vault2"
    TTL = "720"
    owner = "jerome"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${module.ssh-keypair-aws.private_key_pem}"
    host = "${aws_instance.vault2.public_ip}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostname vault2",
      "echo ${var.id_rsapub} >> /home/ubuntu/.ssh/authorized_keys",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update",
      "sudo apt install unzip",
      "sudo apt install dnsmasq",
    ]
  }
}

resource "aws_instance" "consul1" {
  ami           = "${var.awsami}"
  instance_type = "${var.vm_size}"
  subnet_id     = "${aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.pov-sg.id}"]
  associate_public_ip_address = "true"
  key_name = "${module.ssh-keypair-aws.name}"
  tags = {
    Name = "${var.prefix}-consul1"
    TTL = "720"
    owner = "jerome"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${module.ssh-keypair-aws.private_key_pem}"
    host = "${aws_instance.consul1.public_ip}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostname consul1",
      "echo ${var.id_rsapub} >> /home/ubuntu/.ssh/authorized_keys",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update",
      "sudo apt install unzip",
      "sudo apt install dnsmasq",
    ]
  }
}

resource "aws_instance" "consul2" {
  ami           = "${var.awsami}"
  instance_type = "${var.vm_size}"
  subnet_id     = "${aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.pov-sg.id}"]
  associate_public_ip_address = "true"
  key_name = "${module.ssh-keypair-aws.name}"
  tags = {
    Name = "${var.prefix}-consul2"
    TTL = "720"
    owner = "jerome"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${module.ssh-keypair-aws.private_key_pem}"
    host = "${aws_instance.consul2.public_ip}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostname consul2",
      "echo ${var.id_rsapub} >> /home/ubuntu/.ssh/authorized_keys",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update",
      "sudo apt install unzip",
      "sudo apt install dnsmasq",
    ]
  }
}

resource "aws_instance" "consul3" {
  ami           = "${var.awsami}"
  instance_type = "${var.vm_size}"
  subnet_id     = "${aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.pov-sg.id}"]
  associate_public_ip_address = "true"
  key_name = "${module.ssh-keypair-aws.name}"
  tags = {
    Name = "${var.prefix}-consul3"
    TTL = "720"
    owner = "jerome"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${module.ssh-keypair-aws.private_key_pem}"
    host = "${aws_instance.consul3.public_ip}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostname consul3",
      "echo ${var.id_rsapub} >> /home/ubuntu/.ssh/authorized_keys",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update",
      "sudo apt install unzip",
      "sudo apt install dnsmasq",
    ]
  }
}

resource "aws_instance" "ansible" {
  ami           = "${var.awsami}"
  instance_type = "${var.vm_size_ansible}"
  subnet_id     = "${aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.pov-sg.id}"]
  associate_public_ip_address = "true"
  key_name = "${module.ssh-keypair-aws.name}"
  tags = {
    Name = "${var.prefix}-ansible"
    TTL = "720"
    owner = "jerome"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${module.ssh-keypair-aws.private_key_pem}"
    host = "${aws_instance.ansible.public_ip}"
  }
  
  provisioner "file" {
    source      = "keys/.ssh"
    destination = "/home/ubuntu"
  }
  provisioner "file" {
    source      = "files"
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
      "sudo hostname ansible",
      "mkdir ~/roles",
      "git clone https://github.com/brianshumate/ansible-consul /home/ubuntu/roles/ansible-consul",
      "git clone https://github.com/brianshumate/ansible-vault /home/ubuntu/roles/ansible-vault",
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
