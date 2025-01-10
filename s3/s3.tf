resource "aws_s3_bucket" "buckets" {
  for_each = var.s3_buckets
  bucket   = each.value.bucket_name

  tags = each.value.tags
}

resource "aws_s3_bucket_ownership_controls" "ownerships" {
  for_each = var.s3_buckets
  bucket = aws_s3_bucket.buckets[each.key].id
  rule {
    object_ownership = each.value.object_ownership
  }
}

resource "aws_s3_bucket_acl" "acls" {
  for_each = var.s3_buckets
  bucket = aws_s3_bucket.buckets[each.key].id
  acl    = each.value.acl
}







resource "aws_s3_bucket_policy" "policies" {
  for_each = var.s3_buckets
  bucket   = aws_s3_bucket.buckets[each.key].id
  policy = each.value.bucket_policy
}

