RUN_DURATION=600 # 10 minutes
COOLDOWN_PERIOD=300 # 5 minutes
RUNS_PER_CONFIGURATION=8

# Function to start data collection
start_data_collection() {
    echo "Starting data collection for $1 at $(date "+%T.%6N")"
    # Start Scaphandre for power monitoring
    scaphandre --exporter prometheus &> "scaphandre_$1.log" &
    
    # Start WattsUpPro monitoring
    echo python3 ../wattsuppro_logger/WattsupPro.py -l -o gl4.log -p /dev/ttyUSB1 > /dev/null 2>&1 &

    
    # Start network traffic capture
    # tcpdump -i docker0 -w "network_$1.pcap" &
}

stop_data_collection() {
    echo "Stopping data collection at $(date "+%T.%6N")"
    killall scaphandre
    pkill -f ../wattsuppro_logger-main/WattsupPro.py
}


for run in $(seq 1 $RUNS_PER_CONFIGURATION); do
    echo "Running baseline ${run} at $(date "+%T.%6N")"

    start_data_collection "$baseline_run${run}"

    echo "Starting Docker environment with Zipkin configurations and microservices at $(date "+%T.%6N")"
    docker-compose -f deployment/baseline/docker-compose-baseline.yml --env-file .env up -d

    sleep $RUN_DURATION

    docker-compose down

    stop_data_collection

    echo "Cooling down at $(date "+%T.%6N")"
    sleep $COOLDOWN_PERIOD
done


echo "Baseline completed!"
