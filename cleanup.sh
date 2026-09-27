#!/bin/bash

# Remove the namespaces, including the common misspelling if it exists.
sudo ip netns delete sender 2>/dev/null
sudo ip netns delete receiver 2>/dev/null
sudo ip netns delete reciever 2>/dev/null

# Remove any virtual interfaces left outside the namespaces.
sudo ip link delete veth-sender 2>/dev/null
sudo ip link delete veth-receiver 2>/dev/null

# Remove normal transfer and RSA signature files.
sudo rm -f /tmp/message.txt /tmp/received.txt
sudo rm -f /tmp/signature.bin /tmp/received_signature.bin
sudo rm -f /tmp/sender_private.pem /tmp/sender_public.pem

# Remove Diffie-Hellman keys and derived secrets.
sudo rm -f /tmp/dhparam.pem
sudo rm -f /tmp/sender_dh_private.pem /tmp/sender_dh_public.pem
sudo rm -f /tmp/receiver_dh_private.pem /tmp/receiver_dh_public.pem
sudo rm -f /tmp/sender_shared_secret.bin /tmp/receiver_shared_secret.bin

# Remove AES, timestamp, encrypted message, and received output files.
sudo rm -f /tmp/secret.key /tmp/body.txt /tmp/timestamp.txt
sudo rm -f /tmp/message_with_timestamp.txt /tmp/signature_timestamp.bin
sudo rm -f /tmp/encrypted_timestamp_message.bin
sudo rm -f /tmp/received_encrypted_timestamp_message.bin
sudo rm -f /tmp/received_signature_timestamp.bin
sudo rm -f /tmp/decrypted_timestamp_message.txt
