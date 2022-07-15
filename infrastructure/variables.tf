variable "region" {
    description = "The AWS region containing my resources"
    type = string
    default = "us-west-2"
}

variable "name" {
    description = "VPC Name"
    type = string
    default = "test-VPC"
}

variable "vpc_cidr_block" {
  description = "CIDR Block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_tags" {
  description = "A map of tags to add to VPC"
  type        = map(string)
  default     = {}
}

variable "num_of_priv_subnets" {
    type = number
    default = 2
}