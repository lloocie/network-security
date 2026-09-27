# Network Security Homework

This project creates two Linux network namespaces that act like two separate computers. The scripts connect them, transfer a file, create and verify a digital signature, encrypt a timestamped message, and clean up the environment.

## Requirements

Run these scripts inside Ubuntu or another Linux system. They do not run directly on macOS because macOS does not provide Linux network namespaces.

Install the required programs on Ubuntu:

```bash
sudo apt update
sudo apt install iproute2 netcat-openbsd openssl
```

## Files

- `01_setup_network.sh` creates the sender and receiver namespaces, connects them, assigns IP addresses, and tests the connection.
- `02_send_file.sh` sends a text file from the sender namespace to the receiver namespace.
- `03_signature.sh` creates RSA keys, signs a message, transfers the message and signature, and verifies the signature.
- `04_diffie_hellman_encrypt_timestamp.sh` creates a shared secret with Diffie-Hellman, encrypts a timestamped message with AES, transfers it, decrypts it, verifies its signature, and checks that its timestamp is fresh.
- `cleanup.sh` removes the namespaces and temporary files created by the other scripts.

## Make the Scripts Executable

Open a terminal in this folder and run:

```bash
chmod +x *.sh
```

## Run the Homework

Run the scripts in this order:

```bash
./01_setup_network.sh
./02_send_file.sh
./03_signature.sh
./04_diffie_hellman_encrypt_timestamp.sh
```

The scripts use `sudo`, so Ubuntu may ask for your password.

Script `04_diffie_hellman_encrypt_timestamp.sh` must run after `03_signature.sh` because it uses the RSA keys created by script 03.

## Expected Results

The first script should show successful ping replies from `10.0.0.2`.

The second script should display:

```text
Hello from sender
```

The signature scripts should display:

```text
Verified OK
```

The final script should also display the timestamp and decrypted message after its security checks pass.

## Cleanup

When finished, remove the namespaces and generated temporary files:

```bash
./cleanup.sh
```

Run the cleanup script before starting again if a previous run stopped with an error.

## Security Features

- Linux network namespaces simulate separate sender and receiver computers.
- Netcat transfers data through the virtual network.
- RSA signatures prove sender identity and detect message changes.
- Diffie-Hellman creates a shared secret.
- AES protects message confidentiality.
- A timestamp helps reject replayed messages older than 60 seconds.

This project is an educational demonstration. Real systems should use established secure protocols such as TLS instead of building a custom security protocol.
