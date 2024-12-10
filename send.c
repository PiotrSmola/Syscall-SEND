#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define PORT 8081

void error(const char *msg) {
    perror(msg);
    exit(EXIT_FAILURE);
}

int main() {
    int server_fd, client_fd;
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_len = sizeof(client_addr);

    // Tworzenie gniazda
    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd < 0) {
        perror("Błąd podczas tworzenia gniazda");
        exit(EXIT_FAILURE);
    }

    // Ustawienie opcji SO_REUSEADDR
    int optval = 1;
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval));

    // Ustawienie adresu serwera
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    server_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK); // 127.0.0.1

    // Bindowanie gniazda
    if (bind(server_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("Błąd podczas bindowania");
        exit(EXIT_FAILURE);
    }

    // Nasłuchiwanie na połączenia
    listen(server_fd, 1);
    printf("Serwer nasluchuje polaczen...\n");

    // Akceptowanie połączenia
    client_fd = accept(server_fd, (struct sockaddr *)&client_addr, &client_len);
    if (client_fd < 0) {
        perror("Błąd podczas akceptowania połączenia");
        exit(EXIT_FAILURE);
    }
    printf("Polaczenie z klientem zaakceptowane.\n");

    // Wysyłanie wiadomości do klienta
    const char *server_msg = "Wiadomosc od serwera!\n";
    send(client_fd, server_msg, strlen(server_msg), 0);
    printf("Wiadomosc wyslana do klienta.\n");

    // Zamknięcie połączeń
    close(client_fd);
    close(server_fd);

    return 0;
}
