#!/bin/bash

## Farben für das Log

white='\033[0;37m'  # ${white}
yellow='\033[0;33m' # ${yellow}
purple='\033[0;35m' # ${purple}
blue='\033[0;34m'   # ${blue}
lblue='\033[1;34m'  # ${lblue}
cyan='\033[0;36m'   # ${cyan}

## Rename Skript Pfad:
JDAutoConfig=$(find ~ -type f -name "JDAutoConfig" 2>/dev/null)
renamelist=$(grep "renamelist=" "$JDAutoConfig" | sed 's/renamelist=//g')

language_Folder=$(grep "language_folder=" "$JDAutoConfig" | sed 's/.*=//g')
if [[ -n $(grep "language=" "$JDAutoConfig" | sed 's/.*=//g') ]]; then
  language=$(grep "language=" "$JDAutoConfig" | sed 's/.*=//g')
else
  language=$(locale | head -n 1 | sed 's/.*=\|\..*//g')
fi

if [[ $language == "C" ]] || [[ ! -d $language_Folder/$language ]]; then
  language=en_US
fi

text_lang() {
  if [ -f "$language_Folder"/"$language"/addrename.lang ]; then
    grep "$1" "$language_Folder"/"$language"/addrename.lang | sed 's/^....//'
  else
    curl -s https://raw.githubusercontent.com/Pakobbix/JDownloader-Autoenc-rename/Multilanguage/lang/en_US/addrename.lang | grep "$1" | sed 's/^....//'
  fi
}

get_DB() {
  grep "$1DB=" "$JDAutoConfig" | sed 's/.*=//g'
}

curl_name() {
  if [[ $dbid == "TheTVDB" ]]; then
    if [[ -z $(curl -sL https://www.thetvdb.com/dereferrer/series/"$dbentry" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g") ]]; then
      curl -sL https://www.thetvdb.com/dereferrer/series/"$dbentry" | grep -i -A1 "en" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g" | head -n 1
    else
      curl -sL https://www.thetvdb.com/dereferrer/series/"$dbentry" | grep -i -A1 "deu" | grep "data-title" | sed 's/.*="\|"//g' | sed "s/&rsquo;/'/g" | head -n 1
    fi
  elif [[ $dbid == "TheMovieDB::TV" ]]; then
    curl -sL https://www.themoviedb.org/tv/"$dbentry" | grep -i "TV Series" | sed -e 's/<[^>]*>\|(TV.*//g'
  elif [[ $dbid == "TheMovieDB" ]]; then
    curl -sL https://www.themoviedb.org/movie/"$dbentry" | grep -i "The Movie Database (TMDB)" | grep title | sed -e 's/<[^>]*>\|&#.*//g'
  elif [[ $dbid == "AniDB" ]]; then
    curl -sL -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" https://anidb.net/anime/"$dbentry" | grep -i -A1 "Synonym" | sed 's/<[^>]*>\|Synonym\|\t//g' | sed '/^$/d'
  fi

}

curl_movie_name() {
  curl -sL "https://themoviedb.org/movie/$dbentry" | grep -i "<title>" | sed -e 's/<[^>]*>//g' | sed 's/&#[0-9].*//g'
}

get_db_id() {
  if [[ $dbid == "TheTVDB" ]]; then
    if [ -z "$key2" ]; then
      echo -e "${purple}https://thetvdb.com/search?query=""$key1""${white}"
    else
      echo -e "${purple}https://thetvdb.com/search?query=""$key1""%20""$key2""${white}"
    fi
  elif [[ $dbid == "TheMovieDB" ]] || [[ $dbid == "TheMovieDB::TV" ]]; then
    if [ -z "$key2" ]; then
      echo -e "${purple}https://www.themoviedb.org/search?language=de&query=""$key1""${white}"
    else
      echo -e "${purple}https://www.themoviedb.org/search?language=de&query=""$key1""%20""$key2""${white}"
    fi
  elif [[ $dbid == "AniDB" ]]; then
    if [ -z "$key2" ]; then
      echo -e "${purple}https://anidb.net/anime/?adb.search=$key1&do.update=Search&noalias=1${white}"
    else
      echo -e "${purple}https://anidb.net/anime/?adb.search=$key1%20$key2&do.update=Search&noalias=1${white}"
    fi
  fi
}

read -rp "$(echo -e "$(text_lang "001")" "${cyan}""$(text_lang "002")""${white}" "$(text_lang "003")" "${blue}""$(text_lang "004")""${white}"/"${lblue}""$(text_lang "005")""${white}" "$(text_lang "006")") ($(text_lang "007")): " adding
if [[ ${adding,,} == *"anime"* ]]; then
  read -rp "$(echo -e "$(text_lang "008")" "${purple}""$(text_lang "009")""${white}" "$(text_lang "010")" "$adding" "$(text_lang "011")")  " key1
  read -rp "$(echo -e "${yellow}""$(text_lang "012")""${white}", "$(text_lang "013")")  " key2
  dbid=$(get_DB "Anime")
  get_db_id
  read -rp "$(echo -e "$(text_lang "019")" "${purple}""$dbid""${white}" "$(text_lang "020")")  " dbentry
  echo "$(text_lang "014") $(curl_name)"
  read -rp "$(text_lang "015")" wrongformat
  if [ "${wrongformat,,}" == "n" ]; then
    text_lang "016"
    exit
  else
    {
      curl_name
      echo "$key1"
      echo "$key2"
      echo "Anime"
      echo "$dbentry"
      echo ""
    } >>"$renamelist"
  fi
elif [[ ${adding,,} == *"serie"* ]]; then
  read -rp "$(echo -e "$(text_lang "008")" "${purple}""$(text_lang "009")""${white}" "$(text_lang "010")" "$adding" "$(text_lang "011")")  " key1
  read -rp "$(echo -e "${yellow}""$(text_lang "012")""${white}", "$(text_lang "013")")  " key2
  dbid=$(get_DB "Series")
  get_db_id
  read -rp "$(echo -e "$(text_lang "019")" "${purple}""$dbid""${white}" "$(text_lang "020")")  " dbentry
  echo "$(text_lang "017") $(curl_name)"
  read -rp "$(text_lang "015")" wrongformat
  if [ "${wrongformat,,}" == "n" ]; then
    text_lang "016"
    exit
  else
    {
      curl_name
      echo "$key1"
      echo "$key2"
      echo "Series"
      echo "$dbentry"
      echo ""
    } >>"$renamelist"
  fi
elif [[ ${adding,,} == *"film"* ]]; then
  read -rp "$(echo -e "$(text_lang "008")" "${purple}""$(text_lang "009")""${white}" "$(text_lang "010")" "$adding" "$(text_lang "011")")  " key1
  read -rp "$(echo -e "${yellow}""$(text_lang "012")""${white}", "$(text_lang "013")") " key2
  dbid=$(get_DB "Movie")
  get_db_id
  read -rp "$(echo -e "$(text_lang "019")" "${purple}"TheMovieDB ID"${white}" "$(text_lang "020")""\n($(text_lang "021"))")  " dbentry
  echo "$(text_lang "018") $(curl_movie_name)"
  read -rp "$(text_lang "015")" wrongformat
  if [ "${wrongformat,,}" == "n" ]; then
    text_lang "016"
    exit
  else
    {
      curl_movie_name
      echo "$key1"
      echo "$key2"
      echo "Movie"
      echo "$dbentry"
      echo ""
    } >>"$renamelist"
  fi
fi
