locals {
  key_name       = "oam"
  website_source = "static"
}


resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = local.key_name
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "key" {
  filename = "aws.pem"
  content  = tls_private_key.key.private_key_pem
}


module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                   = "oam"
  ami                    = "ami-06640050dc3f556bb" # AWS Linux
  instance_type          = "t1.micro"
  key_name               = local.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id
}

resource "null_resource" "deploy" {
  depends_on = [
  module.ec2_instance]

  connection {
    host = module.ec2_instance.private_ip
    user = "ec2-user"
    private_key = tls_private_key.key.private_key_pem
  }

  provisioner "local-exec" {
    command = "rm -rf ${local.website_source} && git clone ${var.code_repo} ${local.website_source}"
  }

  provisioner "remote-exec" {
    inline = [
      "yum install nginx -y",
      "service nginx start",
    ]
  }

  provisioner "file" {
    source      = local.website_source
    destination = "/usr/share/nginx/html/"
  }
}

output "instance_id" {
  value = module.ec2_instance.id
}

output "public_ip" {
  value = module.ec2_instance.public_ip
}

output "private_ip" {
  value = module.ec2_instance.private_ip
}
