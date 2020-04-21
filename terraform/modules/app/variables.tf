variable public_key_path {
  description = "Path to the public key used to connect to instance"
}
variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable zone {
  description = "Zone"
  default = "us-central1-f"
}
variable app_disk_image {
  description = "Disk image for reddit app"
}

variable "reddit_internal_ip" {
  description = "Reddit DB internal ip"
}
variable provision_enabled {
}