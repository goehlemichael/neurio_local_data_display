NEURIO_IP=
USER=
PASSWORD=
DISPLAY=:0
TEMP_DATA_FILE=$(mktemp)
TEMP_GNUPLOT_CONFIG_FILE=$(mktemp).gp
OUTPUT_TERMINAL_TYPE="${TERM_NAME:=x11}"

echo "temp data file location $TEMP_DATA_FILE"
echo "temp gnu plot config location $TEMP_GNUPLOT_CONFIG_FILE"

check_command() {
    if command -v $1 >/dev/null 2>&1; then
        echo "$1 is installed"
    else
        echo "$1 is not installed"
    fi
}

write_config() {
    local file=$1
    shift
    while (( "$#" )); do
        echo "$1" >> $file
        shift
    done
}

check_command curl
check_command jq
check_command gnuplot

: ${DISPLAY:=:0}

write_config $TEMP_GNUPLOT_CONFIG_FILE \
    "set terminal ${OUTPUT_TERMINAL_TYPE}" \
    "set datafile missing \"?\"" \
    "set xdata time" \
    "set timefmt \"%Y-%m-%d %H:%M:%S\"" \
    "set format x \"%H:%M:%S\"" \
    "set ytics font \"Times-Roman,36\"" \
    "set xrange [time(0)-120:time(0)]" \
    "set yrange [:]" \
    "set lmargin at screen 0.1" \
    "set rmargin at screen 0.9" \
    "set bmargin at screen 0.1" \
    "set tmargin at screen 0.9" \
    "plot \""$TEMP_DATA_FILE"\" using 1:3 with lines" \
    "pause 2" \
    "reread"

echo "$DISPLAY"
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
echo "$timestamp 100" >> "$TEMP_DATA_FILE"
gnuplot -p "$TEMP_GNUPLOT_CONFIG_FILE" &

fetch_and_process_data() {
    local data
    data=$(curl -s -X GET -u "${USER}:${PASSWORD}" -H "Content-Type:application/json" "${NEURIO_IP}/current-sample" | jq '.channels[] | select(.type == "CONSUMPTION").p_W')
    if [[ -n "$data" && "$data" -ne 0 ]]; then
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$timestamp $data" >> "$TEMP_DATA_FILE"
        sleep 2
    else
        echo "$timestamp ?" >> "$TEMP_DATA_FILE"
        logger "something went wrong with neurio datapoint $timestamp"
    fi
}

while true; do
    fetch_and_process_data
done
