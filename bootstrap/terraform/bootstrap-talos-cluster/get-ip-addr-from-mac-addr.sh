#!/bin/bash

address_map=$(sudo nmap -sn $1 | awk '/Nmap scan/{ip=$NF;next}ip && /MAC/{print ip, $3}' | sed 's/[)(]//g')

while IFS= read -r address_pair ; do
  ip_addr=${address_pair% *}
  mac_addr=${address_pair#* }
  if [ "$mac_addr" = "$2" ]; then
cat <<EOF
{"ip_addr" : "$ip_addr"}
EOF
    exit 0
  fi
done <<< $address_map

>&2 echo "MAC address ${2} not found"
exit 1