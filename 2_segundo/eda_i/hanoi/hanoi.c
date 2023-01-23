/*
 * Alberto Garcia Martin
 *
 *     TORRES DE HANOI
 *
 *     |       |       |
 *     O       |       |
 *    OOO      |       |
 *   OOOOO     |       |
 * +-------+-------+-------+
 *     1       2       3
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "./esquemas.h"
#include "./salida.h"

unsigned int contador;

int main()
{
    int i, num_discos, salir;
    char lect[3];
    int** torre;

    do {
        printf("\n\tTORRES DE HANOI\n");
        printf("\n Introduce el numero de discos (por defecto 3): ");

        if (fgets(lect, 3, stdin) != NULL) {
            // Limpieza del bufer de entrada si es necesario
            if (!strchr(lect, '\n'))
                while ((getchar()) != '\n')
                    continue;
            num_discos = strtol(lect, NULL, 10);
            if (num_discos <= 0)
                num_discos = 3;
        } else {
            num_discos = 3;
        }

        torre = malloc(num_discos * sizeof(*torre));
        if (torre == NULL)
            exit(-1);
        for (i = 0; i < num_discos; i++) {
            torre[i] = malloc(3 * sizeof(**torre));
            if (torre[i] == NULL)
                exit(-1);
        }

        // Al principio todos los discos estan en la torre 1
        for (i = 0; i < num_discos; i++) {
            torre[i][0] = i + 1;
            torre[i][1] = 0;
            torre[i][2] = 0;
        }

        contador = 0;
        dibujar_estado(num_discos, torre);
        hanoi(num_discos, 1, 3, 2, torre, num_discos);

        for (i = 0; i < num_discos; i++)
            free(torre[i]);
        free(torre);

        salir = 1;
        printf("\n\nDesea salir? (S/n) ");
        fgets(lect, 2, stdin);
        if (!strchr(lect, '\n'))
            while ((getchar()) != '\n')
                continue;
        if (lect[0] == 'n' || lect[0] == 'N') {
            salir = 0;
            for (i = 0; i < 30; i++)
                printf("\n");
        }
    } while (!salir);

    return 0;
}
