The pipeline is implemented using [Experiment Runner](https://github.com/S2-group/experiment-runner).

This directory contains the RunnerConfig used to run the experiment.

Run experiment:

1. Install dependencies

`python3.8 -m pip install -r examples/monitoring-experiment/requirements.txt`

2. Run script

`python3.8 experiment-runner/ examples/monitoring-experiment/RunnerConfig-monitoring.py`

To avoid any kind of issues, it is recommended to have all the necessary images in the Docker build cache before running
the experiment.