#!/bin/bash

# Check if eyewitness is installed
if ! command -v eyewitness &> /dev/null; then
    echo "Eyewitness not found. Installing..."
    sudo apt-get update -y && sudo apt-get install -y eyewitness
    if [ $? -ne 0 ]; then
        echo "Failed to install eyewitness. Exiting."
        exit 1
    fi
fi

# Check if masscan is installed
if ! command -v masscan &> /dev/null; then
    echo "Error: masscan not found. Please install it (e.g., 'sudo apt-get install masscan')."
    exit 1
fi

# Prompt for IP range file
read -p "Enter the path to the file containing IP ranges: " IP_FILE

# Validate file exists
if [ ! -f "$IP_FILE" ]; then
    echo "Error: File not found: $IP_FILE"
    exit 1
fi

# Define ports to scan
PORTS="80,443,8080,8000,8443,8081,591,82,8880,8008,8081"

# Scan for live hosts
echo "Scanning for live hosts on ports: $PORTS..."
sudo masscan -p "$PORTS" --rate=1000 -iL "$IP_FILE" -oG masscan_output.txt
if [ $? -ne 0 ]; then
    echo "Error: masscan failed. Check permissions or input file."
    exit 1
fi

# Extract live IPs with ports
awk '/Host:/ {split($4, port, "/"); print $2 ":" port[1]}' masscan_output.txt | sort -u | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$' > live_hosts.txt
if [ ! -s live_hosts.txt ]; then
    echo "No live hosts found. Exiting."
    rm masscan_output.txt
    exit 0
fi

echo "Found $(wc -l < live_hosts.txt) live hosts. Saved to live_hosts.txt:"
cat live_hosts.txt

# Run eyewitness
echo "Running EyeWitness on live hosts..."
eyewitness --web -f live_hosts.txt --timeout 10 --threads 5 --no-prompt -d eyewitness_report
if [ $? -ne 0 ]; then
    echo "Error: EyeWitness failed. Check live_hosts.txt or eyewitness setup."
    exit 1
fi

# Clean up
rm masscan_output.txt

echo "Done! Check the report in ./eyewitness_report"
