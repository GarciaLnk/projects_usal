#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "./salida.h"

void mensaje(int n, int origen, int destino, int contador)
{
    printf("\n\n\n Movimiento numero %d\n", contador);
    printf("\n Mueve el disco %d desde la torre %d a la %d\n", n, origen,
        destino);
}

// Crea las strings necesarias para poder representar los discos y las torres
// de forma apropiada aunque varie el numero de discos, luego las muestra por
// pantalla.
void dibujar_estado(int n_discos, int** torre)
{
    int i, j;

    char** disco = malloc((n_discos + 1) * sizeof(*disco));
    if (disco == NULL)
        exit(-1);
    for (i = 0; i < n_discos + 1; i++) {
        disco[i] = malloc((n_discos * 2) * sizeof(**disco));
        if (disco[i] == NULL)
            exit(-1);
    }

    // El primer disco representa una posicion vacia en una torre
    strncpy(disco[0], "", 1);
    for (j = 0; j < n_discos - 1; j++)
        strncat(disco[0], " ", 2);
    strncat(disco[0], "|", 2);
    for (j = 0; j < n_discos - 1; j++)
        strncat(disco[0], " ", 2);

    // Cada elemento i en el array disco es una string con i*2-1 caracteres
    // que representan un disco unico de tama�o i
    for (i = 1; i < n_discos + 1; i++) {
        strncpy(disco[i], "", 1);
        for (j = 0; j < n_discos - i; j++)
            strncat(disco[i], " ", 2);
        for (j = 0; j < i; j++)
            strncat(disco[i], "O", 2);
        for (j = 0; j < i - 1; j++)
            strncat(disco[i], "O", 2);
        for (j = 0; j < n_discos - i; j++)
            strncat(disco[i], " ", 2);
    }

    // Imprime las torres por pantalla, el valor de cada elemento del array
    // torre es igual al tama�o del disco que hay en esa posicion
    printf("\n    %s   %s   %s ", disco[0], disco[0], disco[0]);
    for (i = 0; i < n_discos; i++) {
        printf("\n ");
        for (j = 0; j < 3; j++)
            printf("   %s", disco[torre[i][j]]);
    }

    // Imprime la base de las torres
    printf("\n  ");
    printf("+");
    for (i = 0; i < 3; i++) {
        for (j = 0; j < n_discos * 2 + 1; j++)
            printf("-");
        printf("+");
    }
    printf("\n   ");
    for (i = 0; i < 3; i++) {
        for (j = 0; j < n_discos; j++)
            printf(" ");
        printf("%d", i + 1);
        for (j = 0; j < n_discos + 1; j++)
            printf(" ");
    }
    printf("\n");

    printf("\nPulse ENTER para continuar...");
    getchar();

    for (i = 0; i < n_discos + 1; i++)
        free(disco[i]);
    free(disco);
}
