#!/bin/bash

config=$(find ~ -type f -name "JDAutoConfig" 2>/dev/null)
log=$(grep "log=" "$config" | sed 's/.*=//g')

entpackt=$(grep "entpackt=" "$config" | sed 's/.*=//g')
encodes=$(grep "encodes=" "$config" | sed 's/.*=//g')
rename=$(grep "rename=" "$config" | sed 's/.*=//g')
discord=$(grep "discord=" "$config" | sed 's/.*=//g')

# Bitrate & ffmpeg encode preset für die Unterschiedlichen Formate:
bitrate_anime=$(grep "bitrate_anime=" "$config" | sed 's/.*=//g')
preset_anime=$(grep "preset_anime=" "$config" | sed 's/.*=//g')

bitrate_serie=$(grep "bitrate_serie=" "$config" | sed 's/.*=//g')
preset_serie=$(grep "preset_serie=" "$config" | sed 's/.*=//g')

bitrate_filme=$(grep "bitrate_filme=" "$config" | sed 's/.*=//g')
preset_filme=$(grep "preset_filme=" "$config" | sed 's/.*=//g')

# Harware die für das encoden genutzt werden soll:

Encodieren=$(grep "Encodieren=" "$config" | sed 's/.*=//g')

encoder=$(grep "Encoder=" "$config" | sed 's/.*=//g')

discord=$(grep "discord=" "$config" | sed 's/.*=//g')

if [[ ${encoder,,} == "nvidia" ]]; then
  hw_accel="cuda"
  codec="hevc_nvenc"
elif [[ ${encoder,,} == "amd" ]]; then
  hw_accel="auto"
  codec="hevc_amf"
elif [[ ${encoder,,} == "intel" ]]; then
  hw_accel="qsv"
  codec="hevc_qsf"
elif [[ ${encoder,,} == "software" ]]; then
  hw_accel="qsv"
  codec="hevc_qsf"
fi

red='\033[0;31m'    # ${red}
white='\033[0;37m'  # ${white}
yellow='\033[0;33m' # ${yellow}
green='\033[0;32m'  # ${green}
blue='\033[0;34m'   # ${blue}
lblue='\033[1;34m'  # ${lblue}
cyan='\033[0;36m'   # ${cyan}
purple='\033[0;35m' # ${purple}

# Überprüfung, ob es bereits eine Gestartete Instanz gibt. Falls ja, warte 1 Minute

while [ -f /tmp/jdautoenc.lock ]; do
  log_msg "${red} Rename läufts bereits! Warte auf dessen durchlauf"
  sleep 5
done
echo $$ >/tmp/jdautoenc.lock
sleep 1

# Funktionen:

log_msg() {
  echo -e "${yellow}$(date +"%d.%m.%y %T")${white} $1${white}" >>"${log[@]}"
}

discord_msg() {
  curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" "$discord"
}

ff_encode() {
  if [[ ${Encodieren,,} == "yes" ]]; then
    if ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel "$1" -hwaccel_output_format "$1" -i "$i" -c:v "$2" -preset "$3" -b:v "$4" -c:a "$5" -map 0 -c:s copy "${encodes[*]}""${fertig%.*}.mkv" >>"${log[@]}"; then
      log_msg "${red}Lösche${white} Quelldatei ${purple}""$clear""${white}" >>"${log[@]}"
      rmerror=$(rm -f "$i" 2>&1) || log_msg "$rmerror"
    else
      discord_msg "Konnte $clear nicht mit $2 umwandeln. $?" &>/dev/null
    fi
  else
    mv "$i" "${encodes[*]}""${fertig%.*}"
  fi
}
log_msg "##########################"
log_msg "Starte ${green}JDautoenc.sh${white} Skript"
log_msg "##########################"
# Finde alle .mkv und .mp4 Dateien im entpackt Ordner.

find -L "${entpackt[@]}" -name '*.mkv' -or -name '*.mp4' | while IFS= read -r i; do

  ## Überprüfe die dauer des Video Files
  duration=$(ffprobe -hide_banner -loglevel error -v quiet -stats -i "$i" -show_entries format=duration -v quiet -of csv="p=0" | sed 's/\..*//g')
  ## Setze Namen für das fertige Video
  fertig=$(basename "$i")
  clear=$(basename "$i" .mkv | sed 's/\./ /g;s/AAC\|1080p\|WebDL\|[a-z]26[0-9]\|[hH][eE][Vv][Cc]\|[tT]anuki\| dl \| web \|repack\|wayne\|\|[-]\|[gG]er\|[eE]ng\|[sS]ub//g;s/\[[^][]*\]//g;s/_/ /g')
  ## Erstelle eine Logdatei mit Datum und dem jetzigen Vorgang.
  log_msg ""

  ################################################ Anime Sektion ################################################

  ## Falls das Video weniger als 1560 Sekunden beträgt, Kategoriere das Video Als Anime ein
  if [ -z "$duration" ] || [ "$duration" -lt "1560" ]; then
    log_msg "${purple}""$clear""${white} ist ein ${blue}Anime${white}. Überprüfe nun den Video Codec"
    ## Überprüfe in welchen Codec das Video vorliegt
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    ## Wenn Video Codec NICHT HEVC ist, dann überprüfe auch den Audio codec.
    if ! [ "$vcodec" == "hevc" ]; then
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${blue}Anime${white} ${purple}""$clear""${white} Encode von ""${vcodec^^}"" & ""${acodec^^}"" zu HEVC & AC3"
        ff_encode "$hw_accel" "$codec" "$preset_anime" "$bitrate_anime" ac3
      else
        log_msg "${blue}Anime${white} ${purple}""$clear""${white} Encode von ""${vcodec^^}"" zu HEVC"
        ff_encode "$hw_accel" "$codec" "$preset_anime" "$bitrate_anime" "copy"
      fi
    else
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      log_msg "${purple}""$clear""${white} ist bereits HEVC, Überprüfe Audio Codec. Wenn in eac3 oder dts dann Encode Audio zu AC3"
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${purple}""$clear""${white} Encode von ""${acodec^^}"" zu AC3"
        ff_encode "$hw_accel" "copy" "$preset_anime" "$bitrate_anime" "copy"
      else
        log_msg "Nichts zu tun bei ${purple}""$clear""${white}"
        mv "$i" "${encodes[@]}"
      fi
    fi

    ################################################ Serien Sektion ################################################

  elif [ "$duration" -gt "1561" ] && [ "$duration" -lt "4000" ]; then
    log_msg "%s""$fertig"" eine ${lblue}Serie${white}. Überprüfe nun den Video Codec"
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    if ! [ "$vcodec" = "hevc" ]; then
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${lblue}Serie${white} ${purple}""$clear""${white} Encode von ""${vcodec^^}"" & ""${acodec^^}"" zu HEVC 1700k & AC3"
        ff_encode "$hw_accel" "$codec" "$preset_serie" "$bitrate_serie" "ac3"
      else
        log_msg "${lblue}Serie${white} ""$fertig"" Encode von ""${vcodec^^}"" zu HEVC 1700k"
        ff_encode "$hw_accel" "$codec" "$preset_serie" "$bitrate_serie" "copy"
      fi
    else
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${purple}""$clear""${white} Encode von ""${acodec^^}"" zu AC3"
        ff_encode "$hw_accel" "copy" "$preset_serie" "$bitrate_serie" "copy"
      else
        log_msg "Nichts zu tun bei ${purple}""$clear""${white}" >>"${log[@]}"
        log_msg "verschiebe ${purple}""$clear""${white} zum umbenennen"
        mv "$i" "${encodes[@]}"
      fi
    fi

    ################################################ Filme Sektion ################################################

  elif [ "$duration" -gt "4001" ]; then
    log_msg " Video ist ein ${cyan}Film${white}, überprüfe nun den Video Codec"
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    if ! [ "$vcodec" = "hevc" ]; then
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${cyan}Film${white} ${purple}""$clear""${white} Encode von ""$vcodec"" & ""$acodec"" zu HEVC 2M & AC3 500k"
        ff_encode "$hw_accel" "$codec" "$preset_filme" "$bitrate_filme" "ac3"
      else
        log_msg "${cyan}Film${white} ${purple}""$clear""${white} Encode von ""$vcodec"" zu HEVC 2M"
        ff_encode "$hw_accel" "$codec" "$preset_filme" "$bitrate_filme" "copy"
      fi
    else
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      log_msg "Wenn Audio Codec eac3 oder dts dann Convertiere Video und Audio Codec zu HEVC ac3"
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${purple}""$clear""${white} Encode von ""${acodec^^}"" zu AC3"
        ff_encode "$hw_accel" "copy" "$preset_filme" "$bitrate_filme" "copy"
      else
        log_msg "Nichts zu tun bei ${purple}""$clear""${white}"
        mv "$i" "${encodes[@]}"
      fi
    fi
  fi
done

log_msg "${red}Lösche${white} leere Ordner im Entpackt verzeichnis"
find "${entpackt[@]}"* -type d -empty -delete >>"${log[@]}" 2>&1 >>"${log[@]}"

rm -f /tmp/jdautoenc.lock

/bin/bash "$rename" "$log" "$config" &
