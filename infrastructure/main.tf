terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
      }
    }
    required_version = ">= 1.1.0"
}

provider "aws" {
    region = "us-west-2"
}


locals {
    region = var.region
    name = var.name
    cidr_block = var.vpc_cidr_block
    tags = var.vpc_tags
    num_of_priv_subnets = var.num_of_priv_subnets
}

resource  "aws_vpc" "vpc" {
    cidr_block = local.cidr_block
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = merge({
        Name = local.name
    }, local.tags )
}

resource "aws_subnet" "private_subnet"{
    vpc_id = aws_vpc.vpc.id
    count = local.num_of_priv_subnets
    cidr_block = cidrsubnet(local.cidr_block, 4, count.index )
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = false
    tags = merge(
        {
            Name = "${local.name} Private Subnet ${data.aws_availability_zones.available.names[count.index]}"
        },
        local.tags
        )
}

resource "aws_security_group" "security_group"{
    name = "${local.name} Security Group"
    description = "Default SG to allow traffic from the VPC"
    vpc_id = aws_vpc.vpc.id
    depends_on = [
      aws_vpc.vpc
    ]
    ingress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        self = true
    }
    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        self = "true"
    }
}