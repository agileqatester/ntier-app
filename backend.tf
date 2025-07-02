terraform {
  backend "s3" {
    bucket         = "ntier-app-terraform-state-bucket"
    key            = "ntier-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ntier-terraform-locks"
    encrypt        = true
  }
}