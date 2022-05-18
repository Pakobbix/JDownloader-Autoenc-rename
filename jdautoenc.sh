#!/bin/bash

entpackt="$1"
log="$2"
out="$3"
rename="$4"
renamelist="$5"
discord="$6"

# Bitrate & ffmpeg encode preset für die Unterschiedlichen Formate:
bitrate_anime=1400
preset_anime=fast

bitrate_serie=1700
preset_serie=fast

bitrate_filme=2000
preset_filme=fast

# Harware die für das encoden genutzt werden soll:

hw_accel="cuda"
codec="hevc_nvenc"

# AMD:

#hw_accel="auto"
#codec="hevc_amf"

# Intel:

#hw_accel="qsv"
#codec="hevc_qsf"

red='\033[0;31m'    # ${red}
white='\033[0;37m'  # ${white}
yellow='\033[0;33m' # ${yellow}
green='\033[0;32m'  # ${green}
blue='\033[0;34m'   # ${blue}
lblue='\033[1;34m'  # ${lblue}
cyan='\033[0;36m'   # ${cyan}
purple='\033[0;35m' # ${purple}

# Funktionen:

log_msg() {
  echo -e "${yellow}$(date +"%d.%m.%y %T")${white}  $1${white}" >>"${log[@]}"
}

discord_msg() {
  curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" "$discord"
}

ff_encode() {
  if ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel "$1" -hwaccel_output_format "$1" -i "$i" -c:v "$2" -preset "$3" -b:v "$4"K -c:a "$5" -map 0 -c:s copy "${out[*]}""${fertig%.*}.mkv" >>"${log[@]}" 2>&1; then
    log_msg "${red}Lösche${white} ${purple}""$clear""${white}" >>"${log[@]}"
    rm -f "$i" >>"${log[@]}"
  else
    discord_msg "Konnte $clear nicht mit $2 umwandeln. $?"
  fi
}

log_msg "Starte ${green}JDautoenc.sh${white} Skript"

# Finde alle .mkv und .mp4 Dateien im entpackt Ordner.

find -L "${entpackt[@]}" -name '*.mkv' -or -name '*.mp4' | while IFS= read -r i; do

  ## Überprüfe die dauer des Video Files
  duration=$(ffprobe -hide_banner -loglevel error -v quiet -stats -i "$i" -show_entries format=duration -v quiet -of csv="p=0" | sed 's/\..*//g')
  ## Setze Namen für das fertige Video
  fertig=$(basename "$i")
  clear=$(basename "$i" .mkv | sed 's/\./ /g;s/AAC\|1080p\|WebDL\|[a-z]26[0-9]\|[hH][eE][Vv][Cc]\|[tT]anuki\| dl \| web \|repack\|wayne\|\|[-]\|[gG]er\|[eE]ng\|[sS]ub//g;s/\[[^][]*\]//g;s/_/ /g')
  ## Erstelle eine Logdatei mit Datum und dem jetzigen Vorgang.
  log_msg "Überprüfe ob ${purple}""$clear""${white} ein ${blue}Anime${white} ist (weniger als 24 Minuten)"

  ################################################ Anime Sektion ################################################

  ## Falls die $duration weniger als 1560 Sekunden beträgt, Kategoriere das Video Als Anime ein
  if [ -z "$duration" ] || [ "$duration" -lt "1560" ]; then
    log_msg "${purple}""$clear""${white} ist ein ${blue}Anime${white}. Überprüfe nun den Video Codec"
    ## Überprüfe in welchen Codec das Video vorliegt
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    log_msg "Wenn ${purple}""$clear""${white} nicht in HEVC überprüfe Audio Codec"
    ## Wenn Video Codec NICHT HEVC ist, dann überprüfe auch den Audio codec.
    if ! [ "$vcodec" == "hevc" ]; then
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      log_msg "Wenn Audio Codec eac3 oder dts dann Convertiere ${purple}""$clear""${white} und Audio Codec zu HEVC AC3"
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
        mv "$i" "${out[@]}"
      fi
    fi
    ################################################ Serien Sektion ################################################
    log_msg "Überprüfe ob ${purple}""$clear""${white} eine ${lblue}Serie${white} ist (mehr als 25 Minuten, weniger als 65 Minuten)"
  elif [ "$duration" -gt "1561" ] && [ "$duration" -lt "4000" ]; then
    log_msg "%s""$fertig"" eine ${lblue}Serie${white}. Überprüfe nun den Video Codec"
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    log_msg "${purple}""$clear""${white} nutz Codec ""${vcodec^^}"". Wenn nicht in HEVC überprüfe Audio Codec"
    if ! [ "$vcodec" = "hevc" ]; then
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      log_msg "Wenn Audio Codec eac3 oder dts dann Convertiere Video und Audio Codec zu HEVC ac3"
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${lblue}Serie${white} ${purple}""$clear""${white} Encode von ""${vcodec^^}"" & ""${acodec^^}"" zu HEVC 1700k & AC3"
        ff_encode "$hw_accel" "$codec" "$preset_serie" "$bitrate_serie" "ac3"
      else
        log_msg "${lblue}Serie${white} ""$fertig"" Encode von ""${vcodec^^}"" zu HEVC 1700k"
        ff_encode "$hw_accel" "$codec" "$preset_serie" "$bitrate_serie" "copy"
      fi
    else
      log_msg "Wenn ${lblue}Serie${white} in HEVC überprüfe Audiocodec und Encode nur diesen"
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      log_msg "Wenn Audio Codec eac3 oder dts dann Convertiere Video und Audio Codec zu HEVC ac3"
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${purple}""$clear""${white} Encode von ""${acodec^^}"" zu AC3"
        ff_encode "$hw_accel" "copy" "$preset_serie" "$bitrate_serie" "copy"
      else
        log_msg "Nichts zu tun bei ${purple}""$clear""${white}" >>"${log[@]}"
        log_msg "verschiebe ${purple}""$clear""${white} zum umbenennen"
        mv "$i" "${out[@]}"
      fi
    fi

    ################################################ Filme Sektion ################################################
    log_msg "Überprüfe ob ${purple}""$clear""${white} ein ${cyan}Film${white} ist (mehr als 65 Minuten)"
  elif [ "$duration" -gt "4001" ]; then
    log_msg " Video ist ein ${cyan}Film${white}, überprüfe nun den Video Codec"
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    log_msg "Wenn Video nicht in HEVC überprüfe Audio Codec"
    if ! [ "$vcodec" = "hevc" ]; then
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      log_msg "Wenn Audio Codec eac3 oder dts dann Convertiere Video und Audio Codec zu HEVC ac3"
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
        mv "$i" "${out[@]}"
      fi
    fi
  fi
done

log_msg "${red}Lösche${white} leere Ordner im Entpackt verzeichnis"
find "${entpackt[@]}"* -type d -empty -delete >>"${log[@]}" 2>&1 >>"${log[@]}"

/bin/bash "$rename" "$log" "$out" "$renamelist" "$discord" &
