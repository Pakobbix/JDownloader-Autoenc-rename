#!/bin/bash

## Farben für das Log
red='\033[0;31m'
green='\033[0;32m'
white='\033[0;37m'
yellow='\033[0;33m'
purple='\033[0;35m' # ${purple}

log="$1"
config="$2"

# Message System
discord=$(grep "discord=" "$config" | sed 's/.*=//g')

#Liste für die Umbenennung
renamelist=$(grep "renamelist=" "$config" | sed 's/.*=//g')

#Ordner Pfade

encodes=$(grep "encodes=" "$config" | sed 's/.*=//g')

Filme=$(grep "Filme=" "$config" | sed 's/.*=//g')
Serien=$(grep "Serien=" "$config" | sed 's/.*=//g')
Animes=$(grep "Animes=" "$config" | sed 's/.*=//g')

FilmDB=$(grep "FilmeDB=" "$config" | sed 's/.*=//g')
SerienDB=$(grep "SerienDB=" "$config" | sed 's/.*=//g')
AnimeDB=$(grep "AnimeDB=" "$config" | sed 's/.*=//g')

FilmName=$(grep "FilmName=" "$config" | sed 's/.*=//g')
SerienName=$(grep "SerienName=" "$config" | sed 's/.*=//g')
AnimeNames=$(grep "AnimeNames=" "$config" | sed 's/.*=//g')

FileBotLang=$(grep "FileBotLang=" "$config" | sed 's/.*=//g')

log_msg() {
  echo -e "${yellow}$(date +"%d.%m.%y %T")${white} $1${white}" >>"${log[@]}"
}

discord_msg() {
  curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" "$discord"
}

filebot_rename() {
  if ! filebot -rename "$v" --db "$1" -non-strict --lang "$2" --format "$3/$4" --q "$5" >>"${log[@]}"; then
    discord_msg "Fehler bei der Umbenennung von $v." 2>/dev/null
    log_msg "${red}Fehler bei der Umbenennung. Probiere es erneut."
    sleep 5s
    filebot -rename "$v" --db "$1" -non-strict --lang "$2" --format "$3/$4" --q "$5" >>"${log[@]}"
  fi
}

names() {
  curl -sL https://www.thetvdb.com/dereferrer/series/"$1" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g"
}

## Script start

log_msg "#######################"
log_msg "Starte ${green}rename.sh${white} Skript"
log_msg "#######################"

if pgrep -f 'jdautoenc.sh' >/dev/null 2>&1; then # ignore
  log_msg "Warte auf das beenden vom Encoden"
  sleep 2
fi

while pgrep -f 'jdautoenc.sh' >/dev/null 2>&1; do
  log_msg "Warte 1 Minute vor dem nächsten Versuch"
  sleep 1m
done

# Erstelle lock Datei, Warte 5 Sekunden und überprüfe nochmals
while [ -f /tmp/rename.lock ]; do
  log_msg "${red} Rename läufts bereits! Warte auf dessen durchlauf"
  sleep 5
done
echo $$ >/tmp/rename.lock
sleep 1

while read -r name; do
  read -r keyword1
  read -r keyword2
  read -r format
  read -r dbid
  read -r nextentry

  find -L "${encodes[@]}" -name '*.mkv' -or -name '*.mp4' | while IFS= read -r v; do

    if [[ ${v,,} == *"$keyword1"*"$keyword2"* ]]; then
      log_msg "Bennene $v um in $name Staffel Episode Episodentitel"
      if [[ ${format,,} == "anime" ]]; then
        filebot_rename "$AnimeDB" "$FileBotLang" "$Animes" "$AnimeNames" "$dbid"
      elif [[ ${format,,} == "serie" ]]; then
        filebot_rename "$SerienDB" "$FileBotLang" "$Serien" "$SerienName" "$dbid"
      elif [[ ${format,,} == "film" ]]; then
        filebot_rename "$FilmDB" "$FileBotLang" "$Filme" "$FilmName" "$dbid"
      else
        log_msg "${red}$v stimmt nicht mit $name überein"
        log_msg "${red}Gehe zum nächsten Eintrag."
      fi
    fi

  done
done <"$renamelist"

find -L "${encodes[@]}" -name '*.mkv' -or -name '*.mp4' | while IFS= read -r v; do
  log_msg "${red}Schaue ob Filme zum umbenennen vorliegen."
  duration=$(ffprobe -hide_banner -loglevel error -v quiet -stats -i "$v" -show_entries format=duration -v quiet -of csv="p=0" | sed -e 's/\..*//g')
  if [ "$duration" -gt "4000" ]; then # ignore
    log_msg "${purple}$v${white} ist ein Film, extrahiere Namen für Ordner"
    movie=$(basename "$v")
    folder=$(basename "$v" .mkv)
    ## Hier wird nun ein Ordner mit dem Namen des Videos erstellt. Dies ist eine Vorsichtsmaßnahme, da mein Ordner (encoded) auch bei eindeutigen Film
    ## Namen immer wieder dazu führte, dass der Film als "ENCODED EXPLODED" umbenannt wurde -.-

    log_msg "Erstelle Ordner $folder" "$yellow" "$white" "$folder"
    mkdir "$encodes""$folder"
    log_msg "Verschiebe ${purple}$v${white} nach $folder"
    mv "$v" "$encodes""$folder" >>"${log[@]}"
    log_msg "Fange an mit der Umbenennung"
    filebot -rename "$encodes""$folder"/"$movie" --db TheMovieDB -non-strict --lang German --format "/mnt/Medien/Filme/{n} ({y})" >>"${log[@]}"
    log_msg "Falls Umbennung erfolgreich, ${red}Lösche${white} Ordner"
    sleep 5s
    rmdir "$encodes"*
  fi
done

rm -f /tmp/rename.lock
