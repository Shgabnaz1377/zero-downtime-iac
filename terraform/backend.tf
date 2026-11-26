# State is kept locally by default so the project works with zero setup.
#
# For anything shared, move it to a remote backend. Any S3-compatible object
# store works, including Hetzner Object Storage. Uncomment, fill in, then run
# `terraform init -migrate-state`. Credentials come from the usual
# AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY environment variables.
#
# terraform {
#   backend "s3" {
#     bucket                      = "my-terraform-state"
#     key                         = "zero-downtime-iac/terraform.tfstate"
#     region                      = "eu-central"
#     endpoints                   = { s3 = "https://fsn1.your-objectstorage.com" }
#     use_path_style              = true
#     use_lockfile                = true
#     skip_credentials_validation = true
#     skip_region_validation      = true
#     skip_requesting_account_id  = true
#     skip_metadata_api_check     = true
#     skip_s3_checksum            = true
#   }
# }
