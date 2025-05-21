#!/bin/bash

if ! command -v eyewitness &> /dev/null; then
    echo "Eyewitness not found. Installing..."
    sudo apt-get update -y && sudo apt-get install -y eyewitness
    if [ $? -ne 0 ]; then
        echo "Failed to install eyewitness. Exiting."
        exit 1
    fi
fi

if ! command -v masscan &> /dev/null; then
    echo "Error: masscan not found. Please install it (e.g., 'sudo apt-get install masscan')."
    exit 1
fi

read -p "Enter the path to the file containing IP ranges: " IP_FILE

if [ ! -f "$IP_FILE" ]; then
    echo "Error: File not found: $IP_FILE"
    exit 1
fi

PORTS="80,443,8080,8000,8443,8081,591,82,8880,8008"
TMP_OUTPUT=$(mktemp)

echo "Scanning for live hosts on ports: $PORTS..."
sudo masscan -p"$PORTS" --rate=1000 -iL "$IP_FILE" > "$TMP_OUTPUT"
if [ $? -ne 0 ]; then
    echo "Error: masscan failed. Check permissions or input file."
    rm "$TMP_OUTPUT"
    exit 1
fi

awk '/Discovered open port/ {gsub(/[()]/, "", $6); print $6}' "$TMP_OUTPUT" | sort -u > live_hosts.txt
rm "$TMP_OUTPUT"
if [ ! -s live_hosts.txt ]; then
    echo "No live hosts found. Exiting."
    exit 0
fi

echo "Found $(wc -l < live_hosts.txt) live hosts. Saved to live_hosts.txt:"
cat live_hosts.txt
echo "Running EyeWitness on live hosts..."
eyewitness --web -f live_hosts.txt --timeout 10 --threads 5 --no-prompt -d eyewitness_report
if [ $? -ne 0 ]; then
    echo "Error: EyeWitness failed. Check live_hosts.txt or eyewitness setup."
    exit 1
fi

echo "Done! Check the report in ./eyewitness_report"
