#!/bin/bash

red='\033[0;31m'    # ${red}
white='\033[0;37m'  # ${white}
yellow='\033[0;33m' # ${yellow}
green='\033[0;32m'  # ${green}
blue='\033[0;34m'   # ${blue}
lblue='\033[1;34m'  # ${lblue}
cyan='\033[0;36m'   # ${cyan}
purple='\033[0;35m' # ${purple}

# Hier definieren wir die wahl. Das ist für die Auswahl, damit nur zahlen von 1-5 angenommen werden
echo ""
echo -e "${yellow}Was möchtest du Konfigurieren${white}"
echo ""
# Die Auswahlmöglichkeiten für die Konfiguration
PS3="Konfiguriere (1-5): "

select option in "Ordnerpfade" "Log Farben" "Encoding Settings (Bitrate, Codec)" "Encoding Hardware" "Beenden"; do

	case $option in
	"Ordnerpfade")
		echo ""
		echo -e "Versuche den ${green}Pfad${white} der ${purple}startencode.sh${white} automatisch zu finden"
		startencode=$(find ~ -type f -iname "startencode.sh")
		echo ""
		read -rp "$(echo -e Ist der "${green}"Pfad"${white}" der "${purple}""$startencode""${white}" Richtig?) (Y/n): " startencodel
		if [ "${startencodel,,}" == "n" ]; then
			unset startencode
			echo -e "Gebe zunächst den vollständigen "${green}"Pfad"${white}" an, wo das "${purple}"startencode.sh"${white}" sich befindet:"
			read -rp "" startencode
			jdautoencpfad=$(sed '13q;d' "$startencode" | sed 's/jdautoenc=\|["]//g')
			renamepfad=$(sed '14q;d' "$startencode" | sed 's/rename=\|["]//g')
			entpacktpfad=$(sed '15q;d' "$startencode" | sed 's/entpackt=\|["]//g')
			outpfad=$(sed '16q;d' "$startencode" | sed 's/out=\|["]//g')
			logpfad=$(sed '17q;d' "$startencode" | sed 's/log=\|["]//g')
			echo ""
			echo -e "1. Momentaner Pfad der jdautoenc.sh: "
			echo -e "${green}$jdautoencpfad${white}"
			echo ""
			echo -e "2. Momentaner Pfad der rename.sh:"
			echo -e "${green}$renamepfad${white}"
			echo ""
			echo -e "3. Momentane Konfiguration for den entpackt Ordner:"
			echo -e "${green}$entpacktpfad${white}"
			echo ""
			echo -e "4. Momentane Konfiguration for den out Ordner:"
			echo -e "${green}$outpfad${white}"
			echo ""
			echo -e "5. Das log wird mometan hier hin geschrieben:"
			echo -e "${green}$logpfad${white}"
			echo ""
			PS4="Wähle den zu ändernden Ordner Pfad"
			select folder in "jdautoenc.sh" "rename.sh" "Entpackt Ordner" "Out Ordner" "Log Pfad" "Zurück"; do
				case $folder in
				"jdautoenc.sh")
					echo ""
					echo "Versuche die jdautoenc.sh selbstständig zu finden"
					echo ""
					jdpath=$(find ~ -type f -iname "jdautoenc.sh")
					echo ""
					echo "jdautoenc.sh wurde hier gefunden:"
					echo -e "${green}$jdpath${white}"
					echo ""
					echo -e "Kopiere oder gebe Manuell den ${green}Pfad${white} der zu benutzenden ${purple}jdautoenc.sh${white} an"
					read -rp "" newjdautopfad
					echo ""
					echo -e "Setze ${purple}jdautoenc.sh${white} ${green}Pfad${white} zu ${green}$newjdautopfad${white}"
					echo ""
					;;
				"rename.sh")
					echo ""
					echo "Versuche die rename.sh selbstständig zu finden"
					echo ""
					renamepath=$(find ~ -type f -iname "rename.sh")
					echo ""
					echo "rename.sh wurde hier gefunden:"
					echo -e "${green}$renamepath${white}"
					echo ""
					echo -e "Kopiere oder gebe Manuell den ${green}Pfad${white} der zu benutzenden ${purple}rename.sh${white} an"
					read -rp "" newrenamepath
					echo ""
					echo -e "Setze ${purple}rename.sh${white} ${green}Pfad${white} zu ${green}$newrenamepath${white}"
					echo ""
					;;
				"Entpackt Ordner")
					echo ""
					echo -e "Gebe Manuell den ${green}Pfad${white} des zu benutzenden ${blue}Entpackt Ordners${white} an"
					read -rp "" entpacktordner
					echo ""
					echo -e "Setze ${blue}Entpackt Ordner${white} ${green}Pfad${white} zu ${green}$entpacktordner${white}"
					echo ""
					;;
				"Out Ordner")
					echo ""
					echo -e "Gebe Manuell den ${green}Pfad${white} des zu benutzenden ${blue}Out Ordners${white} an"
					read -rp "" outordner
					echo ""
					echo -e "Setze ${blue}Out Ordner${white} ${green}Pfad${white} zu ${green}$outordner${white}"
					echo ""
					;;
				"Log Pfad")
					echo ""
					echo -e "Wie soll der ${green}Pfad${white} zum ${lblue}Log${white} sein? (nur Verzeichnis)"
					read -rp "" newlogpfad
					echo ""
					echo -e "Setze ${blue}Log${white} ${green}Pfad${white} zu ${green}$newlogpfad${white}"
					echo ""
					;;
				"Zurück")
					echo ""
					echo -e "${yellow}Zurück zum Menü${white}"
					echo ""
					break
					;;

				esac
				echo "1) jdautoenc.sh  2) rename.sh  3) Entpackt Ordner  4) Out Ordner  5) Log Pfad  6) Zurück"
			done

		else
			jdautoencpfad=$(sed '13q;d' "$startencode" | sed 's/jdautoenc=\|["]//g')
			renamepfad=$(sed '14q;d' "$startencode" | sed 's/rename=\|["]//g')
			entpacktpfad=$(sed '15q;d' "$startencode" | sed 's/entpackt=\|["]//g')
			outpfad=$(sed '16q;d' "$startencode" | sed 's/out=\|["]//g')
			logpfad=$(sed '17q;d' "$startencode" | sed 's/log=\|["]//g')
			echo ""
			echo -e "1. Momentaner Pfad der jdautoenc.sh: "
			echo -e "${green}$jdautoencpfad${white}"
			echo ""
			echo -e "2. Momentaner Pfad der rename.sh:"
			echo -e "${green}$renamepfad${white}"
			echo ""
			echo -e "3. Momentane Konfiguration for den entpackt Ordner:"
			echo -e "${green}$entpacktpfad${white}"
			echo ""
			echo -e "4. Momentane Konfiguration for den out Ordner:"
			echo -e "${green}$outpfad${white}"
			echo ""
			echo -e "5. Das log wird mometan hier hin geschrieben:"
			echo -e "${green}$logpfad${white}"
			echo ""
			PS4="Wähle den zu ändernden Ordner Pfad"
			select folder in "jdautoenc.sh" "rename.sh" "Entpackt Ordner" "Out Ordner" "Log Pfad" "Zurück"; do
				case $folder in
				"jdautoenc.sh")
					echo ""
					echo "Versuche die jdautoenc.sh selbstständig zu finden"
					echo ""
					jdpath=$(find ~ -type f -iname "jdautoenc.sh")
					echo ""
					echo "jdautoenc.sh wurde hier gefunden:"
					echo -e "${green}$jdpath${white}"
					echo ""
					echo -e "Kopiere oder gebe Manuell den ${green}Pfad${white} der zu benutzenden ${purple}jdautoenc.sh${white} an"
					read -rp "" newjdautopfad
					echo ""
					echo -e "Setze ${purple}jdautoenc.sh${white} ${green}Pfad${white} zu ${green}$newjdautopfad${white}"
					echo ""
					;;
				"rename.sh")
					echo ""
					echo "Versuche die rename.sh selbstständig zu finden"
					echo ""
					renamepath=$(find ~ -type f -iname "rename.sh")
					echo ""
					echo "rename.sh wurde hier gefunden:"
					echo -e "${green}$renamepath${white}"
					echo ""
					echo -e "Kopiere oder gebe Manuell den ${green}Pfad${white} der zu benutzenden ${purple}rename.sh${white} an"
					read -rp "" newrenamepath
					echo ""
					echo -e "Setze ${purple}rename.sh${white} ${green}Pfad${white} zu ${green}$newrenamepath${white}"
					echo ""
					;;
				"Entpackt Ordner")
					echo ""
					echo -e "Gebe Manuell den ${green}Pfad${white} des zu benutzenden ${blue}Entpackt Ordners${white} an"
					read -rp "" entpacktordner
					echo ""
					echo -e "Setze ${blue}Entpackt Ordner${white} ${green}Pfad${white} zu ${green}$entpacktordner${white}"
					echo ""
					;;
				"Out Ordner")
					echo ""
					echo -e "Gebe Manuell den ${green}Pfad${white} des zu benutzenden ${blue}Out Ordners${white} an"
					read -rp "" outordner
					echo ""
					echo -e "Setze ${blue}Out Ordner${white} ${green}Pfad${white} zu ${green}$outordner${white}"
					echo ""
					;;
				"Log Pfad")
					echo ""
					echo -e "Wie soll der ${green}Pfad${white} zum ${lblue}Log${white} sein? (nur Verzeichnis)"
					read -rp "" newlogpfad
					echo ""
					echo -e "Setze ${blue}Log${white} ${green}Pfad${white} zu ${green}$newlogpfad${white}"
					echo ""
					;;
				"Zurück")
					echo ""
					echo -e "${yellow}Zurück zum Menü${white}"
					echo ""
					break
					;;

				esac
				echo "1) jdautoenc.sh  2) rename.sh  3) Entpackt Ordner  4) Out Ordner  5) Log Pfad  6) Zurück"
			done
		fi
		;;

	"Log Farben")
		echo "Log Farben Konfigurieren"
		;;
	"Encoding Settings (Bitrate, Codec)")
		echo "Encoding Settings Konfigurieren"
		;;
	"Encoding Hardware")
		echo "Encoding Hardware Konfigurieren"
		;;
	"Beenden")
		break
		;;
	esac
	echo ""
	echo "1) Ordnerpfade			       3) Encoding Settings (Bitrate, Codec)  5) Abbrechen
2) Log Farben			       4) Encoding Hardware"
	echo ""
done
