#!/bin/bash

## Farben für das Log

white='\033[0;37m'  # ${white}
yellow='\033[0;33m' # ${yellow}
green='\033[0;32m'  # ${green}
purple='\033[0;35m' # ${purple}
#blue='\033[0;34m'  # ${blue}
#lblue='\033[1;34m' # ${lblue}

## Rename Skript Pfad:
rename=~/.local/scripts/renamelist

curl_name() {
  if [[ -z $(curl -sL https://www.thetvdb.com/dereferrer/series/"$thetvdb" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g") ]]; then
    curl -sL https://www.thetvdb.com/dereferrer/series/"$thetvdb" | grep -i -A1 "en" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g"
  else
    curl -sL https://www.thetvdb.com/dereferrer/series/"$thetvdb" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g"
  fi
}

format_search() {
  if [[ -z $(curl -sL https://www.thetvdb.com/dereferrer/series/"$thetvdb" | grep -i "genres/\<anime\>" | sed 's/.*anime">\|<\/a>.*//g') ]]; then
    echo "die Serie:"
  else
    echo "den Anime:"
  fi
}

read -rp "$(echo -e Möchtest du einen "${green}"neuen Eintrag"${white}" zum umbenennen hinzufügen?) (Y/n)" adding
if [ "${adding,,}" == "n" ]; then
  exit
else
  read -rp "$(echo -e Nach welchem "${purple}"Schlagwort"${white}" soll das fertig encodierte Video abgeglichen werden?)  " key1
  read -rp "$(echo -e "${yellow}"Falls du möchtest"${white}", gebe nun ein zweites Schlagwort ein)  " key2
  if [ -z "$key2" ]; then
    echo -e "${purple}https://thetvdb.com/search?query=""$key1""${white}"
  else
    echo -e "${purple}https://thetvdb.com/search?query=""$key1""%20""$key2""${white}"
  fi
  read -rp "$(echo -e Gebe nun die "${purple}"TheTVDB ID"${white}" ein)  " thetvdb
  format=$(format_search)
  echo "Es handelt sich um $format $(curl_name)"
  read -rp "Ist dies Korrekt? (Y/n)" wrongformat
  if [ "${wrongformat,,}" == "n" ]; then
    echo "Leider konnte deine Anfrage nicht automatisch abgearbeitet werden. Du kannst aber immernoch manuell einen Eintrag hinzufügen"
    exit
  else
    {
      curl_name
      echo "$key1"
      echo "$key2"
      echo "$format"
      echo "$thetvdb"
      echo ""
    } >>$rename
  fi

fi
