/*
 *  Fichero: servidor.c
 *  Autores:
 *  Alberto García Martín DNI 70916117X
 *  Ángel Iñiguez Amorín DNI 70942933P
 */

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <libgen.h>
#include <netdb.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

#define PORT 16117
#define BUFFER_SIZE 8192

void daemonaux(int sUDP, int lsTCP);
void server(int sock, struct sockaddr_in clientaddr_in, char *buffer);

char *exename;
volatile sig_atomic_t stop;

void stophandler() {
    stop = 1;
}

int main(int argc, char *argv[]) {
    int sockUDP;
    int listenTCP;
    struct sockaddr_in myaddr_in;
    struct sigaction saign, sastop;
    char logfile[] = "peticiones.log";

    exename = (argc > 0) ? basename(argv[0]) : "";

    // crea el socket para la escucha de conexiones TCP
    listenTCP = socket(AF_INET, SOCK_STREAM, 0);
    if (listenTCP == -1) {
        perror(argv[0]);
        fprintf(stderr, "%s: error al crear el socket de escucha\n", argv[0]);
        exit(1);
    }

    // pone a cero las estructuras de las direcciones de los sockets
    memset((char *)&myaddr_in, 0, sizeof(struct sockaddr_in));

    // inicializa la estructura para la direccion del socket de escucha
    myaddr_in.sin_family = AF_INET;
    // el socket se asociara a todas las interfaces locales
    myaddr_in.sin_addr.s_addr = INADDR_ANY;
    myaddr_in.sin_port = htons(PORT);  // puerto en orden de red

    // asocia una direccion al socket de escucha TCP
    if (bind(listenTCP, (const struct sockaddr *)&myaddr_in,
             sizeof(struct sockaddr_in)) == -1) {
        perror(argv[0]);
        fprintf(stderr, "%s: error al hacer bind TCP\n", argv[0]);
        exit(1);
    }

    // inicia la escucha para que los clientes se puedan conectar
    // el numero maximo de conexiones pendientes que puede tener la cola
    // esta definido por SOMAXCONN
    if (listen(listenTCP, SOMAXCONN) == -1) {
        perror(argv[0]);
        fprintf(stderr, "%s: error al escuchar\n", argv[0]);
        exit(1);
    }

    // crea el socket para UDP
    sockUDP = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockUDP == -1) {
        perror(argv[0]);
        printf("%s: error al crear el socket UDP\n", argv[0]);
        exit(1);
    }

    // asocia una direccion al socket UDP
    if (bind(sockUDP, (struct sockaddr *)&myaddr_in,
             sizeof(struct sockaddr_in)) == -1) {
        perror(argv[0]);
        printf("%s: error al hacer bind UDP\n", argv[0]);
        exit(1);
    }

    setpgrp();

    stop = 0;

    switch (fork()) {
        case -1:
            perror(argv[0]);
            fprintf(stderr, "%s: error al hacer fork\n", argv[0]);
            exit(1);
        case 0:  // el proceso del hijo devuelve 0 (demonio)
            // cierra los streams de entrada y error
            fclose(stdin);
#ifndef DEBUG
            fclose(stderr);
            // stdout se redirecciona a un archivo de log
            // w+ abre en RW y crea/vacia el archivo
            if (freopen(logfile, "w+", stdout) == NULL) {
                perror(argv[0]);
                fprintf(stderr, "%s: error al abrir el log\n", argv[0]);
                exit(1);
            }
            // desactiva el buffer en stdout
            setbuf(stdout, NULL);
#endif

            // se ignora SIGCHLD para prevenir procesos zombie
            memset(&saign, 0, sizeof(saign));
            saign.sa_handler = SIG_IGN;
            if (sigaction(SIGCHLD, &saign, NULL) == -1) {
                perror(argv[0]);
                fprintf(stderr, "%s: error al registrar SIGCHLD\n", argv[0]);
                exit(1);
            }

            memset(&sastop, 0, sizeof(sastop));
            sastop.sa_flags = 0;
            sastop.sa_handler = stophandler;
            if (sigaction(SIGTERM, &sastop, NULL) == -1) {
                perror(argv[0]);
                fprintf(stderr, "%s: error al registrar SIGTERM\n", argv[0]);
                exit(1);
            }

            while (!stop) {
                // funcion auxiliar para evitar anidamiento
                daemonaux(sockUDP, listenTCP);
            }

            // destruye los sockets
            close(listenTCP);
            close(sockUDP);

            printf("\nFin de programa servidor!\n");
            break;
        default:  // el proceso del padre continua aqui
            exit(0);
    }

    return 0;
}

void daemonaux(int sUDP, int lsTCP) {
    fd_set readfds;
    struct sockaddr_in clientaddr_in;
    struct linger linger;
    int maxfd, addrlen;

    // pone a cero la estructura de las direcciones de los sockets
    memset((char *)&clientaddr_in, 0, sizeof(struct sockaddr_in));

    addrlen = sizeof(struct sockaddr_in);

    // mete en el conjunto de descriptores los sockets UDP y TCP
    FD_ZERO(&readfds);
    FD_SET(lsTCP, &readfds);
    FD_SET(sUDP, &readfds);

    // encuentra el descriptor mas grande para la llamada a select
    if (lsTCP > sUDP) {
        maxfd = lsTCP;
    } else {
        maxfd = sUDP;
    }

    // selecciona el socket que este disponible para la lectura
    // los sockets que no esten listos se eliminan de readfds
    if (select(maxfd + 1, &readfds, NULL, NULL, NULL) == -1) {
        stop = 1;
        if (errno == EINTR) {
            perror("signal recibida al hacer select\n");
        } else {
            perror("error al hacer select\n");
        }
    } else {
        // comprueba si el socket seleccionado es el de TCP
        if (FD_ISSET(lsTCP, &readfds)) {
            // bloquea hasta que recibe una direccion
            int sTCP = accept(lsTCP, (struct sockaddr *)&clientaddr_in,
                              (socklen_t *)&addrlen);
            if (sTCP == -1)
                exit(1);

            switch (fork()) {
                case -1:  // error al hacer el fork
                    exit(1);
                case 0:            // el proceso del hijo empieza aqui
                    close(lsTCP);  // cierra el socket heredado del demonio

                    // hace que el socket espere a que todos los datos
                    // enviados lleguen al cliente remoto o hasta que pase 1s
                    linger.l_onoff = 1;   // activado
                    linger.l_linger = 1;  // un segundo
                    if (setsockopt(sTCP, SOL_SOCKET, SO_LINGER, &linger,
                                   sizeof(linger)) == -1) {
                        perror("error al establecer las opciones del socket\n");
                        exit(1);
                    }

                    server(sTCP, clientaddr_in, NULL);
                    exit(0);
                default:  // el proceso del demonio sigue aqui
                    // destruye el socket para la conexion TCP
                    close(sTCP);
            }
        }

        // comprueba si el socket seleccionado es el de UDP
        if (FD_ISSET(sUDP, &readfds)) {
            char buffer[BUFFER_SIZE];
            int n = recvfrom(sUDP, buffer, BUFFER_SIZE, 0,
                             (struct sockaddr *)&clientaddr_in,
                             (socklen_t *)&addrlen);
            if (n == -1) {
                perror("error al hacer recvfrom\n");
                exit(1);
            }
            buffer[n] = '\0';

            server(sUDP, clientaddr_in, buffer);
        }
    }

    return;
}

// FUNCIONALIDAD AQUI
void server(int sock, struct sockaddr_in clientaddr_in, char *buffer) {
    int isTCP, n, code, fd;
    char buf[BUFFER_SIZE];
    char hostname[NI_MAXHOST], ipaddress[45];
    time_t timevar;
    struct tm *timetmp, timeres;
    char timestr[200], protstr[5];
    char *tokbuf, *linea, *campo;
    char command[100], path[100], host[100];
    char getcommand[] = "GET", root[] = "./www", hoststr[] = "Host:";
    char nombreserver[] = "Servidor de Angel Iñiguez y Alberto García";
    char notfoundstr[] =
        "<html><body><h1>404 Not Found</h1></body></html>";
    char notimplementedstr[] =
        "<html><body><h1>501 Not Implemented</h1></body></html>";
    struct stat sb;
    char *sndbuf, *filebuf;

    // obtiene el hostname a partir de una direccion IP dada
    if (getnameinfo((struct sockaddr *)&clientaddr_in,
                    sizeof(clientaddr_in), hostname, NI_MAXHOST, NULL, 0, 0))
        perror("getnameinfo\n");

    // obtiene la direccion IP en formato de texto
    if (inet_ntop(AF_INET, &(clientaddr_in.sin_addr), ipaddress,
                  sizeof(ipaddress)) == NULL)
        perror("inet_ntop\n");

    time(&timevar);
    timetmp = localtime_r(&timevar, &timeres);
    strftime(timestr, sizeof(timestr), "[%d/%m/%y %X]", timetmp);

    if (buffer == NULL) {
        int len, keepalive = 1;
        char connection[100];
        char connectionstr[] = "Connection:";
        char keepstr[] = "keep-alive", closestr[] = "close";

        isTCP = 1;
        printf(
            "%s %s: "
            "Comunicacion TCP realizada con %s (%s) y puerto efimero %u\n",
            timestr, exename, hostname, ipaddress,
            ntohs(clientaddr_in.sin_port));

        while (keepalive && (len = recv(sock, buf, BUFFER_SIZE, 0))) {
            if (len == -1) {
                perror(hostname);
                exit(1);
            }
            buf[len] = '\0';

            bzero(command, sizeof(command));
            bzero(path, sizeof(path));
            bzero(host, sizeof(host));
            bzero(connection, sizeof(connection));
            code = 200;

            tokbuf = strtok_r(buf, "\r\n", &linea);
            while (tokbuf != NULL) {
                strtok_r(tokbuf, " ", &campo);

                if (strcmp(tokbuf, getcommand) == 0) {
                    strncpy(command, tokbuf, sizeof(command) - 1);
                    tokbuf = strtok_r(NULL, " ", &campo);
                    strncpy(path, root, sizeof(path) - 1);
                    strncat(path, tokbuf, sizeof(path) - sizeof(root) - 1);
                } else if (strcmp(tokbuf, hoststr) == 0) {
                    tokbuf = strtok_r(NULL, " ", &campo);
                    strncpy(host, tokbuf, sizeof(host) - 1);
                } else if (strcmp(tokbuf, connectionstr) == 0) {
                    tokbuf = strtok_r(NULL, " ", &campo);
                    if (tokbuf == NULL) {
                        keepalive = 0;
                        strncpy(connection, closestr, sizeof(connection) - 1);
                        break;
                    }
                    if (strcmp(tokbuf, keepstr) == 0) {
                        strncpy(connection, tokbuf, sizeof(connection) - 1);
                    } else {
                        keepalive = 0;
                        strncpy(connection, closestr, sizeof(connection) - 1);
                    }
                }

                tokbuf = strtok_r(NULL, "\r\n", &linea);
            }

            if (strcmp(command, getcommand) == 0) {
                if (stat(path, &sb)) {
                    code = 404;
                } else {
                    fd = open(path, O_RDONLY);
                    fstat(fd, &sb);
                    filebuf = malloc(sb.st_size + 1);
                    read(fd, filebuf, sb.st_size);
                    filebuf[sb.st_size] = '\0';
                }
            } else {
                code = 501;
            }

            bzero(buf, sizeof(buf));
            if (code == 501) {
                snprintf(buf, sizeof(buf),
                         "HTTP/1.1 501 Not Implemented\r\n"
                         "Server: %s\r\n"
                         "Connection: %s\r\n"
                         "Content-Length: %zu\r\n"
                         "\r\n"
                         "%s",
                         nombreserver, connection, strlen(notimplementedstr),
                         notimplementedstr);
            } else if (code == 404) {
                snprintf(buf, sizeof(buf),
                         "HTTP/1.1 404 Not Found\r\n"
                         "Server: %s\r\n"
                         "Connection: %s\r\n"
                         "Content-Length: %zu\r\n"
                         "\r\n"
                         "%s",
                         nombreserver, connection, strlen(notfoundstr),
                         notfoundstr);
            } else if (code == 200) {
                snprintf(buf, sizeof(buf),
                         "HTTP/1.1 200 OK\r\n"
                         "Server: %s\r\n"
                         "Connection: %s\r\n"
                         "Content-Length: %zu\r\n"
                         "\r\n",
                         nombreserver, connection, strlen(filebuf));
            }

            if (code == 200) {
                sndbuf = malloc(strlen(buf) + sb.st_size + 1);
                strncpy(sndbuf, buf, strlen(buf) + sb.st_size + 1);
                strncat(sndbuf, filebuf, sb.st_size + 1);
                n = send(sock, sndbuf, strlen(sndbuf), 0);
                close(fd);
                free(filebuf);
            } else {
                sndbuf = malloc(strlen(buf) + 1);
                strncpy(sndbuf, buf, strlen(buf) + 1);
                n = send(sock, sndbuf, strlen(sndbuf), 0);
            }
            if (n == -1) {
                perror(exename);
                fprintf(stderr, "%s: error al hacer send\n", exename);
            }

            time(&timevar);
            timetmp = localtime_r(&timevar, &timeres);
            strftime(timestr, sizeof(timestr), "[%d/%m/%y %X]", timetmp);
            if (code == 200) {
                printf("%s %s: Peticion atendida correctamente\n",
                       timestr, exename);
            } else {
                printf("%s %s: Peticion erronea. Codigo de error: %d\n",
                       timestr, exename, code);
            }
        }

        shutdown(sock, SHUT_RDWR);
        close(sock);
    } else {
        char *tmpbuf;

        isTCP = 0;
        printf(
            "%s %s: "
            "Comunicacion UDP realizada con %s (%s) y puerto efimero %u\n",
            timestr, exename, hostname, ipaddress,
            ntohs(clientaddr_in.sin_port));
        strncpy(buf, buffer, sizeof(buf) - 1);

        bzero(command, sizeof(command));
        bzero(path, sizeof(path));
        bzero(host, sizeof(host));
        code = 200;

        tokbuf = strtok_r(buf, "\r\n", &linea);
        while (tokbuf != NULL) {
            strtok_r(tokbuf, " ", &campo);

            if (strcmp(tokbuf, getcommand) == 0) {
                strncpy(command, tokbuf, sizeof(command) - 1);
                tokbuf = strtok_r(NULL, " ", &campo);
                strncpy(path, root, sizeof(path) - 1);
                strncat(path, tokbuf, sizeof(path) - sizeof(root) - 1);
            } else if (strcmp(tokbuf, hoststr) == 0) {
                tokbuf = strtok_r(NULL, " ", &campo);
                strncpy(host, tokbuf, sizeof(host) - 1);
            }

            tokbuf = strtok_r(NULL, "\r\n", &linea);
        }

        if (strcmp(command, getcommand) == 0) {
            if (stat(path, &sb)) {
                code = 404;
            } else {
                fd = open(path, O_RDONLY);
                fstat(fd, &sb);
                filebuf = malloc(sb.st_size + 1);
                read(fd, filebuf, sb.st_size);
                filebuf[sb.st_size] = '\0';
            }
        } else {
            code = 501;
        }

        bzero(buf, sizeof(buf));
        if (code == 501) {
            snprintf(buf, sizeof(buf),
                     "HTTP/1.1 501 Not Implemented\r\n"
                     "Server: %s\r\n"
                     "Content-Length: %zu\r\n"
                     "\r\n"
                     "%s",
                     nombreserver, strlen(notimplementedstr),
                     notimplementedstr);
        } else if (code == 404) {
            snprintf(buf, sizeof(buf),
                     "HTTP/1.1 404 Not Found\r\n"
                     "Server: %s\r\n"
                     "Content-Length: %zu\r\n"
                     "\r\n"
                     "%s",
                     nombreserver, strlen(notfoundstr),
                     notfoundstr);
        } else if (code == 200) {
            snprintf(buf, sizeof(buf),
                     "HTTP/1.1 200 OK\r\n"
                     "Server: %s\r\n"
                     "Content-Length: %zu\r\n"
                     "\r\n",
                     nombreserver, strlen(filebuf));
        }

        if (code == 200) {
            long pos, posbuf;
            int i;

            sndbuf = malloc(strlen(buf) + sb.st_size + 1);
            strncpy(sndbuf, buf, strlen(buf) + sb.st_size + 1);
            strncat(sndbuf, filebuf, sb.st_size + 1);
            if (strlen(filebuf) + strlen(buf) > BUFFER_SIZE) {
                pos = BUFFER_SIZE;
                posbuf = BUFFER_SIZE - strlen(buf);
                i = 0;
            } else {
                pos = strlen(filebuf) + strlen(buf);
            }
            tmpbuf = realloc(sndbuf, pos);
            if (tmpbuf == NULL) free(sndbuf);
            n = sendto(sock, sndbuf, strlen(sndbuf), 0,
                       (struct sockaddr *)&clientaddr_in,
                       sizeof(struct sockaddr_in));
            while (pos == BUFFER_SIZE) {
                // dar tiempo al cliente a leer
                usleep(100000);
                if (strlen(filebuf) - posbuf - BUFFER_SIZE * i > BUFFER_SIZE) {
                    strncpy(sndbuf, filebuf + posbuf + BUFFER_SIZE * i,
                            BUFFER_SIZE);
                    n = sendto(sock, sndbuf, strlen(sndbuf), 0,
                               (struct sockaddr *)&clientaddr_in,
                               sizeof(struct sockaddr_in));
                    i++;
                } else {
                    pos = strlen(filebuf) - posbuf - BUFFER_SIZE * i;
                    strncpy(sndbuf, filebuf + posbuf + BUFFER_SIZE * i,
                            pos + 1);
                    tmpbuf = realloc(sndbuf, pos + 1);
                    if (tmpbuf == NULL) free(sndbuf);
                    n = sendto(sock, sndbuf, strlen(sndbuf), 0,
                               (struct sockaddr *)&clientaddr_in,
                               sizeof(struct sockaddr_in));
                }
            }
            close(fd);
            free(filebuf);
        } else {
            sndbuf = malloc(strlen(buf) + 1);
            strncpy(sndbuf, buf, strlen(buf) + 1);
            tmpbuf = realloc(sndbuf, BUFFER_SIZE);
            if (tmpbuf == NULL) {
                free(sndbuf);
            } else {
                sndbuf = tmpbuf;
            }
            n = sendto(sock, sndbuf, strlen(sndbuf), 0,
                       (struct sockaddr *)&clientaddr_in,
                       sizeof(struct sockaddr_in));
        }
        if (n == -1) {
            perror(exename);
            fprintf(stderr, "%s: error al hacer send\n", exename);
        }
        if (tmpbuf != NULL)
            free(sndbuf);

        time(&timevar);
        timetmp = localtime_r(&timevar, &timeres);
        strftime(timestr, sizeof(timestr), "[%d/%m/%y %X]", timetmp);
        if (code == 200) {
            printf("%s %s: Peticion atendida correctamente\n",
                   timestr, exename);
        } else {
            printf("%s %s: Peticion erronea. Codigo de error: %d\n",
                   timestr, exename, code);
        }
    }

    strncpy(protstr, isTCP ? "TCP" : "UDP", sizeof(protstr));
    printf(
        "%s %s: "
        "Comunicacion %s finalizada con %s (%s) y puerto efimero %u\n",
        timestr, exename, protstr, hostname, ipaddress,
        ntohs(clientaddr_in.sin_port));

    return;
}
