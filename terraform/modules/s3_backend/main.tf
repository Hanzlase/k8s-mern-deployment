resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "assignment3-tfstate-${random_id.bucket_suffix.hex}"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "assignment3-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}