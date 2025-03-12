#!/bin/bash

echo "Updating package lists..."
sudo apt-get update -y

echo "Installing masscan..."
sudo apt-get install -y masscan

echo "Installing eyewitness and dependencies..."
sudo apt-get install -y eyewitness firefox-esr xvfb python3-pip
sudo pip3 install selenium

echo "Installing geckodriver..."
wget https://github.com/mozilla/geckodriver/releases/download/v0.34.0/geckodriver-v0.34.0-linux64.tar.gz
sudo tar -xzf geckodriver-v0.34.0-linux64.tar.gz -C /usr/local/bin/
rm geckodriver-v0.34.0-linux64.tar.gz

chmod +x autoeye.sh

echo "Installation complete. Run './autoeye.sh' to start."
