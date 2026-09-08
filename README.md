# Postgres Docker Compose

To setup run the following command:
```
docker compose up -d --build
```

To access the SQL shell run the following:
```
docker exec -it my-postgres psql -U postgres -d mydatabase
```

## Setting up Postgres for Alloy

To give the alloy the information it needs to connect to fleet management and write telemetry create a .env file in the root directory and create the following variables. The missing values should be filled in from your grafana cloud instance.
Please also change the COLLECTOR_ID to make it unique to your current setup.
```
GCLOUD_HOSTED_METRICS_ID=
GCLOUD_HOSTED_METRICS_URL=
GCLOUD_HOSTED_LOGS_ID=
GCLOUD_HOSTED_LOGS_URL=
GCLOUD_FM_URL=
GCLOUD_FM_POLL_FREQUENCY=
GCLOUD_FM_HOSTED_ID=
GCLOUD_RW_API_KEY=
DB_POSTGRES_DSN="postgresql://db-o11y:o11y_password@my-postgres:5432/mydatabase?sslmode=disable"
DB_POSTGRES_DSN2="postgresql://db-o11y:o11y_password@my-postgres:5432/cje_test_1?sslmode=disable"
DB_POSTGRES_DSN3="postgresql://db-o11y:o11y_password@my-postgres:5432/cje_test_2?sslmode=disable"
COLLECTOR_ID="postgres_demo_collector"

```

## Setting up Fleet Management for Alloy

Below is an example that may not be complete - note this version only sets up a single DSN for the Explain Plans

```
prometheus.exporter.postgres "demo_cje_postgres_postgres_prometheus_exporter" {
	data_source_names  = [sys.env("DB_POSTGRES_DSN")]
	enabled_collectors = ["stat_statements"]

	stat_statements {
		exclude_users = ["db-o11y"]
	}

	autodiscovery {
		enabled = true
	}
}

database_observability.postgres "demo_cje_postgres_postgres_db_observability" {
	data_source_name  = sys.env("DB_POSTGRES_DSN")
	forward_to        = [loki.relabel.demo_cje_postgres_postgres_loki_relabel.receiver]
	targets           = prometheus.exporter.postgres.demo_cje_postgres_postgres_prometheus_exporter.targets
	enable_collectors = ["query_details", "query_samples", "schema_details", "explain_plans"]
}

loki.relabel "demo_cje_postgres_postgres_loki_relabel" {
	forward_to = [loki.write.demo_cje_postgres_postgres_loki_write.receiver]

	rule {
		source_labels = ["instance"]
		target_label  = "dsn"
	}

	rule {
		target_label = "team"
		replacement  = "dba"
	}
}

discovery.relabel "demo_cje_postgres_postgres_discovery_relabel" {
	targets = database_observability.postgres.demo_cje_postgres_postgres_db_observability.targets

	rule {
		target_label = "job"
		replacement  = "integrations/db-o11y"
	}

	rule {
		source_labels = ["instance"]
		target_label  = "dsn"
	}

	rule {
		target_label = "team"
		replacement  = "dba"
	}
}

prometheus.scrape "demo_cje_postgres_postgres_prometheus_scrape" {
	targets    = discovery.relabel.demo_cje_postgres_postgres_discovery_relabel.output
	forward_to = [prometheus.remote_write.demo_cje_postgres_postgres_prometheus_remote_write.receiver]
}

prometheus.remote_write "demo_cje_postgres_postgres_prometheus_remote_write" {
	endpoint {
		url = sys.env("GCLOUD_HOSTED_METRICS_URL")

		basic_auth {
			password = sys.env("GCLOUD_RW_API_KEY")
			username = sys.env("GCLOUD_HOSTED_METRICS_ID")
		}
	}
}

loki.source.file "logs_integrations_postgres_exporter" {
	targets = [{
		__path__ = "/var/log/postgresql/postgresql-*.log",
		job      = "postgres_logs",
	}]

	file_match {
		enabled = true
	}

	forward_to = [database_observability.postgres.demo_cje_postgres_postgres_db_observability.logs_receiver]
}

loki.write "demo_cje_postgres_postgres_loki_write" {
	endpoint {
		url = sys.env("GCLOUD_HOSTED_LOGS_URL")

		basic_auth {
			password = sys.env("GCLOUD_RW_API_KEY")
			username = sys.env("GCLOUD_HOSTED_LOGS_ID")
		}
	}
}
```

The following is an Example of a pipeline with all targeted DSNs:

```
prometheus.exporter.postgres "demo_cje_postgres_postgres_prometheus_exporter" {
	data_source_names  = [sys.env("DB_POSTGRES_DSN")]
	enabled_collectors = ["stat_statements"]

	stat_statements {
		exclude_users = ["db-o11y"]
	}

	autodiscovery {
		enabled = true
	}
}

database_observability.postgres "demo_cje_postgres_postgres_db_observability_mydatabase" {
	data_source_name  = sys.env("DB_POSTGRES_DSN")
	forward_to        = [loki.relabel.demo_cje_postgres_postgres_loki_relabel.receiver]
	targets           = prometheus.exporter.postgres.demo_cje_postgres_postgres_prometheus_exporter.targets
	enable_collectors = ["query_details", "query_samples", "schema_details", "explain_plans"]
}

database_observability.postgres "demo_cje_postgres_postgres_db_observability_cje_test_1" {
	data_source_name  = sys.env("DB_POSTGRES_DSN2")
	forward_to        = [loki.relabel.demo_cje_postgres_postgres_loki_relabel.receiver]
	targets           = prometheus.exporter.postgres.demo_cje_postgres_postgres_prometheus_exporter.targets
	enable_collectors = ["query_details", "query_samples", "schema_details", "explain_plans"]
}

database_observability.postgres "demo_cje_postgres_postgres_db_observability_cje_test_2" {
	data_source_name  = sys.env("DB_POSTGRES_DSN3")
	forward_to        = [loki.relabel.demo_cje_postgres_postgres_loki_relabel.receiver]
	targets           = prometheus.exporter.postgres.demo_cje_postgres_postgres_prometheus_exporter.targets
	enable_collectors = ["query_details", "query_samples", "schema_details", "explain_plans"]
}

loki.relabel "demo_cje_postgres_postgres_loki_relabel" {
	forward_to = [loki.write.demo_cje_postgres_postgres_loki_write.receiver]

	rule {
		source_labels = ["instance"]
		target_label  = "dsn"
	}

	rule {
		target_label = "team"
		replacement  = "dba"
	}
}

discovery.relabel "demo_cje_postgres_postgres_discovery_relabel" {
	targets = database_observability.postgres.demo_cje_postgres_postgres_db_observability_mydatabase.targets

	rule {
		target_label = "job"
		replacement  = "integrations/db-o11y"
	}

	rule {
		source_labels = ["instance"]
		target_label  = "dsn"
	}

	rule {
		target_label = "team"
		replacement  = "dba"
	}
}

prometheus.scrape "demo_cje_postgres_postgres_prometheus_scrape" {
	targets    = discovery.relabel.demo_cje_postgres_postgres_discovery_relabel.output
	forward_to = [prometheus.remote_write.demo_cje_postgres_postgres_prometheus_remote_write.receiver]
}

prometheus.remote_write "demo_cje_postgres_postgres_prometheus_remote_write" {
	endpoint {
		url = sys.env("GCLOUD_HOSTED_METRICS_URL")

		basic_auth {
			password = sys.env("GCLOUD_RW_API_KEY")
			username = sys.env("GCLOUD_HOSTED_METRICS_ID")
		}
	}
}

loki.source.file "logs_integrations_postgres_exporter" {
	targets = [{
		__path__ = "/var/log/postgresql/postgresql-*.log",
		job      = "postgres_logs",
	}]

	file_match {
		enabled = true
	}

	forward_to = [database_observability.postgres.demo_cje_postgres_postgres_db_observability_mydatabase.logs_receiver]
}

loki.write "demo_cje_postgres_postgres_loki_write" {
	endpoint {
		url = sys.env("GCLOUD_HOSTED_LOGS_URL")

		basic_auth {
			password = sys.env("GCLOUD_RW_API_KEY")
			username = sys.env("GCLOUD_HOSTED_LOGS_ID")
		}
	}
}
```

## Troubleshooting and Stopping

To get logs from the docker run the following:
```
docker compose logs alloy
docker compose logs db
docker compose logs python-tester
```

To stop the setup and delete voluemes run the following:
```
docker compose down --volumes
```
