terraform {
  backend "s3" {
    bucket         = "nurlan-yagublu-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "nurlan-yagublu-terraform-locks"
  }
}
