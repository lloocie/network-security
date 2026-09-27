#!/bin/bash

# Stop the script immediately if a command fails.
set -e

# Create a test message to send through the virtual network.
printf '%s\n' "Hello from sender" | sudo tee /tmp/message.txt > /dev/null

# Start Netcat inside the receiver namespace and save incoming data.
# The ampersand runs the receiver in the background so this script can continue.
sudo ip netns exec receiver sh -c 'nc -l 5000 > /tmp/received.txt' &
receiver_pid=$!

# Give the receiver a moment to begin listening on port 5000.
sleep 1

# Send the message from the sender namespace to the receiver's IP address.
sudo ip netns exec sender sh -c 'nc 10.0.0.2 5000 < /tmp/message.txt'

# Wait for the receiver process to finish writing the received file.
wait "$receiver_pid"

# Display the received message so the transfer can be checked.
cat /tmp/received.txt
