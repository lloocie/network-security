#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define HOST "10.0.0.2"   // our own IP inside the "receiver" namespace
#define PORT 5000
#define BUF_SIZE 1024

// Small helper: if a syscall fails (returns < 0), print why and quit.
// This replaces the repeated "if (x < 0) { perror(...); return 1; }" blocks.
void must(int result, const char *what) {
    if (result < 0) {
        perror(what);
        exit(1);
    }
}

int main(void) {
    char buffer[BUF_SIZE] = {0};

    // 1. Create a TCP socket
    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    must(server_fd, "socket");
    //the number of the reciever socket we name it server as it needs to listen 
    

    // 2. Let us reuse this address instantly if we restart the program
    int opt = 1;
    must(setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)), "setsockopt");
    //opt -> flag on 
    //the reciever can quickly reuse the port 
    

    // 3. Describe the address we want to listen on: HOST:PORT
    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_port = htons(PORT);
    must(inet_pton(AF_INET, HOST, &addr.sin_addr), "inet_pton");

    //tells were to listen , recievers ip and port

    // 4. Claim that address, then start listening for one connection
    must(bind(server_fd, (struct sockaddr *)&addr, sizeof(addr)), "bind");
    must(listen(server_fd, 1), "listen");
    printf("[receiver] Listening on %s:%d...\n", HOST, PORT);

    //sender contacts port 5000 but it doesnt know which socket to use so the bind assigns its own ip and port to the socket

    // 5. Wait here until a client connects
    struct sockaddr_in client_addr;
    socklen_t client_len = sizeof(client_addr);
    int client_fd = accept(server_fd, (struct sockaddr *)&client_addr, &client_len);
    must(client_fd, "accept");
    printf("[receiver] Connection from %s:%d\n",
           inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));

    //server_fd	The listening socket—waits for incoming connections. Created by socket().
    //only for new connections 
    //client_fd	The connected socket—receives the sender’s message. Created by accept().
    //The sender calls connect. The receiver calls accept on the server socket, and accept
    // returns a new connected socket, the client socket. Now the sender sends its message. 
    // The receiver reads that message using the client socket, not the server socket


    // 6. Read whatever the client sends and print it
    ssize_t n = recv(client_fd, buffer, BUF_SIZE - 1, 0);
    must(n, "recv");
    buffer[n] = '\0';
    printf("[receiver] Received: %s\n", buffer);

    // 7. Clean up
    close(client_fd);
    close(server_fd);
    return 0;
}