#!/bin/bash

function disque_dur()
{
    espace_total=$(df -BG | grep /dev/sda3 | awk '{print $2}' | sed 's/G//g')
    espace_utiliser=$(df -BG | grep /dev/sda3 | awk '{print $3}' | sed 's/G//g')
    espace_libre=$(df -BG | grep /dev/sda3 | awk '{print $4}' | sed 's/G//g')
    pourcentage_disk=$(df -BG | grep /dev/sda3 | awk '{print $5}' | sed 's/%//g')
}

function cpu()
{
    utilisation=$(sar -u 2 5 | grep Moyenne | sed 's/     /:/g' | sed 's/      /:/g' | sed 's/::/:/g' | sed 's/ //g'| awk -F: {'print $NF'})
    pourcentage_cpu=$(awk "BEGIN {print 100 - $utilisation}" | sed 's/ /./g')
    modele=$(sudo lshw -C CPU | grep produit | awk -F: '{print $2}' | sed 's/^[[:space:]]*//')
    frequence=$(inxi | grep speed | awk '{print $2}'| cut -d'/' -f1)
}

function ram()
{
    ram_total=$(inxi -m | grep System | awk '{print $4}')
    type=$(inxi -m | grep Device-1 | awk '{print $8}')
    ram_percent=$(inxi -m | grep System | awk '{print $NF}' | sed 's/(//g' | sed 's/)//g' | sed 's/%//g')
}

function times()
{
    uptime=$(uptime | awk '{print $1}' | sed 's/^[[:space:]]//')
    boot_time=$(uptime -p | sed 's/up//g' | sed 's/^[[:space:]]//')
}

while [ true ]
do
disque_dur
cpu
ram
times

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

echo "$json_data"

curl -X POST http://localhost:3000 \
     -H "Content-Type: application/json" \
     -d "$json_data"

sleep 1
done