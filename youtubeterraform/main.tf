provider "aws" {
  region = "ap-south-1"
  
}

resource "aws_instance" "pranay" {
  ami           = "ami-0d54604676873b4ec"
  instance_type = "t2.micro"
  subnet_id     = "subnet-003cfbbd4cf753c77"
  tags = {
    Name = "sample-text"
  }
}
