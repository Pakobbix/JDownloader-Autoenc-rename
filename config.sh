#!/bin/bash

# Sucht das startencode.sh Skript und fragt, ob dies der richtige Pfad ist.

startencode=$(find ~ -type f -iname "startencode.sh" 2>/dev/null)

# Funktion für später, um z.B. zenity statt whiptail zu nutzen.

check_skript_location() {
  if ! $1 --title "Ist der Pfad vom startencode.sh richtig?" --"$2" "$startencode" 16 100; then
    unset startencode
    startencode=$($1 --title "Wie lautet der Richtige Pfad?" --"$3" "Gebe hier den Vollständigen Pfad zur startencode.sh an" 16 100 "$4" 3>&2 2>&1 1>&3)
  fi
}

change_path() {
  if [[ -z $2 ]]; then
    whiptail --title "Pfad wurde nicht geändert" --msgbox "Der Pfad wurde nicht geändert" 16 50
    return
  else
    if sed -i "s/$1/$2/g" "$startencode"; then
      whiptail --title "Der Pfad vom $4 wurde geändert" --msgbox "Der neue Pfad lautet:\n$2" 16 100
    else
      whiptail --title "Fehler beim ändern des Pfads" --msgbox "Der neue Pfad: $2\nKonnte nicht geändert werden" 16 100
    fi
  fi
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
      "3)" "Encoding Einstellungen" \
      "4)" "Encoding Hardware" \
      "5)" "Beenden" 3>&2 2>&1 1>&3
  )
  # Zuordnung Funktionen zu Menüpunkten
  case $Wahl in
  "1)")
    # Abfrage, ob alle Skripte (startencode.sh, jdautoenc.sh und rename.sh) am selben Ort sind, um den generellen Pfad auf diesen umzustellen
    if whiptail --title "Befinden sich alle Skripte an der selben stelle?" --yesno "Das startencode.sh Skript wurde in ${startencode//startencode.sh/} gefunden. Ist dies der Pfad aller Skripte?\n\nACHTUNG! Nur die Skripte werden dadurch angepasst. der Entpackt und der Out Ordner sowie der Pfad für das Log müssen manuell gesetzt werden!" 20 100; then
      newpath=$(echo "${startencode//startencode.sh/}" | sed -e "s#/#\\\/#g")
      jdautoencpfad=$(grep "jdautoenc=" "$startencode" | sed 's/jdautoenc=\|["]//g' | sed -e "s#/#\\\/#g")
      renamepfad=$(grep "rename=" "$startencode" | sed 's/rename=\|["]//g' | sed -e "s#/#\\\/#g")
      renamelist=$(grep "renamelist=" "$startencode" | sed 's/renamelist=\|["]//g' | sed -e "s#/#\\\/#g")
      change_path "$jdautoencpfad" "$newpath\/jdautoenc.sh" "$startencode" "jdautoenc.sh"
      change_path "$renamepfad" "$newpath\/rename.sh" "$startencode" "rename.sh"
      change_path "$renamelist" "$newpath\/renamelist" "$startencode" "renamelist"
    else
      jdautoencpfad=$(grep "jdautoenc=" "$startencode" | sed 's/jdautoenc=\|["]//g' | sed -e "s#/#\\\/#g")
      renamepfad=$(grep "rename=" "$startencode" | sed 's/rename=\|["]//g' | sed -e "s#/#\\\/#g")
      renamelist=$(grep "renamelist=" "$startencode" | sed 's/renamelist=\|["]//g' | sed -e "s#/#\\\/#g")
      entpacktpfad=$(grep "entpackt=" "$startencode" | sed 's/entpackt=\|["]//g' | sed -e "s#/#\\\/#g")
      outpfad=$(grep "out=" "$startencode" | sed 's/out=\|["]//g' | sed -e "s#/#\\\/#g")
      logpfad=$(grep "log=" "$startencode" | sed 's/log=\|["]//g' | sed -e "s#/#\\\/#g")
      # Neues Menü Loop für das ändern von Pfaden
      while true; do
        # Aufbau des Menüs
        Wahl=$(
          whiptail --title "Welchen Ordnerpfad möchtest du Anpassen?" --menu "Bitte Auswahl treffen" 22 100 9 \
            "1)" "jdautoenc.sh $jdautoencpfad" \
            "2)" "rename.sh $renamepfad" \
            "3)" "renamelist $renamelist" \
            "4)" "Entpackt Ordner $entpacktpfad" \
            "5)" "Out Ordner $outpfad" \
            "6)" "Log Pfad $logpfad" \
            "7)" "Beenden" 3>&2 2>&1 1>&3
        )
        # Ordnerpfade Verändern
        case $Wahl in
        "1)")
          # jdautoenc.sh Pfad
          newjdautopfad=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für jdautoenc.sh:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
          change_path "$jdautoencpfad" "$newjdautopfad" "$startencode" "jdautoenc.sh"
          ;;
        "2)")
          # rename.sh Pfad
          newrenamepfad=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für rename.sh:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
          change_path "$renamepfad" "$newrenamepfad" "$startencode" "rename.sh"
          ;;
        "3)")
          # renamelist Pfad
          newrenamelist=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad fürdie renamelist:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
          change_path "$renamelist" "$newrenamelist" "$startencode" "renamelist"
          ;;
        "4)")
          # Ordnerpfad für den Ordner in dem entpackte Videos liegen.
          newentpackpfad=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Ordnerpfad für den Ordner in dem vom JD2 entpackte Videos liegen:" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
          change_path "$entpacktpfad" "$newentpackpfad" "$startencode" "Entpackt Ordner"
          ;;
        "5)")
          # Orderpfad in dem die encodierten Videos hinterlegt werden.
          newoutfolder=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für das Verzeichnis, in dem die Fertig encodierten Videos sind/sollen" 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
          change_path "$outpfad" "$newoutfolder" "$startencode" "Out Ordner"
          ;;
        "6)")
          # Log Pfad. Hier wird das Log hingeschrieben
          newlogpfad=$(whiptail --title "Pfad Einstellung ändern" --inputbox "Neuer Pfad für log." 16 100 3>&1 1>&2 2>&3 | sed -e "s#/#\\\/#g")
          change_path "$logpfad" "$newlogpfad" "$startencode" "Log Pfad"
          ;;
        "7)")
          # break = Gehe zurück in das vorherige Menü
          break
          ;;
          # Ende vom Menü
        esac
      done
    fi
    ;;
  "2)")
    # Hier werden die Log Farben angepasst. Muss mir noch überlegen, wie ich die definieren kann.
    whiptail --msgbox "Work in Progress" 20 78
    ;;
  "3)")
    # Einstellungen für das encoden. (noch in der jdautoenc.sh definiert. Wandern vielleicht bald in das startencode.sh skript)
    while true; do
      jdautoencpfad=$(grep "jdautoenc=" "$startencode" | sed 's/jdautoenc=\|["]//g')
      curr_anime_bitrate=$(grep "bitrate_anime=" "$jdautoencpfad" | sed 's/.*bitrate_anime=//g')
      curr_anime_preset=$(grep "preset_anime=" "$jdautoencpfad" | sed 's/.*preset_anime=//g')
      curr_serien_bitrate=$(grep "bitrate_serie=" "$jdautoencpfad" | sed 's/.*bitrate_serie=//g')
      curr_serien_preset=$(grep "preset_serie=" "$jdautoencpfad" | sed 's/.*preset_serie=//g')
      curr_filme_bitrate=$(grep "bitrate_filme=" "$jdautoencpfad" | sed 's/.*bitrate_filme=//g')
      curr_filme_preset=$(grep "preset_filme=" "$jdautoencpfad" | sed 's/.*preset_filme=//g')
      bitratewahl=$(
        whiptail --title "Hier kannst du die FFmpeg Settings ändern" --menu "Wähle hier die zu ändernden Einstellungen" 20 100 9 \
          "1)" "Bitrate Anime Aktuell: $curr_anime_bitrate K" \
          "2)" "FFmpeg Preset Animes Aktuell: $curr_anime_preset" \
          "3)" "Bitrate Serien Aktuell: $curr_serien_bitrate K" \
          "4)" "FFmpeg Preset Serien Aktuell: $curr_serien_preset" \
          "5)" "Bitrate Filme Aktuell: $curr_filme_bitrate K" \
          "6)" "FFmpeg Preset Filme Aktuell: $curr_filme_preset" \
          "7)" "Beenden" 3>&2 2>&1 1>&3
      )
      case $bitratewahl in
      "1)")
        # Ändere die bitrate für Animes
        new_anime_bitrate=$(bitrate_auswahl "Animes" ON OFF OFF)
        sed -i "s/^bitrate_anime.*/bitrate_anime=$new_anime_bitrate/g" "$jdautoencpfad"
        ;;
      "2)")
        # Ändere das zu nutzende Preset für Animes
        new_anime_preset=$(preset_auswahl "Animes")
        sed -i "s/^preset_anime=.*/preset_anime=$new_anime_preset/g" "$jdautoencpfad"
        ;;
      "3)")
        # Ändere die bitrate für Serien
        new_serien_bitrate=$(bitrate_auswahl "Serien" OFF ON OFF)
        sed -i "s/^bitrate_serie.*/bitrate_serie=$new_serien_bitrate/g" "$jdautoencpfad"
        ;;
      "4)")
        # Ändere das zu nutzende Preset für Serien
        new_serien_preset=$(preset_auswahl "Serien")
        sed -i "s/^preset_serie=.*/preset_serie=$new_serien_preset/g" "$jdautoencpfad"
        ;;
      "5)")
        # Ändere die bitrate für Filme
        new_filme_bitrate=$(bitrate_auswahl "Filme" OFF OFF ON)
        sed -i "s/^bitrate_filme.*/bitrate_filme=$new_filme_bitrate/g" "$jdautoencpfad"
        ;;
      "6)")
        # Ändere das zu nutzende Preset für Filme
        new_filme_preset=$(preset_auswahl "Filme")
        sed -i "s/^preset_filme=.*/preset_filme=$new_filme_preset/g" "$jdautoencpfad"
        ;;
      "7)")
        break
        ;;
      esac
    done
    ;;
  "4)")
    jdautoencpfad=$(grep "jdautoenc=" "$startencode" | sed 's/jdautoenc=\|["]//g')
    # Wir schauen, ob wir kompatible Hardware anzeigen lassen können
    gethw=$(lshw -class display 2>/dev/null | grep vendor)
    for hw in $gethw; do
      if [[ ${hw,,} == *"nvidia"* ]]; then
        hw1="\nnVidia Grafikkarte"
      elif [[ ${hw,,} == *"intel"* ]]; then
        hw2="\nIntel iGPU"
      elif [[ ${hw,,} == *"radeon"* ]]; then
        hw3="\nAMD Grafikkarte"
      fi
    done
    Hardwareauswahl=$(
      whiptail --title "Welchen Hardware möchtest du verwenden?" --menu "Bitte wähle die zu nutzende Hardware. Folgende Hardware scheint installiert zu sein:$hw1 $hw2 $hw3" 20 100 9 \
        "1)" "nVidia" \
        "2)" "AMD" \
        "3)" "Intel QuickSync (Intel CPU)" \
        "4)" "Software (noch NICHT IMPLEMENTIERT!)" \
        "5)" "Beenden" 3>&2 2>&1 1>&3
    )
    case $Hardwareauswahl in
    "1)")
      # Ändere Einstellung zu nVidia Encoding
      sed -i 's/^hw_accel.*/hw_accel="cuda"/g' "$jdautoencpfad"
      sed -i 's/^codec.*/codec="hevc_nvenc"/g' "$jdautoencpfad"
      whiptail --msgbox "Die Encoding Einstellungen wurden zu nVidia geändert.\nEs werden die Cuda Prozessoren mit dem NVENC encoder genutzt" 20 78
      ;;
    "2)")
      # Ändere Einstellung zu AMD Enconding
      sed -i 's/^hw_accel.*/hw_accel="auto"/g' "$jdautoencpfad"
      sed -i 's/^codec.*/codec="hevc_amf"/g' "$jdautoencpfad"
      whiptail --msgbox "Die Encoding Einstellungen wurden zu AMD geändert.\nEs werden mit der AMD-Transistoren mit dem amf encoder genutzt" 20 78
      ;;
    "3)")
      # Ändere Einstellung zu Intel Quick Sync Encoding
      sed -i 's/^hw_accel.*/hw_accel="qsv"/g' "$jdautoencpfad"
      sed -i 's/^codec.*/codec="hevc_qsf"/g' "$jdautoencpfad"
      whiptail --msgbox "Die Encoding Einstellungen wurden zu nVidia geändert.\nEs wird der Intel QuickSync Chip mit qsv encoder genutzt" 20 78
      ;;
    "4)")
      # Ändere Einstellung zu Software Encoding
      break
      ;;
    "5)")
      break
      ;;
    esac
    ;;
  "5)")
    break
    ;;
  esac
done
