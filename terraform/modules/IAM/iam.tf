resource "aws_iam_user" "efuse_user" {
  name = var.user_name
}

resource "aws_iam_access_key" "efuse_key" {
    user = aws_iam_user.efuse_user.name
}

resource "aws_iam_policy" "efuse_policy" {
  name = "${var.user_name}-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}/*",
        "arn:aws:s3:::${var.bucket_name}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "efuse" {
  user = aws_iam_user.efuse_user.name
  policy_arn = aws_iam_policy.efuse_policy.arn
}



