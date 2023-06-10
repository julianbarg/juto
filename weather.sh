#!/usr/bin/env bash

API_KEY="$(cat $HOME/.openweather)"
CITY="N6A"
UNITS="METRIC"
CURRENT=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=${CITY},ca&appid=${API_KEY}&units=${UNITS}")
FORECAST=$(curl -s "http://api.openweathermap.org/data/2.5/forecast?q=${CITY},ca&appid=${API_KEY}&units=${UNITS}")

CURRENT_T="$(echo "$CURRENT" | yq '.main.feels_like')"
FORECAST_T="$(echo "$FORECAST" \
  | yq '[.list.[:6] | 
    .[] | [{"time": .dt_txt, "temp": .main.feels_like, "rain": .weather[0].description}] | 
    .[] | .time |= split(" ").[1] | 
    .time |= split(":").[0]]')"

echo "$FORECAST_T" > ~/out/test.yaml

echo "$FORECAST_T" | yq '.[] |= pick(["time", "rain"]) | .[] | [.time, .rain] | join("h: ")'

echo "$FORECAST_T" | yq '.' -o=csv \
  | awk 'BEGIN{FS=OFS=","} {if(NR==1){print "Index",$0}else{print (NR-2)*3,$0}}' \
  | cut -d',' -f1,3- \
  | uplot --title "Forecast" -H lineplot -d , --xlabel "Hours" --ylabel "°C" -w 72 --xlim 0,15

# gnuplot -persist <<EOF
# set datafile separator ","
# set xdata time
# set timefmt "%H:%M"
# set format x "%H:%M"
# set xlabel "Time"
# set ylabel "Temperature"
# set title "Temperature vs. Time"

# plot '-' using 1:2 with linespoints
# $FORECAST_T
# EOF
