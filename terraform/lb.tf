# Пример создания балансера в googe cloud и использованием terraform
# 0. Создаем шаблон. Из этого шаблона будут создаваться виртуальные машины в рамках группы
# Основой будет созданный ранее с помощью packer "bake" образ.

resource "google_compute_instance_template" "instance_template" {
  name_prefix  = "instance-template-"
  machine_type = "f1-micro"
  region       = var.region
  tags         = ["reddit-app"]
  disk {
    source_image = "reddit-full-1585048298"
    auto_delete  = true
    boot         = true
  }
  network_interface {
    network = "default"
    access_config {}
  }
}
# 1. создаем группу инстансов, на нее мы будем перенаправлять трафик
# есть два типа групп  managed и unmanaged, от типа группы зависят параметры, которые нужно указывать
# основные отличия - в managed группах можно настрайвать автоскейлинг в зависимости от нагрузки
# https://cloud.google.com/community/tutorials/modular-load-balancing-with-terraform
# https://www.terraform.io/docs/providers/google/r/compute_global_forwarding_rule.html
# https://cloud.google.com/load-balancing/docs/https/
# в данном случае используется managed

resource "google_compute_instance_group_manager" "ex-8-instance-group" {
  name        = "ex-8-instance-group"
  description = "Terraform test instance group"
  base_instance_name = "internal-glb"
  version { 
    instance_template = google_compute_instance_template.instance_template.self_link
    name              = "primary"
  }
  named_port {
    name = "http"
    port = "9292"
  }
  target_size = 1
  zone = "us-central1-f"
}

# создаем health-check для проверки состояния наших инстансов в группе
# Если нагрузка большая, система может создавать доп. инстансы
resource "google_compute_health_check" "ex-8-health-check" {
  name = "ex-8-health-check"

  timeout_sec        = 1
  check_interval_sec = 1

  http_health_check {
    port = 9292
    request_path       = "/"
  }
}

# в разделе loadbalansing создается бекенд. Эта сущьность служит
# ссылкой с будущего балансера на нашу группу инстансов
resource "google_compute_backend_service" "default" {
  name          = "backend-service"
  health_checks = [google_compute_health_check.ex-8-health-check.self_link]
  backend {
    group = google_compute_instance_group_manager.ex-8-instance-group.instance_group
  }
}

# создаем балансировщик нагрузки
resource "google_compute_url_map" "urlmap" {
  name        = "urlmap"
  description = "a description"
  default_service = google_compute_backend_service.default.self_link
}

# https://cloud.google.com/load-balancing/docs/target-proxies
# создаем целевой прокси сервер
resource "google_compute_target_http_proxy" "default" {
  name    = "test-proxy"
  url_map = google_compute_url_map.urlmap.self_link
}

# добавляем правила обработки трафика
resource "google_compute_global_forwarding_rule" "default" {
  name       = "global-rule"
  target     = google_compute_target_http_proxy.default.self_link
  port_range = "80"
}


