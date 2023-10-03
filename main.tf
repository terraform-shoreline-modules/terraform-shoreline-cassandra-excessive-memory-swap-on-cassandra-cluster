terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "excessive_memory_swap_on_cassandra_cluster" {
  source    = "./modules/excessive_memory_swap_on_cassandra_cluster"

  providers = {
    shoreline = shoreline
  }
}