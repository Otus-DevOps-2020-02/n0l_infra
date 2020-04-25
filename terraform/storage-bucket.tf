provider "google" {
  version = "~> 2.12"
  project = var.project
  region  = var.region
}

#module "storage-bucket" {
#  source  = "SweetOps/storage-bucket/google"
#  version = "0.3.0"
#  # Имена поменяйте на другие
#  name = "storage-bucket-oleg222"
#  location = var.region
#}

#output storage-bucket_url {
#  value = module.storage-bucket.url
#}
