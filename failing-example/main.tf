provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bad_bucket" {
  bucket = "my-public-bucket"
  acl    = "public-read"  # ❌ PCI, SOC2, ISO 27001
}

resource "aws_security_group" "open_sg" {
  name        = "allow_all"
  description = "Open to the world"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ❌ SOC2, ISO 27001
  }
}

resource "aws_db_instance" "db" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  name                 = "exampledb"
  username             = "foo"
  password             = "bar"
  publicly_accessible  = true           # ❌ PCI-DSS
  skip_final_snapshot  = true
}
