#!/usr/bin/env bash


TMP_METRICS_WEB_DIR=$(mktemp -d)
LISTENING_PORT=3000



function getTotalInboundTraffic(){
    local receivedBytes=0
    local networkDevices=$(ls /sys/class/net/ | grep -v lo)

    local bytesBefore=0
    for device in ${networkDevices}; do
        local bytesOnDevice=$(cat /sys/class/net/${device}/statistics/rx_bytes)
        bytesBefore=$((${bytesBefore} + ${bytesOnDevice}))
    done

    sleep 1

    local bytesAfter=0
    for device in ${networkDevices}; do
        local bytesOnDevice=$(cat /sys/class/net/${device}/statistics/rx_bytes)
        bytesAfter=$((${bytesAfter} + ${bytesOnDevice}))
    done

    receivedBytes=$((${bytesAfter} - ${bytesBefore}))
    echo "${receivedBytes}"
}


function getTotalCountOfProcesses(){
    local processCount=0
    processCount=$(ps aux | wc -l)
    echo "${processCount}"
}


function getTotalMemoryUsage(){
    local memoryInKibibytes=0
    memoryInKibibytes=$(free -k | grep Mem | awk -F " " '{ print $2}')
    echo "${memoryInKibibytes}"
}


function getTotalUptime(){
    local uptimeInSeconds=0
    uptimeInSeconds=$(cat /proc/uptime | awk -F " " '{ print $1}')
    echo ""${uptimeInSeconds}""
}



# Replace file content after every sleep cycle
( while true; do

    printf "%s\n" \
        "# HELP process_count_total Amount of running processes" \
        "# TYPE process_count_total gauge" \
        "process_count_total $(getTotalCountOfProcesses)" \
        "" \
        "# HELP memory_utilization_total_kib Amount of currently used memory" \
        "# TYPE memory_utilization_total_kib gauge" \
        "memory_utilization_total_kib $(getTotalMemoryUsage)" \
        "" \
        "# HELP uptime_total_seconds Amount of time the system is running already" \
        "# TYPE uptime_total_seconds counter" \
        "uptime_total_seconds $(getTotalUptime)" \
        "" \
        "# HELP traffic_inbound_total_bytes_per_second Amount of receiving traffic within a second across all network interfaces, except lo" \
        "# TYPE traffic_inbound_total_bytes_per_second gauge" \
        "traffic_inbound_total_bytes_per_second $(getTotalInboundTraffic)" \
    > "${TMP_METRICS_WEB_DIR}/index.html"

    sleep 3;

done ) & PIDS[1]=$!


# Start web server to serve metrics file
( python3 -m http.server \
    --bind 0.0.0.0 \
    --directory "${TMP_METRICS_WEB_DIR}" \
    "${LISTENING_PORT}"
) & PIDS[2]=$!



function quit(){
    for PID in ${PIDS[*]}; do kill -s SIGTERM ${PID}; done;
    rm -rf "${TMP_METRICS_WEB_DIR}"
    exit 0
}

trap quit SIGINT SIGTERM

wait
