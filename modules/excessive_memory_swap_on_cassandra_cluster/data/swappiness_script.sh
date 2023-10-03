

#!/bin/bash



# Set the desired swappiness value

SWAPPINESS=${DESIRED_SWAPPINESS_VALUE}



# Check if the current swappiness value is different from the desired value

if [ $(cat /proc/sys/vm/swappiness) -ne $SWAPPINESS ]; then

  # Update the swappiness value

  echo $SWAPPINESS | sudo tee /proc/sys/vm/swappiness



  # Update the sysctl.conf file to make the changes persistent across reboots

  echo "vm.swappiness = $SWAPPINESS" | sudo tee -a /etc/sysctl.conf



  # Apply the new swappiness value

  sudo sysctl -p

fi