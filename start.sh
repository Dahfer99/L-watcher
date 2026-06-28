#!/bin/bash

# Chemin

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

# HELP

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
    echo "  -r ADMIN    Copie les archives de sauvegardes vers un autre pc (fonctionne avec sshd uniquement)"
    echo ""
    echo "Exemples:"
    echo "  ./start.sh"
    echo "  ./start.sh -d 14"
    echo "  ./start.sh -c /etc/lwatcher/custom.conf"
    echo "  ./start.sh -d 30 -c /etc/lwatcher/custom.conf"
    echo "  ./start.sh -r user@192.169.1.2:/chemin/sauvegarde"
    echo ""
    exit 0
}

# Couleur

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[35m"
CYAN="\033[36m"
RESET="\033[0m"



session_time=$(date +%Y%m%d_%H%M) # Synchronisation des dates
max_days=7 # MAximum de jour par defaut
config_file="./config/inotify.config" # Chemin du fichier de configuration


# Verification du fichier binaire
if [ ! -f "./bin/inotify" ];then
    make &
fi

# Verification du fichier de configuration
if [ ! -f "$config_file" ];then 
    printf "${RED}Error:${RESET} ficher .config absent"
    exit 0
fi

#if [ "$EUID" -ne 0 ];then
#    printf "${YELLOW}Warning:${RESET} Le script n'est pas executer en tant que root"
#fi

# Gestion des options

while getopts "hsDd:c:C:a:r:" opt; do
    case $opt in
        h) show_help ;;
        s) show_path ;;
        D) echo -n "" > "$config_file"
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
            exit 0
            ;;
        r) remote_backup=$OPTARG;;
        ?) echo "Option inconnue, ./start -h pour afficher l'aide."; exit 1 ;;
    esac
done

if [ -n "$remote_backup" ]; then
    ssh-keygen -t ed25519 -f ~/.ssh/lwatch_key -N ""
    ssh-copy-id -i ~/.ssh/lwatch_key.pub "${remote_backup%%:*}"
fi

{
# Gestion des signals
trap "./scripts/cleanup.sh $session_time $max_days $remote_backup" EXIT
# Execution des autres scripts
./scripts/backup.sh "$session_time" "$remote_backup"
./bin/inotify | ./scripts/output.sh "$session_time"
} 2>> "./logs/error.log"