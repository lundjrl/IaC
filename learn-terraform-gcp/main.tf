terraform {
  cloud {
    organization = "jrlbidamin2"

    workspaces {
      name = "example-workspace"
    }
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = "us-east5"
  zone    = "us-east5-a"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {

    }
  }
}

resource "google_compute_firewall" "default" {
  name    = "terraform-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_tags = ["web"]
}

resource "google_storage_bucket" "ded-ed-terraform-test-bucket" {
  name                     = "ded-ed-terraform-test-bucket"
  location                 = "US"
  public_access_prevention = "enforced"
  project                  = var.project
  storage_class            = "STANDARD"
}

resource "google_storage_bucket" "auto-expire" {
  name                     = "no-public-access-auto-expiring-bucket"
  location                 = "US"
  force_destroy            = true
  public_access_prevention = "enforced"
  project                  = var.project
  storage_class            = "STANDARD"

  lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_object" "archive" {
  name      = "index.zip"
  bucket    = google_storage_bucket.ded-ed-terraform-test-bucket.name
  source    = "./index.zip"
}

resource "google_cloudfunctions_function" "my-function" {
  name          = "function-test"
  description   = "Does a thing"
  runtime       = "nodejs18"
  project       = var.project 

  available_memory_mb = 128
  source_archive_bucket = google_storage_bucket.ded-ed-terraform-test-bucket.name
  source_archive_object = google_storage_bucket_object.archive.name

  trigger_http          = true
  entry_point           = "helloGET"
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.my-function.project
  region         = google_cloudfunctions_function.my-function.region 
  cloud_function = google_cloudfunctions_function.my-function.name

  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}