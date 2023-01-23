/*
 *  Fichero: cliente.c
 *  Autores:
 *  Alberto García Martín DNI 70916117X
 *  Ángel Iñiguez Amorín DNI 70942933P
 */

#include <ctype.h>
#include <errno.h>
#include <netdb.h>
#include <netinet/ip.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define PORT 16117
#define BUFFER_SIZE 8192
#define TIMEOUT 5

volatile sig_atomic_t stop;

void stophandler()
{
    stop = 1;
}

void handler()
{
    printf("Alarma recibida\n");
}

int main(int argc, char* argv[])
{
    char tcpstr[] = "TCP", udpstr[] = "UDP";
    int isTCP, sock;
    struct sockaddr_in servaddr_in, myaddr_in;
    struct addrinfo hints;
    struct addrinfo* result;
    int addrlen, i;
    struct sigaction salrm, sint;
    char buf[BUFFER_SIZE], tmpchar, *tokbuf, *campo;
    char command[100], filename[100], connection[100], hostname[100];
    FILE* file = NULL;
    char logfile[100];

    if (argc < 3) {
        fprintf(stderr, "Uso: %s <servidor remoto> <protocolo>\n", argv[0]);
        exit(1);
    }

    if (argc == 4) {
        file = fopen(argv[3], "r");
    }

    strncpy(hostname, argv[1], sizeof(hostname) - 1);

    if (strcmp(argv[2], tcpstr) == 0) {
        isTCP = 1;
    } else if (strcmp(argv[2], udpstr) == 0) {
        isTCP = 0;
    } else {
        fprintf(stderr, "Uso: %s <servidor remoto> <protocolo>\n", argv[0]);
        fprintf(stderr, "El protocolo tiene que ser %s o %s\n", tcpstr, udpstr);
        exit(1);
    }

    // crea el socket
    // AF_NET: usar protocolos de IPv4
    if (isTCP) {
        // SOCK_STREAM para TCP (stream de bytes)
        sock = socket(AF_INET, SOCK_STREAM, 0);
    } else {
        // SOCK_DGRAM para UDP (envio de datagramas)
        sock = socket(AF_INET, SOCK_DGRAM, 0);
    }

    if (sock == -1) {
        perror(argv[0]);
        fprintf(stderr, "%s: error al crear el socket\n", argv[0]);
        exit(1);
    }

    // pone a cero las estructuras de las direcciones de los sockets
    memset((char*)&myaddr_in, 0, sizeof(struct sockaddr_in));
    memset((char*)&servaddr_in, 0, sizeof(struct sockaddr_in));

    // establece los valores de la direccion a la que nos conectaremos (IPv4)
    servaddr_in.sin_family = AF_INET;

    // pone a cero la estructura
    memset(&hints, 0, sizeof(hints));
    // especifica la familia de la direccion devuelta (IPv4)
    hints.ai_family = AF_INET;

    if (getaddrinfo(hostname, NULL, &hints, &result) != 0) {
        perror(argv[0]);
        fprintf(stderr, "%s: error al resolver la IP de %s\n",
            argv[0], hostname);
        exit(1);
    }

    // copia la direccion del host devuelto
    servaddr_in.sin_addr = ((struct sockaddr_in*)result->ai_addr)->sin_addr;
    // libera la memoria asignada a res ya que no necesitamos mas informacion
    freeaddrinfo(result);

    servaddr_in.sin_port = htons(PORT); // puerto en orden de red

    // segun la descripcion del manual de connect() para UDP
    // connect() NO establece conexion con el servidor remoto solo asocia
    // un puerto efimero y la direccion local al socket, como bind
    if (connect(sock, (const struct sockaddr*)&servaddr_in,
            sizeof(struct sockaddr_in))
        == -1) {
        perror(argv[0]);
        fprintf(stderr, "%s: error al conectarse con el servidor\n", argv[0]);
        exit(1);
    }

    addrlen = sizeof(struct sockaddr_in);
    if (getsockname(sock, (struct sockaddr*)&myaddr_in,
            (socklen_t*)&addrlen)
        == -1) {
        perror(argv[0]);
        fprintf(stderr, "%s: error al leer la direccion de socket\n", argv[0]);
        exit(1);
    }

#ifndef DEBUG
    snprintf(logfile, sizeof(logfile),
        "%u.txt", ntohs(myaddr_in.sin_port));
    if (freopen(logfile, "w+", stdout) == NULL) {
        perror(argv[0]);
        fprintf(stderr, "%s: error al abrir el txt\n", argv[0]);
        exit(1);
    }
    setbuf(stdout, NULL);
    dup2(fileno(stdout), fileno(stderr));
#endif

    // registrar SIGALRM para no quedarse bloqueado en el receive
    memset(&salrm, 0, sizeof(salrm));
    salrm.sa_flags = 0;
    salrm.sa_handler = handler;
    if (sigaction(SIGALRM, &salrm, NULL) == -1) {
        perror(argv[0]);
        fprintf(stderr, "%s: error al registrar SIGALRM\n", argv[0]);
        exit(1);
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
        int n = 0;
        long pos = -1;

        bzero(buf, sizeof(buf));
        if (file == NULL) {
            while ((tmpchar = getc(stdin)) != '\n' && !stop) {
                buf[n++] = tmpchar;
            }
        } else {
            pos = ftell(file);
            if (fgets(buf, BUFFER_SIZE, file) == NULL) {
                stop = 1;
            }
            buf[strcspn(buf, "\r\n")] = 0;
        }
        if (stop)
            break;
        if (strlen(buf) == 0)
            continue;

        bzero(command, sizeof(command));
        bzero(filename, sizeof(filename));
        bzero(connection, sizeof(connection));
        tokbuf = strtok_r(buf, " ", &campo);
        for (i = 0; i < 3; i++) {
            if (tokbuf == NULL)
                break;

            if (i == 0) {
                strncpy(command, tokbuf, sizeof(command) - 1);
            } else if (i == 1) {
                strncpy(filename, tokbuf, sizeof(filename) - 1);
            } else if (i == 2) {
                strncpy(connection, tokbuf, sizeof(connection) - 1);
            }

            tokbuf = strtok_r(NULL, " ", &campo);
        }

        if (strcmp(connection, "k") == 0) {
            strncpy(connection, "keep-alive", sizeof(connection));
        } else if (strcmp(connection, "c") == 0) {
            strncpy(connection, "close", sizeof(connection));
        }

        snprintf(buf, sizeof(buf),
            "%s %s HTTP/1.1\r\n"
            "Host: %s\r\n"
            "Connection: %s\r\n"
            "\r\n",
            command, filename, hostname, connection);
        if (isTCP) {
            n = send(sock, buf, BUFFER_SIZE, 0);
        } else {
            n = sendto(sock, buf, BUFFER_SIZE, 0,
                (struct sockaddr*)&servaddr_in, addrlen);
        }
        if (n == -1) {
            perror(argv[0]);
            fprintf(stderr, "%s: error al hacer send\n", argv[0]);
            exit(1);
        }

        // se podrian implementar reintentos
        alarm(TIMEOUT);
        if (isTCP) {
            do {
                n = recv(sock, buf, BUFFER_SIZE, 0);
                if (n == -1) {
                    perror(argv[0]);
                    fprintf(stderr, "%s: error al hacer recv\n", argv[0]);
                    exit(1);
                } else if (n == 0) {
                    // reintentar conexion
                    close(sock);
                    sock = socket(AF_INET, SOCK_STREAM, 0);
                    if (connect(sock, (const struct sockaddr*)&servaddr_in,
                            sizeof(struct sockaddr_in))
                        == -1) {
                        perror(argv[0]);
                        fprintf(stderr, "%s: error al conectarse\n", argv[0]);
                        exit(1);
                    }
                    if (file != NULL) {
                        fseek(file, pos, 0);
                    } else {
                        stop = 1;
                    }
                    continue;
                }
                buf[n] = '\0';
                printf("%s\n", buf);
            } while (n == BUFFER_SIZE);

            if (file == NULL && strcmp(connection, "keep-alive"))
                stop = 1;
        } else {
            do {
                n = recvfrom(sock, buf, BUFFER_SIZE, 0,
                    (struct sockaddr*)&servaddr_in,
                    (socklen_t*)&addrlen);
                if (n == -1) {
                    perror(argv[0]);
                    fprintf(stderr, "%s: error al hacer recvfrom\n", argv[0]);
                    exit(1);
                }
                buf[n] = '\0';
                printf("%s\n", buf);
            } while (n == BUFFER_SIZE);
        }
        alarm(0); // cancela la alarma pendiente

        printf("\n");
    }

    if (isTCP) {
        // cierra la conexion para futuros sends (SHUT_WR)
        if (shutdown(sock, SHUT_WR) == -1) {
            perror(argv[0]);
            fprintf(stderr, "%s: unable to shutdown socket\n", argv[0]);
        }
    }

    close(sock);

    return 0;
}
