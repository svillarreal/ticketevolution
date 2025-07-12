terraform {
  backend "s3" {
    bucket = "terraform-remote-state-svillarreal"
    key    = "ticketevolution/dev-eks"
    region = "us-east-1"
  }
}
