terraform {
  backend "s3" {
    bucket       = "observcw01"
    key          = "terrform.tfstate"
    region       = "eu-west-2"
    profile      = "sandbox"
    use_lockfile = true
    encrypt      = true
  }
}
