terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.19.0"
    }
  }
}

provider "postgresql" {
  alias           = "pg"
  host            = "postgres_server_ip"
  port            = 5432
  database        = "postgres"
  username        = "postgres_user"
  password        = "postgres_password"
  sslmode         = "require"
  connect_timeout = 15
}

resource "postgresql_database" "my_db" {
  provider = postgresql.pg
  name     = "my_db"
}

