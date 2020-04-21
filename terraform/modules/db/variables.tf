variable public_key_path {
description = "Path to the public key used to connect to instance"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable db_disk_image {
  description = "Disk image for reddit db"
}
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "us-central1-f"
}
variable provision_enabled {
}