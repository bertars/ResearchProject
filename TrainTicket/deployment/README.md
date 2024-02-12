You can use `baseline/docker-compose-baseline.yml` to run the system without any monitoring system.

To monitor the system, we provide integration with:

### 1. Elasticsearch and Metricbeat to collect metrics from containers

Check `deployment/elastic`.

Use `metricbeat.yml` for configuration (e.g., to configure the time interval (in seconds) for metrics to be sent to the
Elasticsearch cluster). This file should go in `/etc/metricbeat/`.

### 2. Netdata

Check `deployment/netdata`.

Use `netdata.yml` for configuration.

### 3. Prometheus

Check `deployment/prometheus`.

Use `prometheus.yml` for configuration (e.g., to set the desired scrape interval).

### 4. Zipkin with OpenTracing collector for distributed tracing

Check `deployment/zipkin`.

Services are integrated with Zipkin on branches `zipkin-high-freq`, `zipkin-medium-freq`, `zipkin-low-freq`. You can
switch to one of those branches to build the relevant images, depending on the desired frequency:

- high - 100% sampling rate
- medium - 50% sampling rate
- low - 25% sampling rate

Building the images:

`sudo mvn clean package -Dmaven.test.skip=true`

`docker compose -f deployment/jaeger/docker-compose-zipkin-<low,medium,high>.yml --env-file .env build`
