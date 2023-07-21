variable "project" {
  
}

variable "credentials_file" {

}

variable "region" {
  default = "us-east5"
}

variable "zone" {
  default = "us-east5-a"
}

variable "gcp_service_list" {
  description = "Needed service api's to use GCP infra."

  type = list(string)

  default = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
    "cloudbuild.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigquerystorage.googleapis.com",
    "datastore.googleapis.com",
    "oslogin.googleapis.com",
    "run.googleapis.com", 
    "sql-component.googleapis.com",
    "storage-component.googleapis.com", 
    "storage.googleapis.com", 
    "cloudtrace.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudapis.googleapis.com",
    "storage-api.googleapis.com",
    # "source.googleapis.com",
    "policytroubleshooter.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
  ]
}