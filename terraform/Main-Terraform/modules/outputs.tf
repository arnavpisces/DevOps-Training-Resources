output "vpc_id" {
    value=aws_vpc.vpc.id
}
output "public_ip"{
    value=aws_instance.ansible_test.public_ip
}