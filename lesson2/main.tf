terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.13.0"
    }
  }
  backend "s3" {
    bucket = "nstar-tf-backend"
    encrypt = true
    key = "terraformlesson2.tfstate"
    region = "us-east-1"
    shared_credentials_file = "/Users/Administrator/AWS/credentials"
  }
}

provider "aws" {
  region = "eu-central-1"
  shared_config_files      = ["/Users/Administrator/AWS/config"]
  shared_credentials_files = ["/Users/Administrator/AWS/credentials"]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_key_pair" "UbuntuLesson2" {
  key_name = "UbuntuLesson2"
}

data "aws_vpcs" "myVPCs" {

}

data "aws_vpc" "lesson2-vpc" {
  id = "vpc-0c4d3717394d1de8a"
  
}

data "aws_security_groups" "lesson2" {

}

data "aws_security_group" "lesson2" {
  name = "lesson2-sg"
}
 
resource "aws_network_interface" "lesson2cheat-nic" {
  subnet_id   = "subnet-04437f974d4ef5ac0"
  private_ips = ["10.0.16.25"]
  security_groups = [data.aws_security_group.lesson2.id]
  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "lesson2cheat-Ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = data.aws_key_pair.UbuntuLesson2.key_name
  network_interface {
    network_interface_id = aws_network_interface.lesson2cheat-nic.id
    device_index = 0
  }
  tags = {
    Name = "lesson2cheat"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("C:\\Users\\Administrator\\AWS\\UbuntuLesson2.pem")
    host = self.public_ip
  }

  
  provisioner "remote-exec" {
    inline = ["sudo apt -y install nginx"]
  }

  provisioner "local-exec" {
    command =  "echo ${self.public_ip} ${self.private_ip}"
    
  }

}

data "aws_subnets" "lesson2-subnets" {

}

data "aws_subnet" "lesson2-subnet" {
  for_each = toset(data.aws_subnets.lesson2-subnets.ids)
  id = each.value
}

resource "aws_db_subnet_group" "dblesson2" {
  name       = "main"
  subnet_ids = [for i in data.aws_subnet.lesson2-subnet : i.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "lesson2" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "13.4"
  vpc_security_group_ids = [data.aws_security_group.lesson2.id]
  instance_class       = "db.t3.micro"
  db_subnet_group_name = aws_db_subnet_group.dblesson2.name
  db_name              = "lesson2"
  username             = "postgres"
  password             = "postgres"
  parameter_group_name = "default.postgres13"
  skip_final_snapshot  = true
}