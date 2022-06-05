#!/bin/bash

# Farben für echo

red='\033[0;31m'
white='\033[0;37m'
yellow='\033[0;33m'

# Rename Skript:
JDAutoConfig=$(find ~ -type f -name "JDAutoConfig" 2>/dev/null)
renamelist=$(grep "renamelist=" "$JDAutoConfig" | sed 's/renamelist=//g')

language_Folder=$(grep "language_folder=" "$JDAutoConfig" | sed 's/.*=//g')
if [[ -n $(grep "language=" "$JDAutoConfig" | sed 's/.*=//g') ]]; then
  language=$(grep "language=" "$JDAutoConfig" | sed 's/.*=//g')
else
  language=$(locale | head -n 1 | sed 's/.*=\|\..*//g')
fi

if [[ $language == "C" ]] || [[ ! -d $language_Folder/$language ]]; then
  language=en_US
fi

text_lang() {
  if [ -f "$language_Folder"/"$language"/removerename.lang ]; then
    grep "$1" "$language_Folder"/"$language"/removerename.lang | sed 's/^....//'
  else
    curl -s https://raw.githubusercontent.com/Pakobbix/JDownloader-Autoenc-rename/Multilanguage/lang/en_US/removerename.lang | grep "$1" | sed 's/^....//'
  fi
}

clear
IFS=$'\n'
frage="$(text_lang "001") "
entrys=($(awk 'NR % 6 == 1' "$renamelist" | sed 's/#.*/Beispiel Eintrag/g'))

PS3="$frage "
select entry in "${entrys[@]}" "$(text_lang "002")"; do
  if ((REPLY == 1 + ${#entrys[@]})); then
    exit
    break

  elif ((REPLY > 0 && REPLY <= ${#entrys[@]})); then
    tvdbid=$(grep -A5 "$entry" "$renamelist" | awk 'NR % 5 == 0')
    if [[ -z $(curl -sL https://www.thetvdb.com/dereferrer/series/"$tvdbid" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g") ]]; then
      curl -sL https://www.thetvdb.com/dereferrer/series/"$tvdbid" | grep -i -A1 "en" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g"
    fi
    echo ""
    read -rp "$(echo -e "$(text_lang "003")" "${yellow}""$entry" "${red}""$(text_lang "004")""${white}" "$(text_lang "005")") (y/N) " sure
    if [ "${sure,,}" == "y" ]; then
      sed -i "/$entry/,+5d" "$renamelist"
    fi
    /bin/bash "${BASH_SOURCE[0]}"
  else
    text_lang "006"
  fi
done
