Simple bash command line utility to manage the Netgear GS108E_v3 switch (and possibly others, this one is mine). Depends on curl to manage the switch over it's web server. Only the basic functions are implemneted but the code should contain enough examples of command implementations to make implementing the rest straightforward.
In general open the web interface in chrome and enable the developer tab. with the network tab open execute the POST request you want to implement, this is usually the request going to a .cgi file. Open this request and scroll down to the data fields. This should give you enough information to implement the missing command.


Usage: ./gs108_cli.sh <ip addr switch> <pw switch> --command
--getProduct              get the product name
--getBootloader           get the bootloader version
--getMac                  get the mac address
--getFirmware             get the firmware version
--getSerial               get the serial number
--getIp                   get the ipv4 address
--getGateway              get the ipv4 gateway address
--getSubnet               get the ipv4 subnet
--getName                 get the name
--getDhcp                 get the Dhcp status (1=on, 0=off)
--getPortstatus           get the status of the specified port (--getPort <port>)
--getPortSpeed            get the speed of the specified port (--getPortSpeed <port>)
--getPortLinkedSpeed      get the speed of the device linked to the specified port (--getPortLinkedSpeed <port>)
--getPortFlowControl      get the status of flowcontrol on the specified port (--getPortFlowcontrol <port>)
--getPortPacketsRecieved  get the amount of packets received on this port (--getPortPacketsRecieved <port>)
--getPortPacketsError     get the amount of errors on this port (--getPortPacketsError <port>)
--getPortPacketsSent      get the amount of packets sent on thisport (--getPortPacketsSent <port>)
--getJSON                 JSON formatted output of all data
--reboot                  reboot the device
--resetPassword           reset the password for the device --resetPassword <newpass>
--resetStatistics         reset the statistics counters
--setPortFlowControl      set the status of flowcontrol on the specified port (--setPortFlowcontrol <port> <enabled/disabled>)
--setGateway              set the gatewayaddress (only if dhcp is disabled)
--setDhcp                 set dhcp to on (--setdhcp 1) or to off (--setdhcp <ipaddress> <gateway> <netmask>)
--setName                 set the name of the switch
--setIp                   set the ip address (only if dhcp is disabled)
--setPortSpeed            set the speed of the specified port (--setPortSpeed <port> <auto/disable/10Mhalf/10Mfull/100Mhalf/100Mfull>)
--setNetmask              set the netmask (only if dhcp is disabled)
--help                    display this help

