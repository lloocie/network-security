#!/bin/bash

# Stop the script if a command fails.
set -e

# Create the message to send.
echo "Hello from sender" > /tmp/message.txt

# Start the receiver in the background and save incoming data.
ip netns exec receiver nc -l 5000 > /tmp/received.txt &
receiver_pid=$!

# Give the receiver time to start listening.
sleep 1

# Send the message; -N closes the connection after the file is sent.
ip netns exec sender nc -N 10.0.0.2 5000 < /tmp/message.txt

# Wait for the receiver to finish writing the file.
wait "$receiver_pid"

# Display the complete received message.
cat /tmp/received.txt