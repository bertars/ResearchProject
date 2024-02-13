RUN_DURATION=60 # 10 minutes
COOLDOWN_PERIOD=30 # 5 minutes
RUNS_PER_CONFIGURATION=8
CONTAINER_START_TIMEOUT=20
LOGS_EXTRACTION_TIMEOUT=10

# Function to start data collection
start_data_collection() {
    echo "Starting data collection for $1 at $(date "+%T.%6N")"
    # Start Scaphandre for power monitoring
    # scaphandre --exporter prometheus &> "logs/scaphandre_$1.log" &
    
    # Start WattsUpPro monitoring
    # echo python3 ../wattsuppro_logger/WattsupPro.py -l -o gl4.log -p /dev/ttyUSB2 > /dev/null 2>&1 &

    
}

stop_data_collection() {
    echo "Stopping data collection at $(date "+%T.%6N")"
    # killall scaphandre
    # pkill -f ../wattsuppro_logger-main/WattsupPro.py
}

mkdir -p logs

for run in $(seq 1 $RUNS_PER_CONFIGURATION); do
    echo "Starting Docker environment with Zipkin configurations and microservices at $(date "+%T.%6N")"
    docker-compose -f deployment/baseline/docker-compose-baseline.yml --env-file .env up -d

    echo "Waiting for services to start"
    sleep $CONTAINER_START_TIMEOUT
    echo "Services started!"

    executionStartTime=$(date "+%T.%6N")
    echo "Running baseline ${run} at $(date "+%T.%6N")"
    
    start_data_collection "$baseline_run${run}"

    sleep $RUN_DURATION

    stop_data_collection

    executionStopTime=$(date "+%T.%6N")
    echo "Stopped baseline at $executionStopTime"
    echo "baseline, run, $executionStartTime, $executionStopTime" >> logs/baseline_log_${run}.csv

    echo "Stopping services"
    docker-compose -f deployment/baseline/docker-compose-baseline.yml --env-file .env down

    echo "Cooling down at $(date "+%T.%6N")"
    sleep $COOLDOWN_PERIOD
done


echo "Baseline completed!"
