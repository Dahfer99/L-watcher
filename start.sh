#!/bin/bash
show_path(){
  echo ""
  while IFS= read -r line;do
      [[ "$line" == \#* ]] && continue
      [[ -z "$line" ]] && continue
      echo "$line"
  done < "$config_file"
  echo ""
  exit 0
}

show_help(){
    echo ""
    echo "Usage: ./start.sh [OPTIONS] [CHEMIN]"
    echo ""
    echo "Options:"
    echo "  -h          Afficher cette manuel"
    echo "  -s          Afficher les repertoires surveillés"
    echo "  -D          Supprime la liste des repertoires à surveiller"
    echo "  -d n        Définir le nombre de jour maximum pour stocker les sauvegardes (par defaut: 7)"
    echo "  -c CHEMIN   Ajouter un nouvel repertoire à surveiller puis lancer le programme"
    echo "  -C CHEMIN   Supprime la liste des repertoires à surveiller et ajouter un nouvel repertoire à surveiller puis lance le programme"
    echo "  -a          Ajoute un nouvel repertoire à surveiller (sans lancer le programme)"
    echo ""
    echo "Exemples:"
    echo "  ./start.sh"
    echo "  ./start.sh -d 14"
    echo "  ./start.sh -c /etc/lwatcher/custom.conf"
    echo "  ./start.sh -d 30 -c /etc/lwatcher/custom.conf"
    echo ""
    exit 0
}

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[35m"
CYAN="\033[36m"
RESET="\033[0m"

session_time=$(date +%Y%m%d_%H%M)
max_days=7
config_file="./config/inotify.config"


if [ ! -f "./bin/inotify" ];then
    make &
fi

if [ ! -f "$config_file" ];then 
    printf "${RED}Error:${RESET} ficher .config absent"
    exit 0
fi

if [ "$EUID" -ne 0 ];then 
    printf "${YELLOW}Warning:${RESET} Le script n'est pas executer en tant que root"
fi 

while getopts "hsDd:c:C:a:" opt; do
    case $opt in
        h) show_help ;;
        s) show_path ;;
        D) echo "" > "$config_file"
           exit 0
           ;;
        d) max_days=$OPTARG ;;
        c) new_path=$OPTARG
            if [[ -n "$new_path" ]];then
                echo "$new_path" >> "$config_file"
            fi
            ;;
        C) new_path=$OPTARG
           if [[ -n "$new_path" ]];then
              echo "$new_path" > "$config_file"
           fi
           ;;
        a) new_path=$OPTARG
            if [[ -n "$new_path" ]];then
                echo "$new_path" >> "$config_file"
            fi
            ewit 0
            ;;
        ?) echo "Option inconnue, ./start -h pour afficher l'aide."; exit 1 ;;
    esac
done


trap "./scripts/cleanup.sh $session_time $max_days" EXIT

./scripts/backup.sh $session_time
./bin/inotify | ./scripts/output.sh $session_time