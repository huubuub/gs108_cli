#!/bin/bash

# set your data here
myPass="$2"
myIp="$1"

portOffset="4"
statusOffset="7"
speedOffset="10"
linkedSpeedOffset="13"
flowControlOffset="16"

# login and grab a cookie
out="$(curl -s -c koekjes --data "password=${myPass}" http://${myIp}/login.cgi)"

# get the info page 
myData="$(curl -s -b koekjes http://${myIp}/switch_info.cgi)"
myPortData="$(curl -s -b koekjes http://${myIp}/status.htm)"
myStatData="$(curl -s -b koekjes http://${myIp}/port_statistics.htm)"

# extract the hash
myHash="$(echo "${myData}" | grep hash | sed 's/.*value=.\([0-9][0-9]*\).*/\1/')"
myPortHash="$(echo "${myData}" | grep hash | sed 's/.*value=.\([0-9][0-9]*\).*/\1/')"

# display usage info
if [ "$1" = "" ] || [ "$1" = "--help" ] || [ "$3" = "--help" ]; then
  echo "Usage: $0 <ip addr switch> <pw switch> --command"
  echo "--getProduct              get the product name"
  echo "--getBootloader           get the bootloader version"
  echo "--getMac                  get the mac address"
  echo "--getFirmware             get the firmware version"
  echo "--getSerial               get the serial number"
  echo "--getIp                   get the ipv4 address"
  echo "--getGateway              get the ipv4 gateway address"
  echo "--getSubnet               get the ipv4 subnet"
  echo "--getName                 get the name"
  echo "--getDhcp                 get the Dhcp status (1=on, 0=off)"
  echo "--getPortstatus           get the status of the specified port (--getPort <port>)"
  echo "--getPortSpeed            get the speed of the specified port (--getPortSpeed <port>)"
  echo "--getPortLinkedSpeed      get the speed of the device linked to the specified port (--getPortLinkedSpeed <port>)"
  echo "--getPortFlowControl      get the status of flowcontrol on the specified port (--getPortFlowcontrol <port>)"
  echo "--getPortPacketsRecieved  get the amount of packets received on this port (--getPortPacketsRecieved <port>)" 
  echo "--getPortPacketsError     get the amount of errors on this port (--getPortPacketsError <port>)"
  echo "--getPortPacketsSent      get the amount of packets sent on thisport (--getPortPacketsSent <port>)"
  echo "--getJSON                 JSON formatted output of all data"
  echo "--reboot                  reboot the device"
  echo "--resetPassword           reset the password for the device --resetPassword <newpass>"
  echo "--resetStatistics         reset the statistics counters"
  echo "--setPortFlowControl      set the status of flowcontrol on the specified port (--setPortFlowcontrol <port> <enabled/disabled>)"
  echo "--setGateway              set the gatewayaddress (only if dhcp is disabled)"
  echo "--setDhcp                 set dhcp to on (--setdhcp 1) or to off (--setdhcp <ipaddress> <gateway> <netmask>)" 
  echo "--setName                 set the name of the switch"
  echo "--setIp                   set the ip address (only if dhcp is disabled)"
  echo "--setPortSpeed            set the speed of the specified port (--setPortSpeed <port> <auto/disable/10Mhalf/10Mfull/100Mhalf/100Mfull>)"
  echo "--setNetmask              set the netmask (only if dhcp is disabled)"
  echo "--help                    display this help"
  exit
fi

# parse info page
myProduct="$(echo "${myData}"    | grep -A1 Product | tail -n 1 | sed 's/.*align=.center.>\([^<][^<]*\).*/\1/')"
myBootloader="$(echo "${myData}" | grep -A1 Bootloader | tail -n 1 | sed 's/.*align=.center.>\([^<][^<]*\).*/\1/')"
myMac="$(echo "${myData}"        | grep -A1 MAC | tail -n 1 | sed 's/.*align=.center.>\([^<][^<]*\).*/\1/')"
myFirmware="$(echo "${myData}"   | grep -A1 Firmware | tail -n 1 | sed 's/.*align=.center.>\([^<][^<]*\).*/\1/')"
mySerial="$(echo "${myData}"     | grep -A1 Serial | tail -n 1 | sed 's/.*align=.center.>\([^<][^<]*\).*/\1/')"
myIp="$(echo "${myData}"         | grep 'id=.ip_address' | sed 's/.*value=.\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/')"
myGateway="$(echo "${myData}"    | grep 'id=.gateway_address' | sed 's/.*value=.\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/')"
mySubnet="$(echo "${myData}"     | grep 'id=.subnet_mask' | sed 's/.*value=.\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/')"
myName="$(echo "${myData}"       | grep -A1 Switch | tail -n 1 | sed "s/.*value=.\([^'][^']*\).*/\1/")"
myDhcp="$(echo "${myData}"       | grep 'id=.dhcp_mode' | sed 's/.*value=.\([0-9]\).*/\1/')"
myPorts="$(echo ${myPortData}    | sed "s/>/>\n/g" | grep 'name="port' | tail -n 1 | sed 's/.*name="port\([0-9]*\).*/\1/')";

#execute commands
case "$3" in
  --getProduct) echo $myProduct; exit ;;
  --getBootloader) echo $myBootloader; exit ;;
  --getMac) echo $myMac; exit ;;
  --getFirmware) echo $myFirmware ; exit ;;
  --getSerial) echo $mySerial; exit ;;
  --getIp) echo $myIp; exit ;;
  --getGateway) echo $myGateway; exit ;;
  --getSubnet) echo $mySubnet; exit ;;
  --getName) echo $myName; exit ;;
  --getDhcp) echo $myDhcp; exit ;;
  --getJSON) # dump data in JSON format
    echo '{';
    echo '  "product": '${myProduct},;
    echo '  "bootloader": '${myBootloader},;
    echo '  "mac": '${myMac},;
    echo '  "firmware": '${myFirmware},;
    echo '  "serial": '${mySerial},;
    echo '  "ip": '${myIp},;
    echo '  "gateway": '${myGateway},;
    echo '  "subnet": '${mySubnet},;
    echo '  "name": '${myName},;
    echo '  "dhcp": '${myDhcp},;
    counter=1 ;
    while [ $counter -le $myPorts ]
    do
      myPort=port$counter ;
      myStatus="$(echo ${myPortData} | sed "s/>/>\n/g" | grep "${myPort}" -A18 | head -n "${statusOffset}" | tail -n 1 | sed 's/^\([^<]*\) <.*/\1/')"
      mySpeed="$(echo ${myPortData} | sed "s/>/>\n/g" | grep "${myPort}" -A18 | head -n "${speedOffset}" | tail -n 1 | sed 's/^\([^<]*\) <.*/\1/')"
      myLinked="$(echo ${myPortData} | sed "s/>/>\n/g" | grep "${myPort}" -A18 | head -n "${linkedSpeedOffset}" | tail -n 1 | sed 's/^\([^<]*\) <.*/\1/')"
      myFlow="$(echo ${myPortData} | sed "s/>/>\n/g" | grep "${myPort}" -A18 | head -n "${flowControlOffset}" | tail -n 1 | sed 's/^\([^<]*\) <.*/\1/')"
      myRecv="$(echo ${myStatData} | sed "s/>/>\n/g" | grep "^${counter}" -A11 | grep txpkt | sed 's/.*value=.\([0123456789ABCDEF][0123456789ABCDEF]*\).>/\1/')";
      mySent="$(echo ${myStatData} | sed "s/>/>\n/g" | grep "^${counter}" -A11 | grep rxPkt | sed 's/.*value=.\([0123456789ABCDEF][0123456789ABCDEF]*\).>/\1/')";
      myErrs="$(echo ${myStatData} | sed "s/>/>\n/g" | grep "^${counter}" -A11 | grep crcPkt | sed 's/.*value=.\([0123456789ABCDEF][0123456789ABCDEF]*\).>/\1/')";
      myRecvDec="$(echo $((16#$myRecv)))"
      mySentDec="$(echo $((16#$mySent)))"
      myErrsDec="$(echo $((16#$myErrs)))"
      echo '  "portstatus_'$myPort'": '${myStatus},;
      echo '  "portspeed_'$myPort'": '${mySpeed},;
      echo '  "linkedspeed_'$myPort'": '${myLinked},;
      echo '  "flowcontrol_'$myPort'": '${myFlow},;
      echo '  "rxPackets_'$myPort'": '${myRecvDec},;
      echo '  "txPackets_'$myPort'": '${mySentDec},;
      echo '  "crcPackets_'$myPort'": '${myErrsdec},;
      ((counter++)) ;
    done ;
    echo '  "numberPorts": '${myPorts};
    echo '}';
    exit ;; 
  --setDhcp) #set dhcp on or off
    newDhcp=$4;
    if [ "$newDhcp" -eq 0 ]; then
      newIp=$5;
      newGateway=$6;
      newNetmask=$7;
      stat="$(curl -s -b koekjes --data "switch_name=${myName}&dhcpmode=${newDhcp}&dhcp_mode=${myDhcp}&ip_address=${newIp}&subnet_mask=${newNetmask}&gateway_address=${newGateway}&hash=${myHash}" http://${myIp}/switch_info.cgi)";
    else
      stat="$(curl -s -b koekjes --data "switch_name=${myName}&dhcpmode=${newDhcp}&dhcp_mode=${myDhcp}&hash=${myHash}" http://${myIp}/switch_info.cgi)";
    fi;
    exit ;;
  --setName) #set name
    newName=$4;
    if [ "$myDhcp" -eq 1 ]; then
      stat="$(curl -s -b koekjes --data "switch_name=${newName}&dhcpmode=${myDhcp}&dhcp_mode=${myDhcp}&hash=${myHash}" http://${myIp}/switch_info.cgi)";
    else
      stat="$(curl -s -b koekjes --data "switch_name=${newName}&dhcpmode=${myDhcp}&dhcp_mode=${myDhcp}&ip_address=${myIp}&subnet_mask=${myNetmask}&gateway_address=${myGateway}&hash=${myHash}" http://${myIp}/switch_info.cgi)";
    fi;
    exit ;;
  --setIp) #set ipaddress
    if [ "$myDhcp" -eq 0 ]; then
      echo "First enable dhcp";
    else
      newIp=$4;
      stat="$(curl -s -b koekjes --data "switch_name=${myName}&dhcpmode=${myDhcp}&dhcp_mode=${myDhcp}&ip_address=${newIp}&subnet_mask=${myNetmask}&gateway_address=${myGateway}&hash=${myHash}" http://${myIp}/switch_info.cgi)";
    fi;
    exit ;;
  --setNetmask) #set netmask
    if [ "$myDhcp" -eq 0 ]; then
      echo "First enable dhcp";
    else
      newNetmask=$4;
      stat="$(curl -s -b koekjes --data "switch_name=${myName}&dhcpmode=${myDhcp}&dhcp_mode=${myDhcp}&ip_address=${myIp}&subnet_mask=${newNetmask}&gateway_address=${myGateway}&hash=${myHash}" http://${myIp}/switch_info.cgi)";
    fi;
    exit ;;
  --setGateway) #set gateway
    if [ "$myDhcp" -eq 0 ]; then
      echo "First enable dhcp";
    else
      newGateway=$4;
      stat="$(curl -s -b koekjes --data "switch_name=${myName}&dhcpmode=${myDhcp}&dhcp_mode=${myDhcp}&ip_address=${myIp}&subnet_mask=${myNetmask}&gateway_address=${newGateway}&hash=${myHash}" http://${myIp}/switch_info.cgi)";
    fi;
    exit ;;
  --refreshLease) #refresh the dhcp lease
    if [ "$myDhcp" -eq 0 ]; then
      echo "First enable dhcp";
    else
      stat="$(curl -s -b koekjes --data "switch_name=${myName}&dhcpmode=${myDhcp}&dhcp_mode=${myDhcp}&refresh=1&hash=${myHash}" http://${myIp}/switch_info.cgi)";
    fi;
    exit ;;
  --getPortStatus)
    if [ "$4" -gt "$myPorts" ]; then
      echo "Only $myPorts ports present" ;
    else
      myPort=port$4;
      myStatus="$(echo ${myPortData} | sed "s/>/>\n/g" | grep "${myPort}" -A18 | head -n "${statusOffset}" | tail -n 1 | sed 's/^\([^<]*\) <.*/\1/')"
      echo $myStatus
    fi;
    exit ;;
  --getPortSpeed)
    if [ "$4" -gt "$myPorts" ]; then
      echo "Only $myPorts ports present" ;
    else
      myPort=port$4;
      mySpeed="$(echo ${myPortData} | sed "s/>/>\n/g" | grep "${myPort}" -A18 | head -n "${speedOffset}" | tail -n 1 | sed 's/^\([^<]*\) <.*/\1/')"
      echo $mySpeed
    fi;
    exit ;;
  --getPortLinkedSpeed)
    if [ "$4" -gt "$myPorts" ]; then
      echo "Only $myPorts ports present" ;
    else
      myPort=port$4;
      myLinked="$(echo ${myPortData} | sed "s/>/>\n/g" | grep "${myPort}" -A18 | head -n "${linkedSpeedOffset}" | tail -n 1 | sed 's/^\([^<]*\) <.*/\1/')"
      echo $myLinked
    fi;
    exit ;;
  --getPortFlowControl)
    if [ "$4" -gt "$myPorts" ]; then
      echo "Only $myPorts ports present" ;
    else
      myPort=port$4;
      myFlow="$(echo ${myPortData} | sed "s/>/>\n/g" | grep "${myPort}" -A18 | head -n "${flowControlOffset}" | tail -n 1 | sed 's/^\([^<]*\) <.*/\1/')"
      echo $myFlow
    fi;
    exit ;;
  --getNumberOfPorts)
    echo $myPorts;
    exit ;;
  --setPortFlowControl)
    if [ "$4" -gt "$myPorts" ]; then
      echo "Only $myPorts ports present" ;
    else
      myPort=port$4;
      if [ "$5" = "disable" ]; then
        newFlow=2;
      else
        newFlow=1;
      fi;
      mySpeed="$(echo ${myPortData} | sed "s/>/>\n/g" | grep "${myPort}" -A18 | head -n "${speedOffset}" | tail -n 1 | sed 's/^\([^<]*\) <.*/\1/')";
      stat="$(curl -s -b koekjes --data "SPEED=${mySpeed}&FLOWCONTROL=${newFlow}&$myPorte=checked&hash=${myHash}" http://${myIp}/status.cgi)";
    fi;
    exit ;;
  --setPortSpeed)
    if [ "$4" -gt "$myPorts" ]; then
      echo "Only $myPorts ports present" ;
    else
      myPort=port$4;
      case "$5" in
        auto) newSpeed=1 ;;
        disable) newSpeed=2 ;;
        10Mhalf) newSpeed=3 ;;
        10Mfull) newSpeed=4 ;;
        100Mhalf) newSpeed=5 ;;
        100Mfull) newSpeed=6 ;;
      esac;
      myFlow="$(echo ${myPortData} | sed "s/>/>\n/g" | grep "${myPort}" -A18 | head -n "${flowControlOffset}" | tail -n 1 | sed 's/^\([^<]*\) <.*/\1/')"
      stat="$(curl -s -b koekjes --data "SPEED=${newSpeed}&FLOWCONTROL=${myFlow}&${myPort}=checked&hash=${myHash}" http://${myIp}/status.cgi)";
    fi;
    exit ;;
  --reboot)
    stat="$(curl -s -b koekjes --data "CBox=on&hash=${myHash}" http://${myIp}/device_reboot.cgi)";
    exit ;;
  --resetPassword)
    newPass=$4 ;
    stat="$(curl -s -b koekjes --data "oldPassword=${myPass}&newPassword=${newPass}&hash=${myHash}" http://${myIp}/user.cgi)";
    exit ;;
  --getPortPacketsRecieved)
    if [ "$4" -gt "$myPorts" ]; then
      echo "Only $myPorts ports present" ;
    else
      myRecv="$(echo ${myStatData} | sed "s/>/>\n/g" | grep "^$4" -A11 | grep txpkt | sed 's/.*value=.\([0123456789ABCDEF][0123456789ABCDEF]*\).>/\1/')";
      myRecvDec="$(echo $((16#$myRecv)))"
      echo $myRecvDec;
    fi;
    exit ;;
  --getPortPacketsSent)
    if [ "$4" -gt "$myPorts" ]; then
      echo "Only $myPorts ports present" ;
    else
      mySent="$(echo ${myStatData} | sed "s/>/>\n/g" | grep "^$4" -A11 | grep rxPkt | sed 's/.*value=.\([0123456789ABCDEF][0123456789ABCDEF]*\).>/\1/')";
      mySentDec="$(echo $((16#$mySent)))"
      echo $mySentDec;
    fi;
    exit ;;
  --getPortPacketsError)
    if [ "$4" -gt "$myPorts" ]; then
      echo "Only $myPorts ports present" ;
    else
      myErrs="$(echo ${myStatData} | sed "s/>/>\n/g" | grep "^$4" -A11 | grep crcPkt | sed 's/.*value=.\([0123456789ABCDEF][0123456789ABCDEF]*\).>/\1/')";
      myErrsDec="$(echo $((16#$myErrs)))"
      echo $myErrsDec;
    fi;
    exit ;;
  --resetStatistics)
    stat="$(curl -s -b koekjes --data "clearCounters=&hash=${myHash}" http://${myIp}/portStatistics.cgi)";
    exit ;;

esac

