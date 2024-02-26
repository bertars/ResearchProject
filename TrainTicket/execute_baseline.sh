RUN_DURATION=60 # 10 minutes
COOLDOWN_PERIOD=30 # 5 minutes
RUNS_PER_CONFIGURATION=8
CONTAINER_START_TIMEOUT=20
LOGS_EXTRACTION_TIMEOUT=10

# Function to start data collection
start_data_collection() {
    echo "Starting data collection for baseline at $(date "+%T.%6N")"
    # Start Scaphandre for power monitoring
    # docker run -d --name scaphandre_1 \
    #     -v /sys/class/powercap:/sys/class/powercap \
    #     -v /proc:/proc \
    #     -v /var/run/docker.sock:/var/run/docker.sock \
    #     --privileged -ti hubblo/scaphandre json -t $RUN_DURATION >> "logs/scaphandre_1.log" 
    docker run --name scaphandre_1 -v /sys/class/powercap:/sys/class/powercap -v /proc:/proc -v /var/run/docker.sock:/var/run/docker.sock --privileged -ti hubblo/scaphandre json -t $RUN_DURATION --containers >> "logs/scaphandre_1.json" 
    
    
}

stop_data_collection() {
    echo "Stopping data collection at $(date "+%T.%6N")"
    docker stop scaphandre_1
    docker rm scaphandre_1
}

mkdir -p logs

echo "Starting Docker environment with Zipkin configurations and microservices at $(date "+%T.%6N")"
docker compose -f deployment/baseline/docker-compose-baseline.yml --env-file .env up -d

# echo "Waiting for services to start"
# sleep $CONTAINER_START_TIMEOUT
echo "Services started!"

executionStartTime=$(date "+%T.%6N")
echo "Running baseline 1 at $executionStartTime"

start_data_collection "$baseline_run1"

curl localhost:8080 > /dev/null 2>&1 &

echo "Sleeping..."
sleep $RUN_DURATION

stop_data_collection

executionStopTime=$(date "+%T.%6N")
echo "Stopped baseline at $executionStopTime"
echo "baseline, run1, $executionStartTime, $executionStopTime" >> logs/baseline_log_1.csv

echo "Stopping services"
docker compose -f deployment/baseline/docker-compose-baseline.yml --env-file .env down

echo "Cooling down at $(date "+%T.%6N")"
sleep $COOLDOWN_PERIOD

# for run in $(seq 1 $RUNS_PER_CONFIGURATION); do
#     echo "Starting Docker environment with Zipkin configurations and microservices at $(date "+%T.%6N")"
#     docker-compose -f deployment/baseline/docker-compose-baseline.yml --env-file .env up -d

#     echo "Waiting for services to start"
#     sleep $CONTAINER_START_TIMEOUT
#     echo "Services started!"

#     executionStartTime=$(date "+%T.%6N")
#     echo "Running baseline ${run} at $(date "+%T.%6N")"
    
#     start_data_collection "$baseline_run${run}"

#     sleep $RUN_DURATION

#     stop_data_collection

#     executionStopTime=$(date "+%T.%6N")
#     echo "Stopped baseline at $executionStopTime"
#     echo "baseline, run${run}, $executionStartTime, $executionStopTime" >> logs/baseline_log_${run}.csv

#     echo "Stopping services"
#     docker-compose -f deployment/baseline/docker-compose-baseline.yml --env-file .env down

#     echo "Cooling down at $(date "+%T.%6N")"
#     sleep $COOLDOWN_PERIOD
# done


echo "Baseline completed!"
