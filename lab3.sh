#!/bin/bash

# Initialize variables
VERBOSE_MODE=""

# Parse command-line arguments for verbose mode
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -verbose) VERBOSE_MODE="-verbose" ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Server details
SERVER1="remoteadmin@server1-mgmt"
SERVER2="remoteadmin@server2-mgmt"

# Configuration details
SERVER1_NAME="loghost"
SERVER1_IP="192.168.16.3"
SERVER2_NAME="webhost"
SERVER2_IP="192.168.16.4"

# Deploy and execute on Server 1
scp configure-host.sh $SERVER1:/root
if [ $? -ne 0 ]; then echo "SCP to $SERVER1 failed"; exit 1; fi

ssh $SERVER1 "bash /root/configure-host.sh $VERBOSE_MODE -name $SERVER1_NAME -ip $SERVER1_IP -hostentry $SERVER2_NAME $SERVER2_IP"
if [ $? -ne 0 ]; then echo "SSH command on $SERVER1 failed"; exit 1; fi

# Deploy and execute on Server 2
scp configure-host.sh $SERVER2:/root
if [ $? -ne 0 ]; then echo "SCP to $SERVER2 failed"; exit 1; fi

ssh $SERVER2 "bash /root/configure-host.sh $VERBOSE_MODE -name $SERVER2_NAME -ip $SERVER2_IP -hostentry $SERVER1_NAME $SERVER1_IP"
if [ $? -ne 0 ]; then echo "SSH command on $SERVER2 failed"; exit 1; fi

# Optional: Local configuration for host entries
./configure-host.sh $VERBOSE_MODE -hostentry $SERVER1_NAME $SERVER1_IP
./configure-host.sh $VERBOSE_MODE -hostentry $SERVER2_NAME $SERVER2_IP
