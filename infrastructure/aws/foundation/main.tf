# create a kms key to encrypt s3 objects in state bucket
resource "aws_kms_key" "s3_kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

# our infrastructure tf state - important to enable versioning because of accidental deletion
resource "aws_s3_bucket" "infra-terraform-state" {
  bucket = "${var.tf_state_bucket_name}"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.s3_kms_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
  versioning {
    enabled = "true"
  }
  lifecycle {
    prevent_destroy = "true"
  }
  tags = {
    Name = "S3 Remote Terraform State Store"
  }
}

# block public access to tf state bucket
resource "aws_s3_bucket_public_access_block" "infra-terraform-state" {
  bucket = "${aws_s3_bucket.infra-terraform-state.id}"

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

# locking table for terraform resources
resource "aws_dynamodb_table" "aws-terraform-state-lock" {
  name = "aws-terraform-state-lock"
  hash_key = "LockID"
  read_capacity = 2
  write_capacity = 2
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}