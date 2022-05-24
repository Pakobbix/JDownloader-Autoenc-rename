#!/bin/bash

# Sucht JDAutoConfig und fragt, ob dies der richtige Pfad ist.

JDAutoConfig=$(find ~ -type f -iname "JDAutoConfig" 2>/dev/null)

# Setzt die Sprach entweder über das JDAutoConfig, oder falls nicht gesetzt, über die Systemsprache
# Checking if language is set at JDAutoConfig, if not, use systemlocale.

language_Folder=$(grep "language_folder=" "$JDAutoConfig" | sed 's/.*=//g')
if [[ -n $(grep "language=" "$JDAutoConfig" | sed 's/.*=//g') ]]; then
  language=$(grep "language=" "$JDAutoConfig" | sed 's/.*=//g')
else
  language=$(locale | head -n 1 | sed 's/.*=\|\..*//g')
fi

# Falls die Sprache
if [[ ! -d $language_Folder/$language ]]; then
  language=en_US
  language_Folder=$(find ~ -type f -iname "JDAutoConfig" 2>/dev/null | sed 's/JDAutoConfig/lang/g')
fi

#language=$(locale | head -n 1 | sed 's/.*=\|\..*//g')

# Funktion für später, um z.B. zenity statt whiptail zu nutzen.

text_lang() {
  grep "$1" "$language_Folder"/"$language"/config.lang | sed 's/^....//'
}

check_skript_location() {
  if ! $1 --title "$(text_lang "001")" --"$2" "$JDAutoConfig" 16 100; then
    unset JDAutoConfig
    JDAutoConfig=$($1 --title "$(text_lang "002")" --"$3" "$(text_lang "003")" 16 100 "$4" 3>&2 2>&1 1>&3)
  fi
}

change_path() {
  if [[ -z $2 ]]; then
    whiptail --title "$(text_lang "004")" --msgbox "$(text_lang "005")" 16 50
    return
  else
    if sed -i "s/$1/$2/g" "$JDAutoConfig"; then
      whiptail --title "$(text_lang "006") $4 $(text_lang "092")" --msgbox "$(text_lang "007"):\n$2" 16 100
    else
      whiptail --title "$(text_lang "008")" --msgbox "$(text_lang "009")\n$2 $(text_lang "093")" 16 100
    fi
  fi
}

db_auswhal() {
  choose_db=$(
    whiptail --title "$(text_lang "010")" --menu "" 20 100 12 \
      "1)" "TheMovieDB" \
      "2)" "TheTVDB" \
      "3)" "AniDB" \
      "4)" "$(text_lang "011")" 3>&2 2>&1 1>&3
  )
  case $choose_db in
  "1)")
    newdb="TheMovieDB"
    ;;
  "2)")
    newdb="TheTVDB"
    ;;
  "3)")
    newdb="AniDB"
    ;;
  "4)")
    return
    ;;
  esac
}

bitrate_auswahl() {
  whiptail --title "$1 $(text_lang "012")" --radiolist "$(text_lang "013") $1\n$(text_lang "017")" 20 100 12 \
    "1000" "1000K $(text_lang "014")" OFF \
    "1100" "1100K $(text_lang "014")" OFF \
    "1200" "1200K $(text_lang "014")" OFF \
    "1300" "1300K $(text_lang "014")" OFF \
    "1400" "1400K $(text_lang "014")" $2 \
    "1500" "1500K $(text_lang "014")" OFF \
    "1600" "1600K $(text_lang "014")" OFF \
    "1700" "1700K $(text_lang "014")" $3 \
    "1800" "1800K $(text_lang "014")" OFF \
    "1900" "1900K $(text_lang "014")" OFF \
    "2000" "2000K $(text_lang "014")" $4 \
    "2100" "2100K $(text_lang "014")" OFF \
    "2200" "2200K $(text_lang "014")" OFF \
    "2300" "2300K $(text_lang "014")" OFF \
    "2400" "2400K $(text_lang "014")" OFF \
    "2500" "2500K $(text_lang "014")" OFF \
    "2600" "2600K $(text_lang "014")" OFF \
    "2700" "2700K $(text_lang "014")" OFF \
    "2800" "2800K $(text_lang "014")" OFF \
    "2900" "2900K $(text_lang "014")" OFF \
    "3000" "3000K $(text_lang "014")" OFF 3>&1 1>&2 2>&3
}

preset_auswahl() {
  whiptail --title "$1 $(text_lang "015")" --radiolist "$(text_lang "016") $1 an:\n$(text_lang "017")" 22 120 12 \
    "Ultrafast" "$(text_lang "018")" OFF \
    "superfast" "$(text_lang "019")" OFF \
    "veryfast" "$(text_lang "019")" OFF \
    "faster" "$(text_lang "020")" OFF \
    "fast" "$(text_lang "021")  " ON \
    "medium" "$(text_lang "022") $2" OFF \
    "slow" "$(text_lang "023")  " OFF \
    "slower" "$(text_lang "024")." OFF \
    "veryslow" "$(text_lang "025").$3" OFF \
    "hq" "$(text_lang "026")?" OFF \
    "lossless" "$(text_lang "027")?" OFF 3>&1 1>&2 2>&3

}

# Fragt, ob der gefundene Pfad zur startencode.sh der richtige ist.
check_skript_location whiptail yesno inputbox
# Loop das Hauptmenü
while true; do
  # Aufbau des Menüs
  Wahl=$(
    whiptail --title "$(text_lang "028")?" --menu "$(text_lang "029")" 20 100 9 \
      "1)" "$(text_lang "030")" \
      "2)" "$(text_lang "031")" \
      "3)" "Discord WebHook" \
      "4)" "$(text_lang "032")" \
      "5)" "$(text_lang "033")" \
      "6)" "$(text_lang "034")" \
      "7)" "$(text_lang "096")" \
      "8)" "$(text_lang "011")" 3>&2 2>&1 1>&3
  )
  # Zuordnung Funktionen zu Menüpunkten
  case $Wahl in
  "1)")
    # Abfrage, ob alle Skripte (startencode.sh, jdautoenc.sh und rename.sh) am selben Ort sind, um den generellen Pfad auf diesen umzustellen
    if whiptail --title "$(text_lang "035")?" --yesno "In ${JDAutoConfig//JDAutoConfig/} $(text_lang "036")" 20 100; then
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
    MoviePath=$(grep "Movies=" "$JDAutoConfig" | sed 's/Movies=\|["]//g' | sed -e "s#/#\\\/#g")
    TVShowPath=$(grep "TVShows=" "$JDAutoConfig" | sed 's/TVShows=\|["]//g' | sed -e "s#/#\\\/#g")
    AnimePfad=$(grep "Animes=" "$JDAutoConfig" | sed 's/Animes=\|["]//g' | sed -e "s#/#\\\/#g")
    language_path=$(grep "language_folder=" "$JDAutoConfig" | sed 's/language_folder=\|["]//g' | sed -e "s#/#\\\/#g")
    # Neues Menü Loop für das ändern von Pfaden
    while true; do
      # Aufbau des Menüs
      Wahl=$(
        whiptail --title "$(text_lang "037")?" --menu "$(text_lang "038")" 22 100 13 \
          "1)" "jdautoenc.sh $jdautoencpfad" \
          "2)" "rename.sh $renamepfad" \
          "3)" "renamelist $renamelist" \
          "" "" \
          "4)" "$(text_lang "039") $entpacktpfad" \
          "5)" "$(text_lang "040") $encodespfad" \
          "6)" "$(text_lang "041") $logpfad" \
          "" "" \
          "7)" "$(text_lang "042"): $MoviePath" \
          "8)" "$(text_lang "043"): $TVShowPath" \
          "9)" "$(text_lang "044"): $AnimePfad" \
          "" "" \
          "10)" "$(text_lang "097"): $language_path" \
          "11)" "$(text_lang "011")" 3>&2 2>&1 1>&3
      )
      # Ordnerpfade Verändern
      case $Wahl in
      "1)")
        # jdautoenc.sh Pfad
        newjdautopfad=$(whiptail --title "$(text_lang "045")" --inputbox "$(text_lang "046") jdautoenc.sh:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$jdautoencpfad" "$newjdautopfad" "$JDAutoConfig" "jdautoenc.sh"
        ;;
      "2)")
        # rename.sh Pfad
        newrenamepfad=$(whiptail --title "$(text_lang "045")" --inputbox "$(text_lang "046") rename.sh:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$renamepfad" "$newrenamepfad" "$JDAutoConfig" "rename.sh"
        ;;
      "3)")
        # renamelist Pfad
        newrenamelist=$(whiptail --title "$(text_lang "045")" --inputbox "$(text_lang "046") renamelist:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$renamelist" "$newrenamelist" "$JDAutoConfig" "renamelist"
        ;;
      "4)")
        # Ordnerpfad für den Ordner in dem entpackte Videos liegen.
        newentpackpfad=$(whiptail --title "$(text_lang "045")" --inputbox "$(text_lang "047"):" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$entpacktpfad" "$newentpackpfad" "$JDAutoConfig" "$(text_lang "039")"
        ;;
      "5)")
        # Orderpfad in dem die encodierten Videos hinterlegt werden.
        newencodesfolder=$(whiptail --title "$(text_lang "045")" --inputbox "$(text_lang "048")" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$encodespfad" "$newencodesfolder" "$JDAutoConfig" "$(text_lang "040")"
        ;;
      "6)")
        # Log Pfad. Hier wird das Log hingeschrieben
        newlogpfad=$(whiptail --title "$(text_lang "045")" --inputbox "$(text_lang "046") log." 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$logpfad" "$newlogpfad" "$JDAutoConfig" "$(text_lang "041")"
        ;;
      "7)")
        newMoviePath=$(whiptail --title "$(text_lang "045")" --inputbox "$(text_lang "046") $(text_lang "089")." 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$MoviePath" "$newMoviePath" "$JDAutoConfig" "$(text_lang "089")"
        ;;
      "8)")
        newTVShowPath=$(whiptail --title "$(text_lang "045")" --inputbox "$(text_lang "046") $(text_lang "090")." 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$TVShowPath" "$newTVShowPath" "$JDAutoConfig" "$(text_lang "090")"
        ;;
      "9)")
        newAnimePfad=$(whiptail --title "$(text_lang "045")" --inputbox "$(text_lang "046") $(text_lang "091")." 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$AnimePfad" "$newAnimePfad" "$JDAutoConfig" "$(text_lang "091")"
        ;;
      "10)")
        newlanguagePath=$(whiptail --title "$(text_lang "045")" --inputbox "$(text_lang "046") $(text_lang "091")." 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$language_path" "$newlanguagePath" "$JDAutoConfig" "$(text_lang "091")"
        ;;
        # Ende vom Menü
      "11)")
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
    # Hier werden die Log Farben angepasst. Muss mir noch überlegen, wie ich die definieren kann.
    curr_dishook=$(grep "discord=" "$JDAutoConfig" | sed 's/.*=//g')
    dishook=$(whiptail --title "$(text_lang "049")" --inputbox "$(text_lang "050"): \n$curr_dishook" 16 100 "$4" 3>&2 2>&1 1>&3 | sed -e "s#/#\\\/#g")
    if [ -z "$dishook" ]; then
      echo ""
    else
      sed -i "s/discord=.*/discord=$dishook/g" "$JDAutoConfig"
    fi
    ;;
  "4)")
    # Einstellungen für das encoden. (noch in der jdautoenc.sh definiert. Wandern vielleicht bald in das startencode.sh skript)
    while true; do
      curr_encode_allow=$(if [[ $(grep "Encode=" "$JDAutoConfig" | sed 's/.*Encode=//g') == "yes" ]]; then text_lang "051"; else text_lang "052"; fi)
      curr_anime_bitrate=$(grep "bitrate_anime=" "$JDAutoConfig" | sed 's/.*bitrate_anime=//g')
      curr_anime_preset=$(grep "preset_anime=" "$JDAutoConfig" | sed 's/.*preset_anime=//g')
      curr_tvshow_bitrate=$(grep "bitrate_tvshows=" "$JDAutoConfig" | sed 's/.*bitrate_tvshows=//g')
      curr_tvshow_preset=$(grep "preset_tvshows=" "$JDAutoConfig" | sed 's/.*preset_tvshows=//g')
      curr_movie_bitrate=$(grep "bitrate_movies=" "$JDAutoConfig" | sed 's/.*bitrate_movies=//g')
      curr_movie_preset=$(grep "preset_movies=" "$JDAutoConfig" | sed 's/.*preset_movies=//g')
      bitratewahl=$(
        whiptail --title "$(text_lang "053")" --menu "$(text_lang "054")" 20 100 13 \
          "1)" "$(text_lang "055"): $curr_encode_allow" \
          "2)" "$(text_lang "056"): $curr_anime_bitrate K" \
          "3)" "$(text_lang "057"): $curr_anime_preset" \
          "" "" \
          "4)" "$(text_lang "058"): $curr_tvshow_bitrate K" \
          "5)" "$(text_lang "059"): $curr_tvshow_preset" \
          "" "" \
          "6)" "$(text_lang "060"): $curr_movie_bitrate K" \
          "7)" "$(text_lang "061"): $curr_movie_preset" \
          "" "" \
          "8)" "$(text_lang "011")" 3>&2 2>&1 1>&3
      )
      case $bitratewahl in
      "1)")
        # Ändere die bitrate für Animes
        if whiptail --title "$(text_lang "062")" --yesno "$(text_lang "063")" 20 100; then
          sed -i "s/Encode=.*/Encode=yes/g" "$JDAutoConfig"
        else
          sed -i "s/Encode=.*/Encode=no/g" "$JDAutoConfig"
        fi
        ;;
      "2)")
        # Ändere die bitrate für Animes
        new_anime_bitrate=$(bitrate_auswahl "$(text_lang "091")" ON OFF OFF)
        sed -i "s/^bitrate_anime.*/bitrate_anime=$new_anime_bitrate/g" "$JDAutoConfig"
        ;;
      "3)")
        # Ändere das zu nutzende Preset für Animes
        new_anime_preset=$(preset_auswahl "$(text_lang "091")")
        sed -i "s/^preset_anime=.*/preset_anime=$new_anime_preset/g" "$JDAutoConfig"
        ;;
      "4)")
        # Ändere die bitrate für Serien
        new_tvshow_bitrate=$(bitrate_auswahl "$(text_lang "090")" OFF ON OFF)
        sed -i "s/^bitrate_tvshows.*/bitrate_tvshows=$new_tvshow_bitrate/g" "$JDAutoConfig"
        ;;
      "5)")
        # Ändere das zu nutzende Preset für Serien
        new_tvshow_preset=$(preset_auswahl "$(text_lang "090")")
        sed -i "s/^preset_tvshows=.*/preset_tvshows=$new_tvshow_preset/g" "$JDAutoConfig"
        ;;
      "6)")
        # Ändere die bitrate für Filme
        new_movie_bitrate=$(bitrate_auswahl "$(text_lang "089")" OFF OFF ON)
        sed -i "s/^bitrate_movies.*/bitrate_movies=$new_movie_bitrate/g" "$JDAutoConfig"
        ;;
      "7)")
        # Ändere das zu nutzende Preset für Filme
        new_movie_preset=$(preset_auswahl "$(text_lang "089")")
        sed -i "s/^preset_movies=.*/preset_movies=$new_movie_preset/g" "$JDAutoConfig"
        ;;
      "8)")
        break
        ;;
      esac
    done
    ;;
  "5)")
    jdautoencpfad=$(grep "jdautoenc=" "$JDAutoConfig" | sed 's/jdautoenc=\|["]//g')
    # Wir schauen, ob wir kompatible Hardware anzeigen lassen können
    gethw=$(lshw -class display 2>/dev/null | grep vendor)
    for hw in $gethw; do
      if [[ ${hw,,} == *"nvidia"* ]]; then
        hw1="\nnVidia $(text_lang "064")"
      elif [[ ${hw,,} == *"intel"* ]]; then
        hw2="\nIntel iGPU"
      elif [[ ${hw,,} == *"radeon"* ]]; then
        hw3="\nAMD $(text_lang "064")"
      elif [[ ${hw,,} == *"microsoft"* ]]; then
        hw4="\nMicrosoft WSL $(text_lang "065")!"
      fi
    done
    Hardwareauswahl=$(
      whiptail --title "$(text_lang "067")?" --menu "$(text_lang "068"):$hw1 $hw2 $hw3 $hw4" 20 100 9 \
        "1)" "nVidia" \
        "2)" "AMD" \
        "3)" "Intel QuickSync (Intel CPU)" \
        "4)" "Software ($(text_lang "066")!)" \
        "5)" "$(text_lang "011")" 3>&2 2>&1 1>&3
    )
    case $Hardwareauswahl in
    "1)")
      # Ändere Einstellung zu nVidia Encoding
      sed -i 's/Encoder=.*/Encoder=nvidia/g' "$JDAutoConfig"
      whiptail --msgbox "$(text_lang "069")" 20 78
      ;;
    "2)")
      # Ändere Einstellung zu AMD Enconding
      sed -i 's/Encoder=.*/Encoder=amd/g' "$JDAutoConfig"
      whiptail --msgbox "$(text_lang "070")" 20 78
      ;;
    "3)")
      # Ändere Einstellung zu Intel Quick Sync Encoding
      sed -i 's/Encoder=.*/Encoder=intel/g' "$JDAutoConfig"
      whiptail --msgbox "$(text_lang "071")" 20 78
      ;;
    "4)")
      # Ändere Einstellung zu Software Encoding
      whiptail --msgbox "$(text_lang "046")!" 20 78
      return
      ;;
    "5)")
      return 2>/dev/null
      ;;
    esac
    ;;
  "6)")
    while true; do
      curr_film_db=$(grep "MovieDB=" "$JDAutoConfig" | sed 's/.*MovieDB=//g')
      curr_Serien_db=$(grep "TVShowDB=" "$JDAutoConfig" | sed 's/.*TVShowDB=//g')
      curr_Anime_db=$(grep "AnimeDB=" "$JDAutoConfig" | sed 's/.*AnimeDB=//g')
      curr_film_name=$(grep "MovieName=" "$JDAutoConfig" | sed 's/.*MovieName=//g')
      curr_serien_name=$(grep "TVShowName=" "$JDAutoConfig" | sed 's/.*TVShowName=//g')
      curr_anime_name=$(grep "AnimeName=" "$JDAutoConfig" | sed 's/.*AnimeName=//g')
      curr_Language=$(grep "FileBotLang=" "$JDAutoConfig" | sed 's/.*FileBotLang=//g')
      FileBotMenu=$(
        whiptail --title "$(text_lang "073")?" --menu "$(text_lang "028")?" 20 100 12 \
          "1)" "$(text_lang "075"): $curr_film_db" \
          "2)" "$(text_lang "076"): $curr_Serien_db" \
          "3)" "$(text_lang "077"): $curr_Anime_db" \
          "" "" \
          "4)" "$(text_lang "078"): $curr_film_name" \
          "5)" "$(text_lang "079"): $curr_serien_name" \
          "6)" "$(text_lang "080"): $curr_anime_name" \
          "" "" \
          "7)" "$(text_lang "081"): $curr_Language" \
          "8)" "$(text_lang "011")" 3>&2 2>&1 1>&3
      )
      case $FileBotMenu in
      "1)")
        db_auswhal
        sed -i "s/MovieDB.*/MovieDB=$newdb/g" "$JDAutoConfig"
        ;;
      "2)")
        db_auswhal
        sed -i "s/TVShowDB.*/TVShowDB=$newdb/g" "$JDAutoConfig"
        ;;
      "3)")
        db_auswhal
        sed -i "s/AnimeDB.*/AnimeDB=$newdb/g" "$JDAutoConfig"
        ;;
      "4)")
        new_film_name=$(whiptail --title "$(text_lang "082")" --inputbox "$(text_lang "083"): https://www.filebot.net/naming.html" 16 100 3>&1 1>&2 2>&3)
        if [[ -n $new_film_name ]]; then
          sed -i "s/FilmName=.*/FilmName=$new_film_name/g" "$JDAutoConfig"
        else
          whiptail --msgbox "$(text_lang "0086")!" 20 78
        fi
        ;;
      "5)")
        new_serien_name=$(whiptail --title "$(text_lang "082")" --inputbox "$(text_lang "084"): https://www.filebot.net/naming.html" 16 100 3>&1 1>&2 2>&3)
        if [[ -n $new_serien_name ]]; then
          sed -i "s/SerienName=.*/SerienName=$new_serien_name/g" "$JDAutoConfig"
        else
          whiptail --msgbox "$(text_lang "0086")!" 20 78
        fi
        ;;

      "6)")
        new_anime_name=$(whiptail --title "$(text_lang "082")" --inputbox "$(text_lang "085"): https://www.filebot.net/naming.html" 16 100 3>&1 1>&2 2>&3)
        if [[ -n $new_anime_name ]]; then
          sed -i "s/AnimeName=.*/AnimeName=$new_anime_name/g" "$JDAutoConfig"
        else
          whiptail --msgbox "$(text_lang "086")!" 20 78
        fi
        ;;
      "7)")
        new_lang=$(
          whiptail --title "$(text_lang "087")" --radiolist "$(text_lang "088")" 20 100 12 \
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
    possible_lang=$(ls "$language_Folder" | tr '\n' ' ')

    radiolist_lang=(
      --title "$(text_lang "094")"
      --radiolist "$(text_lang "095")"
      20 100 1${#possible_lang[@]}
    )

    for lang in ${possible_lang[@]}; do
      radiolist_lang+=("$lang" " ")
      if [[ $lang == "$language" ]]; then
        radiolist_lang+=("on")
      else
        radiolist_lang+=("off")
      fi
    done

    choose_lang=$(whiptail "${radiolist_lang[@]}" 3>&1 1>&2 2>&3)
    sed -i "s/language=.*/language=$choose_lang/g" "$JDAutoConfig"
    ;;
  "8)")
    exit
    ;;
  esac
done
