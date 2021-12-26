#!/bin/bash

# Farben für echo

red='\033[0;31m'
white='\033[0;37m'
yellow='\033[0;33m'

# Rename Skript:

rename=~/.local/scripts/rename.sh

clear
IFS=$'\n'
frage="Wähle den zu löschenden Eintrag aus: "
entrys=($(grep "\-\-q" "$rename" | sed 's/.* # //g'))

PS3="$frage "
select entry in "${entrys[@]}" "Beenden"; do
    if ((REPLY == 1 + ${#entrys[@]})); then
        exit
        break

    elif ((REPLY > 0 && REPLY <= ${#entrys[@]})); then
        tvdbid=$(grep -i "$entry" "$rename" | grep "\-\-q" | sed 's/.*\-\-q //g' | cut -d" " -f1)
        curl -sL https://www.thetvdb.com/dereferrer/series/"$tvdbid" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g"
        echo ""
        read -rp "$(echo -e Bist du sicher, dass du "${yellow}""$entry" "${red}"löschen"${white}" willst?) (y/N) " sure
        if [ "${sure,,}" == "y" ]; then
            grep -v "$entry" "$rename" >"$rename".bak
            mv "$rename".bak "$rename"
            chmod +x "$rename"
            break
        fi
        /bin/bash "${BASH_SOURCE[0]}"
    else
        echo "Ungültige Eingabe."
    fi
done

xdg-open >/dev/null 2>&1 "https://www.anisearch.de/anime/index?text=banished+&quick-search=&char=all&q=true"
