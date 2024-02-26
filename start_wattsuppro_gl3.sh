RUN_DURATION=60 # 10 minutes
COOLDOWN_PERIOD=30 # 5 minutes
RUNS_PER_CONFIGURATION=8
CONTAINER_START_TIMEOUT=20
CONTAINER_STOP_TIMEOUT=5
LOGS_EXTRACTION_TIMEOUT=10

echo "Waiting for services to start"
sleep $CONTAINER_START_TIMEOUT

loggingStartTime=$(date "+%T.%6N")
echo "Monitoring baseline 1 at $loggingStartTime"

sudo python3 ./wattsuppro_logger-main/WattsupPro.py -l -o gl3_baseline1.log -p /dev/ttyUSB0 -t $RUN_DURATION

echo "Waiting for services to start"
sleep $CONTAINER_STOP_TIMEOUT

echo "Cooling down at $(date "+%T.%6N")"
sleep $COOLDOWN_PERIOD

# for run in $(seq 1 $RUNS_PER_CONFIGURATION); do
#     echo "Waiting for services to start"
#     sleep $CONTAINER_START_TIMEOUT

#     loggingStartTime=$(date "+%T.%6N")
#     echo "Monitoring baseline ${run} at $loggingStartTime"

#     sudo python3 ./wattsuppro_logger-main/WattsupPro.py -l -o gl3_baseline${run}.log -p /dev/ttyUSB0 -t $RUN_DURATION

#     echo "Cooling down at $(date "+%T.%6N")"
#     sleep $COOLDOWN_PERIOD
# done