#include "./esquemas.h"
#include "./salida.h"

extern unsigned int contador;

void hanoi(int n, int origen, int destino, int aux, int **torre, int tam) {
    while (n > 0) {
        hanoi(n - 1, origen, aux, destino, torre, tam);
        if (!mover_disco(n, origen - 1, destino - 1, torre, tam)) {
            contador++;
            mensaje(n, origen, destino, contador);
            dibujar_estado(tam, torre);
        }
        intercambiar(&origen, &aux);
        n--;
    }
}

// Mueve un valor entero que representa un disco del array torre de origen al
// de destino. Cada disco tiene un valor entre 1 y TAM, el 0 representa una
// posicion vacia.
int mover_disco(int disco, int origen, int destino, int **torre, int tam) {
    int i, pos_orig = -1, pos_dest = -1;

    // Busqueda de la posicion en la torre de origen del disco a mover
    for (i = 0; i < tam; i++) {
        if (torre[i][origen] == disco) {
            pos_orig = i;
            break;
        }
    }

    // El disco que se mueve debera estar en la posicion mas cercana a la base
    // que no este ocupada (los discos mas grandes estan mas cerca de la base)
    for (i = tam - 1; i >= 0; i--) {
        if (torre[i][destino] == 0) {
            pos_dest = i;
            break;
        }
    }

    // Si el movimiento es erroneo se devuelve un codigo de error
    if (pos_orig < 0 || pos_dest < 0) {
        return -1;
    } else if (pos_dest < tam - 1 &&
               torre[pos_dest + 1][destino] < torre[pos_dest][destino]) {
        // El disco por debajo de la posicion final es menor que el movido
        return -2;
    } else {
        torre[pos_dest][destino] = torre[pos_orig][origen];
        torre[pos_orig][origen] = 0;

        return 0;
    }
}

void intercambiar(int *x, int *y) {
    int temp;

    temp = *x;
    *x = *y;
    *y = temp;
}
