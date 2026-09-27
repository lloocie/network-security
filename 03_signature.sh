#!/bin/bash

# Stop the script immediately if a command fails.
set -e

# Generate the sender's private RSA key. Keep this key secret.
openssl genpkey -algorithm RSA -out /tmp/sender_private.pem

# Create the public key that the receiver uses for verification.
openssl rsa -pubout -in /tmp/sender_private.pem -out /tmp/sender_public.pem

# Create and digitally sign the message with SHA-256 and the private key.
printf '%s\n' "Hello from sender" > /tmp/message.txt
openssl dgst -sha256 -sign /tmp/sender_private.pem -out /tmp/signature.bin /tmp/message.txt

# Start the receiver in the background and save the incoming message.
sudo ip netns exec receiver sh -c 'nc -l 5000 > /tmp/received.txt' &
message_receiver_pid=$!
sleep 1

# Send the message through the sender namespace.
sudo ip netns exec sender sh -c 'nc 10.0.0.2 5000 < /tmp/message.txt'
wait "$message_receiver_pid"

# Start another receiver for the binary signature.
sudo ip netns exec receiver sh -c 'nc -l 5001 > /tmp/received_signature.bin' &
signature_receiver_pid=$!
sleep 1

# Send the signature through a separate network port.
sudo ip netns exec sender sh -c 'nc 10.0.0.2 5001 < /tmp/signature.bin'
wait "$signature_receiver_pid"

# Verify that the received message is authentic and unchanged.
openssl dgst -sha256 \
  -verify /tmp/sender_public.pem \
  -signature /tmp/received_signature.bin \
  /tmp/received.txt
