#!/bin/bash

set -e

# Download ngrok script
curl -sLkO https://github.com/kmille36/Docker-Ubuntu-Desktop-NoMachine/raw/main/ngrok.sh

# Make ngrok script executable
chmod +x ngrok.sh

# Authenticate ngrok
clear
printf "Go to: https://dashboard.ngrok.com/get-started/your-authtoken\n"
read -rp "Paste Ngrok Authtoken: " ngrok_token
./ngrok.sh authtoken "${ngrok_token}"

# Choose ngrok region
clear
printf "Choose ngrok region for better connection:\n"
printf "us - United States (Ohio)\n"
printf "eu - Europe (Frankfurt)\n"
printf "ap - Asia/Pacific (Singapore)\n"
printf "au - Australia (Sydney)\n"
printf "sa - South America (Sao Paulo)\n"
printf "jp - Japan (Tokyo)\n"
printf "in - India (Mumbai)\n"
read -rp "Choose ngrok region: " ngrok_region
./ngrok.sh tcp --region "${ngrok_region}" 4000 &>/dev/null &

# Check ngrok status
if curl --silent --show-error http://127.0.0.1:4040/api/tunnels >/dev/null 2>&1; then
  printf "Ngrok status: OK\n"
else
  printf "Ngrok Error! Please try again!\n" && sleep 1
  exec "$0"
fi

# Run Docker container
docker run --rm -d --network host --privileged --name nomachine-xfce4 \
  -e PASSWORD=123456 -e USER=user --cap-add=SYS_PTRACE --shm-size=1g \
  thuonghai2711/nomachine-ubuntu-desktop:windows10

# Display NoMachine information
clear
printf "NoMachine: https://www.nomachine.com/download\n"
printf "Done! NoMachine Information:\n"
printf "IP Address: "
curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p'
printf "User: user\n"
printf "Password: 123456\n"
printf "VM can't connect? Restart Cloud Shell then Re-run script.\n"

# Countdown timer
printf "Running "
for i in {43200..1}; do
  printf "."
  sleep 0.1
done
printf "\n"
