terraform {
  backend "s3" {
    bucket = "terraform-remote-state-svillarreal"
    key    = "devex-fullstack-challenge/dev/bootstrap"
    region = "us-east-1"
  }
}
