import enum
import os, glob
import json
import re


class WorkloadValidation(enum.Enum):
    """
    Workload = the number of vus
    value 1 - the number of iterations
    value 2 - the number of fails allowed
    """
    W_LOW = (345, 5000)
    W_MEDIUM = (690, 9100)
    W_HIGH = (1380, 18100)


path = 'raw_data_experiment_5/reports'


def validate_runs():
    for filename in glob.glob(os.path.join(path, '*.json')):
        with open(os.path.join(os.getcwd(), filename), 'r') as f:
            data = json.load(f)

        passes = data['metrics']['checks']['passes']
        fails = data['metrics']['checks']['fails']
        total = passes + fails

        parts = re.split('[-.]', filename)
        workload_level = parts[3]

        iterations = WorkloadValidation[workload_level].value[0]
        allowed_fails = WorkloadValidation[workload_level].value[1]

        if data['metrics']['iterations'] != iterations and total != iterations and fails > allowed_fails:
            print(f"{filename} with {data['metrics']['iterations']['count']} iterations and {fails} fails")


if __name__ == '__main__':
    validate_runs()
