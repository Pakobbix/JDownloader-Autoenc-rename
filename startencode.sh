#!/bin/bash

green='\033[0;32m'
white='\033[0;37m'
yellow='\033[0;33m' # ${yellow}

##### Ordner Pfade: Hier sind nun einige Ordnerpfade, die dann an die anderen
##### Skripte weitergegeben werden. Ändert ihr hier den Ordnerpfad, sind
##### diese für alle Skripte geändert. Macht das Bearbeiten leichter.
##### Ausnahme ist leider filebot. Ich kann die Ordner nicht an filebot
##### weiterreichen. Diese werden dann als plain text gelesen.

jdautoenc="$HOME/.local/scripts/jdautoenc.sh"
rename="$HOME/.local/scripts/rename.sh"
renamelist="$HOME/.local/scripts/renamelist"
entpackt="/mnt/downloads/entpackt/"
out="/mnt/Medien/encode/"
log="$HOME/.local/logs/jdautoenc.log"

# Benachrichtungen.
# Hier können externe Benachrichtigungen definiert werden. Den Anfang macht Discord.
# Wozu? Falls es zu fehlern kommt, kann man sich so benachrichtigen lassen.
# Encodieren/Umbenennen ist schiefgegangen? Sende eine Nachricht, damit du überhaupt bescheid weißt.

discord='https://discord.com/api/webhooks/'

echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Starte ${green}startencode.sh${white} Skript" >>"${log[@]}"

if pgrep -f 'jdautoenc.sh' >/dev/null 2>&1; then
  echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Warte auf das beenden vom vorherigen Auto Encode Skript" >>"${log[@]}"
fi

while pgrep -f 'jdautoenc.sh' >/dev/null 2>&1; do
  sleep 1m
done

/bin/bash "$jdautoenc" "$entpackt" "$log" "$out" "$rename" "$renamelist" "$discord" &
