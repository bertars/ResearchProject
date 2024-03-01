RUN_DURATION=600 # 10 minutes
COOLDOWN_PERIOD=300 # 5 minutes
RUNS_PER_CONFIGURATION=8
combinations_dir="env_files"
env_file="combination_27.env"

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
for run in $(seq 1 $RUNS_PER_CONFIGURATION); do
    echo "Starting Docker environment with Zipkin configurations and microservices at $(date "+%T.%6N")"
    # docker compose -f deployment/zipkin/docker-compose-zipkin.yml --env-file "env_files/combination_2.env" up -d
    docker compose -f deployment/zipkin/docker-compose-zipkin.yml --env-file "${combinations_dir}/${env_file}" start

    echo "Services started!"

    executionStartTime=$(date "+%T.%6N")
    echo "Running ${env_file} iteration ${run} at $executionStartTime"

    curl localhost:8080 > /dev/null 2>&1 &
    curl localhost:9411/zipkin > /dev/null 2>&1 &

    start_data_collection "${env_file}_run${run}"

    # stop_data_collection

    executionStopTime=$(date "+%T.%6N")
    echo "Stopped ${env_file}${run} at $executionStopTime"
    echo "${env_file}, run${run}, $executionStartTime, $executionStopTime" >> logs/${env_file}.csv

    echo "Stopping services"
    docker compose -f deployment/zipkin/docker-compose-zipkin.yml --env-file "${combinations_dir}/${env_file}" stop
    # docker compose -f deployment/zipkin/docker-compose-zipkin.yml --env-file "${combinations_dir}/${env_file}" down

    echo "Cooling down at $(date "+%T.%6N")"
    sleep $COOLDOWN_PERIOD
done
# for env_file in $(ls $combinations_dir); do
#     for run in $(seq 1 $RUNS_PER_CONFIGURATION); do
#         echo "Starting Docker environment with Zipkin configurations and microservices at $(date "+%T.%6N")"
#         # docker compose -f deployment/zipkin/docker-compose-zipkin.yml --env-file "${combinations_dir}/${env_file}" up -d
#         docker compose -f deployment/zipkin/docker-compose-zipkin.yml --env-file "${combinations_dir}/${env_file}" start

#         echo "Services started!"

#         executionStartTime=$(date "+%T.%6N")
#         echo "Running ${env_file} iteration ${run} at $executionStartTime"

#         curl localhost:8080 > /dev/null 2>&1 &
#         curl localhost:9411/zipkin > /dev/null 2>&1 &
        
#         start_data_collection "${env_file}_run${run}"

#         stop_data_collection

#         executionStopTime=$(date "+%T.%6N")
#         echo "Stopped ${env_file}${run} at $executionStopTime"
#         echo "${env_file}, run${run}, $executionStartTime, $executionStopTime" >> logs/${env_file}_log_${run}.csv

#         echo "Stopping services"
#         docker compose -f deployment/zipkin/docker-compose-zipkin.yml --env-file "${combinations_dir}/${env_file}" stop
#         # docker compose -f deployment/zipkin/docker-compose-zipkin.yml --env-file "${combinations_dir}/${env_file}" down

#         echo "Cooling down at $(date "+%T.%6N")"
#         sleep $COOLDOWN_PERIOD
#     done
# done

echo "Experiment completed!"
