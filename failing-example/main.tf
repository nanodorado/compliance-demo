provider "aws" {
  region = "us-east-1"
}

# S3 BUCKET – INSECURE CONFIGURATION
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "my-insecure-bucket"
  acl    = "public-read" 
  # Violates PCI DSS 3.3, HIPAA 164.312(a)(2)(iv), ISO 27001 A.9, GDPR Art. 32 – public access to sensitive data.

  versioning {
    enabled = false
    # Violates ISO 27001 A.12.4.1, PCI DSS 10 – no versioning reduces auditability and traceability.
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256" 
        # Uses encryption but lacks key management control (e.g., KMS) – not fully aligned with PCI DSS 3.5, ISO A.10.1.1.
      }
    }
  }

  # Missing:
  # - Access logging (violates PCI DSS 10.2, ISO A.12.4)
  # - Public access block (violates GDPR and ISO A.9)
  # - Lifecycle rules for retention (GDPR Art. 5, PCI DSS 3.1) a
}

# EC2 INSTANCE – POOR SECURITY PRACTICES
resource "aws_instance" "insecure_instance" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t2.micro"
  associate_public_ip_address = true 
  # Violates PCI DSS 1.3.4, ISO 27001 A.13, HIPAA 164.312(e) – exposing compute resources to the public internet.

  # No encryption for root volume – violates HIPAA 164.312(a), PCI DSS 3.4
  # No IAM instance profile – violates least privilege principle (ISO A.9.2)
  # No metadata protection (IMDSv2) – risk of credential theft (CIS AWS Foundations, PCI DSS 2.2)

  tags = {
    Name = "insecure-demo-instance"
  }
}

# RDS INSTANCE – HIGHLY NON-COMPLIANT
resource "aws_db_instance" "insecure_db" {
  allocated_storage   = 10
  engine              = "mysql"
  instance_class      = "db.t2.micro"
  name                = "insecuredb"
  username            = "admin"
  password            = "weakpassword"
  # Hardcoded and weak credentials – violates PCI DSS 8.2.3, HIPAA 164.308(a)(5)(ii)(D), ISO A.9.4.3

  publicly_accessible = true 
  # Exposes database to the internet – violates GDPR Art. 32, HIPAA 164.312(e), PCI DSS 1.3.7

  skip_final_snapshot = true 
  # Disables disaster recovery – violates ISO A.17.1.2, PCI DSS 12.10.1, HIPAA 164.308(a)(7)(ii)(B

  # Missing:
  # - Encryption at rest (PCI DSS 3.4, ISO A.10.1)
  # - Encryption in transit (HIPAA 164.312(e)(1))
  # - IAM authentication (ISO A.9.2, PCI DSS 7)
  # - Backups and retention (HIPAA 164.308(a)(7), GDPR Art. 5)
  # - Enhanced monitoring and CloudWatch logging (PCI DSS 10.2, ISO A.12.4)
  # - Multi-AZ for availability (ISO A.17, HIPAA)
}