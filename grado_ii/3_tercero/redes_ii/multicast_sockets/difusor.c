/*
 *  Fichero: difusor.c
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
#include <unistd.h>

#define BUFFER_SIZE 8192

#define PUERTO 16117
#define SALTOS 10
#define INTERVALO 5

volatile sig_atomic_t stop;

void stophandler()
{
    stop = 1;
}

int main(int argc, char const* argv[])
{
    struct sigaction sint;
    struct sockaddr_in6 multi_addr, my_addr;
    int if_indice, sock;
    int enable = 1;
    char mensaje[BUFFER_SIZE] = "Mensaje de prueba";
    char ipmulti[INET6_ADDRSTRLEN] = "ff15::17";
    char interfaz[IFNAMSIZ] = "eth0";
    int puerto = PUERTO;
    int saltos = SALTOS;
    int intervalo = INTERVALO;

    // Uso: difusor <mensaje_difu> <ip6-mu> <if> <prt> <hop> <interval>
    //    ./difusor "Hola que tal" ff15::17 eth0 16117 10 15

    if (argc >= 2) {
        strncpy(mensaje, argv[1], sizeof(mensaje) - 1);
    }

    if (argc >= 3) {
        strncpy(ipmulti, argv[2], sizeof(ipmulti) - 1);
    }

    if (argc >= 4) {
        strncpy(interfaz, argv[3], sizeof(interfaz) - 1);
    }

    if (argc >= 5) {
        puerto = strtol(argv[4], NULL, 10);
    }

    if (argc >= 6) {
        saltos = strtol(argv[5], NULL, 10);
    }

    if (argc >= 7) {
        intervalo = strtol(argv[6], NULL, 10);
    }

    // pone a cero la estructura de la direccion del socket
    memset((char*)&multi_addr, 0, sizeof(multi_addr));
    memset((char*)&my_addr, 0, sizeof(my_addr));

    // crea el socket IPv6 y UDP
    if ((sock = socket(AF_INET6, SOCK_DGRAM, 0)) < 0) {
        perror("socket: error al crear el socket\n");
        exit(-1);
    }

    my_addr.sin6_family = AF_INET6;
    my_addr.sin6_addr = in6addr_any;
    my_addr.sin6_port = 0;
    my_addr.sin6_flowinfo = 0;

    multi_addr.sin6_family = AF_INET6;
    multi_addr.sin6_port = htons(puerto);
    multi_addr.sin6_flowinfo = 0;

    // asigna la direccion ipv6 multicast
    if (inet_pton(AF_INET6, ipmulti, &multi_addr.sin6_addr) <= 0) {
        perror("inet_pton: error al convertir la direccion\n");
        exit(-1);
    }

    // hacer bind sobre el socket
    if (bind(sock, (const struct sockaddr*)&my_addr, sizeof(my_addr)) < 0) {
        perror("error al hacer el bind\n");
        exit(-1);
    }

    // activa opcion IPV6_MULTICAST_LOOP
    if (setsockopt(sock, IPPROTO_IPV6, IPV6_MULTICAST_LOOP, &enable, sizeof(enable)) < 0) {
        perror("error al establecer IPV6_MULTICAST_LOOP\n");
        exit(-1);
    }

    // establece IPV6_MULTICAST_IF
    if_indice = if_nametoindex(interfaz);
    if (if_indice == 0) {
        fprintf(stderr, "if_nametoindex: no se encuentra la interfaz %s \n", interfaz);
        exit(-1);
    } else {
        if (setsockopt(sock, IPPROTO_IPV6, IPV6_MULTICAST_IF, &if_indice, sizeof(if_indice)) < 0) {
            perror("error al establecer IPPROTO_IPV6\n");
            exit(-1);
        }
    }

    // establece IPV6_MULTICAST_HOPS
    if (setsockopt(sock, IPPROTO_IPV6, IPV6_MULTICAST_HOPS, &saltos, sizeof(saltos)) < 0) {
        perror("error al establecer IPV6_MULTICAST_HOPS\n");
        exit(-1);
    }

    // registrar SIGINT para hacer Ctrl-C y terminar de forma ordenada
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
        if (sendto(sock, mensaje, BUFFER_SIZE, 0, (struct sockaddr*)&multi_addr, sizeof(multi_addr)) == -1) {
            perror("error al hacer sendto\n");
            exit(1);
        }

        sleep(intervalo);
    }

    return 0;
}
