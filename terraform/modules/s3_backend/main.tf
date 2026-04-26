// S3 backend module: creates an S3 bucket and a DynamoDB table
// for storing Terraform state remotely and enabling state locking.

// Random suffix to ensure a globally unique S3 bucket name.
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

// S3 bucket to hold Terraform state files remotely.
resource "aws_s3_bucket" "terraform_state" {
  bucket = "assignment3-tfstate-${random_id.bucket_suffix.hex}"
}

// DynamoDB table used by Terraform for state locking to avoid concurrent writes.
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "assignment3-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}