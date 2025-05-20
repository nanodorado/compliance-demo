provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "replica_bucket" {
  bucket = "my-secure-bucket-replica"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "alias/aws/s3"
      }
    }
  }

  logging {
    target_bucket = "my-logging-bucket"
    target_prefix = "log/"
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 30
    }
  }

  replication_configuration {
    role = "arn:aws:iam::123456789012:role/replication-role" # Replace with actual IAM role
    rules {
      id     = "replication-rule"
      status = "Enabled"
      destination {
        bucket        = aws_s3_bucket.secure_bucket.arn
        storage_class = "STANDARD"
      }
      filter {
        prefix = ""
      }
    }
  }

  tags = {
    Environment = "replica"
  }
}

resource "aws_s3_bucket_public_access_block" "replica_block" {
  bucket = aws_s3_bucket.replica_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "replica_notifications" {
  bucket = aws_s3_bucket.replica_bucket.id
  lambda_function {
    lambda_function_arn = "arn:aws:lambda:us-east-1:111122223333:function:dummy"
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-secure-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "alias/aws/s3"
      }
    }
  }

  logging {
    target_bucket = "my-logging-bucket"
    target_prefix = "log/"
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 30
    }
  }

  replication_configuration {
    role = "arn:aws:iam::123456789012:role/replication-role"
    rules {
      id     = "replication-rule"
      status = "Enabled"
      destination {
        bucket        = aws_s3_bucket.replica_bucket.arn
        storage_class = "STANDARD"
      }
      filter {
        prefix = ""
      }
    }
  }

  tags = {
    Environment = "secure"
  }
}

resource "aws_s3_bucket_public_access_block" "secure_block" {
  bucket = aws_s3_bucket.secure_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "secure_notifications" {
  bucket = aws_s3_bucket.secure_bucket.id
  lambda_function {
    lambda_function_arn = "arn:aws:lambda:us-east-1:111122223333:function:dummy"
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_security_group" "restricted_sg" {
  name        = "restricted-ssh"
  description = "Allow SSH from internal IPs only"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/24"]
    description = "SSH access from internal subnet"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS egress only"
  }

  tags = {
    Environment = "secure"
  }
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "checkov-secure-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "checkov-secure-ec2-profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_instance" "dummy" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.restricted_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  monitoring                  = true
  ebs_optimized               = true

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "compliance-checkov-ec2"
  }
}

resource "aws_db_instance" "secure_db" {
  allocated_storage                     = 20
  engine                                = "mysql"
  engine_version                        = "8.0"
  instance_class                        = "db.t3.micro"
  name                                  = "securedb"
  username                              = "admin"
  password                              = "strongerpassword123!"
  publicly_accessible                   = false
  skip_final_snapshot                   = false
  deletion_protection                   = true
  multi_az                              = true
  backup_retention_period               = 7
  storage_encrypted                     = true
  monitoring_interval                   = 60
  auto_minor_version_upgrade            = true
  copy_tags_to_snapshot                 = true
  iam_database_authentication_enabled   = true
  enabled_cloudwatch_logs_exports       = ["error", "general", "slowquery"]

  tags = {
    Environment = "secure"
  }
}