RUN_DURATION=600 # 10 minutes
COOLDOWN_PERIOD=300 # 5 minutes
RUNS_PER_CONFIGURATION=8


# Function to start data collection
start_data_collection() {
    echo "Starting data collection for $1 at $(date "+%T.%6N")"
    echo "Running Scaphandre..."
    docker run --name scaphandre_$1 -v /sys/class/powercap:/sys/class/powercap -v /proc:/proc -v /var/run/docker.sock:/var/run/docker.sock --privileged -ti hubblo/scaphandre json -t $RUN_DURATION --containers >> "logs/scaphandre_$1.log"  
}

# stop_data_collection() {
#     echo "Stopping data collection at $(date "+%T.%6N")"
#     docker stop scaphandre_1
#     docker rm scaphandre_1
# }

mkdir -p logs


for run in $(seq 1 $RUNS_PER_CONFIGURATION); do
    echo "Starting Docker environment with Zipkin configurations and microservices at $(date "+%T.%6N")"
    # docker compose -f deployment/baseline/docker-compose-baseline.yml --env-file .env up -d
    docker compose -f deployment/baseline/docker-compose-baseline.yml --env-file .env start

    # echo "Waiting for services to start"
    # sleep $CONTAINER_START_TIMEOUT
    echo "Services started!"

    executionStartTime=$(date "+%T.%6N")
    echo "Running baseline ${run} at $executionStartTime"

    curl localhost:8080 > /dev/null 2>&1 &

    start_data_collection "$baseline_run${run}"

    # stop_data_collection

    executionStopTime=$(date "+%T.%6N")
    echo "Stopped baseline at $executionStopTime"
    echo "baseline, run${run}, $executionStartTime, $executionStopTime" >> logs/baseline.csv

    echo "Stopping services"
    docker compose -f deployment/baseline/docker-compose-baseline.yml --env-file .env stop
    # docker compose -f deployment/baseline/docker-compose-baseline.yml --env-file .env down

    echo "Cooling down at $(date "+%T.%6N")"
    sleep $COOLDOWN_PERIOD
done


echo "Baseline completed!"
