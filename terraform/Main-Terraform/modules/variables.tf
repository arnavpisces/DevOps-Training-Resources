variable "region" {
  default = "ap-south-1"
}
variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}
variable "cidr_subnet_1" {
  description = "CIDR block for the public subnet 1"
  default     = "10.0.2.0/24"
}
variable "cidr_subnet_2" {
  description = "CIDR block for public subnet 2"
  default     = "10.0.3.0/24"
}
variable "cidr_subnet_1_pvt" {
  description = "CIDR block for private subnet 1"
  default     = "10.0.1.0/24"
}
variable "cidr_subnet_2_pvt" {
  description = "CIDR block for private subnet 2"
  default     = "10.0.4.0/24"
}
variable "availability_zone" {
  description = "availability zone to create subnet"
  default = {
    "zone-a" = "ap-south-1a"
    "zone-b" = "ap-south-1b"
  }
}
variable "public_key_path" {
  description = "Public Key Path"
  default     = "./aws-terraform.pub"
}
variable "instance_ami" {
  description = "AMI for aws EC2 instance"
  default     = "ami-0732b62d310b80e97"
}
variable "instance_type" {
  description = "type for aws EC2 instance"
  default     = "t2.micro"
}
variable "environment_tag" {
  description = "Environment tag"
  default     = "Production"
}
variable "free_instance"{
  type=map
  default = {
    "ami" = "ami-0732b62d310b80e97"
    "instance_type" = "t2.micro"
  }
}
variable "test_key_pair"{
  type=map
  default={
    "key_name"="test_key_pair"
  }
}
