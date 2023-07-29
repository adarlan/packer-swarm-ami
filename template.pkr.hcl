packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "custom-swarm-ami-x86_64" {
  ami_name = "custom-swarm-ami-{{timestamp}}-x86_64"
  region   = "us-east-1"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "al2023-ami-2023.*-x86_64"
      root-device-type    = "ebs"
    }
    owners      = ["137112412989"]
    most_recent = true
  }
  instance_type = "t2.micro"
  ssh_username  = "ec2-user"
}

build {
  name    = "my-build"
  sources = ["source.amazon-ebs.custom-swarm-ami-x86_64"]

  provisioner "shell" {
    inline = [
      "sudo yum update",
      "sudo yum install git -y",
      "git version"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo dnf update",
      "sudo dnf install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo systemctl status docker",
      "sudo usermod -aG docker ec2-user"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo yum update",
      "sudo yum install cronie -y",
      "sudo systemctl enable crond.service",
      "sudo systemctl start crond.service",
      "sudo systemctl status crond | grep Active",
      "sudo systemctl status crond.service"
    ]
  }

  provisioner "file" {
    source      = "deploy.sh"
    destination = "/tmp/deploy.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/deploy.sh /usr/local/bin/deploy.sh",
      "chmod +x /usr/local/bin/deploy.sh"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '* * * * * /usr/local/bin/deploy.sh >> /home/ec2-user/deploy.log 2>&1' | crontab -"
    ]
  }
}
