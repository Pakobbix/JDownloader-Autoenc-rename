#!/bin/bash

# Farben für echo

red='\033[0;31m'
green='\033[0;32m'
white='\033[0;37m'
yellow='\033[0;33m' # ${yellow}

# Rename Skript:

rename=~/.local/scripts/rename.sh

entrys=$(grep "\-\-q" "$rename" | sed 's/.* # //g')

clear
echo -e "Wähle das Keyword aus, für welchen eintrag du aus dem ${green}rename.sh Skript ${red}löschen${white} möchtest"
echo "$entrys"
read -rp "Anime/Serie zu löschen: " key1
tvdbid=$(grep -i "$key1" "$rename" | grep "\-\-q" | sed 's/.*\-\-q //g' | cut -d" " -f1)
curl -sL https://www.thetvdb.com/dereferrer/series/"$tvdbid" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g"
read -rp "$(echo -e Bist du sicher, dass du "${yellow}""$key1" "${red}"löschen"${white}" willst?) (y/N) " sure
if [ "${sure,,}" == "y" ]; then
    grep -v "$key1" "$rename" >"$rename".bak
    mv "$rename".bak "$rename"
    chmod +x "$rename"
else
    exit
fi
