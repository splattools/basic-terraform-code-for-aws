# S3バケットの作成
resource "aws_s3_bucket" "buckets" {
  for_each = var.s3_buckets
  bucket   = "${var.project}-${var.environment}-${each.value.bucket_name}"

  tags = merge(
    each.value.tags,
    {
      Name        = "${var.project}-${var.environment}-${each.value.bucket_name}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}

# バケットのバージョニング設定
resource "aws_s3_bucket_versioning" "versioning" {
  for_each = var.s3_buckets
  bucket = aws_s3_bucket.buckets[each.key].id
  
  versioning_configuration {
    status = each.value.versioning ? "Enabled" : "Disabled"
  }
}

# バケットの暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = var.s3_buckets
  bucket = aws_s3_bucket.buckets[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = each.value.encryption.sse_algorithm
      kms_master_key_id = each.value.encryption.kms_master_key_id
    }
    bucket_key_enabled = each.value.encryption.bucket_key_enabled
  }
}

# バケットの所有者設定
resource "aws_s3_bucket_ownership_controls" "ownership" {
  for_each = var.s3_buckets
  bucket = aws_s3_bucket.buckets[each.key].id
  
  rule {
    object_ownership = each.value.object_ownership
  }
}

# バケットのACL設定
resource "aws_s3_bucket_acl" "acl" {
  for_each = { for k, v in var.s3_buckets : k => v if v.acl != null }
  bucket = aws_s3_bucket.buckets[each.key].id
  acl    = each.value.acl

  depends_on = [aws_s3_bucket_ownership_controls.ownership]
}

# パブリックアクセスブロック設定
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  for_each = { for k, v in var.s3_buckets : k => v if v.public_access_block != null }
  bucket = aws_s3_bucket.buckets[each.key].id

  block_public_acls       = each.value.public_access_block.block_public_acls
  block_public_policy     = each.value.public_access_block.block_public_policy
  ignore_public_acls      = each.value.public_access_block.ignore_public_acls
  restrict_public_buckets = each.value.public_access_block.restrict_public_buckets
}

# ライフサイクルルール設定
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  for_each = { for k, v in var.s3_buckets : k => v if v.lifecycle_rules != null }
  bucket = aws_s3_bucket.buckets[each.key].id

  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "transition" {
        for_each = rule.value.transition != null ? rule.value.transition : []
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days = expiration.value.days
        }
      }

      dynamic "filter" {
        for_each = rule.value.prefix != null || rule.value.tags != null ? [1] : []
        content {
          and {
            prefix = rule.value.prefix
            tags   = rule.value.tags
          }
        }
      }
    }
  }
}

# CORSルール設定
resource "aws_s3_bucket_cors_configuration" "cors" {
  for_each = { for k, v in var.s3_buckets : k => v if v.cors_rules != null }
  bucket = aws_s3_bucket.buckets[each.key].id

  dynamic "cors_rule" {
    for_each = each.value.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

# レプリケーション設定
resource "aws_s3_bucket_replication_configuration" "replication" {
  for_each = { for k, v in var.s3_buckets : k => v if v.replication_configuration != null }
  bucket = aws_s3_bucket.buckets[each.key].id
  role   = each.value.replication_configuration.role

  dynamic "rule" {
    for_each = each.value.replication_configuration.rules
    content {
      id       = rule.value.id
      status   = rule.value.status
      priority = rule.value.priority

      destination {
        bucket        = rule.value.destination.bucket
        storage_class = rule.value.destination.storage_class
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.versioning]
}

# ログ設定
resource "aws_s3_bucket_logging" "logging" {
  for_each = { for k, v in var.s3_buckets : k => v if v.logging != null }
  bucket = aws_s3_bucket.buckets[each.key].id

  target_bucket = each.value.logging.target_bucket
  target_prefix = each.value.logging.target_prefix
}

# バケットポリシー設定
resource "aws_s3_bucket_policy" "policy" {
  for_each = { for k, v in var.s3_buckets : k => v if v.bucket_policy_file != null }
  bucket = aws_s3_bucket.buckets[each.key].id
  policy = file("${path.module}/policies/${each.value.bucket_policy_file}")
}
