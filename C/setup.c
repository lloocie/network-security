#include <stdio.h>
#include <stdlib.h>

// Run a shell command; if it fails, stop the whole program.
void run(const char *cmd) {
    printf("> %s\n", cmd);
    if (system(cmd) != 0) {
        printf("Command failed: %s\n", cmd);
        exit(1);
    }
}

int main(void) {
    // Listing every step as one array makes the whole setup easy to scan
    // and easy to reorder/edit, instead of one run() call per line.
    const char *steps[] = {
        // Create two isolated virtual networks
        "ip netns add sender",
        "ip netns add receiver",

        // Create a virtual "cable" (veth pair) with two ends
        "ip link add veth-sender type veth peer name veth-receiver",

        // Plug one end into each namespace
        "ip link set veth-sender netns sender",
        "ip link set veth-receiver netns receiver",

        // Give each end an IP address on the same subnet
        "ip netns exec sender ip addr add 10.0.0.1/24 dev veth-sender",
        "ip netns exec receiver ip addr add 10.0.0.2/24 dev veth-receiver",

        // Turn the interfaces on
        "ip netns exec sender ip link set veth-sender up",
        "ip netns exec receiver ip link set veth-receiver up",

        // Turn on loopback (127.0.0.1) inside each namespace too
        "ip netns exec sender ip link set lo up",
        "ip netns exec receiver ip link set lo up",

        // Sanity check: can sender reach receiver?
        "ip netns exec sender ping -c 4 10.0.0.2",
    };

    int step_count = sizeof(steps) / sizeof(steps[0]);
    for (int i = 0; i < step_count; i++) {
        run(steps[i]);
    }

    return 0;
}