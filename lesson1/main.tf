terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.13.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  shared_config_files      = ["/Users/Administrator/.aws/config"]
  shared_credentials_files = ["/Users/Administrator/.aws/credentials"]
}

data "aws_vpcs" "myVPCs" {

}

data "aws_vpc" "myVPCs" {
  for_each = toset(data.aws_vpcs.myVPCs.ids)
  id = each.value
  
}

output "my_VPCs" {
  value = [for v in data.aws_vpc.myVPCs : v.tags]
}

data "aws_subnets" "my_subnets" {

}

data "aws_subnet" "my_subnet" {
  for_each = toset(data.aws_subnets.my_subnets.ids)
  id = each.value
}

output "my_subnets_IP" {
  value = [for s in data.aws_subnet.my_subnet : s.cidr_block]
  
}

output "my_subnets_names" {
  value = [for s in data.aws_subnet.my_subnet : s.tags]  
}

data "aws_security_groups" "mySGs" {

}

data "aws_security_group" "mySGs" {
  for_each = toset(data.aws_security_groups.mySGs.ids)
  id = each.value
}

output "mySGs" {
  value = [for sg in data.aws_security_group.mySGs : sg.name]
}