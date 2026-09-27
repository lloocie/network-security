#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define TARGET_HOST "10.0.0.2"   // receiver's IP
#define TARGET_PORT 5000
#define MESSAGE "Hello from sender namespace!"

void must(int result, const char *what) {
    if (result < 0) {
        perror(what);
        exit(1);
    }
}

int main(void) {
    // 1. Create a TCP socket
    int sock_fd = socket(AF_INET, SOCK_STREAM, 0);
    
    //Socket (use ipv4 addresse, give me a reliabel ordered byte stream (), use the default protocol)
    //C program asking the operating system for the socket
    //We use sockets to connect to reciever sockets, its the interface the code uses, 
    //you give the data to the socket and then the OS takes the job from there
    //int sock_fd -> reference the progeam uses to identify the socket

    must(sock_fd, "socket");

    // 2. Describe who we want to connect to

    //in the addr i keep the address the destination the sender wants to connect to
    struct sockaddr_in addr = {0};
    //addrees fam, the port and ip address
    addr.sin_family = AF_INET;
    addr.sin_port = htons(TARGET_PORT);
    //htons -> host to network short (converts the port number into the standart form that networm expects)

    must(inet_pton(AF_INET, TARGET_HOST, &addr.sin_addr), "inet_pton");
    //pton -> presentaiton to network
    //converts ip address text converts to binary form so the os can use 
    //takes the family and ip address string and converts it to binary and writes it in struct

    //so now the struct have -> family set to ipv4 , port is 5000, and the binary reciever ip address 

    // 3. Connect (this is what unblocks the receiver's accept())
    must(connect(sock_fd, (struct sockaddr *)&addr, sizeof(addr)), "connect");
    printf("[sender] Connected to %s:%d\n", TARGET_HOST, TARGET_PORT);

    // asks OS to use the socket to start a TCP connection to that address, if it works then the socket is connected

    // 4. Send the message
    must(send(sock_fd, MESSAGE, strlen(MESSAGE), 0), "send");
    printf("[sender] Sent: %s\n", MESSAGE);

    // 5. Clean up
    close(sock_fd);
    return 0;
}