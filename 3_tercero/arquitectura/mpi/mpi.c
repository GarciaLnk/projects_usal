#include <math.h>
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

#define CHAR_NF 32 // Para marcar no encontrado (espacio, por simplificar)
#define CHAR_MIN 33
#define CHAR_MAX 127

#define PESO_COMPROBAR 5000000
#define PESO_GENERAR 10000000

#define MAX_LONGITUD_PALABRA 255

double mygettime(void)
{
    double time = 0.0;
    time = clock();
    return time / CLOCKS_PER_SEC;
}

void fuerza_espera(unsigned long peso)
{
    for (unsigned long i = 1; i < 1 * peso; i++)
        sqrt(i);
}

int main(int argc, char* argv[])
{
    int id, numprocs;
    unsigned int seed;
    char palabra_secreta[MAX_LONGITUD_PALABRA] = { 0 };
    char palabra_adivina[MAX_LONGITUD_PALABRA] = { 0 };
    char pista[MAX_LONGITUD_PALABRA];
    char pista_anterior[MAX_LONGITUD_PALABRA];
    int lpalabra, idcomprobador;
    MPI_Status infosender, infogen;
    double tmpcomp, tmpgen, tmpespera, tmpsumcomp, tmpsumgen, tmpsumespera;
    double tmpcomptotal, tmpgentotal;
    int ngeneraciones, ncomprobaciones;
    int numparams, numcomp, modopista;
    int espera_mensaje, control = 1;

    for (int i = 0; i < MAX_LONGITUD_PALABRA; i++) {
        pista[i] = CHAR_NF;
        pista_anterior[i] = CHAR_NF;
    }

    numparams = argc;
    numcomp = strtol(argv[1], NULL, 10);
    modopista = strtol(argv[2], NULL, 10);

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &id);
    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);

    if (id == 0) { // E/S
        if (numparams < 3) {
            printf("Numero de argumentos invalido\n");
            printf("Uso: mpirun -np [numprocesos] mpi [numcomprobadores] [modopista]\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }

        if (numprocs < 3) {
            printf("Hacen falta al menos 3 procesos\n");
            MPI_Abort(MPI_COMM_WORLD, 2);
        } else if (numcomp < 1 || numcomp > (numprocs - 2)) {
            printf("El numero de comprobadores tiene que estar entre 1 y [numprocesos]-2\n");
            MPI_Abort(MPI_COMM_WORLD, 2);
        } else if (modopista != 0 && modopista != 1) {
            printf("El valor de modo pista solo puede ser 1 o 0\n");
            MPI_Abort(MPI_COMM_WORLD, 2);
        }

        printf("NUMERO DE PROCESOS: Total %d: E/S: 1, Comprobadores: %d, Generadores: %d\n\n",
            numprocs, numcomp, numprocs - numcomp - 1);
        snprintf(palabra_secreta, sizeof(palabra_secreta),
            "ABCDEFGHIJKLMNIOQUJAKSGHAJHGFSGfghafsghafsghafstjharfasdhjshdjh216531823612678&&!1281asdasdjahsdkjhadsljhaejuj");
        lpalabra = strlen(palabra_secreta);
        MPI_Bcast(&lpalabra, sizeof(lpalabra), MPI_INT, 0, MPI_COMM_WORLD);

        printf("NOTIFICACION TIPO\n");
        for (int i = 1; i < numprocs; i++) {
            if (i <= numcomp) {
                idcomprobador = 0;
            } else {
                idcomprobador = 1 + i % numcomp;
            }

            printf("%02d) %d\n", i, idcomprobador);
            MPI_Send(&idcomprobador, sizeof(idcomprobador), MPI_INT, i, 0, MPI_COMM_WORLD);
        }

        printf("\nNOTIFICACION PALABRA COMPROBADORES\n");
        for (int i = 1; i <= numcomp; i++) {
            MPI_Send(&palabra_secreta, sizeof(palabra_secreta), MPI_CHAR, i, 0, MPI_COMM_WORLD);
            printf("%02d) %s, %d\n", i, palabra_secreta, lpalabra);
        }
    } else {
        MPI_Bcast(&lpalabra, sizeof(lpalabra), MPI_INT, 0, MPI_COMM_WORLD);
        MPI_Recv(&idcomprobador, sizeof(idcomprobador), MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }

    if (id == 0) {
        double arrTC[4] = { 0 }, arrTG[10] = { 0 }, arrTE[10] = { 0 };
        int gentotal, comptotal;
        double tmptotal;

        printf("\nBUSCANDO\n");
        tmptotal = mygettime();
        while (control) {
            MPI_Recv(&pista, sizeof(pista), MPI_CHAR, MPI_ANY_SOURCE, 0, MPI_COMM_WORLD, &infogen);
            pista[lpalabra] = '\0';
            if (strncmp(pista, palabra_secreta, lpalabra) == 0) {
                control = 0;
                printf("\nPALABRA ENCONTRADA POR: %d\n", infogen.MPI_SOURCE);
                printf("BUSCADA...: %s\n", palabra_secreta);
                printf("ENCONTRADA: %s\n", pista);
            } else if (strncmp(pista, pista_anterior, lpalabra) != 0) {
                printf("%02d) PISTA.....: %s\n", infogen.MPI_SOURCE, pista);
                snprintf(pista_anterior, sizeof(pista_anterior), "%s", pista);

                if (modopista) {
                    for (int i = numcomp + 1; i < numprocs; i++) {
                        if (i != infogen.MPI_SOURCE) {
                            MPI_Send(&pista, sizeof(pista), MPI_CHAR, i, 1, MPI_COMM_WORLD);
                        }
                    }
                }
            }
        }

        for (int i = numcomp + 1; i < numprocs; i++) {
            MPI_Send(&control, sizeof(control), MPI_CHAR, i, 0, MPI_COMM_WORLD);
            printf("%02d) Fin Generadores\n", i);
        }

        printf("\nGeneradores\nIteraciones IteracionesTotal TpoTotal TpoGen TpoEspComp\n");
        gentotal = 0;
        for (int i = numcomp + 1; i < numprocs; i++) {
            MPI_Recv(&tmpsumgen, sizeof(tmpsumgen), MPI_DOUBLE, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            MPI_Recv(&tmpsumespera, sizeof(tmpsumespera), MPI_DOUBLE, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            MPI_Recv(&tmpgentotal, sizeof(tmpgentotal), MPI_DOUBLE, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            MPI_Recv(&ngeneraciones, sizeof(ngeneraciones), MPI_INT, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

            gentotal += ngeneraciones;
            printf("%02d) %4d %4d | %f, %f (%f), %f (%f)\n", i, ngeneraciones, gentotal, tmpgentotal, tmpsumgen,
                (tmpsumgen / tmpgentotal) * 100, tmpsumespera, (tmpsumespera / tmpgentotal) * 100);

            arrTG[i - (numcomp + 1)] = tmpsumgen / tmpgentotal;
            arrTE[i - (numcomp + 1)] = tmpsumespera / tmpgentotal;
        }

        for (int i = 1; i <= numcomp; i++) {
            MPI_Send(&control, sizeof(control), MPI_CHAR, i, 0, MPI_COMM_WORLD);
            printf("%02d) Fin Comprobadores\n", i);
        }

        printf("\nComprobadores\nIteraciones IteracionesTotal TpoTotal TpoComp\n");
        comptotal = 0;
        for (int i = 1; i <= numcomp; i++) {
            MPI_Recv(&tmpsumcomp, sizeof(tmpsumcomp), MPI_DOUBLE, i, 2, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            MPI_Recv(&tmpcomptotal, sizeof(tmpcomptotal), MPI_DOUBLE, i, 2, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            MPI_Recv(&ncomprobaciones, sizeof(ncomprobaciones), MPI_INT, i, 2, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

            comptotal += ncomprobaciones;
            printf("%02d) %4d %4d | %f, %f (%f)\n", i, ncomprobaciones, comptotal, tmpcomptotal, tmpsumcomp,
                (tmpsumcomp / tmpcomptotal) * 100);

            arrTC[i - 1] = tmpsumcomp / tmpcomptotal;
        }

        tmptotal = mygettime() - tmptotal;
        printf("\n>----------------ESTADISTICAS TOTALES----------------<\n");
        printf("Numero Procesos: %d\n", numprocs);
        printf("Tiempo Procesamiento: %f\n", tmptotal);
        printf("\n>----------------FIN----------------<\n");

        // printf(
        //     "%d; 1; %d; %d; %d; %d; %f;"
        //     " %f; %f; %f; %f;"
        //     " %f; %f; %f; %f; %f; %f; %f; %f; %f; %f;"
        //     " %f; %f; %f; %f; %f; %f; %f; %f; %f; %f;"
        //     " %f\n",
        //     numprocs, numcomp, numprocs - numcomp - 1, modopista, comptotal, tmptotal,
        //     arrTC[0], arrTC[1], arrTC[2], arrTC[3],
        //     arrTG[0], arrTE[0], arrTG[1], arrTE[1], arrTG[2], arrTE[2], arrTG[3], arrTE[3], arrTG[4], arrTE[4],
        //     arrTG[5], arrTE[5], arrTG[6], arrTE[6], arrTG[7], arrTE[7], arrTG[8], arrTE[8], arrTG[9], arrTE[9],
        //     comptotal / tmptotal);

    } else if (idcomprobador == 0) { // Comprobador
        MPI_Recv(&palabra_secreta, sizeof(palabra_secreta), MPI_CHAR, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        tmpsumcomp = 0;
        ncomprobaciones = 0;

        tmpcomptotal = mygettime();
        while (control) {
            MPI_Probe(MPI_ANY_SOURCE, 0, MPI_COMM_WORLD, &infosender);
            if (infosender.MPI_SOURCE == 0) {
                MPI_Recv(&control, sizeof(control), MPI_CHAR, infosender.MPI_SOURCE, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            } else {
                MPI_Recv(&palabra_adivina, sizeof(palabra_adivina), MPI_CHAR,
                    infosender.MPI_SOURCE, 0, MPI_COMM_WORLD, &infogen);
                tmpcomp = mygettime();
                for (int i = 0; i < lpalabra; i++) {
                    if (palabra_secreta[i] == palabra_adivina[i]) {
                        pista[i] = palabra_adivina[i];
                    } else {
                        pista[i] = CHAR_NF;
                    }
                }
                fuerza_espera(PESO_COMPROBAR);
                tmpcomp = mygettime() - tmpcomp;
                tmpsumcomp += tmpcomp;
                ncomprobaciones++;

                MPI_Send(&pista, sizeof(pista), MPI_CHAR, infosender.MPI_SOURCE, 0, MPI_COMM_WORLD);
            }
        }
        tmpcomptotal = mygettime() - tmpcomptotal;

        MPI_Send(&tmpsumcomp, sizeof(tmpsumcomp), MPI_DOUBLE, 0, 2, MPI_COMM_WORLD);
        MPI_Send(&tmpcomptotal, sizeof(tmpcomptotal), MPI_DOUBLE, 0, 2, MPI_COMM_WORLD);
        MPI_Send(&ncomprobaciones, sizeof(ncomprobaciones), MPI_INT, 0, 2, MPI_COMM_WORLD);
    } else { // Generador
        // seed = time(NULL) * id;
        seed = 1647545409 * id;
        srand(seed);

        ngeneraciones = 0;
        tmpsumgen = 0;
        tmpsumespera = 0;

        tmpgentotal = mygettime();
        while (control) {
            tmpgen = mygettime();
            for (int i = 0; i < lpalabra; i++) {
                if (pista[i] != CHAR_NF) {
                    palabra_adivina[i] = pista[i];
                } else {
                    palabra_adivina[i] = rand_r(&seed) % (CHAR_MAX + 1 - CHAR_MIN) + CHAR_MIN;
                }
            }
            fuerza_espera(PESO_GENERAR);
            tmpgen = mygettime() - tmpgen;
            tmpsumgen += tmpgen;
            ngeneraciones++;

            tmpespera = mygettime();
            MPI_Send(&palabra_adivina, sizeof(palabra_adivina), MPI_CHAR, idcomprobador, 0, MPI_COMM_WORLD);
            espera_mensaje = 1;
            while (espera_mensaje) {
                MPI_Probe(MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &infosender);
                if (infosender.MPI_SOURCE == 0) {
                    if (infosender.MPI_TAG == 0) {
                        MPI_Recv(&control, sizeof(control), MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
                        tmpespera = 0;
                        espera_mensaje = 0;
                    } else {
                        MPI_Recv(&pista, sizeof(pista), MPI_CHAR, 0, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
                        for (int i = 0; i < lpalabra; i++) {
                            if (pista[i] == CHAR_NF && pista_anterior[i] != CHAR_NF) {
                                pista[i] = pista_anterior[i];
                            }
                        }
                        snprintf(pista_anterior, sizeof(pista_anterior), "%s", pista);
                    }
                } else {
                    MPI_Recv(&pista, sizeof(pista), MPI_CHAR, idcomprobador, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
                    tmpespera = mygettime() - tmpespera;
                    espera_mensaje = 0;

                    if (strncmp(pista, pista_anterior, lpalabra) != 0) {
                        for (int i = 0; i < lpalabra; i++) {
                            if (pista[i] == CHAR_NF && pista_anterior[i] != CHAR_NF) {
                                pista[i] = pista_anterior[i];
                            }
                        }

                        MPI_Send(&pista, sizeof(pista), MPI_CHAR, 0, 0, MPI_COMM_WORLD);
                        snprintf(pista_anterior, sizeof(pista_anterior), "%s", pista);
                    }
                }
            }
            tmpsumespera += tmpespera;
        }
        tmpgentotal = mygettime() - tmpgentotal;

        MPI_Send(&tmpsumgen, sizeof(tmpsumgen), MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
        MPI_Send(&tmpsumespera, sizeof(tmpsumespera), MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
        MPI_Send(&tmpgentotal, sizeof(tmpgentotal), MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
        MPI_Send(&ngeneraciones, sizeof(ngeneraciones), MPI_INT, 0, 0, MPI_COMM_WORLD);
    }

    MPI_Finalize();
    return 0;
}
