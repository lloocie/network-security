#!/bin/bash

# Stop immediately if any network setup command fails.
set -e

# Create two Linux network namespaces that simulate separate computers.
sudo ip netns add sender
sudo ip netns add receiver

# Create a virtual Ethernet cable and move one end into each namespace.
sudo ip link add veth-sender type veth peer name veth-receiver
sudo ip link set veth-sender netns sender
sudo ip link set veth-receiver netns receiver

# Assign an IP address to each end of the virtual cable.
sudo ip netns exec sender ip addr add 10.0.0.1/24 dev veth-sender
sudo ip netns exec receiver ip addr add 10.0.0.2/24 dev veth-receiver

# Enable both Ethernet interfaces and both loopback interfaces.
sudo ip netns exec sender ip link set veth-sender up
sudo ip netns exec receiver ip link set veth-receiver up
sudo ip netns exec sender ip link set lo up
sudo ip netns exec receiver ip link set lo up

# Test that sender can reach receiver.
sudo ip netns exec sender ping -c 4 10.0.0.2
