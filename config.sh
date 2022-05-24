#!/bin/bash

# Sucht JDAutoConfig und fragt, ob dies der richtige Pfad ist.

JDAutoConfig=$(find ~ -type f -iname "JDAutoConfig" 2>/dev/null)

# Funktion für später, um z.B. zenity statt whiptail zu nutzen.

check_skript_location() {
  if ! $1 --title "Ist der Pfad der JDAutoConfig richtig?" --"$2" "$JDAutoConfig" 16 100; then
    unset JDAutoConfig
    JDAutoConfig=$($1 --title "Wie lautet der Richtige Pfad?" --"$3" "Gebe hier den Vollständigen Pfad zum JDAutoConfig an" 16 100 "$4" 3>&2 2>&1 1>&3)
  fi
}

change_path() {
  if [[ -z $2 ]]; then
    whiptail --title "Pfad wurde nicht geändert" --msgbox "Der Pfad wurde nicht geändert" 16 50
    return
  else
    if sed -i "s/$1/$2/g" "$JDAutoConfig"; then
      whiptail --title "Der Pfad vom $4 wurde geändert" --msgbox "Der neue Pfad lautet:\n$2" 16 100
    else
      whiptail --title "Fehler beim ändern des Pfads" --msgbox "Der neue Pfad: $2\nKonnte nicht geändert werden" 16 100
    fi
  fi
}

db_auswhal() {
  choose_db=$(
    whiptail --title "Wähle die zu nutzende Datenbank aus" --menu "" 20 100 12 \
      "1)" "TheMovieDB" \
      "2)" "TheTVDB" \
      "3)" "AniDB" \
      "4)" "Beenden" 3>&2 2>&1 1>&3
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
  whiptail --title "$1 Bitrate Einstellungen" --radiolist "Gebe hier die Kbits (ohne endung) für $1 an:\nLeertaste zum auswählen, Enter zum bestätigen" 20 100 12 \
    "1000" "Wähle 1000K aus                                                " OFF \
    "1100" "Wähle 1100K aus" OFF \
    "1200" "Wähle 1200K aus" OFF \
    "1300" "Wähle 1300K aus" OFF \
    "1400" "Wähle 1400K aus" $2 \
    "1500" "Wähle 1500K aus" OFF \
    "1600" "Wähle 1600K aus" OFF \
    "1700" "Wähle 1700K aus" $3 \
    "1800" "Wähle 1800K aus" OFF \
    "1900" "Wähle 1900K aus" OFF \
    "2000" "Wähle 2000K aus" $4 \
    "2100" "Wähle 2100K aus" OFF \
    "2200" "Wähle 2200K aus" OFF \
    "2300" "Wähle 2300K aus" OFF \
    "2400" "Wähle 2400K aus" OFF \
    "2500" "Wähle 2500K aus" OFF \
    "2600" "Wähle 2600K aus" OFF \
    "2700" "Wähle 2700K aus" OFF \
    "2800" "Wähle 2800K aus" OFF \
    "2900" "Wähle 2900K aus" OFF \
    "3000" "Wähle 3000K aus" OFF 3>&1 1>&2 2>&3
}

preset_auswahl() {
  whiptail --title "$1 Preset Einstellungen" --radiolist "Gebe hier das zu nutzende FFmpeg Preset für $1 an:\nLeertaste zum auswählen, Enter zum bestätigen" 20 120 12 \
    "Ultrafast" "Am Schnellsten, geringste Qualität                                                " OFF \
    "superfast" "Schnell Geringe Qualität" OFF \
    "veryfast" "Schnell Geringe Qualität" OFF \
    "faster" "Schnell annehmbare Qualität" OFF \
    "fast" "Empfohlen. Relativ schnell, Qualität laut VMAF Tool im schnitt 96-99% vom Quellmedium  " ON \
    "medium" "Balanced$2" OFF \
    "slow" "Etwas langsam. Nur noch kleinere Dateigrößen, keine relevanten Qualitätseinbußen mehr  " OFF \
    "slower" "Noch langsamer." OFF \
    "veryslow" "Wirklich Langsam.$3" OFF \
    "hq" "Vielleicht doch lieber auf ein Remux warten?" OFF \
    "lossless" "Naja, am besten encodieren ausschalten, huh?" OFF 3>&1 1>&2 2>&3

}

# Fragt, ob der gefundene Pfad zur startencode.sh der richtige ist.
check_skript_location whiptail yesno inputbox
# Loop das Hauptmenü
while true; do
  # Aufbau des Menüs
  Wahl=$(
    whiptail --title "Was möchtest du Konfigurieren?" --menu "WIP. Die Möglichkeiten zum Feinjustieren, werden noch erweitert.\nBei Problemen öffnet ein issue unter: shorturl.at/bvDQ6 (Github link, einfacher abzutippen)" 20 100 9 \
      "1)" "Ordnerpfade" \
      "2)" "Log Farben" \
      "3)" "Discord WebHook" \
      "4)" "Encoding Einstellungen" \
      "5)" "Encoding Hardware" \
      "6)" "FileBot Settings" \
      "7)" "Beenden" 3>&2 2>&1 1>&3
  )
  # Zuordnung Funktionen zu Menüpunkten
  case $Wahl in
  "1)")
    # Abfrage, ob alle Skripte (startencode.sh, jdautoenc.sh und rename.sh) am selben Ort sind, um den generellen Pfad auf diesen umzustellen
    if whiptail --title "Befinden sich alle Skripte an der selben stelle?" --yesno "Die JDAutoConfig wurde in ${JDAutoConfig//JDAutoConfig/} gefunden. Ist dies der Pfad aller Skripte?\n\nACHTUNG! Nur die Skripte werden dadurch angepasst. der Entpackt und der Out Ordner sowie der Pfad für das Log müssen manuell gesetzt werden!" 20 100; then
      newpath=$(echo "${JDAutoConfig//\/JDAutoConfig/}" | sed -e "s#/#\\\/#g")
      echo "$newpath"
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
    entpacktpfad=$(grep "entpackt=" "$JDAutoConfig" | sed 's/entpackt=\|["]//g' | sed -e "s#/#\\\/#g")
    encodespfad=$(grep "encodes=" "$JDAutoConfig" | sed 's/encodes=\|["]//g' | sed -e "s#/#\\\/#g")
    logpfad=$(grep "log=" "$JDAutoConfig" | sed 's/log=\|["]//g' | sed -e "s#/#\\\/#g")
    FilmPfad=$(grep "Filme=" "$JDAutoConfig" | sed 's/Filme=\|["]//g' | sed -e "s#/#\\\/#g")
    SerienPfad=$(grep "Serien=" "$JDAutoConfig" | sed 's/Serien=\|["]//g' | sed -e "s#/#\\\/#g")
    AnimePfad=$(grep "Animes=" "$JDAutoConfig" | sed 's/Animes=\|["]//g' | sed -e "s#/#\\\/#g")
    # Neues Menü Loop für das ändern von Pfaden
    while true; do
      # Aufbau des Menüs
      Wahl=$(
        whiptail --title "Welchen Ordnerpfad möchtest du Anpassen?" --menu "Bitte Auswahl treffen" 22 100 13 \
          "1)" "jdautoenc.sh $jdautoencpfad" \
          "2)" "rename.sh $renamepfad" \
          "3)" "renamelist $renamelist" \
          "" "" \
          "4)" "Entpackt Ordner $entpacktpfad" \
          "5)" "Encodes Ordner $encodespfad" \
          "6)" "Log Pfad $logpfad" \
          "" "" \
          "7)" "Filme: $FilmPfad" \
          "8)" "Serien: $SerienPfad" \
          "9)" "Animes: $AnimePfad" \
          "" "" \
          "10)" "Beenden" 3>&2 2>&1 1>&3
      )
      # Ordnerpfade Verändern
      case $Wahl in
      "1)")
        # jdautoenc.sh Pfad
        newjdautopfad=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für jdautoenc.sh:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$jdautoencpfad" "$newjdautopfad" "$JDAutoConfig" "jdautoenc.sh"
        ;;
      "2)")
        # rename.sh Pfad
        newrenamepfad=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für rename.sh:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$renamepfad" "$newrenamepfad" "$JDAutoConfig" "rename.sh"
        ;;
      "3)")
        # renamelist Pfad
        newrenamelist=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad fürdie renamelist:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$renamelist" "$newrenamelist" "$JDAutoConfig" "renamelist"
        ;;
      "4)")
        # Ordnerpfad für den Ordner in dem entpackte Videos liegen.
        newentpackpfad=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Ordnerpfad für den Ordner in dem vom JD2 entpackte Videos liegen:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$entpacktpfad" "$newentpackpfad" "$JDAutoConfig" "Entpackt Ordner"
        ;;
      "5)")
        # Orderpfad in dem die encodierten Videos hinterlegt werden.
        newencodesfolder=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für das Verzeichnis, in dem die Fertig encodierten Videos sind/sollen" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$encodespfad" "$newencodesfolder" "$JDAutoConfig" "Out Ordner"
        ;;
      "6)")
        # Log Pfad. Hier wird das Log hingeschrieben
        newlogpfad=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für log." 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$logpfad" "$newlogpfad" "$JDAutoConfig" "Log Pfad"
        ;;
      "7)")
        # Log Pfad. Hier wird das Log hingeschrieben
        newFilmpfad=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für Filme." 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$FilmPfad" "$newFilmpfad" "$JDAutoConfig" "Log Pfad"
        ;;
      "8)")
        # Log Pfad. Hier wird das Log hingeschrieben
        newSerienpfad=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für Serien." 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$SerienPfad" "$newSerienpfad" "$JDAutoConfig" "Log Pfad"
        ;;
      "9)")
        # Log Pfad. Hier wird das Log hingeschrieben
        newAnimePfad=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für Animes." 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
        change_path "$AnimePfad" "$newAnimePfad" "$JDAutoConfig" "Log Pfad"
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
    # Hier werden die Log Farben angepasst. Muss mir noch überlegen, wie ich die definieren kann.
    curr_dishook=$(grep "discord=" "$JDAutoConfig" | sed 's/.*=//g')
    dishook=$(whiptail --title "Konfiguration der Discord WebHook" --inputbox "Gebe hier die Vollständige Adresse der Discord Webhook an. Momentan: $curr_dishook" 16 100 "$4" 3>&2 2>&1 1>&3 | sed -e "s#/#\\\/#g")
    if [ -z "$dishook" ]; then
      echo ""
    else
      sed -i "s/discord=.*/discord=$dishook/g" "$JDAutoConfig"
    fi
    ;;
  "4)")
    # Einstellungen für das encoden. (noch in der jdautoenc.sh definiert. Wandern vielleicht bald in das startencode.sh skript)
    while true; do
      curr_encode_allow=$(if [[ $(grep "Encodieren=" "$JDAutoConfig" | sed 's/.*Encodieren=//g') == "yes" ]]; then echo "Eingeschaltet"; else echo "Ausgeschaltet"; fi)
      curr_anime_bitrate=$(grep "bitrate_anime=" "$JDAutoConfig" | sed 's/.*bitrate_anime=//g')
      curr_anime_preset=$(grep "preset_anime=" "$JDAutoConfig" | sed 's/.*preset_anime=//g')
      curr_serien_bitrate=$(grep "bitrate_serie=" "$JDAutoConfig" | sed 's/.*bitrate_serie=//g')
      curr_serien_preset=$(grep "preset_serie=" "$JDAutoConfig" | sed 's/.*preset_serie=//g')
      curr_filme_bitrate=$(grep "bitrate_filme=" "$JDAutoConfig" | sed 's/.*bitrate_filme=//g')
      curr_filme_preset=$(grep "preset_filme=" "$JDAutoConfig" | sed 's/.*preset_filme=//g')
      bitratewahl=$(
        whiptail --title "Hier kannst du die FFmpeg Settings ändern" --menu "Wähle hier die zu ändernden Einstellungen" 20 100 13 \
          "1)" "Encodieren: $curr_encode_allow" \
          "2)" "Bitrate Anime Aktuell: $curr_anime_bitrate K" \
          "3)" "FFmpeg Preset Animes Aktuell: $curr_anime_preset" \
          "" "" \
          "4)" "Bitrate Serien Aktuell: $curr_serien_bitrate K" \
          "5)" "FFmpeg Preset Serien Aktuell: $curr_serien_preset" \
          "" "" \
          "6)" "Bitrate Filme Aktuell: $curr_filme_bitrate K" \
          "7)" "FFmpeg Preset Filme Aktuell: $curr_filme_preset" \
          "" "" \
          "8)" "Beenden" 3>&2 2>&1 1>&3
      )
      case $bitratewahl in
      "1)")
        # Ändere die bitrate für Animes
        if whiptail --title "Encodieren ein/ausschalten" --yesno "Wähle ob du Encodieren möchtest" 20 100; then
          sed -i "s/Encodieren=.*/Encodieren=yes/g" "$JDAutoConfig"
        else
          sed -i "s/Encodieren=.*/Encodieren=no/g" "$JDAutoConfig"
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
        sed -i "s/^bitrate_serie.*/bitrate_serie=$new_serien_bitrate/g" "$JDAutoConfig"
        ;;
      "5)")
        # Ändere das zu nutzende Preset für Serien
        new_serien_preset=$(preset_auswahl "Serien")
        sed -i "s/^preset_serie=.*/preset_serie=$new_serien_preset/g" "$JDAutoConfig"
        ;;
      "6)")
        # Ändere die bitrate für Filme
        new_filme_bitrate=$(bitrate_auswahl "Filme" OFF OFF ON)
        sed -i "s/^bitrate_filme.*/bitrate_filme=$new_filme_bitrate/g" "$JDAutoConfig"
        ;;
      "7)")
        # Ändere das zu nutzende Preset für Filme
        new_filme_preset=$(preset_auswahl "Filme")
        sed -i "s/^preset_filme=.*/preset_filme=$new_filme_preset/g" "$JDAutoConfig"
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
        hw1="\nnVidia Grafikkarte"
      elif [[ ${hw,,} == *"intel"* ]]; then
        hw2="\nIntel iGPU"
      elif [[ ${hw,,} == *"radeon"* ]]; then
        hw3="\nAMD Grafikkarte"
      elif [[ ${hw,,} == *"microsoft"* ]]; then
        hw4="\nMicrosoft WSL Entdeckt!"
      fi
    done
    Hardwareauswahl=$(
      whiptail --title "Welchen Hardware möchtest du verwenden?" --menu "Bitte wähle die zu nutzende Hardware. Folgende Hardware scheint installiert zu sein:$hw1 $hw2 $hw3 $hw4" 20 100 9 \
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
      whiptail --msgbox "Die Encoding Einstellungen wurden zu nVidia geändert.\nEs werden die Cuda Prozessoren mit dem NVENC encoder genutzt" 20 78
      ;;
    "2)")
      # Ändere Einstellung zu AMD Enconding
      sed -i 's/Encoder=.*/Encoder=amd/g' "$JDAutoConfig"
      whiptail --msgbox "Die Encoding Einstellungen wurden zu AMD geändert.\nEs werden mit der AMD-Transistoren mit dem amf encoder genutzt" 20 78
      ;;
    "3)")
      # Ändere Einstellung zu Intel Quick Sync Encoding
      sed -i 's/Encoder=.*/Encoder=intel/g' "$JDAutoConfig"
      whiptail --msgbox "Die Encoding Einstellungen wurden zu nVidia geändert.\nEs wird der Intel QuickSync Chip mit qsv encoder genutzt" 20 78
      ;;
    "4)")
      whiptail --msgbox "Das Encoding per Software wird zurzeit nicht unterstützt!" 20 78
      return
      ;;
    "5)")
      return
      ;;
    esac
    ;;
  "6)")
    while true; do
      curr_film_db=$(grep "FilmeDB=" "$JDAutoConfig" | sed 's/.*FilmeDB=//g')
      curr_Serien_db=$(grep "SerienDB=" "$JDAutoConfig" | sed 's/.*SerienDB=//g')
      curr_Anime_db=$(grep "AnimeDB=" "$JDAutoConfig" | sed 's/.*AnimeDB=//g')
      curr_film_name=$(grep "FilmName=" "$JDAutoConfig" | sed 's/.*FilmName=//g')
      curr_serien_name=$(grep "SerienName=" "$JDAutoConfig" | sed 's/.*SerienName=//g')
      curr_anime_name=$(grep "AnimeNames=" "$JDAutoConfig" | sed 's/.*AnimeNames=//g')
      curr_Language=$(grep "FileBotLang=" "$JDAutoConfig" | sed 's/.*FileBotLang=//g')
      FileBotMenu=$(
        whiptail --title "Ändere FileBot Spezifische Einstellungen?" --menu "Was möchtest du verändern?" 20 100 12 \
          "1)" "Film Datenbank zurzeit: $curr_film_db" \
          "2)" "Serien Datenbank zurzeit: $curr_Serien_db" \
          "3)" "Anime Datenbank zurzeit: $curr_Anime_db" \
          "" "" \
          "4)" "Film Namensschema zurzeit: $curr_film_name" \
          "5)" "Serien Namensschema zurzeit: $curr_serien_name" \
          "6)" "Anime Namensschema zurzeit: $curr_anime_name" \
          "" "" \
          "7)" "Abzugleichende Sprache zurzeit: $curr_Language" \
          "8)" "Beenden" 3>&2 2>&1 1>&3
      )
      case $FileBotMenu in
      "1)")
        db_auswhal
        sed -i "s/FilmeDB.*/FilmeDB=$newdb/g" "$JDAutoConfig"
        ;;
      "2)")
        db_auswhal
        sed -i "s/SerienDB.*/SerienDB=$newdb/g" "$JDAutoConfig"
        ;;
      "3)")
        db_auswhal
        sed -i "s/AnimeDB.*/AnimeDB=$newdb/g" "$JDAutoConfig"
        ;;
      "4)")
        new_film_name=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für Filme. Für Beispiele und Möglichkeiten: https://www.filebot.net/naming.html" 16 100 3>&1 1>&2 2>&3)
        if [[ -n $new_film_name ]]; then
          sed -i "s/FilmName=.*/FilmName=$new_film_name/g" "$JDAutoConfig"
        else
          whiptail --msgbox "Das Namenschema wurde nicht verändert!" 20 78
        fi
        ;;
      "5)")
        new_serien_name=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für Serien. Für Beispiele und Möglichkeiten: https://www.filebot.net/naming.html" 16 100 3>&1 1>&2 2>&3)
        if [[ -n $new_serien_name ]]; then
          sed -i "s/SerienName=.*/SerienName=$new_serien_name/g" "$JDAutoConfig"
        else
          whiptail --msgbox "Das Namenschema wurde nicht verändert!" 20 78
        fi
        ;;

      "6)")
        new_anime_name=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für Animes. Für Beispiele und Möglichkeiten: https://www.filebot.net/naming.html" 16 100 3>&1 1>&2 2>&3)
        if [[ -n $new_anime_name ]]; then
          sed -i "s/AnimeNames=.*/AnimeNames=$new_anime_name/g" "$JDAutoConfig"
        else
          whiptail --msgbox "Das Namenschema wurde nicht verändert!" 20 78
        fi
        ;;
      "7)")
        new_lang=$(
          whiptail --title "Filebot zu nutzende Sprache aus" --radiolist "Wähle die von FileBot zu nutzende Sprache aus" 20 100 12 \
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
