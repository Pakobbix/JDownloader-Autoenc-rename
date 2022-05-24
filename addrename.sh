#!/bin/bash

## Farben für das Log

white='\033[0;37m'  # ${white}
yellow='\033[0;33m' # ${yellow}
green='\033[0;32m'  # ${green}
purple='\033[0;35m' # ${purple}
#blue='\033[0;34m'  # ${blue}
#lblue='\033[1;34m' # ${lblue}

JDAutoConfig=$(find ~ -type f -iname "JDAutoConfig" 2>/dev/null)

language_Folder=$(grep "language_folder=" "$JDAutoConfig" | sed 's/.*=//g')
if [[ -n $(grep "language=" "$JDAutoConfig" | sed 's/.*=//g') ]]; then
  language=$(grep "language=" "$JDAutoConfig" | sed 's/.*=//g')
else
  language=$(locale | head -n 1 | sed 's/.*=\|\..*//g')
fi

if [[ $language == "C" ]] || [[ ! -d $language_Folder/$language ]]; then
  language=en_US
fi

## Rename Skript Pfad:
renamelist=$(grep "renamelist=" "$JDAutoConfig" | sed 's/.*=//g')

text_lang() {
  grep "$1" "$language_Folder"/"$language"/addrename.lang | sed 's/^....//'
}

curl_name() {
  if [[ -z $(curl -sL https://www.thetvdb.com/dereferrer/series/"$thetvdb" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g") ]]; then
    curl -sL https://www.thetvdb.com/dereferrer/series/"$thetvdb" | grep -i -A1 "en" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g" | head -n 1
  else
    curl -sL https://www.thetvdb.com/dereferrer/series/"$thetvdb" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g" | head -n 1
  fi
}

format_search() {
  if [[ -z $(curl -sL https://www.thetvdb.com/dereferrer/series/"$thetvdb" | grep -i "genres/\<anime\>" | sed 's/.*anime">\|<\/a>.*//g') ]]; then
    echo "$(text_lang "001"):"
  else
    echo "$(text_lang "002"):"
  fi
}

read -rp "$(echo -e "$(text_lang "003")" "${green}""$(text_lang "004")""${white}" "$(text_lang "005")"?) (Y/n)" adding
if [ "${adding,,}" == "n" ]; then
  exit
else
  read -rp "$(echo -e "$(text_lang "006")" "${purple}""$(text_lang "007")""${white}" "$(text_lang "008")"?)  " key1
  read -rp "$(echo -e "${yellow}""$(text_lang "009")""${white}", "$(text_lang "010")")  " key2
  if [ -z "$key2" ]; then
    echo -e "${purple}https://thetvdb.com/search?query=""$key1""${white}"
  else
    echo -e "${purple}https://thetvdb.com/search?query=""$key1""%20""$key2""${white}"
  fi
  read -rp "$(echo -e "$(text_lang "016")" "${purple}"TheTVDB ID"${white}" "$(text_lang "017")")  " thetvdb
  format=$(format_search)
  typ=$(if [[ $format == "$(text_lang "002"):" ]]; then text_lang "012"; else text_lang "011"; fi)
  echo "$(text_lang "013") $format $(curl_name)"
  read -rp "$(text_lang "014")? (Y/n)" wrongformat
  if [ "${wrongformat,,}" == "n" ]; then
    echo "$(text_lang "015")"
    exit
  else
    {
      curl_name
      echo "$key1"
      echo "$key2"
      echo "$typ"
      echo "$thetvdb"
      echo ""
    } >>"$renamelist"
  fi
fi
