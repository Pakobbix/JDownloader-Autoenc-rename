#!/bin/bash

## Farben für das Log

white='\033[0;37m' # ${white}
yellow='\033[0;33m' # ${yellow}
green='\033[0;32m' # ${green}
purple='\033[0;35m' # ${purple}
#blue='\033[0;34m' # ${blue}
#lblue='\033[1;34m' # ${lblue}

## Rename Skript Pfad:
rename=~/.local/scripts/rename.sh

read -rp "$(echo -e Möchtest du einen "${green}"neuen Eintrag"${white}" zum umbenennen hinzufügen?) (Y/n)" adding
if [ "${adding,,}" == "n" ]
 then
  exit
 else
  read -rp "$(echo -e Nach welchem "${purple}"Schlagwort"${white}" soll das fertig encodierte Video abgeglichen werden?)  " key1
  read -rp "$(echo -e "${yellow}"Falls du möchtest"${white}", gebe nun ein zweites Schlagwort ein)  " key2
  if [ -z "$key2" ]
   then
    echo -e "${purple}https://thetvdb.com/search?query=""$key1""${white}"
   else
    echo -e "${purple}https://thetvdb.com/search?query=""$key1""%20""$key2""${white}"
  fi
  read -rp "$(echo -e Gebe nun die "${purple}"TheTVDB ID"${white}" ein)  " thetvdb
  format=$(curl -sL https://www.thetvdb.com/dereferrer/series/"$thetvdb" | grep -i "genres/\<anime\>" | sed 's/.*anime">\|<\/a>.*//g')
    if [ "${format,,}" == "anime" ]
      then
        printf 'Es handelt sich um den %b %b\n' "$format"  "$(curl -sL https://www.thetvdb.com/dereferrer/series/"""$thetvdb""" | grep -i -A1 "deu" | grep "data-title" |  sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g")"
        read -rp "Ist dies Korrekt? (Y/n)" wrongformat
        if [ "${wrongformat,,}" == "n" ]
         then
          if [ -z "$key2" ]
         then
            sed -i "51i\ \ elif [[ \"\${v,,}\" == *\"${key1,,}\"* ]] \# ""$key1""" -i "$rename"
            sed -i "52i\ \ \ then \# ""$key1""" -i "$rename"
            sed -i "53i\ \ \ \ filebot -rename \"\$v\" --db TheTVDB -non-strict --lang German --format \"/mnt/Medien/Serien/{n} ({y})/Season {s}/{n} - {s00e00} - {t}\" --q $thetvdb >> \"\${log[@]}\" \# ""$key1""" -i "$rename"
          else
            sed -i "51i\ \ elif [[ \"\${v,,}\" == *\"${key1,,}\"*\"${key2,,}\"* ]] \# ""$key1"" ""$key2""" -i "$rename"
            sed -i "52i\ \ \ then \# ""$key1"" ""$key2""" -i "$rename"
            sed -i "53i\ \ \ \ filebot -rename \"\$v\" --db TheTVDB -non-strict --lang German --format \"/mnt/Medien/Serien/{n} ({y})/Season {s}/{n} - {s00e00} - {t}\" --q $thetvdb >> \"\${log[@]}\" \# ""$key1"" ""$key2""" -i "$rename"
        fi
         else
        if [ -z "$key2" ]
          then
            sed -i "51i\ \ elif [[ \"\${v,,}\" == *\"${key1,,}\"* ]] \# ""$key1""" -i "$rename"
            sed -i "52i\ \ \ then \# ""$key1""" -i "$rename"
            sed -i "53i\ \ \ \ filebot -rename \"\$v\" --db TheTVDB -non-strict --lang German --format \"/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}\" --q $thetvdb >> \"\${log[@]}\" \# ""$key1""" -i "$rename"
          else
            sed -i "51i\ \ elif [[ \"\${v,,}\" == *\"${key1,,}\"*\"${key2,,}\"* ]] \# ""$key1"" ""$key2""" -i "$rename"
            sed -i "52i\ \ \ then \# ""$key1"" ""$key2""" -i "$rename"
            sed -i "53i\ \ \ \ filebot -rename \"\$v\" --db TheTVDB -non-strict --lang German --format \"/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}\" --q $thetvdb >> \"\${log[@]}\" \# ""$key1"" ""$key2""" -i "$rename"
        fi
       fi
    elif [ -z "$format" ]
      then
          printf 'Es handelt sich um die Serie %b\n' "$(curl -sL https://www.thetvdb.com/dereferrer/series/"""$thetvdb""" | grep -i -A1 "deu" | grep "data-title" |  sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g")"
          read -rp "Ist dies Korrekt? (Y/n)" wrongformat
        if [ "${wrongformat,,}" == "n" ]
         then
          if [ -z "$key2" ]
           then
            sed -i "51i\ \ elif [[ \"\${v,,}\" == *\"${key1,,}\"* ]] \# ""$key1""" -i "$rename"
            sed -i "52i\ \ \ then \# ""$key1""" -i "$rename"
            sed -i "53i\ \ \ \ filebot -rename \"\$v\" --db TheTVDB -non-strict --lang German --format \"/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}\" --q $thetvdb >> \"\${log[@]}\" \# ""$key1""" -i "$rename"
          else
            sed -i "51i\ \ elif [[ \"\${v,,}\" == *\"${key1,,}\"*\"${key2,,}\"* ]] \# ""$key1"" ""$key2""" -i "$rename"
            sed -i "52i\ \ \ then \# ""$key1"" ""$key2""" -i "$rename"
            sed -i "53i\ \ \ \ filebot -rename \"\$v\" --db TheTVDB -non-strict --lang German --format \"/mnt/Medien/Animes/{n} ({y})/Season {s}/{n} - {s00e00} - {t}\" --q $thetvdb >> \"\${log[@]}\" \# ""$key1"" ""$key2""" -i "$rename"
         fi
         else
        if [ -z "$key2" ]
         then
            sed -i "51i\ \ elif [[ \"\${v,,}\" == *\"${key1,,}\"* ]] \# ""$key1""" -i "$rename"
            sed -i "52i\ \ \ then \# ""$key1""" -i "$rename"
            sed -i "53i\ \ \ \ filebot -rename \"\$v\" --db TheTVDB -non-strict --lang German --format \"/mnt/Medien/Serien/{n} ({y})/Season {s}/{n} - {s00e00} - {t}\" --q $thetvdb >> \"\${log[@]}\" \# ""$key1""" -i "$rename"
          else
            sed -i "51i\ \ elif [[ \"\${v,,}\" == *\"${key1,,}\"*\"${key2,,}\"* ]] \# ""$key1"" ""$key2""" -i "$rename"
            sed -i "52i\ \ \ then \# ""$key1"" ""$key2""" -i "$rename"
            sed -i "53i\ \ \ \ filebot -rename \"\$v\" --db TheTVDB -non-strict --lang German --format \"/mnt/Medien/Serien/{n} ({y})/Season {s}/{n} - {s00e00} - {t}\" --q $thetvdb >> \"\${log[@]}\" \# ""$key1"" ""$key2""" -i "$rename"
        fi
        fi
    fi
fi
