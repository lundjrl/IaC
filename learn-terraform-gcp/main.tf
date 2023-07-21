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
  region  = "us-east4"
  zone    = "us-east4-a"
}

resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project  = var.project
  service  = each.key
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

data "archive_file" "default" {
  type        = "zip"
  output_path = "./functions.zip"
  source_dir  = "functions/hello-world/"
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
  name      = "function-source.zip"
  bucket    = google_storage_bucket.ded-ed-terraform-test-bucket.name
  source    = data.archive_file.default.output_path
}

resource "google_cloudfunctions2_function" "my-function" {
  name          = "function-test"
  description   = "Does a thing"
  location      = "us-east4"
  project       = var.project 

  build_config {
    runtime     = "nodejs18"
    entry_point = "helloGET"
    source {
      storage_source {
        bucket = google_storage_bucket.ded-ed-terraform-test-bucket.name
        object = google_storage_bucket_object.archive.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  } 
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = google_cloudfunctions2_function.my-function.project
  cloud_function = google_cloudfunctions2_function.my-function.name
  location       = "us-east4"

  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}