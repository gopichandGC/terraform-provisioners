resource "aws_instance" "web" {
  ami           = "ami-0f3c7d07486cad139"
  instance_type = "t2.micro"
  #lookup(var.instance_type,terraform.workspace)
  #"t2.micro"
  vpc_security_group_ids=[aws_security_group.roboshop-all.id] # This means list

  tags = {
    Name = "Provisioner"
  }
# Provisioners using local-exec
  provisioner "local-exec" {
    command = "echo ${self.private_ip} > inventory" # self=aws_instance.web
  }

#    provisioner "local-exec" {
#     command = "ansible-playbook -i inventory web.yaml" # self=aws_instance.web
#   }

# Provisioners using local-exec
connection {
    type     = "ssh"
    user     = "centos"
    password = "DevOps321"
    host     = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'this is from remote exec' > /tmp/remote.txt",
      "sudo yum install nginx -y",
      "sudo systemctl start nginx"
    ]
  }
}

resource "aws_security_group" "roboshop-all" { # This is terraform name, for terraform reference only.
  name        = "provisioner"   # This is for aws
  #description = var.sg-description
  #vpc_id      = aws_vpc.main.id
 
  ingress {
    description = "Allow all ports"
    from_port        = 22 # 0 means all ports
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Allow all ports"
    from_port        = 80 # 0 means all ports
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "provisioner"
  }
}
