import glob
from datetime import datetime, timedelta
from enum import Enum
import numpy as np

import pandas as pd
from pathlib import Path

RAW_DATA_PATH = Path('raw_data_experiment')
RESULT_PATH = Path("data_experiment")
RUN_RESULT_PATH = "data_experiment/{frequency}/{workload}/{tool}/{run_number}"
WATTSUP_HEADERS = ["date", "time", "timestamp", "energy_consumption", "v2", "v3"]
RUN_COLUMNS = ['tool', 'frequency', 'workload', 'timestamp', 'run_number']


class SAR_FILES(Enum):
    CPU = "cpu"
    IP = "ip"
    MEMORY = "memory"
    RUN_QUEUE = "q"
    SWAP_SPACE = "S"
    SOCKET = "sock"
    TCP = "tcp"
    UDP = "udp"
    PROCESSES = "w"
    PAGING = "paging"
    SWAP = "swap"


class Metric:
    def __init__(self, name, sar_file, series_extractor, reducer=None):
        self.name = name
        self.sar_file = sar_file
        self.series_extractor = series_extractor  # extracts a column of values
        self.reducer = reducer  # operation to aggregate the series to a single value


SAR_METRICS = [
    Metric("page_in", SAR_FILES.PAGING, lambda data: data["pgpgin/s"]),
    Metric("paged_out", SAR_FILES.PAGING, lambda data: data["pgpgout/s"]),
    Metric("paged_in_out", SAR_FILES.PAGING,
           lambda data: data["pgpgin/s"].astype(float) + data["pgpgout/s"].astype(float)),
    Metric("cpu_usage_percentage", SAR_FILES.CPU, lambda data: data["%user"].astype(float), "mean"),  # mean
    Metric("delivered_datagrams_count", SAR_FILES.IP, lambda data: data["idel/s"]),
    Metric("received_datagrams_count", SAR_FILES.IP, lambda data: data["irec/s"]),
    Metric("total_datagrams_count", SAR_FILES.IP,
           lambda data: data["idel/s"].astype(float) + data["irec/s"].astype(float), "sum"),  # sum
    Metric("memory_usage_percentage", SAR_FILES.MEMORY, lambda data: data["%memused"].astype(float), "mean"),  # mean
    Metric("tasks_waiting_count", SAR_FILES.RUN_QUEUE, lambda data: data["runq-sz"]),
    Metric("load_avg", SAR_FILES.RUN_QUEUE, lambda data: data["ldavg-1"].astype(float), "mean"),  # mean
    Metric("tasks_in_task_view", SAR_FILES.RUN_QUEUE, lambda data: data["plist-sz"]),
    Metric("swap_percentage", SAR_FILES.SWAP_SPACE, lambda data: data["%swpused"]),
    Metric("total_sockets_count", SAR_FILES.SOCKET, lambda data: data["totsck"]),
    Metric("tcp_sockets_count", SAR_FILES.SOCKET, lambda data: data["tcpsck"]),
    Metric("udp_sockets_count", SAR_FILES.SOCKET, lambda data: data["udpsck"]),
    Metric("tcp_segments_received_count", SAR_FILES.TCP, lambda data: data["iseg/s"]),
    Metric("tcp_segments_sent_count", SAR_FILES.TCP, lambda data: data["oseg/s"]),
    Metric("total_tcp_segments_count", SAR_FILES.TCP,
           lambda data: data["iseg/s"].astype(float) + data["oseg/s"].astype(float)),
    Metric("udp_datagrams_send_count", SAR_FILES.UDP, lambda data: data["odgm/s"]),
    Metric("udp_datagrams_delivered_count", SAR_FILES.UDP, lambda data: data["idgm/s"]),
    Metric("total_udp_datagrams_count", SAR_FILES.UDP,
           lambda data: data["odgm/s"].astype(float) + data["idgm/s"].astype(float)),
    Metric("total_context_switches_count", SAR_FILES.PROCESSES, lambda data: data["proc/s"]),
    Metric("total_tasks_created_per_sec_count", SAR_FILES.PROCESSES, lambda data: data["cswch/s"])
]

COLUMNS = RUN_COLUMNS + ["energy_consumption"] + [m.name for m in SAR_METRICS]


def read_file(file_path, headers=None):
    valid_files = glob.glob(str(file_path))
    if not len(valid_files):
        raise Exception(f"Invalid input: {len(valid_files)} no files found for pattern")
    valid_files.sort()
    return pd.read_csv(valid_files[-1], delimiter=" ", names=headers)


def get_whatsapp_data(row):
    file_name = f"sample*-{row['run_number']}-{row['tool']}-{row['frequency']}-{row['workload']}.log"
    file_path = RAW_DATA_PATH / Path(row['run_number']) / Path("wattsup") / Path(file_name)
    dataset = read_file(file_path, WATTSUP_HEADERS)

    # We drop last row as it might be incomplete
    return dataset.iloc[:-1, :]


def get_sar_file(row, metric):
    file_path = RAW_DATA_PATH / Path(row['run_number']) / Path("sar") / Path(
        f"{metric.value}-{row['run_number']}-{row['tool']}-{row['frequency']}-{row['workload']}.log")

    with file_path.open() as f:
        lines = f.readlines()

    # Ignore first 2 lines (Test information) and last line (Average)
    lines = lines[2:-1]

    # Remove extra empty space
    lines = [' '.join(line.split()) for line in lines]
    headers = [h for h in lines[0].split(" ") if h != '']
    start_time = lines[1][0]

    # Fix separator issue (. is used for thousands , for decimals)
    lines = [line.replace(".", "").replace(",", ".") for line in lines]

    headers[0] = "time"
    parsed_line = [line.split(" ") for line in lines[1:]]
    rez = pd.DataFrame(parsed_line, columns=headers)

    return rez, start_time


def whattsup_time_to_sar_format(time_str, sar_time):
    # in case miliseconds are 0
    if len(time_str) == 8:
        time_str = f"{time_str}.000000"
    tm = datetime.strptime(time_str, "%H:%M:%S.%f")
    sar_tm = datetime.strptime(sar_time, "%H:%M:%S")

    min_t, max_t = min(tm, sar_tm), max(tm, sar_tm)

    diff_s =  (min_t - max_t).seconds if min_t.hour == 0 and max_t.hour == 23 else (max_t - min_t).seconds

    if diff_s < 3600 + 401:
        tm += timedelta(hours=1)
    else:
        tm += timedelta(hours=2)
    return tm.strftime("%H:%M:%S")


def get_sar_start_time(sar_data):
    return max([(sar_data[key][0].loc[0]['time']) for key in sar_data])


def calculate_official_start_time(sar_data, wattsup_data):
    sar_start_time = get_sar_start_time(sar_data)
    whatsup_time = wattsup_data['sar_time'][0]

    return max(whatsup_time, sar_start_time)


def trim_sar_data(data, official_start_time):
    return data[(data['time'] >= official_start_time) | ((data['time'].str[:2] == "00") & (official_start_time[:2] == "23"))]


def create_metrics_data_frame_for_run(series):
    dt = pd.DataFrame()
    min_timestamp = min([len(series[s]) for s in series])
    dt['timestamp'] = np.arange(min_timestamp)

    for column_name in series:
        dt[column_name] = series[column_name].head(min_timestamp)
    return dt.set_index("timestamp")


def create_metric_aggregation_for_run(run_dt, row, max_duration):
    rez = {'tool': row['tool'], 'frequency': row['frequency'], 'workload': row['workload'],
           'run_number': row['run_number'], 'duration': max_duration,
           'energy_consumption': run_dt['energy_consumption'].sum()}

    for metric in SAR_METRICS:
        if metric.reducer:
            rez[metric.name] = getattr(run_dt[metric.name], metric.reducer)()

    return rez


def process_data():
    run_table = pd.read_csv(str(RAW_DATA_PATH / Path("run_table.csv")))

    aggregation_per_run = []

    for dt_row in run_table.iterrows():
        row = dt_row[1]
        if row['__done'] != 'DONE':
            continue

        print(f"Parsing results for row {row['run_number']} - {row['tool']} - {row['frequency']} - {row['workload']}")

        # Collect sar data
        sar_data = {sar_file: get_sar_file(row, sar_file) for sar_file in SAR_FILES}

        wattsup_data = get_whatsapp_data(row)
        # Create new column compatible to SAR
        wattsup_data['sar_time'] = wattsup_data.apply(lambda row: whattsup_time_to_sar_format(row['time'], get_sar_start_time(sar_data)), axis=1)

        # Calculate start time
        official_start_time = calculate_official_start_time(sar_data, wattsup_data)

        # Trim entries that are registered before official_start_time
        wattsup_trimmed_data = wattsup_data[wattsup_data['sar_time'] >= official_start_time]
        trimmed_sar_data = {metric: trim_sar_data(sar_data[metric][0], official_start_time) for metric in SAR_FILES}

        # Calculate new metrics
        metrics = {metric.name: metric.series_extractor(trimmed_sar_data[metric.sar_file]) for metric in SAR_METRICS}
        metrics["energy_consumption"] = wattsup_trimmed_data["energy_consumption"]

        # Save run metrics
        run_metrics = create_metrics_data_frame_for_run(metrics)
        save_run_metrics(row, run_metrics)
        aggregation_per_run.append(create_metric_aggregation_for_run(run_metrics, row,
                                                                     max([len(metrics[m]) for m in metrics])))
        # if row['tool'] == 'baseline':
        #     # Save copy of baseline results as F_MEDIUM and F_HIGH
        #     for frequency in ['F_MEDIUM', 'F_HIGH']:
        #         row['frequency'] = frequency
        #         save_run_metrics(row, run_metrics)
        #         aggregation_per_run.append(create_metric_aggregation_for_run(run_metrics, row,
        #                                                                      max([len(metrics[m]) for m in
        #                                                                               metrics])))

    return pd.DataFrame(aggregation_per_run).set_index(['frequency', 'workload', 'tool', 'run_number'])


def save_run_metrics(row, run_metrics):
    run_path = Path(RUN_RESULT_PATH.format(frequency=row['frequency'],
                                           tool=row['tool'],
                                           run_number=row['run_number'],
                                           workload=row['workload']))
    run_path.mkdir(parents=True, exist_ok=True)
    run_metrics.to_csv(str(run_path / Path("data.csv")), header=False)


if __name__ == '__main__':
    processed_data = process_data()
    processed_data.to_csv(str(RESULT_PATH / Path("data.csv")))
