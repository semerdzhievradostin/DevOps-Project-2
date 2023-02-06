terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}

resource "docker_network" "private_network" {
  name = "appnet"
}

resource "docker_image" "img-prometheus" {
  name = "prom/prometheus"
}

resource "docker_image" "img-grafana" {
  name = "grafana/grafana"
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  hostname = "prometheus"
  image = docker_image.img-prometheus.image_id
  ports {
    internal = 9090
    external = 9090
  }
  volumes {
    host_path       = "/vagrant/terraform-all/prometheus.yml"
    container_path  = "/etc/prometheus/prometheus.yml"
    read_only       = true
  }
  networks_advanced {
    name = "appnet"
  }
}

resource "docker_container" "grafana" {
  name  = "grafana"
  hostname = "grafana"
  image = docker_image.img-grafana.image_id
  ports {
    internal = 3000
    external = 3000
  }
  networks_advanced {
    name = "appnet"
  }
  volumes {
    host_path       = "/vagrant/terraform-all/datasource.yml"
    container_path  = "/etc/grafana/provisioning/datasources/datasource.yml"
    read_only       = true
  }
  depends_on = [
    docker_container.prometheus,
  ]
}

resource "docker_image" "img-rabbitmq" {
  name = "rabbitmq:3.11-management"
}

resource "docker_container" "rabbitmq" {
  name  = "rabbitmq"
  hostname = "rabbitmq"
  image = docker_image.img-rabbitmq.image_id
  ports {
    internal = 5672
    external = 5672
  }
  ports {
    internal = 15672
    external = 15672
  }
  ports {
    internal = 15692
    external = 15692
  }
  ports {
    internal = 9092
    external = 9092
  }
  networks_advanced {
    name = "appnet"
  }
}

resource "docker_image" "img-rabbit-discoverer" {
  name = "shekeriev/rabbit-discoverer"
}

resource "docker_image" "img-rabbit-observer" {
  name = "shekeriev/rabbit-observer"
}

resource "docker_container" "rabbit-discoverer" {
  name  = "rabbit-discoverer"
  hostname  = "rabbit-discoverer"
  image = docker_image.img-rabbit-discoverer.image_id
  env   = ["BROKER=rabbitmq","EXCHANGE=demo"]
  networks_advanced {
    name = "appnet"
  }
  depends_on = [
    docker_container.rabbitmq,
  ]
}

resource "docker_container" "rabbit-observer" {
  name  = "rabbit-observer"
  image = docker_image.img-rabbit-observer.image_id
  env   = ["BROKER=rabbitmq", "EXCHANGE=demo"]
  networks_advanced {
    name = "appnet"
  }
  ports {
    internal = 5000
    external = 5000
  }
  depends_on = [
    docker_container.rabbitmq,
  ]
}