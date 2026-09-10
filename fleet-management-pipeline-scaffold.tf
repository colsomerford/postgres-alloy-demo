terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 3.19.0"
    }
  }
}

# 1. Base provider for Grafana Cloud API management
provider "grafana" {
  alias                     = "cloud"
  cloud_access_policy_token = var.grafana_cloud_access_policy_token
}

# Retrieve stack details (provides fleet_management_url and fleet_management_user_id)
data "grafana_cloud_stack" "stack" {
  provider = grafana.cloud
  slug     = var.stack_slug
}

# Fleet Management Access Policy
resource "grafana_cloud_access_policy" "fm_policy" {
  provider = grafana.cloud
  name     = "fleet-management-policy"
  region   = data.grafana_cloud_stack.stack.region_slug
  scopes   = ["fleet-management:read", "fleet-management:write"]

  realm {
    type       = "stack"
    identifier = data.grafana_cloud_stack.stack.id
  }
}

resource "grafana_cloud_access_policy_token" "fm_token" {
  provider         = grafana.cloud
  name             = "fleet-management-token"
  access_policy_id = grafana_cloud_access_policy.fm_policy.policy_id
  region           = data.grafana_cloud_stack.stack.region_slug
}

# 2. Dedicated Fleet Management Provider
provider "grafana" {
  alias                 = "fm"
  fleet_management_url  = data.grafana_cloud_stack.stack.fleet_management_url
  fleet_management_auth = "${data.grafana_cloud_stack.stack.fleet_management_user_id}:${grafana_cloud_access_policy_token.fm_token.token}"
}

# 3. Fleet Management Pipeline resource attached to the 'fm' provider
resource "grafana_fleet_management_pipeline" "pipeline_scaffold" {
  provider = grafana.fm
  name     = "cje_postgres_db1_postgres_pipeline_terraformed"

  contents = <<-EOT
    prometheus.exporter.postgres "cje_postgres_db1_postgres_prometheus_exporter" {
    	data_source_names  = [sys.env("DB_POSTGRES_DSN")]
    	enabled_collectors = ["stat_statements"]

    	stat_statements {
    		exclude_users = ["db-o11y"]
    	}

    	autodiscovery {
    		enabled = false
    	}
    }

    database_observability.postgres "cje_postgres_db1_postgres_db_observability" {
    	data_source_name  = sys.env("DB_POSTGRES_DSN")
    	forward_to        = [loki.relabel.cje_postgres_db1_postgres_loki_relabel.receiver]
    	targets           = prometheus.exporter.postgres.cje_postgres_db1_postgres_prometheus_exporter.targets
    	enable_collectors = ["query_details", "query_samples", "schema_details", "explain_plans"]
    }

    loki.relabel "cje_postgres_db1_postgres_loki_relabel" {
    	forward_to = [loki.write.cje_postgres_db1_postgres_loki_write.receiver]

    	rule {
    		target_label = "instance"
    		replacement  = "cje_postgres_db1"
    	}
    }

    discovery.relabel "cje_postgres_db1_postgres_discovery_relabel" {
    	targets = database_observability.postgres.cje_postgres_db1_postgres_db_observability.targets

    	rule {
    		target_label = "job"
    		replacement  = "integrations/db-o11y"
    	}

    	rule {
    		source_labels = ["instance"]
    		target_label  = "dsn"
    	}

    	rule {
    		target_label = "instance"
    		replacement  = "cje_postgres_db1"
    	}
    }

    prometheus.scrape "cje_postgres_db1_postgres_prometheus_scrape" {
    	targets    = discovery.relabel.cje_postgres_db1_postgres_discovery_relabel.output
    	forward_to = [prometheus.remote_write.cje_postgres_db1_postgres_prometheus_remote_write.receiver]
    }

    prometheus.remote_write "cje_postgres_db1_postgres_prometheus_remote_write" {
    	endpoint {
    		url = sys.env("GCLOUD_HOSTED_METRICS_URL")

    		basic_auth {
    			password = sys.env("GCLOUD_RW_API_KEY")
    			username = sys.env("GCLOUD_HOSTED_METRICS_ID")
    		}
    	}
    }

    loki.write "cje_postgres_db1_postgres_loki_write" {
    	endpoint {
    		url = sys.env("GCLOUD_HOSTED_LOGS_URL")

    		basic_auth {
    			password = sys.env("GCLOUD_RW_API_KEY")
    			username = sys.env("GCLOUD_HOSTED_LOGS_ID")
    		}
    	}
    }
  EOT
}