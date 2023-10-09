NEURIO_IP=
USER=
PASSWORD=
DISPLAY=:0
TEMP_DATA_FILE=$(mktemp)
TEMP_GNUPLOT_CONFIG_FILE=$(mktemp).gp
OUTPUT_TERMINAL_TYPE="${TERM_NAME:=x11}"

echo "temp data file location $TEMP_DATA_FILE"
echo "temp gnu plot config location $TEMP_GNUPLOT_CONFIG_FILE"

if command -v curl >/dev/null 2>&1; then
    echo "curl is installed"
else
    echo "curl is not installed"
fi

if command -v jq >/dev/null 2>&1; then
    echo "jq is installed"
else
    echo "jq is not installed"
fi

if command -v gnuplot >/dev/null 2>&1; then
    echo "gnuplot is installed"
else
    echo "gnuplot is not installed"
fi

if [[ -z "${DISPLAY}" ]]; then
  echo "DISPLAY is not set. Setting it now."
  export DISPLAY=${DISPLAY}
fi

echo "set terminal ${OUTPUT_TERMINAL_TYPE}" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "set xdata time" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "set timefmt \"%Y-%m-%d %H:%M:%S\"" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "set format x \"%H:%M:%S\"" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "set ytics font \"Times-Roman,34\"" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "set xrange [time(0)-120:time(0)]" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "set yrange [:]" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "set lmargin at screen 0.1" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "set rmargin at screen 0.9" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "set bmargin at screen 0.1" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "set tmargin at screen 0.9" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "plot \""$TEMP_DATA_FILE"\" using 1:3 with lines" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "pause 2" >> $TEMP_GNUPLOT_CONFIG_FILE
echo "reread" >> $TEMP_GNUPLOT_CONFIG_FILE

echo "$DISPLAY"
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
echo "$timestamp 100" >> "$TEMP_DATA_FILE"
gnuplot "$TEMP_GNUPLOT_CONFIG_FILE" &

while true; do
    data=$(curl -s -X GET -u "${USER}:${PASSWORD}" -H "Content-Type:application/json" "${NEURIO_IP}/current-sample" | jq '.channels[] | select(.type == "CONSUMPTION").p_W')
    if [ $? -eq 0 ]; then
      if [[ -z "$data" ]]; then
            continue
        fi
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$timestamp $data" >> "$TEMP_DATA_FILE"
        sleep 2
    else
        logger "something went wrong with neurio datapoint $timestamp"
    fi
done
