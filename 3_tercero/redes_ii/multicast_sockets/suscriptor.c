/*
 *  Fichero: suscriptor.c
 *  Autor: Alberto García Martín DNI 70916117X
 *  Usuario: i0916117
 */

#include <arpa/inet.h>
#include <net/if.h>
#include <netinet/in.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>

#define PUERTO 16117
#define BUFFER_SIZE 8192

volatile sig_atomic_t stop;

void stophandler() {
    stop = 1;
}

int main(int argc, char const *argv[]) {
    struct sigaction sint;
    struct sockaddr_in6 multi_addr, emisor_addr;
    struct ipv6_mreq mreq;
    int if_indice, sock, addrlen;
    int enable = 1;
    char buffer[BUFFER_SIZE];
    char ipmulti[INET6_ADDRSTRLEN] = "ff15::17", ipemisor[INET6_ADDRSTRLEN];
    char interfaz[IFNAMSIZ] = "eth0";
    int puerto = PUERTO;

    // Uso: suscriptor <ip6-mu> <if> <prt>
    //    ./suscriptor ff15::17 eth0 16117

    if (argc >= 2) {
        strncpy(ipmulti, argv[1], sizeof(ipmulti) - 1);
    }

    if (argc >= 3) {
        strncpy(interfaz, argv[2], sizeof(interfaz) - 1);
    }

    if (argc >= 4) {
        puerto = strtol(argv[3], NULL, 10);
    }

    // pone a cero la estructura de la direccion del socket
    memset((char *)&multi_addr, 0, sizeof(multi_addr));
    memset((char *)&emisor_addr, 0, sizeof(emisor_addr));

    // crea el socket IPv6 y UDP
    if ((sock = socket(AF_INET6, SOCK_DGRAM, 0)) < 0) {
        perror("Socket: error al crear el socket\n");
        exit(-1);
    }

    multi_addr.sin6_family = AF_INET6;
    multi_addr.sin6_addr = in6addr_any;
    multi_addr.sin6_port = htons(puerto);
    multi_addr.sin6_flowinfo = 0;

    // activa opcion SO_REUSEADDR
    if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(enable)) < 0) {
        perror("error al establecer SO_REUSEADDR\n");
        exit(-1);
    }

    // hace bind sobre el socket
    if (bind(sock, (const struct sockaddr *)&multi_addr, sizeof(multi_addr)) < 0) {
        perror("error al hacer el bind\n");
        exit(-1);
    }

    // asigna la direccion ipv6
    if (inet_pton(AF_INET6, ipmulti, &mreq.ipv6mr_multiaddr) < 0) {
        perror("inet_pton: error al convertir la direccion\n");
        exit(-1);
    }

    // asigna la interfaz
    if_indice = if_nametoindex(interfaz);
    if (if_indice == 0) {
        fprintf(stderr, "if_nametoindex: no se encuentra la interfaz %s \n", interfaz);
        exit(-1);
    } else {
        mreq.ipv6mr_interface = if_indice;
    }

    // utiliza IPV6_ADD_MEMBERSHIP
    if (setsockopt(sock, IPPROTO_IPV6, IPV6_ADD_MEMBERSHIP, &mreq, sizeof(mreq)) < 0) {
        perror("error al establecer IPV6_ADD_MEMBERSHIP\n");
        exit(-1);
    }

    // registra SIGINT para hacer Ctrl-C y terminar de forma ordenada
    memset(&sint, 0, sizeof(sint));
    sint.sa_flags = 0;
    sint.sa_handler = stophandler;
    if (sigaction(SIGINT, &sint, NULL) == -1) {
        perror(argv[0]);
        fprintf(stderr, "%s: error al registrar SIGINT\n", argv[0]);
        exit(1);
    }

    stop = 0;
    while (!stop) {
        int n = recvfrom(sock, buffer, BUFFER_SIZE, 0, (struct sockaddr *)&emisor_addr, (socklen_t *)&addrlen);
        if (n == -1) {
            perror("error al hacer recvfrom\n");
            exit(1);
        }
        buffer[n] = '\0';

        // obtiene la direccion IP del emisor en formato de texto
        if (inet_ntop(AF_INET6, &(emisor_addr.sin6_addr), ipemisor, sizeof(ipemisor)) == NULL) {
            perror("inet_ntop\n");
        }

        printf("%s: %s\n", ipemisor, buffer);
        fflush(stdout);
    }

    return 0;
}
