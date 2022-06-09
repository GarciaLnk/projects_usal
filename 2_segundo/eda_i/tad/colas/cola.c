/**
 * cola.c	Implementación del tipo abstracto de dato cola.
 *
 *      Autor: Alberto García Martín <albertogm@usal.es>
 */

#include <stdlib.h>
#include "cola.h"

int colaCreaVacia(Cola *c) {
  if (c == NULL) {
    return -2;
  } else {
    c->frente = c->fondo = NULL;
    return 0;
  }
}

int colaVacia(Cola *c) {
  if (c == NULL) {
    return -1;
  } else if (c->frente == NULL) {
    return 1;
  } else {
    return 0;
  }
}

// nombre cambiado para coincidir con el archivo de cabecera
int colaInsertaC(tipoElemento elemento, Cola *c) {
  tipoCelda *temp = NULL, *aux;

  if (c == NULL) {
    return -1;
  } else {
    aux = c->frente;
    if ((temp = (tipoCelda *) malloc(sizeof(tipoCelda))) == NULL)
      return -2;
    temp->elemento = elemento;
    temp->sig = NULL;
    if (aux != NULL) {
      while (aux->sig != NULL) {
        aux = aux->sig;
      }
      aux->sig = temp;
    } else {
      c->frente = temp;
    }
    c->fondo = temp;

    return 0;
  }
}

// Se podría añadir un segundo parámetro para almacenar un código de error.
tipoElemento colaSuprime(Cola *c) {
  tipoCelda *aBorrar = NULL;
  tipoElemento ret;

  if (c == NULL || c->frente == NULL) {
    return -1;
  } else {
    aBorrar = c->frente;
    ret = aBorrar->elemento;
    if (c->frente->sig != NULL) {
      c->frente = aBorrar->sig;
      free(aBorrar);
    } else {
      free(aBorrar);
      c->frente = c->fondo = NULL;
    }

    return ret;
  }
}
