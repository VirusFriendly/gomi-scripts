#!/bin/bash
# Linux Bash Ncat Honeyport with IPTables and Dome9 support (v0.1)
# By Sebastien Jeanquier (@securitygen)
# Security Generation - http://www.securitygeneration.com
# Requires: lsof, ncat, curl, iptables
# ----------------------------------------------------------
# The above is the orginal author of this script.
# However this was designed to firewall.
# I wanted to set my system to record and adapted it for use with
# portspoof
#
# <eric.gragsone@erisresearch.org>
# ----------------------------------------------------------
#
# Configuration
#
PORT=23; # Set your port number
HPORT=4444; # Set the port for your Honeypot
METHOD='IPTABLES'; # Blacklist using IPTABLES (requires root) or DOME9
DOMEUSER='user@email.com'; # Your Dome9 username (eg. user@email.com)
DOMEAPI='apikey'; # Your Dome9 API key (https://secure.dome9.com/settings under API Key)
WHITELIST=( "123.2.3.5" "123.2.3.4" ); # Whitelisted IPs eg. ( "1.1.1.1" "123.2.3.4" );
# ----------------------------------------------------------
 
# Ensure a valid blacklist METHOD is set
if [ "${METHOD}" != "IPTABLES" ] && [ "${METHOD}" != "DOME9" ]; then
    echo "[-] Invalid METHOD. Enter IPTABLES or DOME9.";
# Ensure we are root if IPtables is chosen
elif [ "${METHOD}" == "IPTABLES" ] && [[ $EUID -ne 0 ]]; then
    echo "[-] Using method IPtables requires root."
else
    # Check PORT is not in use
    RUNNING=`/usr/bin/lsof -i :${PORT}`;
    if [ -n "$RUNNING" ]; then
        echo "Port $PORT is already in use. Aborting.";
        #echo $RUNNING; # Optional for debugging
        exit;
    else
        echo "[+] Starting Honeyport listener on port $PORT. Waiting for the bees..."    
        while [ -z "$RUNNING" ] 
            do
                # Run Ncat listener on PORT. Run response.sh when a client connects. Grep client's IP.    
#                IP=`/usr/bin/ncat -v -l -p ${PORT} -e ./response.sh 2>&1 1> /dev/null | grep from | egrep '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:' | awk {'print $4'} | cut -d: -f1`;    
		IP=`/usr/bin/ncat -v -l -p ${PORT} --send-only < response.txt 2>&1 1> /dev/null | grep from | egrep '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| awk {'print $4'} | cut -d. -f1,2,3,4`;
 
                # Check IP isn't whitelisted
                WHITELISTED=false;
                for i in "${WHITELIST[@]}"
                do
                    if [ "${IP}" == $i ]; then
                        echo "[!] Hit from whitelisted IP: ${i} - `date`" | tee -a ~/honeyport_log.txt;
                        WHITELISTED=true;
                    fi
                done
 
                # If IP is not blank or localhost or whitelisted, blacklist the IP using IPtables or Dome9 and log.
                if [ "${IP}" != "" ] && [ "${IP}" != "127.0.0.1" ] && [ "${WHITELISTED}" != true ]; then
                    if [ "${METHOD}" == "IPTABLES" ]; then
                        #/sbin/iptables -A INPUT -p all -s ${IP} -j DROP; 
			/sbin/iptables -t nat -A PREROUTING -p tcp -s ${IP} -j REDIRECT --to-ports ${HPORT};
                        echo "[+] Blacklisting: ${IP} with IPtables - `date`" | tee -a ~/honeyport_log.txt;
                    elif [ "${METHOD}" == "DOME9" ]; then
                        /usr/bin/curl -H "Accept: application/json" -u ${DOMEUSER}:${DOMEAPI} -X "POST" -d "IP=$IP&Comment=Honeyport $PORT - `date`" --silent https://api.dome9.com/v1/blacklist/Items/ > /dev/null 2>&1;
                        echo "[+] Blacklisting: ${IP} with Dome9 - `date`" | tee -a ~/honeyport_log.txt;
                    fi;
                fi;
                RUNNING=`/usr/bin/lsof -i :${PORT}`;
            done;
    fi;
fi;
