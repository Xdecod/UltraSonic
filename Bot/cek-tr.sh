#!/bin/bash
clear
function con() {
    local -i bytes=$1;
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$(( (bytes + 1023)/1024 ))KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$(( (bytes + 1048575)/1048576 ))MB"
    else
        echo "$(( (bytes + 1073741823)/1073741824 ))GB"
    fi
}

clear
echo -n >/tmp/other.txt
data=($(cat /etc/xray/tro.json | grep '^#tro-user#' | cut -d ' ' -f 2 | sort | uniq))
echo "━━━━━━━━━━━━━━━━━━"
echo "|Akun | Quota usage | ip limit"
echo "━━━━━━━━━━━━━━━━━━"
for akun in "${data[@]}"
do
if [[ -z "$akun" ]]; then
akun="tidakada"
fi
echo -n > /tmp/iptrojan.txt
data2=( `cat /var/log/xray/accesstro.log | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq`);
for ip in "${data2[@]}"
do
jum=$(cat /var/log/xray/accesstro.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
if [[ "$jum" = "$ip" ]]; then
echo "$jum" >> /tmp/iptrojan.txt
else
echo "$ip" >> /tmp/other.txt
fi
jum2=$(cat /tmp/iptrojan.txt)
sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
done
jum=$(cat /tmp/iptrojan.txt)
if [[ -z "$jum" ]]; then
echo > /dev/null
else
iplimit=$(cat /etc/lunatic/limit/trojan/ip/${akun})
jum2=$(cat /tmp/iptrojan.txt | wc -l)
byte=$(cat /etc/lunatic/limit/trojan/quota/${akun})
lim=$(con ${byte})
wey=$(cat /etc/lunatic/limit/trojan/quota/${akun})
gb=$(con ${wey})
lastlogin=$(cat /var/log/xray/accesstro.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 2 | tail -1)


printf "%-10s %-10s %-10s %-20s\n" " ${akun}" "${gb}/${lim}" "${iplimit}IP/${jum2}IP"

fi 
rm -rf /tmp/iptrojan.txt
done
rm -rf /tmp/other.txt
echo ""
