#!/bin/bash

config=$(find ~ -type f -name "JDAutoConfig" 2>/dev/null)
log=$(grep "log=" "$config" | sed 's/.*=//g')

# shellcheck disable=SC1090
source "$config"

case "${Encoder,,}" in
nvidia)
  hw_accel="cuda"
  codec="hevc_nvenc"
  ;;
amd)
  hw_accel="auto"
  codec="hevc_amf"
  ;;
intel)
  hw_accel="qsv"
  codec="hevc_qsf"
  ;;
software)
  hw_accel="qsv"
  codec="hevc_qsf"
  ;;
esac

red='\033[0;31m'    # ${red}
white='\033[0;37m'  # ${white}
yellow='\033[0;33m' # ${yellow}
green='\033[0;32m'  # ${green}
blue='\033[0;34m'   # ${blue}
lblue='\033[1;34m'  # ${lblue}
cyan='\033[0;36m'   # ${cyan}
purple='\033[0;35m' # ${purple}

if [[ -z $language ]]; then
  language=$(locale | head -n 1 | sed 's/.*=\|\..*//g')
fi

if [[ $language == "C" ]] || [[ ! -d $language_Folder/$language ]]; then
  language=en_US
fi

text_lang() {
  if [ -f "$language_Folder"/"$language"/jdautoenc.lang ]; then
    grep "$1" "$language_Folder"/"$language"/jdautoenc.lang | sed 's/^....//'
  else
    curl -s https://raw.githubusercontent.com/Pakobbix/JDownloader-Autoenc-rename/main/lang/en_US/jdautoenc.lang | grep "$1" | sed 's/^....//'
  fi
}

if [ -f /tmp/jdautoenc.lock ]; then
  log_msg "${red}$(text_lang "001")"
  sleep 3
fi

while [ -f /tmp/jdautoenc.lock ]; do
  sleep $(((RANDOM % 10) + 1))s
done

echo $$ >/tmp/jdautoenc.lock

log_msg() {
  echo -e "${yellow}$(date +"%d.%m.%y %T")${white} $1${white}" >>"${log[@]}"
}

discord_msg() {
  curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" "$discord" &>/dev/null
}

nextcloud_msg() {
  curl -d '{"token":"'"$NextcloudTalkToken"'", "message":"'"$1"'"}' -H "Content-Type: application/json" -H "Accept:application/json" -H "OCS-APIRequest:true" -u "$NextcloudUser:$NextcloudPassword" "$NextcloudDomain"/ocs/v1.php/apps/spreed/api/v1/chat/tokenid &>/dev/null
}

apprise_msg() {
  if [[ -n $apprisetag ]]; then
    curl -d '{"body":"'"$1"'", "title":"#### jdautoenc.sh ####","tag":"'"$apprisetag"'"}' -H "Content-Type: application/json" "$appriseurl" &>/dev/null
  else
    curl -d '{"body":"'"$1"'", "title":"#### jdautoenc.sh ####","tag":"all"}' -H "Content-Type: application/json" "$appriseurl" &>/dev/null
  fi
}

ff_encode() {
  if [[ ${encode,,} == "yes" ]]; then
    total_frames=$(ffprobe -v error -show_format -select_streams v:0 -show_streams "$i" | grep TAG:NUMBER_OF_FRAMES= | sed 's/.*=\|\..*//g')
    fps=$(grep "fps=" "$log" | tail -n 1 | sed 's/.*fps=\| q=.*\|\..*//g')
    eta_encoding=$((total_frames / fps))
    if [[ $eta_encoding -gt "60" ]]; then
      log_msg "Estimated Encoding Time: $((total_frames / fps / 60)) Minutes (based on last encoding speed)"
    else
      log_msg "Estimated Encoding Time: $((total_frames / fps)) Seconds (based on last encoding speed)"
    fi
    if ffmpeg -hide_banner -v quiet -stats -nostdin -hwaccel "$1" -hwaccel_output_format "$1" -i "$i" -c:v "$2" -preset "$3" -b:v "$4"K -c:a "$5" -map 0 -c:s copy "${encodes[*]}""${fertig%.*}.mkv" >>"${log[@]}" 2>&1; then
      finishedduration=$(ffprobe -hide_banner -loglevel error -v quiet -stats -i "${encodes[*]}""${fertig%.*}.mkv" -show_entries format=duration -v quiet -of csv="p=0" | sed 's/\..*//g')
      if [[ $finishedduration -eq $duration ]]; then
        log_msg "${red}$(text_lang "002")${white} $(text_lang "003")${purple}""$clear""${white}"
        if ! rm -f "$i" &>/dev/null; then
          log_msg "${red}$(text_lang "004")"
          discord_msg "$(text_lang "004")"
          nextcloud_msg "$(text_lang "004")"
          apprise_msg "$(text_lang "004")"
        fi
      else
        rmencoded=$(rm -f "${encodes[*]}""${fertig%.*}.mkv" 2>&1) || log_msg "$rmencoded"
        log_msg "${red} $(text_lang "006")"
        nextcloud_msg "$(text_lang "006") $clear $(text_lang "007") $2 $(text_lang "008"). $?"
        discord_msg "$(text_lang "006") $clear $(text_lang "007") $2 $(text_lang "008"). $?"
        apprise_msg "$(text_lang "006") $clear $(text_lang "007") $2 $(text_lang "008"). $?"
      fi
    fi
  else
    mv "$i" "${encodes[*]}""${fertig%.*}"
  fi
}
log_msg ""
log_msg "##########################"
log_msg "$(text_lang "009") ${green}JDautoenc.sh${white} $(text_lang "010")"
log_msg "##########################"
log_msg ""

find -L "${extracted[@]}" -name '*.mkv' -or -name '*.mp4' 2>/dev/null | while IFS= read -r i; do

  duration=$(ffprobe -hide_banner -loglevel error -v quiet -stats -i "$i" -show_entries format=duration -v quiet -of csv="p=0" | sed 's/\..*//g')
  fertig=$(basename "$i")
  clear=$(basename "$i" .mkv | sed 's/\./ /g;s/AAC\|1080p\|WebDL\|[a-z]26[0-9]\|[hH][eE][Vv][Cc]\|[tT]anuki\| dl \| web \|repack\|wayne\|\|[-]\|[gG]er\|[eE]ng\|[sS]ub//g;s/\[[^][]*\]\|WebDL\|JapDub\|CR\|REPACK\|V2DK\|man\|BluRay\|RSG//g;s/_/ /g;s/\( \)*/\1/g')
  ################################################ Anime Sektion ################################################
  if [[ -z $duration || $duration -lt "1560" ]]; then
    log_msg "${purple}$clear${white} $(text_lang "011") ${blue}$(text_lang "012")${white}. $(text_lang "013")"
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    HDR_test=$(ffprobe -v quiet -show_streams -select_streams v:0 "$i" | grep ^color_transfer= | awk -F'=' '{print $2}')
    if [[ $HDR_test == *"smpte2084" || $HDR_test == *"arib-std-b67" ]]; then
      if ! [ "$vcodec" == "hevc" ]; then
        acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
        if [[ $acodec == "eac3" || $acodec == "dts" ]]; then
          log_msg "${blue}$(text_lang "012")${white} ${purple}""$clear""${white} $(text_lang "014") ${vcodec^^} & ${acodec^^} $(text_lang "015") HEVC & AC3"
          ff_encode "$hw_accel" "$codec" "$preset_anime" "$bitrate_anime" ac3
        else
          log_msg "${blue}$(text_lang "012")${white} ${purple}""$clear""${white} $(text_lang "014") ${vcodec^^} $(text_lang "015") HEVC"
          ff_encode "$hw_accel" "$codec" "$preset_anime" "$bitrate_anime" "copy"
        fi
      else
        acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
        log_msg "${purple}""$clear""${white} $(text_lang "016")"
        if [[ $acodec == "eac3" || $acodec == "dts" ]]; then
          log_msg "${purple}""$clear""${white} $(text_lang "014") ${acodec^^} $(text_lang "015") AC3"
          ff_encode "$hw_accel" "copy" "$preset_anime" "$bitrate_anime" "ac3"
        else
          log_msg "$(text_lang "017") ${purple}$clear${white} $(text_lang "018")"
          mv "$i" "${encodes[@]}"
        fi
      fi
    else
      log_msg "$(text_lang "017") ${purple}$clear${white} $(text_lang "018")"
      mv "$i" "${encodes[@]}"
    fi
    ################################################ Serien Sektion ################################################
  elif [ "$duration" -gt "1561" ] && [ "$duration" -lt "4750" ]; then
    log_msg "${purple}$fertig${white} $(text_lang "011") ${lblue}$(text_lang "019")${white}. $(text_lang "013")"
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    HDR_test=$(ffprobe -v quiet -show_streams -select_streams v:0 "$i" | grep ^color_transfer= | awk -F'=' '{print $2}')
    if [[ $HDR_test == *"smpte2084" || $HDR_test == *"arib-std-b67" ]]; then
      if ! [ "$vcodec" = "hevc" ]; then
        acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
        if [[ $acodec == "eac3" || $acodec == "dts" ]]; then
          log_msg "${lblue}$(text_lang "019")${white} ${purple}$clear${white} $(text_lang "014") ${vcodec^^} & ${acodec^^} $(text_lang "015") HEVC 1700k & AC3"
          ff_encode "$hw_accel" "$codec" "$preset_series" "$bitrate_series" "ac3"
        else
          log_msg "${lblue}$(text_lang "019")${white} $fertig $(text_lang "014") ${vcodec^^} $(text_lang "015") HEVC 1700k"
          ff_encode "$hw_accel" "$codec" "$preset_series" "$bitrate_series" "copy"
        fi
      else
        acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
        if [[ $acodec == "eac3" || $acodec == "dts" ]]; then
          log_msg "${purple}$clear${white} $(text_lang "014") ${acodec^^} $(text_lang "015") AC3"
          ff_encode "$hw_accel" "copy" "$preset_series" "$bitrate_series" "ac3"
        else
          log_msg "$(text_lang "017") ${purple}$clear${white} $(text_lang "018")"
          mv "$i" "${encodes[@]}"
        fi
      fi
    else
      log_msg "$(text_lang "017") ${purple}$clear${white} $(text_lang "018")"
      mv "$i" "${encodes[@]}"
    fi
    ################################################ Filme Sektion ################################################
  elif [ "$duration" -gt "4751" ]; then
    log_msg "${purple}$fertig${white} $(text_lang "011") ${cyan}$(text_lang "022")${white}, $(text_lang "013")"
    vcodec=$(ffprobe -hide_banner -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
    HDR_test=$(ffprobe -v quiet -show_streams -select_streams v:0 "$i" | grep ^color_transfer= | awk -F'=' '{print $2}')
    if [[ $HDR_test == *"smpte2084" || $HDR_test == *"arib-std-b67" ]]; then
      if ! [ "$vcodec" = "hevc" ]; then
        acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
        if [[ $acodec == "eac3" || $acodec == "dts" ]]; then
          log_msg "${cyan}$(text_lang "022")${white} ${purple}$clear${white} $(text_lang "014") $vcodec & $acodec $(text_lang "015") HEVC 2M & AC3 500k"
          ff_encode "$hw_accel" "$codec" "$preset_movie" "$bitrate_movie" "ac3"
        else
          log_msg "${cyan}$(text_lang "022")${white} ${purple}$clear${white} $(text_lang "014") $vcodec $(text_lang "015") HEVC 2M"
          ff_encode "$hw_accel" "$codec" "$preset_movie" "$bitrate_movie" "copy"
        fi
      else
        acodec=$(ffprobe -hide_banner -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$i")
        log_msg "${purple}$clear${white} $(text_lang "016")"
        if [[ $acodec == "eac3" || $acodec == "dts" ]]; then
          log_msg "${purple}$clear${white} $(text_lang "014") ${acodec^^} $(text_lang "015") AC3"
          ff_encode "$hw_accel" "copy" "$preset_movie" "$bitrate_movie" "ac3"
        else
          log_msg "$(text_lang "017") ${purple}$clear${white} $(text_lang "018")"
          mv "$i" "${encodes[@]}"
        fi
      fi
    fi
  else
    log_msg "$(text_lang "017") ${purple}$clear${white} $(text_lang "018")"
    mv "$i" "${encodes[@]}"
  fi
done

log_msg "$(text_lang "020")"
rm -f /tmp/jdautoenc.lock

log_msg "${red}$(text_lang "002")${white} $(text_lang "021")"
find "${extracted[@]}"* -type d -empty -delete 2>/dev/null >>"${log[@]}"

/bin/bash "$rename" "$log" "$config" &
