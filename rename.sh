#!/bin/bash

## Farben für das Log
red='\033[0;31m'
green='\033[0;32m'
white='\033[0;37m'
yellow='\033[0;33m'
purple='\033[0;35m' # ${purple}

log="$1"
config="$2"
count=$(($3 + 1))

# shellcheck disable=SC1090
source "$config"

if [[ -z $language ]]; then
  language=$(locale | head -n 1 | sed 's/.*=\|\..*//g')
fi

if [[ $language == "C" ]] || [[ ! -d $language_folder/$language ]]; then
  language=en_US
fi

text_lang() {
  if [ -f "$language_folder"/"$language"/rename.lang ]; then
    grep "$1" "$language_folder"/"$language"/rename.lang | sed 's/^....//'
  else
    curl -s https://raw.githubusercontent.com/Pakobbix/JDownloader-Autoenc-rename/main/lang/en_US/rename.lang | grep "$1" | sed 's/^....//'
  fi
}

log_msg() {
  echo -e "${yellow}$(date +"%d.%m.%y %T")${white} $1${white}" >>"${log[@]}"
}

discord_msg() {
  curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" "$discord" &>/dev/null
}

nextcloud_msg() {
  curl -d '{"token":"'"$NextcloudTalkToken"'", "message":"'"$1"'"}' -H "Content-Type: application/json" -H "Accept:application/json" -H "OCS-APIRequest:true" -u "$NextcloudUser:$NextcloudPassword" "$NextcloudDomain"/ocs/v1.php/apps/spreed/api/v1/chat/tokenid &>/dev/null
}

apprise_msg() {
  if [[ -n $apprisetag ]]; then
    curl -d '{"body":"'"$1"'", "title":"#### jdautoenc.sh ####","tag":"'"$apprisetag"'"}' -H "Content-Type: application/json" "$appriseurl" &>/dev/null
  else
    curl -d '{"body":"'"$1"'", "title":"#### jdautoenc.sh ####"}' -H "Content-Type: application/json" "$appriseurl" &>/dev/null
  fi
}

filebot_rename() {
  filebot -rename "$v" --db "$1" -non-strict --lang "$2" --format "$3/$4" --q "$5" >>"${log[@]}" 2>>"${log[@]}"
}

names() {
  curl -sL https://www.thetvdb.com/dereferrer/series/"$1" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g"
}

if [[ -f /tmp/jdautoenc.lock ]]; then # ignore
  log_msg "$(text_lang "001")"
  sleep 2
fi

while [ -f /tmp/jdautoenc.lock ]; do
  sleep 1m
done

sleep $(((RANDOM % 6) + 1))s

while [ -f /tmp/jdautoenc.lock ]; do
  sleep 1m
done

# Erstelle lock Datei, Warte 5 Sekunden und überprüfe nochmals
while [ -f /tmp/rename.lock ]; do
  sleep $(((RANDOM % 6) + 1))s
done

if [[ -f /tmp/rename.lock ]]; then # ignore
  log_msg "$(text_lang "002")"
  sleep $(((RANDOM % 2) + 1))s
fi

echo $$ >/tmp/rename.lock

## Script start

log_msg ""
log_msg "#######################"
log_msg "$(text_lang "003") ${green}rename.sh${white} $(text_lang "004")"
log_msg "#######################"
log_msg ""

while read -r name; do
  read -r keyword1
  read -r keyword2
  read -r format
  read -r dbid
  read -r nextentry

  find -L "${encodes[@]}" -name '*.mkv' -or -name '*.mp4' 2>/dev/null | while IFS= read -r v; do

    if [[ ${v,,} == *"${keyword1,,}"*"${keyword2,,}"* ]]; then
      log_msg "$(text_lang "005") $(basename "$v" | sed 's/\./ /g;s/AAC\|1080p\|WebDL\|[a-z]26[0-9]\|[hH][eE][Vv][Cc]\|[tT]anuki\| dl \| web \|repack\|wayne\|\|[-]\|[gG]er\|[eE]ng\|[sS]ub//g;s/\[[^][]*\]\|WebDL\|JapDub\|CR\|REPACK\|V2DK\|man\|BluRay\|RSG//g;s/_/ /g;s/\( \)*/\1/g')"
      case ${format,,} in
      anime)
        filebot_rename "$AnimeDB" "$FileBotLang" "$Animes" "$AnimeName" "$dbid"
        ;;
      series)
        filebot_rename "$SeriesDB" "$FileBotLang" "$Series" "$SeriesName" "$dbid"
        ;;
      movie)
        filebot_rename "$MovieDB" "$FileBotLang" "$Movies" "$MovieName" "$dbid"
        ;;
      *)
        log_msg "${red}$v $(text_lang "006") $name $(text_lang "007")"
        log_msg "${red}$(text_lang "008")"
        ;;
      esac
    fi

  done
done <"$renamelist"

find -L "${encodes[@]}" -name '*.mkv' -or -name '*.mp4' 2>/dev/null | while IFS= read -r v; do
  duration=$(ffprobe -hide_banner -loglevel error -v quiet -stats -i "$v" -show_entries format=duration -v quiet -of csv="p=0" | sed -e 's/\..*//g')
  if [ "$duration" -gt "4751" ]; then # ignore
    log_msg "${purple}$v${white} $(text_lang "009")"
    movie=$(basename "$v")
    folder=$(basename "$v" .mkv)
    ## Hier wird nun ein Ordner mit dem Namen des Videos erstellt. Dies ist eine Vorsichtsmaßnahme, da mein Ordner (encoded) auch bei eindeutigen Film
    ## Namen immer wieder dazu führte, dass der Film als "ENCODED EXPLODED" umbenannt wurde -.-

    log_msg "$(text_lang "010") $folder" "$yellow" "$white" "$folder"
    mkdir "$encodes""$folder" 2>/dev/null
    log_msg "$(text_lang "011") ${purple}$v${white} $(text_lang "012") $folder"
    mv "$v" "$encodes""$folder" >>"${log[@]}" 2>/dev/null
    log_msg "$(text_lang "013")"
    filebot -rename "$encodes""$folder"/"$movie" --db TheMovieDB -non-strict --lang German --format "/mnt/Medien/Filme/{n} ({y})" >>"${log[@]}"
    log_msg "$(text_lang "014") ${red}$(text_lang "015")${white} $(text_lang "016")"
    sleep 5s
    rmdir "$encodes"* 2>/dev/null
  fi
done

rm -f /tmp/rename.lock

if tail -n 20 "$log" | grep "Failure" &>/dev/null; then
  if [ "$count" -lt 3 ]; then
    /bin/bash "$0" "$log" "$config" "$count" &
    exit
  else
    log_msg "$(text_lang "017") $count $(text_lang "018")"
    discord_msg "$(text_lang "017") $count $(text_lang "018")"
    nextcloud_msg "$(text_lang "017") $count $(text_lang "018")"
    apprise_msg "$(text_lang "017") $count $(text_lang "018")"
  fi
else
  log_msg "$(text_lang "019")"
fi
