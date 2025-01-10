variable "region" {
  type = string
}

variable "s3_buckets" {
  type = map(object({
    bucket_name = string
    versioning  = bool
    acl         = string
    encription  = object({
      sse_algorithm      = string
      kms_master_key_id  = string
      bucket_key_enabled = bool
    })
    object_ownership = string
    bucket_policy    = string
    tags             = map(string)
  }))
}