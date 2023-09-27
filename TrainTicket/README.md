# Companion repository of the paper "An Empirical Evaluation of the Energy and Performance Overhead of Monitoring Tools on Docker-based Systems"


This folder contains a fork of the [Train Ticket System](https://github.com/FudanSELab/train-ticket) (TTS) repo and it
contains:

- the integration of the TTS with a selection of four monitoring tools;
- a set of 34 load test scripts generated with [K6](https://k6.io/), starting from the Swagger/OpenAPI specification of
  the REST APIs, for the 34 Java Spring Boot microservices belonging to the TTS.

## Overview of the replication package

Our contribution comprises the following elements:

- [deployment]: Docker Compose files for each of
  the integrations with monitoring tools
- [cli.py]: A utility script used to easily run the
  system with Docker Compose
- [k6-test]: The 34 scripts used to load test the TTS

## Quick start

### Integrations
`baseline/docker-compose-baseline.yml` can be used to run the system without any monitoring system.

We provide integration with:

#### 1. Elasticsearch and Metricbeat to collect metrics from containers

Check `deployment/elastic`.

Use `metricbeat.yml` for configuration (e.g., to configure the time interval (in seconds) for metrics to be sent to the
Elasticsearch cluster). This file should go in `/etc/metricbeat/`.

#### 2. Netdata

Check `deployment/netdata`.

Use `netdata.yml` for configuration.

#### 3. Prometheus

Check `deployment/prometheus`.

Use `prometheus.yml` for configuration (e.g., to set the desired scrape interval).

#### 4. Zipkin with OpenTracing collector for distributed tracing

Check `deployment/zipkin`.

Services are integrated with Zipkin on branches `zipkin-high-freq`, `zipkin-medium-freq`, `zipkin-low-freq`. You can
switch to one of those branches to build the relevant images, depending on the desired frequency:

- high - 100% sampling rate
- medium - 50% sampling rate
- low - 25% sampling rate

Building the images:

`sudo mvn clean package -Dmaven.test.skip=true`

`docker compose -f deployment/jaeger/docker-compose-zipkin-<low,medium,high>.yml --env-file .env build`

### Running the TTS with the monitoring tools

[cli.py] can be used to run the system with Docker:

- To configure a specific monitoring tool (elastic, netdata, prometheus, zipkin or baseline) at a specific
  frequency level (low, medium or high):

`python cli.py update-config -t {tool} -f {frequency}`

- To update the configuration and run the TTS with a specific monitoring tool (elastic, netdata, prometheus, zipkin or baseline) at a specific frequency level (low, medium or high):

`python cli.py run-stack -t {tool} -f {frequency}`

- To stop the TTS:

`python cli.py cleanup -t <tool>`

