import enum
import os
import shutil
from functools import partial

import click


class Tools(enum.Enum):
    ELASTIC = "elastic"
    NETDATA = "netdata"
    PROMETHEUS = "prometheus"
    ZIPKIN = "zipkin"
    BASELINE = "baseline"


class Frequency(enum.Enum):
    MEDIUM = "medium"
    LOW = "low"
    HIGH = "high"


def change_last_line_of_file(file_path, last_line):
    with open(file_path, "r") as file:
        lines = file.readlines()

    lines[-1] = last_line

    with open(file_path, "w") as file:
        file.writelines(lines)


def update_elastic(frequency):
    config_value = {
        Frequency.LOW: 10,
        Frequency.MEDIUM: 5,
        Frequency.HIGH: 1
    }
    file_path = "/etc/metricbeat/metricbeat.yml"
    new_config = f"metrics.period: {config_value[frequency]}"

    # modify the last line of /etc/metricbeat/metricbeat.yml to change the metrics.period = {value}
    change_last_line_of_file(file_path, new_config)

    print(f"Updated metricbeat.yml with value {config_value[frequency]}")
    copy_to_main_docker_compose("deployment/elastic/docker-compose-elastic.yml")


def update_netdata(frequency):
    config_value = {
        Frequency.LOW: 10,
        Frequency.MEDIUM: 5,
        Frequency.HIGH: 1
    }

    conf = f"""
[global]
  update every = {config_value[frequency]}
"""
    file_path = "deployment/netdata/netdata.conf"
    with open(file_path, "w") as file:
        file.write(conf)
    shutil.copy(file_path, "netdata.conf")
    print(f"Updated netdata.conf with value {config_value[frequency]}")
    copy_to_main_docker_compose("deployment/netdata/docker-compose-netdata.yml")


def update_prometheus(frequency):
    config_value = {
        Frequency.LOW: 10,
        Frequency.MEDIUM: 5,
        Frequency.HIGH: 1
    }
    file_path = "deployment/prometheus/prometheus.yml"
    new_config = f"  scrape_interval: {config_value[frequency]}s"

    # modify the last line of /prometheus/prometheus.yml to change the metrics.period = {value}
    change_last_line_of_file(file_path, new_config)

    print(f"Updated prometheus.yml with value {config_value[frequency]}")
    shutil.copy(file_path, "prometheus.yml")
    copy_to_main_docker_compose("deployment/prometheus/docker-compose-prometheus.yml")


def update_baseline(_):
    copy_to_main_docker_compose("deployment/baseline/docker-compose-baseline.yml")
    print(f"Update docker compose for baseline")


def update_docker_compose(tool, frequency):
    source_docker_file = f"deployment/{tool}/docker-compose-{tool}-{frequency.value}.yml"
    copy_to_main_docker_compose(source_docker_file)
    print(f"Update docker compose for {tool} with frequency {frequency}")


def copy_to_main_docker_compose(source_docker_file):
    shutil.copy(source_docker_file, "docker-compose.yml")


def noop():
    print("No action required")


def elastic_setup():
    os.system("systemctl start metricbeat")


def elastic_cleanup():
    os.system("systemctl stop metricbeat")
    docker_compose_cleanup()


def netdata_cleanup():
    os.remove("netdata.conf")
    docker_compose_cleanup()


def prometheus_cleanup():
    docker_compose_cleanup()
    os.remove("prometheus.yml")


def docker_compose_cleanup():
    os.system("docker compose down")
    os.remove("docker-compose.yml")
    pass


def update_config_for_tool(tool, frequency):
    print(f"CONFIG UPDATE -- Updating {tool} with {frequency}")
    UPDATE_CONFIG_FUNC[Tools(tool)](Frequency(frequency))
    print(f"CONFIG UPDATE -- Done")


UPDATE_CONFIG_FUNC = {
    Tools.ELASTIC: update_elastic,
    Tools.NETDATA: update_netdata,
    Tools.PROMETHEUS: update_prometheus,
    Tools.ZIPKIN: partial(update_docker_compose, Tools.ZIPKIN.value),
    Tools.BASELINE: update_baseline,
}

SETUP = {
    Tools.ELASTIC: elastic_setup,
    Tools.NETDATA: noop,
    Tools.PROMETHEUS: noop,
    Tools.ZIPKIN: noop,
    Tools.BASELINE: noop,
}

CLEANUP = {
    Tools.ELASTIC: elastic_cleanup,
    Tools.NETDATA: netdata_cleanup,
    Tools.PROMETHEUS: prometheus_cleanup,
    Tools.ZIPKIN: docker_compose_cleanup,
    Tools.BASELINE: docker_compose_cleanup,
}

@click.group()
def cli():
    pass


@click.command()
@click.option('-t', '--tool', type=click.Choice([tool.value for tool in Tools]),
              required=True,
              help='The tool for which you want to update the config')
@click.option('-f', '--frequency', required=True, type=click.Choice([f.value for f in Frequency]),
              help='The frequency that will be updated for the config')
def update_config(tool, frequency):
    update_config_for_tool(tool, frequency)


@click.command()
@click.option('-t', '--tool', type=click.Choice([tool.value for tool in Tools]),
              required=True,
              help='The tool for which you want to update the config')
@click.option('-f', '--frequency', required=True, type=click.Choice([f.value for f in Frequency]),
              help='The value that will be updated for the config')
def run_stack(tool, frequency):
    # Step 1 - Update config
    update_config_for_tool(tool, frequency)

    print(f"STEP 2 -- SETUP")
    SETUP[Tools(tool)]()

    print(f"STEP 3 -- RUN application")
    os.system("docker compose up")


@click.command()
@click.option('-t', '--tool', type=click.Choice([tool.value for tool in Tools]),
              required=True,
              help='The tool for which you want to update the config')
def cleanup(tool):
    print(f"Cleanup")
    CLEANUP[Tools(tool)]()


cli.add_command(update_config)
cli.add_command(run_stack)
cli.add_command(cleanup)


if __name__ == '__main__':
    cli()
