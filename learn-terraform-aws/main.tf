terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-00cd50fd5b2c83900"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "vue-static-site-bucket"

  tags = {
    Name        = "Vue site"
    Environment = "Dev"
  }
}