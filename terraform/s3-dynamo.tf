# s3-dynamo.tf

# 1. Generate a random ID for the bucket name (S3 bucket names must be globally unique)
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 2. Create the S3 Bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "assignment3-tfstate-${random_id.bucket_suffix.hex}" # Uses the random ID

  tags = {
    Name = "Terraform State Storage"
  }
}

# 3. Enable Versioning (If you accidentally delete the state, you can recover it)
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 4. Enable Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 5. Block ALL Public Access (Crucial for security)
resource "aws_s3_bucket_public_access_block" "state_public_block" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 6. Create DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "assignment3-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID" # This exact name is required by Terraform

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}

# 7. Output the exact bucket name so you can use it in the next step
output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}