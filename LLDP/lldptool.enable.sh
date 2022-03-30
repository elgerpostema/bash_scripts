!#/bin/bash

# Elger Postema
# feb 2019
# enable LLDP on all ports of a Linux host
# Tested on CentOS

for INTERFACE in `ip a | grep -E -o "em[0-9]|p[0-9]p[0-9]|eth[0-9]|eno[0-9]|enp[0-9]s[0-9]f[0-9]"| sort -n | uniq` ;
do
      echo "enabling lldp for interface: $INTERFACE" ;
      lldptool set-lldp -i $INTERFACE adminStatus=rxtx  ;
      lldptool -T -i $INTERFACE -V sysName enableTx=yes;
      lldptool -T -i $INTERFACE -V portDesc enableTx=yes ;
      lldptool -T -i $INTERFACE -V sysDesc enableTx=yes;
      lldptool -T -i $INTERFACE -V sysCap enableTx=yes;
      lldptool -T -i $INTERFACE -V mngAddr enableTx=yes;

done
