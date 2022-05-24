#!/bin/bash

JDAutoConfig=$(find ~ -type f -iname "JDAutoConfig" 2>/dev/null)

language_Folder=$(grep "language_folder=" "$JDAutoConfig" | sed 's/.*=//g')
if [[ -n $(grep "language=" "$JDAutoConfig" | sed 's/.*=//g') ]]; then
  language=$(grep "language=" "$JDAutoConfig" | sed 's/.*=//g')
else
  language=$(locale | head -n 1 | sed 's/.*=\|\..*//g')
fi

if [[ ! -d $language_Folder/$language ]]; then
  language=en_US
fi

log=$(grep "log=" "$JDAutoConfig" | sed 's/.*=//g')

extracted=$(grep "extracted=" "$JDAutoConfig" | sed 's/.*=//g')
encodes=$(grep "encodes=" "$JDAutoConfig" | sed 's/.*=//g')
rename=$(grep "rename=" "$JDAutoConfig" | sed 's/.*=//g')
discord=$(grep "discord=" "$JDAutoConfig" | sed 's/.*=//g')

# Bitrate & ffmpeg encode preset für die Unterschiedlichen Formate:
bitrate_anime=$(grep "bitrate_anime=" "$JDAutoConfig" | sed 's/.*=//g')
preset_anime=$(grep "preset_anime=" "$JDAutoConfig" | sed 's/.*=//g')

bitrate_tvshows=$(grep "bitrate_tvshows=" "$JDAutoConfig" | sed 's/.*=//g')
preset_tvshows=$(grep "preset_tvshows=" "$JDAutoConfig" | sed 's/.*=//g')

bitrate_movies=$(grep "bitrate_movies=" "$JDAutoConfig" | sed 's/.*=//g')
preset_movies=$(grep "preset_movies=" "$JDAutoConfig" | sed 's/.*=//g')

# Harware die für das encoden genutzt werden soll:

Encode=$(grep "Encode=" "$JDAutoConfig" | sed 's/.*=//g')

encoder=$(grep "Encoder=" "$JDAutoConfig" | sed 's/.*=//g')

discord=$(grep "discord=" "$JDAutoConfig" | sed 's/.*=//g')

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

# Funktionen:

text_lang() {
  grep "$1" "$language_Folder"/"$language"/jdautoenc.lang | sed 's/^....//'
}

log_msg() {
  echo -e "${yellow}$(date +"%d.%m.%y %T")${white} $1${white}" >>"${log[@]}"
}

discord_msg() {
  curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" "$discord"
}

ff_encode() {
  if [[ ${Encode,,} == "yes" ]] >>"${log[@]}"; then
    if ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel "$1" -hwaccel_output_format "$1" -i "$i" -c:v "$2" -preset "$3" -b:v "$4" -c:a "$5" -map 0 -c:s copy "${encodes[*]}"/"${fertig%.*}.mkv" >>"${log[@]}" 2>&1; then
      log_msg "${red}$(text_lang "022")${white} ${purple}""$clear""${white}"
      rmerror=$(rm -f "$i" 2>&1) || log_msg "$rmerror"
    else
      discord_msg "$(text_lang "002") $clear $(text_lang "003") $2 $(text_lang "004"). $?" &>/dev/null
    fi
  else
    log_msg "$(text_lang "017") ${purple}""$clear""${white} $(text_lang "018")"
    #mv "$i" "${encodes[*]}"/"${fertig%.*}"
  fi
}

# Erstelle lock Datei, Warte 5 Sekunden und überprüfe nochmals
while [ -f /tmp/jdautoenc.lock ]; do
  sleep 5
done
echo $$ >/tmp/jdautoenc.lock
sleep 1

log_msg ""
log_msg "##########################"
log_msg "$(text_lang "005") ${green}JDautoenc.sh${white} $(text_lang "006")"
log_msg "##########################"
log_msg ""
# Finde alle .mkv und .mp4 Dateien im extracted Ordner.

find -L "${extracted[@]}" -name '*.mkv' -or -name '*.mp4' | while IFS= read -r i; do
  ## Überprüfe die dauer des Video Files
  duration=$(ffprobe -hide_banner -loglevel error -v quiet -stats -i "$i" -show_entries format=duration -v quiet -of csv="p=0" | sed 's/\..*//g')
  ## Setze Namen für das fertige Video
  fertig=$(basename "$i")
  clear=$(basename "$i" .mkv | sed 's/\./ /g;s/AAC\|1080p\|stars\|WebDL\|[a-z]26[0-9]\|[hH][eE][Vv][Cc]\|[tT]anuki\| dl \| web \|repack\|wayne\|\|[-]\|[gG]er\|[eE]ng\|[sS]ub//g;s/\[[^][]*\]//g;s/_/ /g')
  ## Erstelle eine Logdatei mit Datum und dem jetzigen Vorgang.
  log_msg ""

  ################################################ Anime Sektion ################################################

  ## Falls die $duration weniger als 1560 Sekunden beträgt, Kategoriere das Video Als Anime ein
  if [ -z "$duration" ] || [ "$duration" -lt "1560" ]; then
    log_msg "${purple}""$clear""${white} $(text_lang "007") ${blue}$(text_lang "008")${white}. $(text_lang "009")"
    ## Überprüfe in welchen Codec das Video vorliegt
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    ## Wenn Video Codec NICHT HEVC ist, dann überprüfe auch den Audio codec.
    if ! [ "$vcodec" == "hevc" ]; then
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${blue}$(text_lang "008")${white} ${purple}""$clear""${white} $(text_lang "010") ""${vcodec^^}"" & ""${acodec^^}"" $(text_lang "011") HEVC & AC3"
        ff_encode "$hw_accel" "$codec" "$preset_anime" "$bitrate_anime" ac3
      else
        log_msg "${blue}$(text_lang "008")${white} ${purple}""$clear""${white} $(text_lang "010") ""${vcodec^^}"" $(text_lang "011") HEVC"
        ff_encode "$hw_accel" "$codec" "$preset_anime" "$bitrate_anime" "copy"
      fi
    else
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      log_msg "${purple}""$clear""${white} $(text_lang "012")"
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${purple}""$clear""${white} $(text_lang "010") ""${acodec^^}"" $(text_lang "011") AC3"
        ff_encode "$hw_accel" "copy" "$preset_anime" "$bitrate_anime" "copy"
      else
        log_msg "$(text_lang "013") ${purple}""$clear""${white}"
        log_msg "$(text_lang "017") ${purple}""$clear""${white} $(text_lang "018")"
        mv "$i" "${encodes[@]}"
      fi
    fi
    ################################################ Serien Sektion ################################################
  elif [ "$duration" -gt "1561" ] && [ "$duration" -lt "4000" ]; then
    log_msg "%s""$fertig"" $(text_lang "015") ${lblue}$(text_lang "016")${white}. $(text_lang "014")"
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    if ! [ "$vcodec" = "hevc" ]; then
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${lblue}$(text_lang "016")${white} ${purple}""$clear""${white} $(text_lang "010") ""${vcodec^^}"" & ""${acodec^^}"" $(text_lang "011") HEVC 1700k & AC3"
        ff_encode "$hw_accel" "$codec" "$preset_tvshows" "$bitrate_tvshows" "ac3"
      else
        log_msg "${lblue}$(text_lang "016")${white} ""$fertig"" $(text_lang "010") ""${vcodec^^}"" $(text_lang "011") HEVC 1700k"
        ff_encode "$hw_accel" "$codec" "$preset_tvshows" "$bitrate_tvshows" "copy"
      fi
    else
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${purple}""$clear""${white} $(text_lang "010") ""${acodec^^}"" $(text_lang "011") AC3"
        ff_encode "$hw_accel" "copy" "$preset_tvshows" "$bitrate_tvshows" "copy"
      else
        log_msg "$(text_lang "013") ${purple}""$clear""${white}" >>"${log[@]}"
        log_msg "$(text_lang "017") ${purple}""$clear""${white} $(text_lang "018")"
        mv "$i" "${encodes[@]}"
      fi
    fi

    ################################################ Filme Sektion ################################################
  elif [ "$duration" -gt "4001" ]; then
    log_msg " $(text_lang "019") ${cyan}$(text_lang "020")${white}, $(text_lang "021")"
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    if ! [ "$vcodec" = "hevc" ]; then
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${cyan}$(text_lang "020")${white} ${purple}""$clear""${white} $(text_lang "010") ""$vcodec"" & ""$acodec"" $(text_lang "011") HEVC 2M & AC3 500k"
        ff_encode "$hw_accel" "$codec" "$preset_movies" "$bitrate_movies" "ac3"
      else
        log_msg "${cyan}$(text_lang "020")${white} ${purple}""$clear""${white} $(text_lang "010") ""$vcodec"" $(text_lang "011") HEVC 2M"
        ff_encode "$hw_accel" "$codec" "$preset_movies" "$bitrate_movies" "copy"
      fi
    else
      acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
      if [ "$acodec" = "eac3" ] || [ "$acodec" = "dts" ]; then
        log_msg "${purple}""$clear""${white} $(text_lang "010") ""${acodec^^}"" $(text_lang "011") AC3"
        ff_encode "$hw_accel" "copy" "$preset_movies" "$bitrate_movies" "copy"
      else
        log_msg "$(text_lang "013") ${purple}""$clear""${white}"
        log_msg "$(text_lang "017") ${purple}""$clear""${white} $(text_lang "018")"
        mv "$i" "${encodes[@]}"
      fi
    fi
  fi
done

log_msg "${red}$(text_lang "022")${white} $(text_lang "023")"
find "${extracted[@]}"* -type d -empty -delete 2>/dev/null >>"${log[@]}"

rm -f /tmp/jdautoenc.lock

/bin/bash "$rename" "$log" "$JDAutoConfig" &
