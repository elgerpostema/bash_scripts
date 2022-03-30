#!/bin/bash

# Elger Postema
# feb 2019
# read the LLDP info from the network ports of a Linux host
# tested on CentOS 7

for INTERFACE in `ip a | grep -E -o "em[0-9]|p[0-9]p[0-9]|eth[0-9]|eno[0-9]|enp[0-9]s[0-9]f[0-9]"| sort -n | uniq` ;
do
      echo "---- $INTERFACE ----" ;
      lldptool get-tlv -n -i $INTERFACE | grep -A1 -E "Port ID TLV|Port Description TLV|System Name TLV" | grep -v "\-\-" ;

done
