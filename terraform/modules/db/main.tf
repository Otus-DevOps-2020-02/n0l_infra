resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["reddit-db"]
  boot_disk {
    initialize_params {
      image = var.db_disk_image
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    # путь до публичного ключа
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "null_resource" "db" {
  # отключить выполнение provision если false
  count = var.provision_enabled ? 1 : 0
  connection {
    type        = "ssh"
    host        = google_compute_instance.db.network_interface.0.access_config.0.nat_ip
    user        = "appuser"
    agent       = false
    private_key = file(var.private_key_path)
  }

  # разрешаем подключаться к бд с любого ip
  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf",
      "sudo systemctl restart mongod",
    ]
  }
}

# Правило firewall
resource "google_compute_firewall" "firewall_mongo" {
name = "allow-mongo-default"
network = "default"
allow {
protocol = "tcp"
ports = ["27017"]
}
target_tags = ["reddit-db"]
source_tags = ["reddit-app"]
}
