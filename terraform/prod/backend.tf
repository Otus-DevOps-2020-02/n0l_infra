terraform {
  backend "gcs" {
    bucket = "storage-bucket-oleg222"
    prefix = "prod-"
  }
}