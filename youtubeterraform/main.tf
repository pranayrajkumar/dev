resource "provider "aws" {
   region = "ap-south-1"
 }

resource "aws_vpc" "pranay" {
  cidr_block = "10.0.0/16"
}

resource "aws_subnet" "pranay" {
  vpc_id            = aws_vpc.pranay.id
  cidr_block        = "10.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true   

}
resource "aws_key_pair" "pranay" {
  key_name   = "pranay-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_route_table" "pranay" {
  vpc_id = aws_vpc.pranay.id
    route {
        cidr_block = "0.0.0/0"
        gateway_id = aws_internet_gateway.pranay.id    
    }
}

resource "aws_internet_gateway" "pranay" {
  vpc_id = aws_vpc.pranay.id
}
resource "aws_route_table_association" "pranay" {
  subnet_id      = aws_subnet.pranay.id
  route_table_id = aws_route_table.pranay.id
}

resource"aws_security_group" "pranay" {
  name        = "pranay-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.pranay.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0/0"]
    }
    ingress {
    description = "ssh"
    from_port   = 80    
    to_port     = 80
    protocol    = "tcp"     
    cidr_blocks = ["0.0.0/0"]
    }
    
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0/0"]
  }

  tags = {
    Name = "pranay-sg"
  } 

  resource "aws_instance" "pranay" {
  ami           = "ami-0261755bbcb8c4a84"
    instance_type = "t2.micro"  
    key_name      = aws_key_pair.pranay.key_name
    subnet_id     = aws_subnet.pranay.id
    vpc_security_groups_ids = [aws_security_group.pranay.name]  

    connection {
      type        = "ssh"       
        user        = "ubuntu"
        private_key = file("~/.ssh/id_rsa")     
    host        = self.public_ip
    }   

    provisioner "remote-exec" {
      inline = [
        echo "Hello, World! from the instance",
       "sudo apt update -y",  # Update package lists (for ubuntu)
      "sudo apt-get install -y python3-pip",  # Example package installation
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "sudo python3 app.py &",
      ]
    }
  }   

