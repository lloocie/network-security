# Network Security

Network security homework organized by language.

## C

The [C](C/) folder contains the C programs:

- `setup.c` creates the Linux network namespaces and virtual connection.
- `receiver.c` listens for a TCP connection and prints the received message.
- `sender.c` connects to the receiver and sends a message.

These programs use Linux network namespaces for this exercise. Run setup first, then run the receiver in the receiver namespace and the sender in the sender namespace.

## Shell

The [Shell](Shell/) folder contains the shell scripts for network setup, file transfer, signatures, encryption, and cleanup. See the [Shell instructions](Shell/README.md) for requirements and usage. Run the shell commands from inside that folder.
