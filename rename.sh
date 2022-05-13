#!/bin/bash

## Farben für das Log
red='\033[0;31m'
green='\033[0;32m'
white='\033[0;37m'
yellow='\033[0;33m'
purple='\033[0;35m' # ${purple}

#Liste für die Umbenennung
renamelist="$3"

#Ordner Pfade

out="$2"

## Log file Output

log="$1"

log_msg() {
  echo -e "${yellow}$(date +"%d.%m.%y %T")${white}  $1${white}" >>"${log[@]}"
}

filebot_rename() {
  filebot -rename "$v" --db "$1" -non-strict --lang German --format "/mnt/Medien/$2/{n} ({y})/Season {s}/{n} - {s00e00} - {t}" --q "$3" >>"${log[@]}"
}

names() {
  curl -sL https://www.thetvdb.com/dereferrer/series/"$1" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g"
}

## Script start

log_msg "Starte ${green}rename.sh${white} Skript"

if pgrep -f 'jdautoenc.sh' >/dev/null 2>&1; then # ignore
  log_msg "Warte auf das beenden vom Encoden"
  sleep 2
fi

while pgrep -f 'jdautoenc.sh' >/dev/null 2>&1; do
  log_msg "Warte 1 Minute vor dem nächsten Versuch"
  sleep 1m
done

while pgrep -f 'startencode.sh' >/dev/null 2>&1; do
  sleep 1m
done

# Erstelle lock Datei, Warte 5 Sekunden und überprüfe nochmals
echo $$ >/tmp/rename.lock
sleep 1
while [ -f rename.lock ]; do
  log_msg "${red} Rename läufts bereits! Warte auf dessen durchlauf"
  sleep 5
done

while read -r name; do
  read -r keyword1
  read -r keyword2
  read -r format
  read -r tvdbid
  read -r nextentry

  find -L "${out[@]}" -name '*.mkv' -or -name '*.mp4' | while IFS= read -r v; do

    if [[ ${v,,} == *"$keyword1"*"$keyword2"* ]]; then
      log_msg "Bennene $v um in $name Staffel Episode Episodentitel"
      filebot_rename TheTVDB "$format" "$tvdbid"
    else
      #      log_msg "${red}Keine Übereinstimmung in den Vordefinierten Animes/Serien"
      #      log_msg "${red}Um Fehler bei der Automatisierten Umbennenung zu verhindern, werden wenn nur Filme automatisch umbennant"
      #      log_msg "${red}Überprüfe nun anhand der Länge des Videos ob es ein Film ist. Ansonsten Script beenden"
      duration=$(ffprobe -hide_banner -loglevel error -v quiet -stats -i "$v" -show_entries format=duration -v quiet -of csv="p=0" | sed -e 's/\..*//g')
      if [ "$duration" -gt "4000" ]; then # ignore
        log_msg "${purple}$v${white} ist ein Film, extrahiere Namen für Ordner"
        movie=$(basename "$v")
        folder=$(basename "$v" .mkv)
        ## Hier wird nun ein Ordner mit dem Namen des Videos erstellt. Dies ist eine Vorsichtsmaßnahme, da mein Ordner (encoded) auch bei eindeutigen Film
        ## Namen immer wieder dazu führte, dass der Film als "ENCODED EXPLODED" umbenannt wurde -.-

        log_msg "Erstelle Ordner $folder" "$yellow" "$white" "$folder"
        mkdir "$out""$folder"
        log_msg "Verschiebe ${purple}$v${white} nach $folder"
        mv "$v" "$out""$folder" >>"${log[@]}"
        log_msg "Fange an mit der Umbenennung"
        filebot -rename "$out""$folder"/"$movie" --db TheMovieDB -non-strict --lang German --format "/mnt/Medien/Filme/{n} ({y})" >>"${log[@]}"
        log_msg "Falls Umbennung erfolgreich, ${red}Lösche${white} Ordner"
        sleep 5s
        rmdir "$out"*
      fi
    fi

  done
done <"$renamelist"

rm -f /tmp/rename.lock
