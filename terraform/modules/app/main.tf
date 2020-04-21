resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params {
      image = var.app_disk_image
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.app_ip.address
    }
  }
  metadata = {
    # путь до публичного ключа
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}
resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "null_resource" "app" {
  # отключить выполнение provision если false
  count = var.provision_enabled ? 1 : 0
  connection {
    type        = "ssh"
    host        = google_compute_instance.app.network_interface.0.access_config.0.nat_ip
    user        = "appuser"
    agent       = false
    private_key = file(var.private_key_path)
  }

  # для передачи переменной лучше использовать шаблоны:
  # https://alexharv074.github.io/2019/11/23/adventures-in-the-terraform-dsl-part-x-templates.html#template-providers--21
  # данный пример без использования шаблонов
  provisioner "remote-exec" {
    inline = [
      "echo DATABASE_URL=${var.reddit_internal_ip} | sudo tee /tmp/int-db-ip.env",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/files/reddit.service"
    destination = "/tmp/reddit.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}

