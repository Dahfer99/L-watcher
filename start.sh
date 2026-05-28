#!/bin/bash
show_help(){
    echo ""
    echo "Usage: ./start.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h          Afficher cette manuel"
    echo "  -d DAYS     Définir le nombre de jour maximum pour stocker les ssauvegardes (par defaut: 7)"
    echo "  -c PATH     Définr un chemin à surveiller"
    echo ""
    echo "Exemples:"
    echo "  ./start.sh"
    echo "  ./start.sh -d 14"
    echo "  ./start.sh -c /etc/lwatcher/custom.conf"
    echo "  ./start.sh -d 30 -c /etc/lwatcher/custom.conf"
    echo ""
    exit 0
}

session_time=$(date +%Y%m%d_%H%M)
max_days=7
config_file="./config/inotify.config"

while getopts "hd:c:" opt; do
    case $opt in
        h) show_help ;;
        d) max_days=$OPTARG ;;
        c) config_file=$OPTARG ;;
        ?) echo "Option inconnue, ./start -h pour afficher l'aide."; exit 1 ;;
    esac
done

trap "./scripts/cleanup.sh $session_time $max_days" EXIT

./scripts/backup.sh $session_time
./bin/inotify | ./scripts/output.sh $session_time