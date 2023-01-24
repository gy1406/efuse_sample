provider "aws" {
    access_key = "${aws_access_key_id}"
    secret_key = "${aws_secret_access_key}"
    region = "us-east-1"
}

module "s3" {
    source = "./modules/S3"
    bucket_name = "efuse-bucket"
    public_read_enabled = true
}

module "iam_user" {
    source = "./modules/IAM"
    user_name = "efuse"
    bucket_name = "efuse-bucket"
}