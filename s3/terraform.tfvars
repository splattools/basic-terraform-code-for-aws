region = "ap-northeast-1"

s3_buckets = {
  bucket001 = {
    bucket_name = "tazima202512151"
    versioning  = true
    acl         = "private"
    encription = {
      sse_algorithm      = "AES256"
      kms_master_key_id  = ""
      bucket_key_enabled = false
    }

    object_ownership = "BucketOwnerPreferred"

    bucket_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": "*",
          "Action": [
            "s3:GetObject",
            "s3:PutBucketPolicy"
          ],
          "Resource": "arn:aws:s3:::tazima202512151/*"
        }
      ]
    }
    EOF

    tags = {
      Name        = "my-bucket-001"
      Environment = "dev"
    }
  }
}