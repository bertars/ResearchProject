# ICSOC 2023 - Replication package
Replication package for the paper titled __An Empirical Evaluation of the Energy and Performance Overhead of Monitoring Tools on Docker-based Systems__ and published at [ICSOC 2023](https://icsoc2023.diag.uniroma1.it).

The preprint of the study is available [here](http://www.ivanomalavolta.com/files/papers/ICSOC_2023.pdf).

This repo contains the raw data and analysis scripts related to all the activities carried out for the experimentation. It also contains the TrainTicket benchmark system with the integration of four monitoring tools.

This study has been designed, developed, and reported by the following investigators:
- Madalina Dinga (VU Amsterdam)
- Ivano Malavolta (VU Amsterdam)
- Luca Giamattei (University of Naples Federico II)
- Antonio Guerriero (University of Naples Federico II)
- Roberto Pietrantuono (University of Naples Federico II)

For any information, interested researchers can contact us by sending an email to any of the investigators listed above.

## How to cite the dataset
If the dataset and/or experiment setup is helping your research, consider to cite our study as follows, thanks!

```
@inproceedings{10.1145/3593434.3593454,
	author = {Madalina Dinga and Ivano Malavolta and Luca Giamattei and Antonio Guerriero and Roberto Pietrantuono},
	title = {{An Empirical Evaluation of Energy and Performance Overhead of Monitoring Tools on Docker-based Systems}},
	year = {2023},
	url = {http://www.ivanomalavolta.com/files/papers/ICSOC_2023.pdf},
	booktitle = {Proceedings of the 21st International Conference on Service-Oriented Computing},
	pages = {To appear},
	numpages = {15},
	location = {Rome, Italy},
	series = {ICSOC '23}
}
```

## Instructions for replicating the experiment

### 1. Experiment execution

Experiment-runner is used for automating the execution of the experiments.

#### Infrastructure setup

The experiment uses the version of TTS available in the [TrainTicket](./TrainTicket) folder. It includes the integration of the TTS with a selection of four monitoring tools (ELK stack, Netdata, Prometheus and Zipkin) and the set of a set of 34 load test scripts generated with [K6](https://k6.io/). Please check [this readme](./TrainTicket/readme.md) file for the detailed instructions about how to setup and deploy the various versions of the TTS used in this experiment. 

The pipeline can be triggered using Experiment-Runner with the `RunnerConfig-monitoring.py` specification. Please follow
the instructions in the project [README](https://github.com/S2-group/experiment-runner).

#### Required software
1. **K6** is required to be installed on the machine for running the K6 load test scripts.
2. Python3, required by Experiment-Runner
3. [Experiment-Runner](https://github.com/S2-group/experiment-runner) - Note that the framework is not supported on
   Windows. 

### 2. Data analysis

Data processing and data analysis scripts for data obtained during the experiment performed on the [Train Ticket system](https://github.com/FudanSELab/train-ticket) are available in the [data](./data) folder.
