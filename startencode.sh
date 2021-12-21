#!/bin/bash

green='\033[0;32m'
white='\033[0;37m'
yellow='\033[0;33m' # ${yellow}


log=(~/.local/logs/jdautoenc.log)

echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Starte ${green}startencode.sh${white} Skript" >> "${log[@]}"

if pgrep -f 'jdautoenc.sh' >/dev/null 2>&1; then
echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Warte auf das beenden vom vorherigen Auto Encode Skript" >> "${log[@]}"
fi

while pgrep -f 'jdautoenc.sh' >/dev/null 2>&1
do
sleep 1m
done

/bin/bash ~/.local/scripts/jdautoenc.sh &
