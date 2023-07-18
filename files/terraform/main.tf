provider "yandex" {
  token     = var.YC_TOKEN
  cloud_id  = var.YC_CLOUD_ID
  folder_id = var.YC_FOLDER_ID
  zone      = var.YC_ZONE
}

#resource "yandex_storage_bucket" "test" {
#  access_key = "YCAJEwQ...HmX8"
#  secret_key = "YCO9N6Wh....gj4Cl1GdSA1"
#  bucket = "backet-rse"
#}

resource "yandex_vpc_network" "network-1" {
  name = "net"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  v4_cidr_blocks = ["10.1.0.0/24"]
  zone           = var.YC_ZONE
  network_id     = yandex_vpc_network.network-1.id
}

resource "yandex_compute_instance" "vm-1-count" {

  count = local.instance_count[terraform.workspace]
  name  = "${terraform.workspace}-count-${count.index}"

  resources {
    cores  = local.vm_cores[terraform.workspace]
    memory = local.vm_memory[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id = "fd8aqitd4vl5950ihohp"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "vm-1-foreach" {

  name  = "${terraform.workspace}-foreach-${each.key}"
  for_each = local.vm_foreach[terraform.workspace]

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = "fd8aqitd4vl5950ihohp"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${file("~/.ssh/id_rsa.pub")}"
  }

  lifecycle {
    create_before_destroy = true
  }

}

locals {
  instance_count = {
    "prod"=2
    "stage"=1
  }
  vm_cores = {
    "prod"=2
    "stage"=1
  }
  vm_memory = {
    "prod"=2
    "stage"=1
  }
  vm_foreach = {
    prod = {
      "3" = { cores = "2", memory = "2" },
      "2" = { cores = "2", memory = "2" }
    }
	stage = {
      "1" = { cores = "1", memory = "1" }
    }
  }
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1-count[*].network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1-count[*].network_interface.0.nat_ip_address
}
