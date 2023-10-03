
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Excessive Memory Swap on Cassandra Cluster
---

Excessive Memory Swap on Cassandra Cluster refers to an incident where the Cassandra database cluster is experiencing high levels of swapping between physical memory and disk space due to the unavailability of enough physical memory. This can lead to degraded performance and unresponsiveness of the database cluster, causing disruptions to the application or service that relies on it. This type of incident requires immediate attention from the operations team to identify the root cause and take necessary measures to mitigate the issue.

### Parameters
```shell
export PID="PLACEHOLDER"

export SERVER_IP="PLACEHOLDER"

export MEMORY_SIZE="PLACEHOLDER"

export NEW_MEMORY="PLACEHOLDER"

export MAX_QUERIES="PLACEHOLDER"

export MAX_MEMORY="PLACEHOLDER"

export DESIRED_SWAPPINESS_VALUE="PLACEHOLDER"
```

## Debug

### Check total available memory
```shell
free -m
```

### Check the swap space utilization
```shell
swapon -s
```

### Display the process that consumes the most memory
```shell
ps -eo %mem,%cpu,cmd --sort=-%mem | head -n 10
```

### Display the processes that are using swap space
```shell
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n | less
```

### Check the amount of swap space used by each process
```shell
pmap -x ${PID} | grep -i swap
```

### Check the amount of memory used by each process
```shell
pmap -x ${PID} | grep total
```

### Identify the processes that are causing excessive memory swapping
```shell
sudo atop -M | grep SWP | sort -k 8nr | head -n 10
```

### Check if the swappiness value is set correctly
```shell
cat /proc/sys/vm/swappiness
```

### Check the value of dirty_ratio and dirty_background_ratio
```shell
sudo cat /proc/sys/vm/dirty_ratio

sudo cat /proc/sys/vm/dirty_background_ratio
```

### Check the current value of vm.dirty_bytes
```shell
sudo cat /proc/sys/vm/dirty_bytes
```

### Check if Transparent Huge Pages (THP) is enabled
```shell
cat /sys/kernel/mm/transparent_hugepage/enabled
```

### Check the status of the Cassandra service
```shell
sudo systemctl status cassandra.service
```

## Repair

### Upgrade the physical memory of the servers in the Cassandra cluster to provide more space for data to reside in memory rather than needing to swap to disk.
```shell
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


```

### Tune the Cassandra configuration to reduce memory consumption, for example, by limiting the number of concurrent queries or reducing the size of data kept in memory.
```shell


#!/bin/bash



# set the maximum number of concurrent queries

MAX_QUERIES=${MAX_QUERIES}



# set the maximum size of data kept in memory

MAX_MEMORY=${MAX_MEMORY}



# update the Cassandra configuration file to include the new settings

echo "max_concurrent_queries = $MAX_QUERIES" >> /etc/cassandra/cassandra.yaml

echo "max_memory_size = $MAX_MEMORY" >> /etc/cassandra/cassandra.yaml



# restart the Cassandra service to apply the changes

service cassandra restart



# verify that the changes were applied successfully

cqlsh -e "DESCRIBE CONFIG;"


```

### Adjust the swapping configuration of the operating system to prevent it from swapping too aggressively.
```shell


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


```