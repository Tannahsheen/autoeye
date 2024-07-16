#!/bin/bash
if ! command -v eyewitness &> /dev/null
then
    echo "Eyewitness could not be found, installing now..."
    sudo apt-get install eyewitness -y
fi

read -p "Enter the path to the file containing IP ranges: " IP_FILE

if [ ! -f "$IP_FILE" ]; then
    echo "File not found: $IP_FILE"
    exit 1
fi

TARGET_IP_RANGE=$(cat $IP_FILE)

PORTS="80,443,8080,8000,8443,8081,591,82,8880,8008,8081"

sudo masscan -p $PORTS $TARGET_IP_RANGE --rate=1000 -oG - | awk '/Host:/ {print $4}' > live_hosts.txt

echo "Live IP addresses saved to live_hosts.txt"

eyewitness --web -f live_hosts.txt
