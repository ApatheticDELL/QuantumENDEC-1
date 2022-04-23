#!/bin/bash
echo "The packages required for the Quantum ENDEC will install automatically in 5 seconds..."
echo "Tho, you may need to input your sudo password"
sleep 5
echo "The code will preform an APT update, press ENTER to continue."
read
sudo apt update
echo "The code will now install the required packages..."
sudo apt-get install ffmpeg curl flite minimodem alsa-utils libttspico-utils inotify-tools -y
sudo apt install imagemagick gmt figlet
sudo apt install python python3 python3-pip
echo "It has been done, if no errors, your ENDEC should be good to go!"
echo "If this is your first time running, you may have to run setup.sh if you didn't already do so."
sleep 5
exit 0
