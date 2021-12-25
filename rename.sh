#!/bin/bash

## Farben für das Log

red='\033[0;31m'
green='\033[0;32m'
white='\033[0;37m'
yellow='\033[0;33m'
purple='\033[0;35m' # ${purple}

#Ordner Pfade

out="$2"

## Log file Output

log="$1"

## Script start

echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Starte ${green}rename.sh${white} Skript" >>"${log[@]}"

if pgrep -f 'jdautoenc.sh' >/dev/null 2>&1; then # ignore
  echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Warte auf das beenden vom Encoden" >>"${log[@]}"
fi

while pgrep -f 'jdautoenc.sh' >/dev/null 2>&1; do
  sleep 1m
done

while pgrep -f 'startencode.sh' >/dev/null 2>&1; do
  sleep 1m
done

## Hier kommt ein neuer Loop für filebot
## Bevor wir die Animes und Serien umbennen, überprüfen wir ob ffmpeg noch encoded.
## Einfach nur um zu verhindern, dass filebot eine Datei umbennent, die noch encoded wird
## und bei zuvielen Dateien mehrere filebot Prozesse versuchen die selbe Datei umzubenennen
## (unwahrscheinlich aber lieber vorsichtig als nachher blöd dazustehen)

sleep $(((RANDOM % 10) + 1))s

for v in "${out[@]}"*.mkv; do
  echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Starte die Umbennenung der encoded Videos" >>"${log[@]}"
  if [ -z "$v" ]; then
    echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Keine Video files zum Umbenennen" >>"${log[@]}"
  elif [[ ${v,,} == *"insanity"* ]]; then                                                                                                                       # insanity
    filebot -rename "$v" --db TheTVDB -non-strict --lang German --format "/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}" --q 407682 >>"${log[@]}" # insanity
  elif [[ ${v,,} == *"banished"*"party"* ]]; then                                                                                                               # banished party
    filebot -rename "$v" --db TheTVDB -non-strict --lang German --format "/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}" --q 400573 >>"${log[@]}" # banished party
  elif [[ ${v,,} == *"mushoku"*"tensei"* ]]; then                                                                                                               # mushoku tensei
    filebot -rename "$v" --db TheTVDB -non-strict --lang German --format "/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}" --q 371310 >>"${log[@]}" # mushoku tensei
  elif [[ ${v,,} == *"faraway"*"paladin"* ]]; then                                                                                                              # faraway paladin
    filebot -rename "$v" --db TheTVDB -non-strict --lang German --format "/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}" --q 401915 >>"${log[@]}" # faraway paladin
  elif [[ ${v,,} == *"assassin"*"reincarnated"* ]]; then                                                                                                        # assassin reincarnated
    filebot -rename "$v" --db TheTVDB -non-strict --lang German --format "/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}" --q 398193 >>"${log[@]}" # assassin reincarnated
  elif [[ ${v,,} == *"world"*"trigger"* ]]; then                                                                                                                # world trigger
    filebot -rename "$v" --db TheTVDB -non-strict --lang German --format "/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}" --q 283934 >>"${log[@]}" # world trigger
  elif [[ ${v,,} == *"scarlet"*"nexus"* ]]; then                                                                                                                # scarlet nexus
    filebot -rename "$v" --db TheTVDB -non-strict --lang German --format "/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}" --q 399222 >>"${log[@]}" # scarlet nexus
  elif [[ ${v,,} == *"shaman"*"king"* ]]; then                                                                                                                  # shaman king
    filebot -rename "$v" --db TheTVDB -non-strict --lang German --format "/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}" --q 383837 >>"${log[@]}" # shaman king
  elif [[ ${v,,} == *"hawkeye"* ]]; then                                                                                                                        # Hawkeye
    filebot -rename "$v" --db TheTVDB -non-strict --lang German --format "/mnt/Medien/Serien/{n} ({y})/Season {s}/{n} - {s00e00} - {t}" --q 367146 >>"${log[@]}" # Hawkeye
  elif [[ ${v,,} == *"kurokos"*"basketball"* ]]; then                                                                                                           # kurokos basketball
    filebot -rename "$v" --db TheTVDB -non-strict --lang German --format "/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}" --q 257765 >>"${log[@]}" # kurokos basketball
  else
    {
      echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Keine Übereinstimmung in den Vordefinierten Animes/Serien${white}"
      echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Um Fehler bei der Automatisierten Umbennenung zu verhindern, werden wenn nur Filme automatisch umbennant${white}"
      echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Überprüfe nun anhand der Länge des Videos ob es ein Film ist. Ansonsten Script beenden${white}"
    } >>"${log[@]}"
    duration=$(ffprobe -hide_banner -loglevel error -v quiet -stats -i "$v" -show_entries format=duration -v quiet -of csv="p=0" | sed -e 's/\..*//g')
    if [ "$duration" -gt "4000" ]; then # ignore
      echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${purple}$v${white} ist ein Film, extrahiere Namen für Ordner" >>"${log[@]}"
      folder=$(basename "$v" .mkv)
      ## Hier wird nun ein Ordner mit dem Namen des Videos erstellt. Dies ist eine Vorsichtsmaßnahme, da mein Ordner (encoded) auch bei eindeutigen Film
      ## Namen immer wieder dazu führte, dass der Film als "ENCODED EXPLODED" umbenannt wurde -.-

      echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Erstelle Ordner $folder" "$yellow" "$white" "$folder" >>"${log[@]}"
      mkdir "$folder"
      echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Verschiebe ${purple}$v${white} nach $folder" >>"${log[@]}"
      mv "$v" "$folder"
      {
        echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Fange an mit der Umbenennung"
        filebot -rename "$folder"/*.mkv --db TheMovieDB -non-strict --lang German --format "/mnt/Medien/Filme/{n} ({y})"
        echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Falls Umbennung erfolgreich,  ${red}Lösche${white} Ordner"
      } >>"${log[@]}"
      rmdir "$folder"
    fi
  fi
done
