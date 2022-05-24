#!/bin/bash

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

text_lang() {
  grep "$1" "$language_Folder"/"$language"/removerename.lang | sed 's/^....//'
}
# Farben für echo

white='\033[0;37m'
yellow='\033[0;33m'

# Rename Skript:

renamelist=$(grep "renamelist=" "$JDAutoConfig" | sed 's/.*=//g')

#clear
IFS=$'\n'
frage="$(text_lang "001"): "
entrys=($(awk 'NR % 6 == 1' "$renamelist" | sed "s/#.*/$(text_lang "005")/g"))

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
    read -rp "$(echo -e $(text_lang "003") "${yellow}""$entry""${white}" ?) (y/N) " sure
    if [ "${sure,,}" == "y" ]; then
      sed -i "/$entry/,+5d" "$renamelist"
    fi
    /bin/bash "${BASH_SOURCE[0]}"
  else
    echo "$(text_lang "004")."
  fi
done
