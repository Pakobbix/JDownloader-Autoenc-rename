#!/bin/bash

## Farben für das Log
red='\033[0;31m'
green='\033[0;32m'
white='\033[0;37m'
yellow='\033[0;33m'
purple='\033[0;35m' # ${purple}

log="$1"
JDAutoConfig="$2"

language_Folder=$(grep "language_folder=" "$JDAutoConfig" | sed 's/.*=//g')
if [[ -n $(grep "language=" "$JDAutoConfig" | sed 's/.*=//g') ]]; then
  language=$(grep "language=" "$JDAutoConfig" | sed 's/.*=//g')
else
  language=$(locale | head -n 1 | sed 's/.*=\|\..*//g')
fi

if [[ $language == "C" ]] || [[ ! -d $language_Folder/$language ]]; then
  language=en_US
fi

# Message System
discord=$(grep "discord=" "$JDAutoConfig" | sed 's/.*=//g')

#Liste für die Umbenennung
renamelist=$(grep "renamelist=" "$JDAutoConfig" | sed 's/.*=//g')

#Ordner Pfade

encodes=$(grep "encodes=" "$JDAutoConfig" | sed 's/.*=//g')

Movies=$(grep "Movies=" "$JDAutoConfig" | sed 's/.*=//g')
TVShows=$(grep "TVShows=" "$JDAutoConfig" | sed 's/.*=//g')
Animes=$(grep "Animes=" "$JDAutoConfig" | sed 's/.*=//g')

MovieDB=$(grep "MovieDB=" "$JDAutoConfig" | sed 's/.*=//g')
TVShowDB=$(grep "TVShowDB=" "$JDAutoConfig" | sed 's/.*=//g')
AnimeDB=$(grep "AnimeDB=" "$JDAutoConfig" | sed 's/.*=//g')

MovieName=$(grep "MovieName=" "$JDAutoConfig" | sed 's/.*=//g')
TVShowName=$(grep "TVShowName=" "$JDAutoConfig" | sed 's/.*=//g')
AnimeName=$(grep "AnimeName=" "$JDAutoConfig" | sed 's/.*=//g')

FileBotLang=$(grep "FileBotLang=" "$JDAutoConfig" | sed 's/.*=//g')

text_lang() {
  grep "$1" "$language_Folder"/"$language"/rename.lang | sed 's/^....//'
}

log_msg() {
  echo -e "${yellow}$(date +"%d.%m.%y %T")${white} $1${white}" >>"${log[@]}"
}

discord_msg() {
  curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" "$discord"
}

filebot_rename() {
  if ! filebot -rename "$v" --db "$1" -non-strict --lang "$2" --format "$3/$4" --q "$5" >>"${log[@]}"; then
    discord_msg "$(text_lang "019") $v." 2>/dev/null
    log_msg "${red}$(text_lang "020")"
    sleep 5s
    filebot -rename "$v" --db "$1" -non-strict --lang "$2" --format "$3/$4" --q "$5" >>"${log[@]}"
  fi
}

## Script start
log_msg
log_msg "#######################"
log_msg "$(text_lang "001") ${green}rename.sh${white} $(text_lang "002")"
log_msg "#######################"
log_msg ""

if [[ -f /tmp/jdautoenc.lock ]]; then
  log_msg "$(text_lang "003")"
  sleep 2
fi

while [ -f /tmp/jdautoenc.lock ]; do
  sleep 1m
done

# Erstelle lock Datei, Warte 5 Sekunden und überprüfe nochmals
while [ -f /tmp/rename.lock ]; do
  sleep 5
done
echo $$ >/tmp/rename.lock

while read -r name; do
  read -r keyword1
  read -r keyword2
  read -r format
  read -r dbid
  read -r nextentry

  find -L "${encodes[@]}" -name '*.mkv' -or -name '*.mp4' | while IFS= read -r v; do
    if [[ ${v,,} == *"$keyword1"*"$keyword2"* ]]; then
      log_msg "$(text_lang "006") $v $(text_lang "007") $name $(text_lang "008")"
      if [[ ${format,,} == "$(text_lang "021")" ]]; then
        filebot_rename "$AnimeDB" "$FileBotLang" "$Animes" "$AnimeName" "$dbid"
      elif [[ ${format,,} == "$(text_lang "022")" ]]; then
        filebot_rename "$TVShowDB" "$FileBotLang" "$TVShows" "$TVShowName" "$dbid"
      elif [[ ${format,,} == "$(text_lang "023")" ]]; then
        filebot_rename "$MovieDB" "$FileBotLang" "$Movies" "$MovieName" "$dbid"
      else
        log_msg "${red}$v $(text_lang "009") $name"
        log_msg "${red}$(text_lang "010")."
      fi
    fi

  done
done <"$renamelist"

find -L "${encodes[@]}" -name '*.mkv' -or -name '*.mp4' | while IFS= read -r v; do
  log_msg "${red}$(text_lang "011")."
  duration=$(ffprobe -hide_banner -loglevel error -v quiet -stats -i "$v" -show_entries format=duration -v quiet -of csv="p=0" | sed -e 's/\..*//g')
  if [ "$duration" -gt "4000" ]; then # ignore
    log_msg "${purple}$v${white} $(text_lang "012")"
    movie=$(basename "$v")
    folder=$(basename "$v" .mkv)
    ## Hier wird nun ein Ordner mit dem Namen des Videos erstellt. Dies ist eine Vorsichtsmaßnahme, da mein Ordner (encoded) auch bei eindeutigen Film
    ## Namen immer wieder dazu führte, dass der Film als "ENCODED EXPLODED" umbenannt wurde -.-
    log_msg "$(text_lang "013") $folder" "$yellow" "$white" "$folder"
    mkdir "$encodes""$folder"
    log_msg "$(text_lang "014") ${purple}$v${white} $(grep "007" "$language_Folder"/"$language"/rename.lang | sed 's/^....//') $folder"
    mv "$v" "$encodes""$folder" >>"${log[@]}"
    log_msg "$(text_lang "015")"
    filebot -rename "$encodes""$folder"/"$movie" --db TheMovieDB -non-strict --lang German --format "/mnt/Medien/Filme/{n} ({y})" >>"${log[@]}"
    log_msg "$(text_lang "016"), ${red}$(text_lang "017")${white} $(text_lang "018")"
    sleep 5s
    rmdir "$encodes"*
  fi
done

rm -f /tmp/rename.lock
