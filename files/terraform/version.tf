terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
#  required_version = ">= 0.13"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "backet-rse"
    region     = "ru-central1"
    key        = ".terraform/terraform.tfstate"
    access_key = "YCAJEw....z6HmX8"
    secret_key = "YCO9N6Whu.....4Cl1GdSA1"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
