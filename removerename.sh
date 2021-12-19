#!/bin/bash

# Farben für echo

red='\033[0;31m'
green='\033[0;32m'
white='\033[0;37m'
yellow='\033[0;33m' # ${yellow}

################################# WARNUNG!! #################################
##                                                                         ##
## Löscht niemals alle Einträge und niemals Insanity (nennt es um).        ##
## Ansonsten wird der ganze if block unbenutzbar                           ##
## und das wars mit dem Skript. Falls ich spontan eine Idee haben sollte   ##
## wie ich das lösen kann, werde ich dies tun, bis dahin lasst den eintrag ##
##                                                                         ##
#############################################################################

## Hier müsst ihr den Pfad zur rename.sh angeben.
## Für die nicht so versierten Nutzer $USER entpricht eurem aktuellen nutzer.

rename="/home/$USER/.local/scripts/rename.sh"


entrys=$(cat "$rename" | grep "\-\-q" | sed 's/.*--q//g' | cut -d" " -f6,7)

clear
echo -e "Wähle das Keyword aus, für welchen eintrag du aus dem ${green}rename.sh ${red}löschen${white} möchtest"
echo "$entrys"
read -rp "Anime/Serie zu löschen:" key1
tvdbid=$(grep "$key1" "$rename" | grep "\-\-q" | sed 's/.*\-\-q //g' | cut -d" " -f1)
curl -sL https://www.thetvdb.com/dereferrer/series/"$tvdbid" | grep '<title>' | sed 's/<title>//g' | sed 's/ - .*//g'
read -rp "$(echo -e Bist du sicher, dass du ${yellow}"$key1" ${red}löschen${white} willst?) (y/N)" sure
if [ "${sure,,}" == "y" ]
 then
  cat "$rename" | grep -v "$key1" > "$rename".bak
  mv "$rename".bak "$rename"
  chmod +x "$rename"
 else
  exit
fi
