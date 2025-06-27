variable "bucket_name" {
  description = "Name of the S3 bucket for static website hosting"
  type        = string
}

variable "enable_website_hosting" {
  description = "Enable static website hosting on the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_public_access" {
  description = "Enable public access to the S3 bucket (required for public website hosting)"
  type        = bool
  default     = false
}

variable "index_document" {
  description = "Name of the index document for the website"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Name of the error document for the website"
  type        = string
  default     = null
}

variable "versioning_enabled" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "cors_rules" {
  description = "List of CORS rules for the S3 bucket"
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default = []
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the S3 bucket"
  type = list(object({
    id     = string
    status = string
    expiration = optional(object({
      days = number
    }))
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }))
  }))
  default = []
}

variable "routing_rules" {
  description = "List of routing rules for website configuration"
  type = list(object({
    condition = object({
      key_prefix_equals = string
    })
    redirect = object({
      replace_key_prefix_with = string
    })
  }))
  default = []
}

# ============================================================================
# CloudFront Variables
# ============================================================================

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution for the S3 bucket"
  type        = bool
  default     = false
}

variable "cloudfront_aliases" {
  description = "List of alternate domain names (CNAMEs) for CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for CloudFront (must be in us-east-1)"
  type        = string
  default     = null
}

variable "cloudfront_price_class" {
  description = "Price class for CloudFront distribution"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "CloudFront price class must be PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}

variable "enable_spa_routing" {
  description = "Enable SPA routing (redirect 404/403 errors to index.html)"
  type        = bool
  default     = true
}

variable "geo_restriction_type" {
  description = "Type of geo restriction (none, whitelist, blacklist)"
  type        = string
  default     = "none"
  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.geo_restriction_type)
    error_message = "Geo restriction type must be none, whitelist, or blacklist."
  }
}

variable "geo_restriction_locations" {
  description = "List of country codes for geo restrictions"
  type        = list(string)
  default     = []
}
