provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-secure-bucket"
  acl    = "private"  # ✅ Fixed: No public access (SOC 2, PCI-DSS, ISO 27001)

  versioning {
    enabled = true  # ✅ Recommended: S3 versioning for auditability
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"  # ✅ Fixed: Encryption at rest (HIPAA, GDPR, PCI-DSS)
      }
    }
  }

  logging {
    target_bucket = "my-logging-bucket"
    target_prefix = "log/"  # ✅ Recommended: Enable access logging (SOC 2, ISO 27001)
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 30  # ✅ Optional: Data retention enforcement (GDPR, CCPA)
    }
  }

  tags = {
    Environment = "secure"
  }
}

resource "aws_security_group" "restricted_sg" {
  name        = "restricted-ssh"
  description = "Allow SSH from internal IPs only"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/24"]  # ✅ Fixed: No 0.0.0.0/0, limited access (ISO 27001, SOC 2)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Default: Allow all outbound
  }
}

resource "aws_db_instance" "secure_db" {
  allocated_storage       = 20
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  name                    = "securedb"
  username                = "admin"
  password                = "strongerpassword123!"  # ✅ Warning: Use secrets manager in production
  publicly_accessible     = false                   # ✅ Fixed: No public DB exposure (HIPAA, PCI-DSS)
  skip_final_snapshot     = false                   # ✅ Fixed: Create snapshot before destroy (ISO 27001)
  backup_retention_period = 7                       # ✅ Best practice: Enable backups (SOC 2, PCI)
  storage_encrypted       = true                    # ✅ Fixed: Encrypt DB storage (HIPAA, PCI-DSS)

  tags = {
    Environment = "secure"
  }
}