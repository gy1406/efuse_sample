resource "aws_s3_bucket" "efuse_bucket" {
  bucket = var.bucket_name
} 

resource "aws_s3_bucket_policy" "efuse" {
  bucket = aws_s3_bucket.efuse_bucket.bucket

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.bucket_name}/*"
        }
    ]
}
EOF
}

resource "aws_s3_bucket_public_access_block" "efuse_block" {
  bucket = aws_s3_bucket.efuse_bucket.id
  block_public_acls = true
  ignore_public_acls = true
}