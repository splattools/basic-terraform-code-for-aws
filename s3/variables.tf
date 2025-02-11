variable "region" {
  type        = string
  description = "AWS region"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}

variable "environment" {
  type        = string
  description = "Environment name for resource tagging"
}

variable "s3_buckets" {
  type = map(object({
    bucket_name = string
    versioning  = bool
    acl         = optional(string)
    encryption  = object({
      sse_algorithm      = string
      kms_master_key_id  = optional(string)
      bucket_key_enabled = optional(bool, true)
    })
    object_ownership = string
    bucket_policy_file = optional(string)
    lifecycle_rules = optional(list(object({
      id      = string
      enabled = bool
      prefix  = optional(string)
      tags    = optional(map(string))
      transition = optional(list(object({
        days          = number
        storage_class = string
      })))
      expiration = optional(object({
        days = number
      }))
    })))
    cors_rules = optional(list(object({
      allowed_headers = list(string)
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = optional(list(string))
      max_age_seconds = optional(number)
    })))
    public_access_block = optional(object({
      block_public_acls       = optional(bool, true)
      block_public_policy     = optional(bool, true)
      ignore_public_acls      = optional(bool, true)
      restrict_public_buckets = optional(bool, true)
    }))
    replication_configuration = optional(object({
      role = string
      rules = list(object({
        id       = string
        status   = string
        priority = optional(number)
        destination = object({
          bucket        = string
          storage_class = optional(string)
        })
      }))
    }))
    logging = optional(object({
      target_bucket = string
      target_prefix = string
    }))
    tags = map(string)
  }))
  description = "Map of S3 bucket configurations"
}
