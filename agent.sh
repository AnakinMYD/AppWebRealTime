#!/bin/bash

# =========================================================================================================================

# Script Agent 
# Fonction : Collecter puis envoyer les données métrique de l'ordinateur
# Écrit par MYD



# Collecte des informations du Disque Dur
function disque_dur()
{
    espace_total=$(df -BG | grep /dev/sda3 | awk '{print $2}' | sed 's/G//g')
    espace_utiliser=$(df -BG | grep /dev/sda3 | awk '{print $3}' | sed 's/G//g')
    espace_libre=$(df -BG | grep /dev/sda3 | awk '{print $4}' | sed 's/G//g')
    pourcentage_disk=$(df -BG | grep /dev/sda3 | awk '{print $5}' | sed 's/%//g')
}

# Collecte des informations du Processeur
function cpu()
{
    utilisation=$(sar -u 2 5 | grep Moyenne | sed 's/     /:/g' | sed 's/      /:/g' | sed 's/::/:/g' | sed 's/ //g'| awk -F: {'print $NF'})
    pourcentage_cpu=$(awk "BEGIN {print 100 - $utilisation}" | sed 's/ /./g')
    modele=$(sudo lshw -C CPU | grep produit | awk -F: '{print $2}' | sed 's/^[[:space:]]*//')
    frequence=$(grep "cpu MHz" /proc/cpuinfo | head -1 | awk '{print $4 " MHz"}' | sed 's/ MHz//g')
}

# Collecte des informations de la Mémoire Vive
function ram()
{
    ram_total=$(free -g | awk '/^Mem:/{print $2}')
    type=$(sudo dmidecode --type memory | grep "Type:" | sed "1d;3d" | sed 's/^[[:space:]]//g' | awk {'print $2'})
    ram_percent=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 *100}')
}

# Horaire Actuel & Temps d'utilisation de l'ordinateur

function times()
{
    uptime=$(uptime | awk '{print $1}' | sed 's/^[[:space:]]//')
    boot_time=$(uptime -p | sed 's/up//g' | sed 's/^[[:space:]]//')
}

# Boucle infini pour actualisé les infos toutes les 1 seconde
while [ true ]
do

# Appel des fonction
disque_dur
cpu
ram
times

# Conversion des données collecter en JSON
json_data=$(jq -n \
    --arg espace_total "$espace_total" \
    --arg espace_utiliser "$espace_utiliser" \
    --arg espace_libre "$espace_libre" \
    --arg pourcentage_disk "$pourcentage_disk" \
    --arg pourcentage_cpu "$pourcentage_cpu" \
    --arg modele "$modele" \
    --arg frequence "$frequence" \
    --arg ram_total "$ram_total" \
    --arg type "$type" \
    --arg ram_percent "$ram_percent" \
    --arg uptime "$uptime" \
    --arg boot_time "$boot_time" \
    '{
      HDD:{
      espace_total:$espace_total,
      espace_libre:$espace_libre,
      espace_utiliser:$espace_utiliser,
      pourentage_disk:$pourcentage_disk
      },
      CPU:{
      pourcentage_cpu:$pourcentage_cpu,
      modele:$modele,
      frequence:$frequence},
      RAM:{
      ram_total:$ram_total,
      type:$type,
      ram_percent:$ram_percent},
      TIME:{
      uptime:$uptime,
      boot_time:$boot_time}
    }')

# Affichage des données pour vérifié leur intégrité
echo "$json_data"

# Transmissions des données JSON à l'adresse suivante
curl -k -X POST https://localhost:3000 \
     -H "Content-Type: application/json" \
     -d "$json_data"

sleep 1
done