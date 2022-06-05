#!/bin/bash

# Sucht JDAutoConfig und fragt, ob dies der richtige Pfad ist.

JDAutoConfig=$(find ~ -type f -iname "JDAutoConfig" 2>/dev/null)

# Funktion für später, um z.B. zenity statt whiptail zu nutzen.

language_Folder=$(grep "language_folder=" "$JDAutoConfig" | sed 's/.*=//g')
if [[ -n $(grep "language=" "$JDAutoConfig" | sed 's/.*=//g') ]]; then
  language=$(grep "language=" "$JDAutoConfig" | sed 's/.*=//g')
else
  language=$(locale | head -n 1 | sed 's/.*=\|\..*//g')
fi

if [[ $language == "C" ]] || [[ ! -d $language_Folder/$language ]]; then
  language=en_US
fi

possiblelangfolder=$(find ~ -type f -wholename "*lang/$language/config.lang" 2>/dev/null | sed 's/en_US\/config.lang//g')

if ! [ -f "$language_Folder"/"$language"/config.lang ]; then
  real_language_Folder=$(whiptail --title "Could not find language folder" --inputbox "WARNING!! Language folder could not be found. Please type the Path to the language folder or else, the script will try to get the language from Github (could be buggy)\nPossible Path: $possiblelangfolder" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
  edit_languagefolder=$(echo "$language_Folder" | sed -e "s#/#\\\/#g")
  sed -i "s/$edit_languagefolder/$real_language_Folder/g" "$JDAutoConfig"
fi

text_lang() {
  if [ -f "$language_Folder"/"$language"/config.lang ]; then
    grep "$1" "$language_Folder"/"$language"/config.lang | sed 's/^....//'
  else
    curl -s https://raw.githubusercontent.com/Pakobbix/JDownloader-Autoenc-rename/Multilanguage/lang/en_US/config.lang | grep "$1" | sed 's/^....//'
  fi
}

check_skript_location() {
  if ! $1 --title "$(text_lang "001")" --"$2" "$JDAutoConfig" 16 100; then
    unset JDAutoConfig
    JDAutoConfig=$($1 --title "$(text_lang "002")" --"$3" "$(text_lang "003")" 16 100 "$4" 3>&2 2>&1 1>&3)
  fi
}

change_path() {
  if [[ -z $2 ]]; then
    whiptail --title "$(text_lang "005")" --msgbox "$(text_lang "005")" 16 50
    return
  else
    if sed -i "s/$1/$2/g" "$JDAutoConfig"; then
      whiptail --title "$(text_lang "006") $4 $(text_lang "007")" --msgbox "$(text_lang "008")\n$2" 16 100
    else
      whiptail --title "$(text_lang "009")" --msgbox "$(text_lang "010") $2\n$(text_lang "011")" 16 100
    fi
  fi
}

db_auswhal() {
  choose_db=$(
    whiptail --title "$(text_lang "012")" --menu "" 20 100 12 \
      "1)" "TheMovieDB" \
      "2)" "TheMovieDB::TV" \
      "3)" "TheTVDB" \
      "4)" "AniDB" \
      "5)" "$(text_lang "017")" 3>&2 2>&1 1>&3
  )
  case $choose_db in
  "1)")
    newdb="TheMovieDB"
    ;;
  "2)")
    newdb="TheMovieDB::TV"
    ;;
  "3)")
    newdb="TheTVDB"
    ;;
  "4)")
    newdb="AniDB"
    ;;
  "5)")
    return
    ;;
  esac
}

bitrate_auswahl() {
  whiptail --title "$1 $(text_lang "013")" --radiolist "$(text_lang "014") $1 an:\n$(text_lang "015")" 20 100 12 \
    "1000" "$(text_lang "016") 1000K" OFF \
    "1100" "$(text_lang "016") 1100K" OFF \
    "1200" "$(text_lang "016") 1200K" OFF \
    "1300" "$(text_lang "016") 1300K" OFF \
    "1400" "$(text_lang "016") 1400K" $2 \
    "1500" "$(text_lang "016") 1500K" OFF \
    "1600" "$(text_lang "016") 1600K" OFF \
    "1700" "$(text_lang "016") 1700K" $3 \
    "1800" "$(text_lang "016") 1800K" OFF \
    "1900" "$(text_lang "016") 1900K" OFF \
    "2000" "$(text_lang "016") 2000K" $4 \
    "2100" "$(text_lang "016") 2100K" OFF \
    "2200" "$(text_lang "016") 2200K" OFF \
    "2300" "$(text_lang "016") 2300K" OFF \
    "2400" "$(text_lang "016") 2400K" OFF \
    "2500" "$(text_lang "016") 2500K" OFF \
    "2600" "$(text_lang "016") 2600K" OFF \
    "2700" "$(text_lang "016") 2700K" OFF \
    "2800" "$(text_lang "016") 2800K" OFF \
    "2900" "$(text_lang "016") 2900K" OFF \
    "3000" "$(text_lang "016") 3000K" OFF 3>&1 1>&2 2>&3
}

preset_auswahl() {
  whiptail --title "$1 $(text_lang "018")" --radiolist "$(text_lang "019") $1 :\n$(text_lang "015")" 20 120 12 \
    "Ultrafast" "$(text_lang "020")" OFF \
    "superfast" "$(text_lang "021")" OFF \
    "veryfast" "$(text_lang "021")" OFF \
    "faster" "$(text_lang "022")" OFF \
    "fast" "$(text_lang "023")" ON \
    "medium" "$(text_lang "024")$2" OFF \
    "slow" "$(text_lang "025")" OFF \
    "slower" "$(text_lang "026")" OFF \
    "veryslow" "$(text_lang "027")$3" OFF \
    "hq" "$(text_lang "028")" OFF \
    "lossless" "$(text_lang "029")" OFF 3>&1 1>&2 2>&3

}

# Fragt, ob der gefundene Pfad zur startencode.sh der richtige ist.
check_skript_location whiptail yesno inputbox
# Loop das Hauptmenü
while true; do
  # Aufbau des Menüs
  Wahl=$(
    whiptail --title "$(text_lang "030")" --menu "$(text_lang "031")\n$(text_lang "032")" 20 100 9 \
      "1)" "$(text_lang "033")" \
      "2)" "$(text_lang "034")" \
      "3)" "$(text_lang "035")" \
      "4)" "$(text_lang "036")" \
      "5)" "$(text_lang "037")" \
      "6)" "$(text_lang "038")" \
      "7)" "$(text_lang "017")" 3>&2 2>&1 1>&3
  )
  # Zuordnung Funktionen zu Menüpunkten
  case $Wahl in
  "1)")
    # Abfrage, ob alle Skripte (startencode.sh, jdautoenc.sh und rename.sh) am selben Ort sind, um den generellen Pfad auf diesen umzustellen
    if whiptail --title "$(text_lang "039")" --yesno "$(text_lang "040") ${JDAutoConfig//JDAutoConfig/} $(text_lang "041")\n\n$(text_lang "042")" 20 100; then
      newpath=$(echo "${JDAutoConfig//\/JDAutoConfig/}" | sed -e "s#/#\\\/#g")
      jdautoencpfad=$(grep "jdautoenc=" "$JDAutoConfig" | sed 's/jdautoenc=\|["]//g' | sed -e "s#/#\\\/#g")
      renamepfad=$(grep "rename=" "$JDAutoConfig" | sed 's/rename=\|["]//g' | sed -e "s#/#\\\/#g")
      renamelist=$(grep "renamelist=" "$JDAutoConfig" | sed 's/renamelist=\|["]//g' | sed -e "s#/#\\\/#g")
      change_path "$jdautoencpfad" "$newpath\/jdautoenc.sh" "$JDAutoConfig" "jdautoenc.sh"
      change_path "$renamepfad" "$newpath\/rename.sh" "$JDAutoConfig" "rename.sh"
      change_path "$renamelist" "$newpath\/renamelist" "$JDAutoConfig" "renamelist"
    fi
    jdautoencpfad=$(grep "jdautoenc=" "$JDAutoConfig" | sed 's/jdautoenc=\|["]//g' | sed -e "s#/#\\\/#g")
    renamepfad=$(grep "rename=" "$JDAutoConfig" | sed 's/rename=\|["]//g' | sed -e "s#/#\\\/#g")
    renamelist=$(grep "renamelist=" "$JDAutoConfig" | sed 's/renamelist=\|["]//g' | sed -e "s#/#\\\/#g")
    entpacktpfad=$(grep "extracted=" "$JDAutoConfig" | sed 's/extracted=\|["]//g' | sed -e "s#/#\\\/#g")
    encodespfad=$(grep "encodes=" "$JDAutoConfig" | sed 's/encodes=\|["]//g' | sed -e "s#/#\\\/#g")
    logpfad=$(grep "log=" "$JDAutoConfig" | sed 's/log=\|["]//g' | sed -e "s#/#\\\/#g")
    FilmPfad=$(grep "Movies=" "$JDAutoConfig" | sed 's/Movies=\|["]//g' | sed -e "s#/#\\\/#g")
    SerienPfad=$(grep "Series=" "$JDAutoConfig" | sed 's/Series=\|["]//g' | sed -e "s#/#\\\/#g")
    AnimePfad=$(grep "Animes=" "$JDAutoConfig" | sed 's/Animes=\|["]//g' | sed -e "s#/#\\\/#g")
    # Neues Menü Loop für das ändern von Pfaden
    while true; do
      #  ____       _   _       ____       _   _   _
      # |  _ \ __ _| |_| |__   / ___|  ___| |_| |_(_)_ __   __ _ ___
      # | |_) / _` | __| '_ \  \___ \ / _ \ __| __| | '_ \ / _` / __|
      # |  __/ (_| | |_| | | |  ___) |  __/ |_| |_| | | | | (_| \__ \
      # |_|   \__,_|\__|_| |_| |____/ \___|\__|\__|_|_| |_|\__, |___/
      #                                                    |___/
      Wahl=$(
        whiptail --title "$(text_lang "043")" --menu "$(text_lang "044")" 22 100 13 \
          "1)" "jdautoenc.sh $jdautoencpfad" \
          "2)" "rename.sh $renamepfad" \
          "3)" "renamelist $renamelist" \
          "" "" \
          "4)" "$(text_lang "045") $entpacktpfad" \
          "5)" "$(text_lang "046") $encodespfad" \
          "6)" "$(text_lang "047") $logpfad" \
          "" "" \
          "7)" "$(text_lang "048") $FilmPfad" \
          "8)" "$(text_lang "049") $SerienPfad" \
          "9)" "$(text_lang "050") $AnimePfad" \
          "" "" \
          "10)" "$(text_lang "017")" 3>&2 2>&1 1>&3
      )
      case $Wahl in
      "1)")
        # jdautoenc.sh Pfad
        newjdautopfad=$(whiptail --title "$(text_lang "051")" --inputbox "$(text_lang "052") jdautoenc.sh:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$jdautoencpfad" "$newjdautopfad" "$JDAutoConfig" "jdautoenc.sh"
        ;;
      "2)")
        # rename.sh Pfad
        newrenamepfad=$(whiptail --title "$(text_lang "051")" --inputbox "$(text_lang "052") rename.sh:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$renamepfad" "$newrenamepfad" "$JDAutoConfig" "rename.sh"
        ;;
      "3)")
        # renamelist Pfad
        newrenamelist=$(whiptail --title "$(text_lang "051")" --inputbox "$(text_lang "052") die renamelist:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$renamelist" "$newrenamelist" "$JDAutoConfig" "renamelist"
        ;;
      "4)")
        # Ordnerpfad für den Ordner in dem entpackte Videos liegen.
        newentpackpfad=$(whiptail --title "$(text_lang "051")" --inputbox "$(text_lang "053")" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$entpacktpfad" "$newentpackpfad" "$JDAutoConfig" "$(text_lang "045")"
        ;;
      "5)")
        # Orderpfad in dem die encodierten Videos hinterlegt werden.
        newencodesfolder=$(whiptail --title "$(text_lang "051")" --inputbox "$(text_lang "054")" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$encodespfad" "$newencodesfolder" "$JDAutoConfig" "$(text_lang "046")"
        ;;
      "6)")
        # Log Pfad. Hier wird das Log hingeschrieben
        newlogpfad=$(whiptail --title "$(text_lang "051")" --inputbox "$(text_lang "052") log." 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$logpfad" "$newlogpfad" "$JDAutoConfig" "Log Pfad"
        ;;
      "7)")
        # Log Pfad. Hier wird das Log hingeschrieben
        newFilmpfad=$(whiptail --title "$(text_lang "051")" --inputbox "$(text_lang "052") $(text_lang "048")" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$FilmPfad" "$newFilmpfad" "$JDAutoConfig" "$(text_lang "055")"
        ;;
      "8)")
        # Log Pfad. Hier wird das Log hingeschrieben
        newSerienpfad=$(whiptail --title "$(text_lang "051")" --inputbox "$(text_lang "052") $(text_lang "049")" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$SerienPfad" "$newSerienpfad" "$JDAutoConfig" "$(text_lang "056")"
        ;;
      "9)")
        # Log Pfad. Hier wird das Log hingeschrieben
        newAnimePfad=$(whiptail --title "$(text_lang "051")" --inputbox "$(text_lang "052") $(text_lang "050")" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$AnimePfad" "$newAnimePfad" "$JDAutoConfig" "$(text_lang "057")"
        ;;
      "10)")
        # break = Gehe zurück in das vorherige Menü
        break
        ;;
        # Ende vom Menü
      esac
    done
    ;;
  "2)")
    # Hier werden die Log Farben angepasst. Muss mir noch überlegen, wie ich die definieren kann.
    whiptail --msgbox "Work in Progress" 20 78
    ;;
  "3)")
    messagesystem=$(
      whiptail --title "$(text_lang "058")" --menu "$(text_lang "059")" 20 100 9 \
        "1)" "Discord" \
        "2)" "Nextcloud Talk" \
        "3)" "coming soon" \
        "4)" "coming soon" \
        "5)" "$(text_lang "017")" 3>&2 2>&1 1>&3
    )
    case $messagesystem in
    "1)")
      #  ____  _                       _   ____       _   _   _
      # |  _ \(_)___  ___ ___  _ __ __| | / ___|  ___| |_| |_(_)_ __   __ _ ___
      # | | | | / __|/ __/ _ \| '__/ _` | \___ \ / _ \ __| __| | '_ \ / _` / __|
      # | |_| | \__ \ (_| (_) | | | (_| |  ___) |  __/ |_| |_| | | | | (_| \__ \
      # |____/|_|___/\___\___/|_|  \__,_| |____/ \___|\__|\__|_|_| |_|\__, |___/
      #                                                               |___/
      # Ändere Einstellung zu nVidia Encoding
      curr_dishook=$(grep "discord=" "$JDAutoConfig" | sed 's/.*=//g')
      dishook=$(whiptail --title "$(text_lang "060")" --inputbox "$(text_lang "061") $curr_dishook" 16 100 "$4" 3>&2 2>&1 1>&3 | sed -e "s#/#\\\/#g")
      if [ -z "$dishook" ]; then
        echo ""
      else
        sed -i "s/discord=.*/discord=$dishook/g" "$JDAutoConfig"
      fi
      ;;
    "2)")
      #  _   _           _       _                 _   ____       _   _   _
      # | \ | | _____  _| |_ ___| | ___  _   _  __| | / ___|  ___| |_| |_(_)_ __   __ _ ___
      # |  \| |/ _ \ \/ / __/ __| |/ _ \| | | |/ _` | \___ \ / _ \ __| __| | '_ \ / _` / __|
      # | |\  |  __/>  <| || (__| | (_) | |_| | (_| |  ___) |  __/ |_| |_| | | | | (_| \__ \
      # |_| \_|\___/_/\_\\__\___|_|\___/ \__,_|\__,_| |____/ \___|\__|\__|_|_| |_|\__, |___/
      #                                                                           |___/
      curr_NextcloudDomain=$(grep "NextcloudDomain=" "$JDAutoConfig" | sed 's/.*=//g')
      curr_NextcloudUser=$(grep "NextcloudUser=" "$JDAutoConfig" | sed 's/.*=//g')
      curr_NextcloudPassword=$(grep "NextcloudPassword=" "$JDAutoConfig" | sed 's/.*=//g')
      curr_NextcloudToken=$(grep "NextcloudTalkToken=" "$JDAutoConfig" | sed 's/.*=//g')
      while true; do
        nextcloudmenu=$(
          whiptail --title "$(text_lang "062")" --menu "$(text_lang "063")" 20 100 13 \
            "1)" "Nextcloud Domain: $(text_lang "064") $curr_NextcloudDomain" \
            "2)" "Nextcloud User: $(text_lang "064") $curr_NextcloudUser" \
            "3)" "Nextcloud Password: $(text_lang "064") $curr_NextcloudPassword" \
            "4)" "Nextcloud Token: $(text_lang "064") $curr_NextcloudToken" \
            "5)" "Beenden" 3>&2 2>&1 1>&3
        )
        case $nextcloudmenu in
        "1)")
          NextcloudDomain=$(whiptail --title "$(text_lang "065")" --inputbox "$(text_lang "066")\n$(text_lang "067")\n$(text_lang "068")\n\n$(text_lang "064") $curr_NextcloudDomain" 16 100 "$4" 3>&2 2>&1 1>&3 | sed -e "s#/#\\\/#g")
          if [ -z "$NextcloudDomain" ]; then
            echo ""
          else
            sed -i "s/NextcloudDomain=.*/NextcloudDomain=$NextcloudDomain/g" "$JDAutoConfig"
          fi
          ;;
        "2)")
          NextcloudUser=$(whiptail --title "$(text_lang "065")" --inputbox "$(text_lang "069") $(text_lang "064") $curr_NextcloudUser" 16 100 "$4" 3>&2 2>&1 1>&3 | sed -e "s#/#\\\/#g")
          if [ -z "$NextcloudUser" ]; then
            echo ""
          else
            sed -i "s/NextcloudUser=.*/NextcloudUser=$NextcloudUser/g" "$JDAutoConfig"
          fi
          ;;
        "3)")
          NextcloudPassword=$(whiptail --title "$(text_lang "065")" --inputbox "$(text_lang "070") $(text_lang "064") $curr_NextcloudPassword" 16 100 "$4" 3>&2 2>&1 1>&3 | sed -e "s#/#\\\/#g")
          if [ -z "$NextcloudPassword" ]; then
            echo ""
          else
            sed -i "s/NextcloudPassword=.*/NextcloudPassword=$NextcloudPassword/g" "$JDAutoConfig"
          fi
          ;;
        "4)")
          NextcloudTalkToken=$(whiptail --title "$(text_lang "065")" --inputbox "$(text_lang "071")\n$(text_lang "072") $(text_lang "064") $curr_NextcloudToken" 16 100 "$4" 3>&2 2>&1 1>&3 | sed -e "s#/#\\\/#g")
          if [ -z "$NextcloudTalkToken" ]; then
            echo ""
          else
            sed -i "s/NextcloudTalkToken=.*/NextcloudTalkToken=$NextcloudTalkToken/g" "$JDAutoConfig"
          fi
          ;;
        "5)")
          break
          ;;
        esac
      done
      ;;
    "3)") ;;

    "4)") ;;

    "5)")
      return 2>/dev/null
      ;;
    esac
    # Hier werden die Log Farben angepasst. Muss mir noch überlegen, wie ich die definieren kann.
    ;;
  "4)")
    #  _____                     _ _               ____       _   _   _
    # | ____|_ __   ___ ___   __| (_)_ __   __ _  / ___|  ___| |_| |_(_)_ __   __ _ ___
    # |  _| | '_ \ / __/ _ \ / _` | | '_ \ / _` | \___ \ / _ \ __| __| | '_ \ / _` / __|
    # | |___| | | | (_| (_) | (_| | | | | | (_| |  ___) |  __/ |_| |_| | | | | (_| \__ \
    # |_____|_| |_|\___\___/ \__,_|_|_| |_|\__, | |____/ \___|\__|\__|_|_| |_|\__, |___/
    #                                      |___/                              |___/
    # Einstellungen für das encoden. (noch in der jdautoenc.sh definiert. Wandern vielleicht bald in das startencode.sh skript)
    while true; do
      curr_encode_allow=$(if [[ $(grep "encode=" "$JDAutoConfig" | sed 's/.*encode=//g') == "yes" ]]; then echo "Eingeschaltet"; else echo "Ausgeschaltet"; fi)
      curr_anime_bitrate=$(grep "bitrate_anime=" "$JDAutoConfig" | sed 's/.*bitrate_anime=//g')
      curr_anime_preset=$(grep "preset_anime=" "$JDAutoConfig" | sed 's/.*preset_anime=//g')
      curr_serien_bitrate=$(grep "bitrate_series=" "$JDAutoConfig" | sed 's/.*bitrate_series=//g')
      curr_serien_preset=$(grep "preset_series=" "$JDAutoConfig" | sed 's/.*preset_series=//g')
      curr_filme_bitrate=$(grep "bitrate_movie=" "$JDAutoConfig" | sed 's/.*bitrate_movie=//g')
      curr_filme_preset=$(grep "preset_movie=" "$JDAutoConfig" | sed 's/.*preset_movie=//g')
      bitratewahl=$(
        whiptail --title "$(text_lang "074")" --menu "$(text_lang "075")" 20 100 13 \
          "1)" "$(text_lang "076") $curr_encode_allow" \
          "2)" "$(text_lang "077") $curr_anime_bitrate K" \
          "3)" "$(text_lang "078") $curr_anime_preset" \
          "" "" \
          "4)" "$(text_lang "079") $curr_serien_bitrate K" \
          "5)" "$(text_lang "080") $curr_serien_preset" \
          "" "" \
          "6)" "$(text_lang "081") $curr_filme_bitrate K" \
          "7)" "$(text_lang "082") $curr_filme_preset" \
          "" "" \
          "8)" "$(text_lang "017")" 3>&2 2>&1 1>&3
      )
      case $bitratewahl in
      "1)")
        # Ändere die bitrate für Animes
        if whiptail --title "$(text_lang "083")" --yesno "$(text_lang "084")" 20 100; then
          sed -i "s/encode=.*/encode=yes/g" "$JDAutoConfig"
        else
          sed -i "s/encode=.*/encode=no/g" "$JDAutoConfig"
        fi
        ;;
      "2)")
        # Ändere die bitrate für Animes
        new_anime_bitrate=$(bitrate_auswahl "Animes" ON OFF OFF)
        sed -i "s/^bitrate_anime.*/bitrate_anime=$new_anime_bitrate/g" "$JDAutoConfig"
        ;;
      "3)")
        # Ändere das zu nutzende Preset für Animes
        new_anime_preset=$(preset_auswahl "Animes")
        sed -i "s/^preset_anime=.*/preset_anime=$new_anime_preset/g" "$JDAutoConfig"
        ;;
      "4)")
        # Ändere die bitrate für Serien
        new_serien_bitrate=$(bitrate_auswahl "Serien" OFF ON OFF)
        sed -i "s/^bitrate_series.*/bitrate_series=$new_serien_bitrate/g" "$JDAutoConfig"
        ;;
      "5)")
        # Ändere das zu nutzende Preset für Serien
        new_serien_preset=$(preset_auswahl "Serien")
        sed -i "s/^preset_series=.*/preset_series=$new_serien_preset/g" "$JDAutoConfig"
        ;;
      "6)")
        # Ändere die bitrate für Filme
        new_filme_bitrate=$(bitrate_auswahl "Filme" OFF OFF ON)
        sed -i "s/^bitrate_movie.*/bitrate_movie=$new_filme_bitrate/g" "$JDAutoConfig"
        ;;
      "7)")
        # Ändere das zu nutzende Preset für Filme
        new_filme_preset=$(preset_auswahl "Filme")
        sed -i "s/^preset_movie=.*/preset_movie=$new_filme_preset/g" "$JDAutoConfig"
        ;;
      "8)")
        break
        ;;
      esac
    done
    ;;
  "5)")
    # _____                     _ _               _   ___        __
    #| ____|_ __   ___ ___   __| (_)_ __   __ _  | | | \ \      / /
    #|  _| | '_ \ / __/ _ \ / _` | | '_ \ / _` | | |_| |\ \ /\ / /
    #| |___| | | | (_| (_) | (_| | | | | | (_| | |  _  | \ V  V /
    #|_____|_| |_|\___\___/ \__,_|_|_| |_|\__, | |_| |_|  \_/\_/
    #                                     |___/
    # Wir schauen, ob wir kompatible Hardware anzeigen lassen können
    gethw=$(lshw -class display 2>/dev/null | grep vendor)
    for hw in $gethw; do
      if [[ ${hw,,} == *"nvidia"* ]]; then
        hw1="\nnVidia $(text_lang "085")"
      elif [[ ${hw,,} == *"intel"* ]]; then
        hw2="\nIntel iGPU"
      elif [[ ${hw,,} == *"radeon"* ]]; then
        hw3="\nAMD $(text_lang "085")"
      elif [[ ${hw,,} == *"microsoft"* ]]; then
        hw4="\nMicrosoft WSL $(text_lang "086")"
      fi
    done
    Hardwareauswahl=$(
      whiptail --title "$(text_lang "087")" --menu "$(text_lang "088") $hw1 $hw2 $hw3 $hw4" 20 100 9 \
        "1)" "nVidia" \
        "2)" "AMD" \
        "3)" "Intel QuickSync (Intel CPU)" \
        "4)" "Software (noch NICHT IMPLEMENTIERT!)" \
        "5)" "Beenden" 3>&2 2>&1 1>&3
    )
    case $Hardwareauswahl in
    "1)")
      # Ändere Einstellung zu nVidia Encoding
      sed -i 's/Encoder=.*/Encoder=nvidia/g' "$JDAutoConfig"
      whiptail --msgbox "$(text_lang "089")\n$(text_lang "090")" 20 78
      ;;
    "2)")
      # Ändere Einstellung zu AMD Enconding
      sed -i 's/Encoder=.*/Encoder=amd/g' "$JDAutoConfig"
      whiptail --msgbox "$(text_lang "091")\n$(text_lang "092")" 20 78
      ;;
    "3)")
      # Ändere Einstellung zu Intel Quick Sync Encoding
      sed -i 's/Encoder=.*/Encoder=intel/g' "$JDAutoConfig"
      whiptail --msgbox "$(text_lang "093")\n$(text_lang "094")" 20 78
      ;;
    "4)")
      whiptail --msgbox "$(text_lang "095")" 20 78
      return 2>/dev/null
      ;;
    "5)")
      return 2>/dev/null
      ;;
    esac
    ;;
  "6)")
    # _____ _ _      ____        _     ____       _   _   _
    #|  ___(_) | ___| __ )  ___ | |_  / ___|  ___| |_| |_(_)_ __   __ _ ___
    #| |_  | | |/ _ \  _ \ / _ \| __| \___ \ / _ \ __| __| | '_ \ / _` / __|
    #|  _| | | |  __/ |_) | (_) | |_   ___) |  __/ |_| |_| | | | | (_| \__ \
    #|_|   |_|_|\___|____/ \___/ \__| |____/ \___|\__|\__|_|_| |_|\__, |___/
    #                                                             |___/
    while true; do
      curr_movie_db=$(grep "MovieDB=" "$JDAutoConfig" | sed 's/.*MovieDB=//g')
      curr_series_db=$(grep "SeriesDB=" "$JDAutoConfig" | sed 's/.*SeriesDB=//g')
      curr_anime_db=$(grep "AnimeDB=" "$JDAutoConfig" | sed 's/.*AnimeDB=//g')
      curr_movie_name=$(grep "MovieName=" "$JDAutoConfig" | sed 's/.*MovieName=//g')
      curr_series_name=$(grep "SeriesName=" "$JDAutoConfig" | sed 's/.*SeriesName=//g')
      curr_anime_name=$(grep "AnimeName=" "$JDAutoConfig" | sed 's/.*AnimeName=//g')
      curr_Language=$(grep "FileBotLang=" "$JDAutoConfig" | sed 's/.*FileBotLang=//g')
      FileBotMenu=$(
        whiptail --title "$(text_lang "096")" --menu "$(text_lang "097")" 20 100 12 \
          "1)" "$(text_lang "098") $curr_movie_db" \
          "2)" "$(text_lang "099") $curr_series_db" \
          "3)" "$(text_lang "100") $curr_anime_db" \
          "" "" \
          "4)" "$(text_lang "101") $curr_movie_name" \
          "5)" "$(text_lang "102") $curr_series_name" \
          "6)" "$(text_lang "103") $curr_anime_name" \
          "" "" \
          "7)" "$(text_lang "104") $curr_Language" \
          "8)" "$(text_lang "017")" 3>&2 2>&1 1>&3
      )
      case $FileBotMenu in
      "1)")
        db_auswhal
        sed -i "s/MovieDB.*/MovieDB=$newdb/g" "$JDAutoConfig"
        ;;
      "2)")
        db_auswhal
        sed -i "s/SeriesDB.*/SeriesDB=$newdb/g" "$JDAutoConfig"
        ;;
      "3)")
        db_auswhal
        sed -i "s/AnimeDB.*/AnimeDB=$newdb/g" "$JDAutoConfig"
        ;;
      "4)")
        new_film_name=$(whiptail --title "$(text_lang "051")" --inputbox "$(text_lang "105")\n{n} {y}\nThe Man From Earth 2007.mkv" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        if [[ -n $new_film_name ]]; then
          sed -i "s/MovieName=.*/MovieName=$new_film_name/g" "$JDAutoConfig"
        else
          whiptail --msgbox "$(text_lang "108")" 20 78
        fi
        ;;
      "5)")
        new_serien_name=$(whiptail --title "$(text_lang "051")" --inputbox "$(text_lang "106")\n{n} {y}/Season {s}/{n} - {s00e00} - {t}\nFirefly 2002/Season 1/Firefly - S01E01 - The Train Job" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        if [[ -n $new_serien_name ]]; then
          sed -i "s/SeriesName=.*/SeriesName=$new_serien_name/g" "$JDAutoConfig"
        else
          whiptail --msgbox "$(text_lang "108")" 20 78
        fi
        ;;

      "6)")
        new_anime_name=$(whiptail --title "$(text_lang "051")" --inputbox "$(text_lang "107")" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        if [[ -n $new_anime_name ]]; then
          sed -i "s/AnimeName=.*/AnimeName=$new_anime_name/g" "$JDAutoConfig"
        else
          whiptail --msgbox "$(text_lang "108")" 20 78
        fi
        ;;
      "7)")
        new_lang=$(
          whiptail --title "$(text_lang "109")" --radiolist "$(text_lang "110")\n{n} {y}/Season {s}/{n} - {s00e00} - {t}\nElfenlied 2004/Season 1/Elfenlied - S01E01 - A Chance Encounter: Begegnung" 20 100 12 \
            "Afar" "aa" OFF \
            "Abkhazian" "ab" OFF \
            "Afrikaans" "af" OFF \
            "Akan" "ak" OFF \
            "Albanian" "sq" OFF \
            "Amharic" "am" OFF \
            "Arabic" "ar" OFF \
            "Aragonese" "an" OFF \
            "Armenian" "hy" OFF \
            "Assamese" "as" OFF \
            "Avaric" "av" OFF \
            "Avestan" "ae" OFF \
            "Aymara" "ay" OFF \
            "Azerbaijani" "az" OFF \
            "Bashkir" "ba" OFF \
            "Bambara" "bm" OFF \
            "Basque" "eu" OFF \
            "Belarusian" "be" OFF \
            "Bengali" "bn" OFF \
            "Bihari" "bh" OFF \
            "Bislama" "bi" OFF \
            "Tibetan" "bo" OFF \
            "Bosnian" "bs" OFF \
            "Breton" "br" OFF \
            "Bulgarian" "bg" OFF \
            "Burmese" "my" OFF \
            "Catalan" "ca" OFF \
            "Czech" "cs" OFF \
            "Chamorro" "ch" OFF \
            "Chechen" "ce" OFF \
            "Chinese" "zh" OFF \
            "Church" "cu" OFF \
            "Chuvash" "cv" OFF \
            "Cornish" "kw" OFF \
            "Corsican" "co" OFF \
            "Cree" "cr" OFF \
            "Welsh" "cy" OFF \
            "Czech" "cs" OFF \
            "Danish" "da" OFF \
            "German" "de" ON \
            "Divehi" "dv" OFF \
            "Dutch" "nl" OFF \
            "Dzongkha" "dz" OFF \
            "Greek" "el" OFF \
            "English" "en" OFF \
            "Esperanto" "eo" OFF \
            "Estonian" "et" OFF \
            "Basque" "eu" OFF \
            "Ewe" "ee" OFF \
            "Faroese" "fo" OFF \
            "Persian" "fa" OFF \
            "Fijian" "fj" OFF \
            "Finnish" "fi" OFF \
            "French" "fr" OFF \
            "French" "fr" OFF \
            "Western" "fy" OFF \
            "Fulah" "ff" OFF \
            "Georgian" "ka" OFF \
            "German" "de" OFF \
            "Gaelic" "gd" OFF \
            "Irish" "ga" OFF \
            "Galician" "gl" OFF \
            "Manx" "gv" OFF \
            "Greek" "el" OFF \
            "Guarani" "gn" OFF \
            "Gujarati" "gu" OFF \
            "Haitian" "ht" OFF \
            "Hausa" "ha" OFF \
            "Hebrew" "he" OFF \
            "Herero" "hz" OFF \
            "Hindi" "hi" OFF \
            "Hiri" "ho" OFF \
            "Croatian" "hr" OFF \
            "Hungarian" "hu" OFF \
            "Armenian" "hy" OFF \
            "Igbo" "ig" OFF \
            "Icelandic" "is" OFF \
            "Ido" "io" OFF \
            "Sichuan" "ii" OFF \
            "Inuktitut" "iu" OFF \
            "Interlingue" "ie" OFF \
            "Interlingua" "ia" OFF \
            "Indonesian" "id" OFF \
            "Inupiaq" "ik" OFF \
            "Icelandic" "is" OFF \
            "Italian" "it" OFF \
            "Javanese" "jv" OFF \
            "Japanese" "ja" OFF \
            "Kalaallisut" "kl" OFF \
            "Kannada" "kn" OFF \
            "Kashmiri" "ks" OFF \
            "Georgian" "ka" OFF \
            "Kanuri" "kr" OFF \
            "Kazakh" "kk" OFF \
            "Central" "km" OFF \
            "Kikuyu" "ki" OFF \
            "Kinyarwanda" "rw" OFF \
            "Kirghiz" "ky" OFF \
            "Komi" "kv" OFF \
            "Kongo" "kg" OFF \
            "Korean" "ko" OFF \
            "Kuanyama" "kj" OFF \
            "Kurdish" "ku" OFF \
            "Lao" "lo" OFF \
            "Latin" "la" OFF \
            "Latvian" "lv" OFF \
            "Limburgan" "li" OFF \
            "Lingala" "ln" OFF \
            "Lithuanian" "lt" OFF \
            "Luxembourgish" "lb" OFF \
            "Luba-Katanga" "lu" OFF \
            "Ganda" "lg" OFF \
            "Macedonian" "mk" OFF \
            "Marshallese" "mh" OFF \
            "Malayalam" "ml" OFF \
            "Maori" "mi" OFF \
            "Marathi" "mr" OFF \
            "Malay" "ms" OFF \
            "Macedonian" "mk" OFF \
            "Malagasy" "mg" OFF \
            "Maltese" "mt" OFF \
            "Mongolian" "mn" OFF \
            "Maori" "mi" OFF \
            "Malay" "ms" OFF \
            "Burmese" "my" OFF \
            "Nauru" "na" OFF \
            "Navajo" "nv" OFF \
            "Ndebele" "nr" OFF \
            "Ndebele" "nd" OFF \
            "Ndonga" "ng" OFF \
            "Nepali" "ne" OFF \
            "Dutch" "nl" OFF \
            "Norwegian" "nn" OFF \
            "Bokmål" "nb" OFF \
            "Norwegian" "no" OFF \
            "Chichewa" "ny" OFF \
            "Occitan" "oc" OFF \
            "Ojibwa" "oj" OFF \
            "Oriya" "or" OFF \
            "Oromo" "om" OFF \
            "Ossetian" "os" OFF \
            "Panjabi" "pa" OFF \
            "Persian" "fa" OFF \
            "Pali" "pi" OFF \
            "Polish" "pl" OFF \
            "Portuguese" "pt" OFF \
            "Pushto" "ps" OFF \
            "Quechua" "qu" OFF \
            "Romansh" "rm" OFF \
            "Romanian" "ro" OFF \
            "Romanian" "ro" OFF \
            "Rundi" "rn" OFF \
            "Russian" "ru" OFF \
            "Sango" "sg" OFF \
            "Sanskrit" "sa" OFF \
            "Sinhala" "si" OFF \
            "Slovak" "sk" OFF \
            "Slovak" "sk" OFF \
            "Slovenian" "sl" OFF \
            "Northern" "se" OFF \
            "Samoan" "sm" OFF \
            "Shona" "sn" OFF \
            "Sindhi" "sd" OFF \
            "Somali" "so" OFF \
            "Sotho" "st" OFF \
            "Spanish" "es" OFF \
            "Albanian" "sq" OFF \
            "Sardinian" "sc" OFF \
            "Serbian" "sr" OFF \
            "Swati" "ss" OFF \
            "Sundanese" "su" OFF \
            "Swahili" "sw" OFF \
            "Swedish" "sv" OFF \
            "Tahitian" "ty" OFF \
            "Tamil" "ta" OFF \
            "Tatar" "tt" OFF \
            "Telugu" "te" OFF \
            "Tajik" "tg" OFF \
            "Tagalog" "tl" OFF \
            "Thai" "th" OFF \
            "Tibetan" "bo" OFF \
            "Tigrinya" "ti" OFF \
            "Tonga" "to" OFF \
            "Tswana" "tn" OFF \
            "Tsonga" "ts" OFF \
            "Turkmen" "tk" OFF \
            "Turkish" "tr" OFF \
            "Twi" "tw" OFF \
            "Uighur" "ug" OFF \
            "Ukrainian" "uk" OFF \
            "Urdu" "ur" OFF \
            "Uzbek" "uz" OFF \
            "Venda" "ve" OFF \
            "Vietnamese" "vi" OFF \
            "Volapük" "vo" OFF \
            "Welsh" "cy" OFF \
            "Walloon" "wa" OFF \
            "Wolof" "wo" OFF \
            "Xhosa" "xh" OFF \
            "Yiddish" "yi" OFF \
            "Yoruba" "yo" OFF \
            "Zhuang" "za" OFF \
            "Chinese" "zh" OFF \
            "Zulu" "zu" OFF 3>&1 1>&2 2>&3
        )
        sed -i "s/FileBotLang=.*/FileBotLang=$new_lang/g" "$JDAutoConfig"
        ;;
      "8)")
        break
        ;;
      esac
    done
    ;;
  "7)")
    exit
    ;;
  esac
done
