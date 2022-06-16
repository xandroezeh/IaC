provider "aws"{
    region = "us-east-1"
}

variable "instance_count"{
	default = "4"
}

#6.Create Security Group to allow port 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
   ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
   ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

#9.Create Ubuntu server and install/enable apache2
resource "aws_instance" "web-server" {
	count = var.instance_count
    ami = "ami-09d56f8956ab235b3"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "xandros-key"
	vpc_security_group_ids = [aws_security_group.allow_web.id]

    tags = {
      Name = "WebServer-${count.index + 1}"
    }
}
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_traffic"
  description = "Allow SSH inbound traffic"

   ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}
resource "aws_instance" "ansible-server" {
    ami = "ami-09d56f8956ab235b3"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "xandros-key"
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  
    tags = {
      Name = "AnsibleServer"
    }
}

output "public_ip" {
	value = aws_instance.web-server.*.public_ip
}

output "ansible_ip" {
	value = aws_instance.ansible-server.public_ip
}