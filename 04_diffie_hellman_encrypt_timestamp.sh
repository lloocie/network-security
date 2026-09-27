#!/bin/bash

# Stop the script immediately if a command fails.
set -e

# Script 03 must run first because this script uses its RSA private key.
test -f /tmp/sender_private.pem
test -f /tmp/sender_public.pem

# Generate public Diffie-Hellman parameters.
openssl genpkey -genparam -algorithm DH -out /tmp/dhparam.pem

# Generate sender and receiver Diffie-Hellman key pairs.
openssl genpkey -paramfile /tmp/dhparam.pem -out /tmp/sender_dh_private.pem
openssl pkey -in /tmp/sender_dh_private.pem -pubout -out /tmp/sender_dh_public.pem
openssl genpkey -paramfile /tmp/dhparam.pem -out /tmp/receiver_dh_private.pem
openssl pkey -in /tmp/receiver_dh_private.pem -pubout -out /tmp/receiver_dh_public.pem

# Each side independently derives the same shared secret.
openssl pkeyutl -derive -inkey /tmp/sender_dh_private.pem -peerkey /tmp/receiver_dh_public.pem -out /tmp/sender_shared_secret.bin
openssl pkeyutl -derive -inkey /tmp/receiver_dh_private.pem -peerkey /tmp/sender_dh_public.pem -out /tmp/receiver_shared_secret.bin

# Confirm that both sides derived exactly the same secret.
cmp /tmp/sender_shared_secret.bin /tmp/receiver_shared_secret.bin

# Convert the shared secret into text used as the AES password.
sha256sum /tmp/sender_shared_secret.bin | awk '{print $1}' > /tmp/secret.key

# Add a Unix timestamp so the receiver can detect replayed old messages.
printf '%s\n' "Hello from sender" > /tmp/body.txt
date +%s > /tmp/timestamp.txt
cat /tmp/timestamp.txt /tmp/body.txt > /tmp/message_with_timestamp.txt

# Sign the plaintext timestamped message with the RSA key from script 03.
openssl dgst -sha256 -sign /tmp/sender_private.pem -out /tmp/signature_timestamp.bin /tmp/message_with_timestamp.txt

# Encrypt the timestamped message with AES-256-CBC.
openssl enc -aes-256-cbc -salt -pbkdf2 \
  -in /tmp/message_with_timestamp.txt \
  -out /tmp/encrypted_timestamp_message.bin \
  -pass file:/tmp/secret.key

# Start the encrypted-message receiver in the background.
sudo ip netns exec receiver sh -c 'nc -l 5002 > /tmp/received_encrypted_timestamp_message.bin' &
encrypted_receiver_pid=$!
sleep 1

# Send the encrypted message through the sender namespace.
sudo ip netns exec sender sh -c 'nc 10.0.0.2 5002 < /tmp/encrypted_timestamp_message.bin'
wait "$encrypted_receiver_pid"

# Start the signature receiver in the background.
sudo ip netns exec receiver sh -c 'nc -l 5003 > /tmp/received_signature_timestamp.bin' &
signature_receiver_pid=$!
sleep 1

# Send the signature through a separate port.
sudo ip netns exec sender sh -c 'nc 10.0.0.2 5003 < /tmp/signature_timestamp.bin'
wait "$signature_receiver_pid"

# Decrypt the received message using the shared Diffie-Hellman-derived key.
openssl enc -d -aes-256-cbc -pbkdf2 \
  -in /tmp/received_encrypted_timestamp_message.bin \
  -out /tmp/decrypted_timestamp_message.txt \
  -pass file:/tmp/secret.key

# Verify the signature against the decrypted timestamped message.
openssl dgst -sha256 \
  -verify /tmp/sender_public.pem \
  -signature /tmp/received_signature_timestamp.bin \
  /tmp/decrypted_timestamp_message.txt

# Reject a message whose timestamp is in the future or older than 60 seconds.
message_timestamp=$(head -n 1 /tmp/decrypted_timestamp_message.txt)
current_timestamp=$(date +%s)
message_age=$((current_timestamp - message_timestamp))
test "$message_age" -ge 0
test "$message_age" -le 60

# Display the accepted decrypted message.
cat /tmp/decrypted_timestamp_message.txt
