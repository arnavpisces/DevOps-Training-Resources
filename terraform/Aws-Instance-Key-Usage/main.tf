provider "aws" {
  profile = "default"
  region  = var.region
}
resource "aws_security_group" "sg_test" {
  name = "sg_test"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress{
    from_port = 80
    to_port=80
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "ansible_test_keypair" {
  key_name   = var.test_key_pair["key_name"]
  public_key = file("./terraform.pub")
}
resource "aws_instance" "ansible_test" {
  ami                    = var.free_instance["ami"]
  instance_type          = var.free_instance["instance_type"]
  key_name               = aws_key_pair.ansible_test_keypair.key_name
  vpc_security_group_ids = [aws_security_group.sg_test.id]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./terraform")
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = ["sudo yum install python -y"]
  }
  provisioner "local-exec" {
      command= "ansible-playbook --user=ec2-user -i '${aws_instance.ansible_test.public_ip},' --private-key=terraform playbook.yml"  
  }
}