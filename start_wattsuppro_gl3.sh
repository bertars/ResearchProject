RUN_DURATION=600 # 10 minutes
COOLDOWN_PERIOD=300 # 5 minutes
RUNS_PER_CONFIGURATION=8
CONTAINER_START_TIMEOUT=20
CONTAINER_STOP_TIMEOUT=15
EXTRA_LOGGING_TIME=20
SudoPassword=$(echo $(head -n 5 ./TrainTicket/.env | tail -1 | cut -d '=' -f 2))
LoggingDuration=$(( ($CONTAINER_START_TIMEOUT + $RUN_DURATION + $CONTAINER_STOP_TIMEOUT + $COOLDOWN_PERIOD + $EXTRA_LOGGING_TIME) * $RUNS_PER_CONFIGURATION)) 
env_file="baseline"
# echo "Waiting for services to start"
# sleep $CONTAINER_START_TIMEOUT

loggingStartTime=$(date "+%T.%6N")
echo "Monitoring baseline 1 at $loggingStartTime"

echo $SudoPassword | sudo -S python3 ./wattsuppro_logger-main/WattsupPro.py -l -o gl3_$env_file.log -p /dev/ttyUSB0 -t $LoggingDuration

echo "Finished monitoring!"
# echo "Waiting for services to stop"
# sleep $CONTAINER_STOP_TIMEOUT

# echo "Cooling down at $(date "+%T.%6N")"
# sleep $COOLDOWN_PERIOD

# for run in $(seq 1 $RUNS_PER_CONFIGURATION); do
#     echo "Waiting for services to start"
#     sleep $CONTAINER_START_TIMEOUT

#     loggingStartTime=$(date "+%T.%6N")
#     echo "Monitoring baseline ${run} at $loggingStartTime"

#     sudo python3 ./wattsuppro_logger-main/WattsupPro.py -l -o gl3_baseline${run}.log -p /dev/ttyUSB0 -t $RUN_DURATION

#     echo "Cooling down at $(date "+%T.%6N")"
#     sleep $COOLDOWN_PERIOD
# done