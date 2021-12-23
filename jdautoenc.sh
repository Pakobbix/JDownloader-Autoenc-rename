#!/bin/bash

# Nehme alle Dateien mit einer .mkv oder .mp4 Endung

entpackt="$1"
log="$2"
out="$3"
rename="$4"
filebotAnime="$5"
filebotSerie="$6"
filebotFilme="$7"


red='\033[0;31m' # ${red}
white='\033[0;37m' # ${white}
yellow='\033[0;33m' # ${yellow}
green='\033[0;32m' # ${green}
blue='\033[0;34m' # ${blue}
lblue='\033[1;34m' # ${lblue}
cyan='\033[0;36m' # ${cyan}
purple='\033[0;35m' # ${purple}

## Leider kann JDownloader nicht unterscheiden zwischen Paket fertig entpackt und ein archiv innerhalb eines Paketes entpackt.
## Daher erstellen wir eine Condition zum überprüfen, ob ffmpeg nicht vielleicht schon läuft durch ein früher ausgeführtes Skript.
## Damit wir aber auch die neuen Dateien encoden und nicht nur die ersten, beenden wir nicht das Skript, sondern warten einfach,
## bis das alte Skript fertig ist. Danach erst lassen wir den Loop im neueren Skript durchlaufen und durch die Löschung der Dateien,
## sollte es keine Doppelten Dateien geben.

echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Starte ${green}JDautoenc.sh${white} Skript" >> "${log[@]}"

find -L "${entpackt[@]}" -name '*.mkv' -or -name '*.mp4' | while IFS= read -r i
do

## Hier einige beispiele für das Encoden mit unterschiedlichen GPU's

#cuda='-hwaccel cuda -hwaccel_output_format cuda -i "$i" -c:v hevc_nvenc'
#amd="-hwaccel auto -i "$i" -c:v hevc_amf"
#intel="-hwaccel qsv -i "$i" -c:v hevc_qsv"

## Überprüfe die dauer des Video Files
  duration=$(ffprobe -hide_banner -loglevel error -v quiet -stats -i "$i" -show_entries format=duration -v quiet -of csv="p=0" | sed 's/\..*//g')
## Setze Namen für das fertige Video
  fertig=$(basename "$i")
  clear=$(basename "$i" .mkv | sed 's/\./ /g;s/AAC\|1080p\|WebDL\|[a-z]26[0-9]\|hevc\|-[t-T]anuki\| dl \| web \|repack\|wayne\|\|[-]\|[gG]er\|[eE]ng\|[sS]ub//g;s/\[[^][]*\]//g;s/_/ /g')
  ## Erstelle eine Logdatei mit Datum und dem jetzigen Vorgang.
  echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Überprüfe ob ${purple}""$clear""${white} ein ${blue}Anime${white} ist (weniger als 24 Minuten)" >> "${log[@]}"

################################################ Anime Sektion ################################################
## Falls die $duration weniger als 1560 Sekunden beträgt, Kategoriere das Video Als Anime ein
  if [ -z "$duration" ] || [ "$duration" -lt "1560" ]
   then
    echo -e  "${yellow}$(date +"%d.%m.%y %T")${white} ${purple}""$clear""${white} ist ein ${blue}Anime${white}. Überprüfe nun den Video Codec" >> "${log[@]}"
## Überprüfe in welchen Codec das Video vorliegt
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Wenn ${purple}""$clear""${white} nicht in HEVC überprüfe Audio Codec" >> "${log[@]}"
## Wenn Video Codec NICHT HEVC ist, dann überprüfe auch den Audio codec.
    if ! [ "$vcodec" == "hevc" ]
     then
       acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
       echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Wenn Audio Codec eac3 oder dts dann Convertiere ${purple}""$clear""${white} und Audio Codec zu HEVC AC3" >> "${log[@]}"
       if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]
        then
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${blue}Anime${white} ${purple}""$clear""${white} Encode von ""${vcodec^^}"" & ""${acodec^^}"" zu HEVC & AC3" >> "${log[@]}"
         ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel cuda -hwaccel_output_format cuda -i "$i" -c:v hevc_nvenc -preset fast -b:v 1400k -c:a ac3 -map 0 -c:s copy  "${out[*]}""${fertig%.*}.mkv" >> "${log[@]}" 2>&1
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Lösche${white} ${purple}""$clear""${white}" >> "${log[@]}"
         if [ -f "${out[*]}""${fertig%.*}.mkv" ]
          then
           rm -f "$i" >> "${log[@]}"
         fi
        else
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${blue}Anime${white} ${purple}""$clear""${white} Encode von ""${vcodec^^}"" zu HEVC" >> "${log[@]}"
         ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel cuda -hwaccel_output_format cuda -i "$i" -c:v hevc_nvenc -preset fast -b:v 1400k -c:a copy -map 0 -c:s copy  "${out[*]}""${fertig%.*}.mkv" >> "${log[@]}" 2>&1
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Lösche${white} ${purple}""$clear""${white}" >> "${log[@]}"
         if [ -f "${out[*]}""${fertig%.*}.mkv" ]
          then
           rm -f "$i" >> "${log[@]}"
         fi
       fi
     else
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${purple}""$clear""${white} ist bereits HEVC, Überprüfe Audio Codec. Wenn in eac3 oder dts dann Encode Audio zu AC3" >> "${log[@]}"
       if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]
        then
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${purple}""$clear""${white} Encode von ""${acodec^^}"" zu AC3" >> "${log[@]}"
         ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel cuda -hwaccel_output_format cuda -i "$i" -c:v copy -preset fast -b:v 1400k -c:a ac3 -map 0 -c:s copy  "${out[*]}""${fertig%.*}.mkv" >> "${log[@]}" 2>&1
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Lösche${white} ${purple}""$clear""${white}" >> "${log[@]}"
         if [ -f "${out[*]}""${fertig%.*}.mkv" ]
          then
           rm -f "$i" >> "${log[@]}"
         fi
        else
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Nichts zu tun bei ${purple}""$clear""${white}" >> "${log[@]}"
         mv "$i" "${out[@]}"
       fi
   fi

################################################ Serien Sektion ################################################
   echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Überprüfe ob ${purple}""$clear""${white} eine ${lblue}Serie${white} ist (mehr als 25 Minuten, weniger als 65 Minuten)" >> "${log[@]}"
  elif [ "$duration" -gt "1561" ] && [ "$duration" -lt "4000" ]
   then
    echo -e "${yellow}$(date +"%d.%m.%y %T")${white} %s""$fertig"" eine ${lblue}Serie${white}. Überprüfe nun den Video Codec" >> "${log[@]}"
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${purple}""$clear""${white} nutz Codec ""${vcodec^^}"". Wenn nicht in HEVC überprüfe Audio Codec" >> "${log[@]}"
    if ! [ "$vcodec" = "hevc" ]
     then
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Wenn Audio Codec eac3 oder dts dann Convertiere Video und Audio Codec zu HEVC ac3" >> "${log[@]}"
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]
       then
        {
        echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${lblue}Serie${white} ${purple}""$clear""${white} Encode von ""${vcodec^^}"" & ""${acodec^^}"" zu HEVC 1700k & AC3"
        ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel cuda -hwaccel_output_format cuda -i "$i" -c:v hevc_nvenc -preset fast -b:v 1700k -c:a ac3 -map 0 -c:s copy  "${out[*]}""${fertig%.*}.mkv" >> "${log[@]}" 2>&1
        echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Lösche${white} ${purple}""$clear""${white}"
        } >> "${log[@]}"
        if [ -f "${out[*]}""${fertig%.*}.mkv" ]
          then
           rm -f "$i" >> "${log[@]}"
         fi
       else
        echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${lblue}Serie${white} ""$fertig"" Encode von ""${vcodec^^}"" zu HEVC 1700k" >> "${log[@]}"
        ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel cuda -hwaccel_output_format cuda -i "$i" -c:v hevc_nvenc -preset fast -b:v 1700k -c:a copy -map 0 -c:s copy  "${out[*]}""${fertig%.*}.mkv" >> "${log[@]}" 2>&1
        echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Lösche${white} ${purple}""$clear""${white}" >> "${log[@]}"
        if [ -f "${out[*]}""${fertig%.*}.mkv" ]
         then
          rm -f "$i" >> "${log[@]}"
        fi
       fi
     else
      echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Wenn ${lblue}Serie${white} in HEVC überprüfe Audiocodec und Encode nur diesen" >> "${log[@]}"
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Wenn Audio Codec eac3 oder dts dann Convertiere Video und Audio Codec zu HEVC ac3" >> "${log[@]}"
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]
       then
        echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${purple}""$clear""${white} Encode von ""${acodec^^}"" zu AC3" >> "${log[@]}"
        ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel cuda -hwaccel_output_format cuda -i "$i" -c:v copy -preset fast -b:v 1700k -c:a ac3 -map 0 -c:s copy  "${out[*]}""${fertig%.*}.mkv" >> "${log[@]}" 2>&1
        echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Lösche${white} ${purple}""$clear""${white}" >> "${log[@]}"
        if [ -f "${out[*]}""${fertig%.*}.mkv" ]
         then
          rm -f "$i" >> "${log[@]}"
        fi
       else
        echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Nichts zu tun bei ${purple}""$clear""${white}" >> "${log[@]}"
        echo -e "${yellow}$(date +"%d.%m.%y %T")${white} verschiebe ${purple}""$clear""${white} zum umbenennen" >> "${log[@]}"
        mv "$i" "${out[@]}"
       fi
  fi

################################################ Filme Sektion ################################################
   echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Überprüfe ob ${purple}""$clear""${white} ein ${cyan}Film${white} ist (mehr als 65 Minuten)" >> "${log[@]}"
  elif [ "$duration" -gt "4001" ]
   then
    echo -e "${yellow}$(date +"%d.%m.%y %T")${white}  Video ist ein ${cyan}Film${white}, überprüfe nun den Video Codec" >> "${log[@]}"
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Wenn Video nicht in HEVC überprüfe Audio Codec" >> "${log[@]}"
    if ! [ "$vcodec" = "hevc" ]
     then
       acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
       echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Wenn Audio Codec eac3 oder dts dann Convertiere Video und Audio Codec zu HEVC ac3" >> "${log[@]}"
       if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]
        then
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${cyan}Film${white} ${purple}""$clear""${white} Encode von ""$vcodec"" & ""$acodec"" zu HEVC 2M & AC3 500k" >> "${log[@]}"
         ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel cuda -hwaccel_output_format cuda -i "$i" -c:v hevc_nvenc -preset fast -b:v 2000k -c:a ac3 -b:a 500k -map 0 -c:s copy  "${out[*]}""${fertig%.*}.mkv" >> "${log[@]}" 2>&1 >> "${log[@]}"
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Lösche${white} ${purple}""$clear""${white}" >> "${log[@]}"
         if [ -f "${out[*]}""${fertig%.*}.mkv" ]
          then
           rm -f "$i" >> "${log[@]}"
         fi
        else
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${cyan}Film${white} ${purple}""$clear""${white} Encode von ""$vcodec"" zu HEVC 2M" >> "${log[@]}"
         ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel cuda -hwaccel_output_format cuda -i "$i" -c:v hevc_nvenc -preset fast -b:v 2000k -c:a copy -map 0 -c:s copy  "${out[*]}""${fertig%.*}.mkv" >> "${log[@]}" 2>&1 >> "${log[@]}"
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Lösche${white} ${purple}""$clear""${white}" >> "${log[@]}"
         if [ -f "${out[*]}""${fertig%.*}.mkv" ]
          then
           rm -f "$i" >> "${log[@]}"
         fi
       fi
    else
     acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
     echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Wenn Audio Codec eac3 oder dts dann Convertiere Video und Audio Codec zu HEVC ac3" >> "${log[@]}"
     if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]
       then
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${purple}""$clear""${white} Encode von ""${acodec^^}"" zu AC3" >> "${log[@]}"
         ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel cuda -hwaccel_output_format cuda -i "$i" -c:v copy -preset fast -b:v 1700k -c:a ac3 -map 0 -c:s copy  "${out[*]}""${fertig%.*}.mkv" >> "${log[@]}" 2>&1
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Lösche${white} ${purple}""$clear""${white}" >> "${log[@]}"
         if [ -f "${out[*]}""${fertig%.*}.mkv" ]
          then
           rm -f "$i"  >> "${log[@]}"
         fi
       else
         echo -e "${yellow}$(date +"%d.%m.%y %T")${white} Nichts zu tun bei ${purple}""$clear""${white}" >> "${log[@]}"
         mv "$i" "${out[@]}"
    fi
  fi
fi
done


echo -e "${yellow}$(date +"%d.%m.%y %T")${white} ${red}Lösche${white} leere Ordner im Entpackt verzeichnis" >> "${log[@]}"
find "${entpackt[@]}"* -type d -empty -delete  >> "${log[@]}" 2>&1 >> "${log[@]}"


/bin/bash "$rename" "$log" "$out" "filebotAnime" "filebotSerie" "filebotFilme" &
