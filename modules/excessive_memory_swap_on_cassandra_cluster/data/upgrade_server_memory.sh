bash

#!/bin/bash



# Set variables

SERVER_IP=${SERVER_IP}

MEMORY_SIZE=${MEMORY_SIZE}



# Upgrade memory size of the server

ssh user@$SERVER_IP "sudo shutdown -h now"

# Once the server is down, install the new memory

ssh user@$SERVER_IP "sudo apt-get install ${NEW_MEMORY}"

# Turn on the server

ssh user@$SERVER_IP "sudo reboot"



# Verify the new memory size

ssh user@$SERVER_IP "sudo grep MemTotal /proc/meminfo"