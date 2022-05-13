#!/bin/bash

# Farben für echo

red='\033[0;31m'
white='\033[0;37m'
yellow='\033[0;33m'

# Rename Skript:

rename=~/.local/scripts/renamelist

clear
IFS=$'\n'
frage="Wähle den zu löschenden Eintrag aus: "
entrys=($(awk 'NR % 6 == 1' "$rename" | sed 's/#.*/Beispiel Eintrag/g'))

PS3="$frage "
select entry in "${entrys[@]}" "Beenden"; do
  if ((REPLY == 1 + ${#entrys[@]})); then
    exit
    break

  elif ((REPLY > 0 && REPLY <= ${#entrys[@]})); then
    tvdbid=$(grep -A5 "$entry" "$renamelist" | awk 'NR % 5 == 0')
    if [[ -z $(curl -sL https://www.thetvdb.com/dereferrer/series/"$tvdbid" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g") ]]; then
      curl -sL https://www.thetvdb.com/dereferrer/series/"$tvdbid" | grep -i -A1 "en" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g"
    fi
    echo ""
    read -rp "$(echo -e Bist du sicher, dass du "${yellow}""$entry" "${red}"löschen"${white}" willst?) (y/N) " sure
    if [ "${sure,,}" == "y" ]; then
      sed -i "/$entry/,+5d" "$renamelist"
    fi
    /bin/bash "${BASH_SOURCE[0]}"
  else
    echo "Ungültige Eingabe."
  fi
done
