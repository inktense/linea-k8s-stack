terraform {
  backend "s3" {
    bucket  = "tf-state-202201108659685447"
    key     = "environments/dev/linea-k8s-stack.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}

