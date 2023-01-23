/**
 * pila.c	Implementación del tipo abstracto de dato pila.
 *
 *      Autor: Alberto García Martín <albertogm@usal.es>
 */

#include <stdlib.h>
#include "pila.h"

int pilaCreaVacia(Pila *p) {
  if (p == NULL) {
    return -1;
  } else {
    (*p) = NULL;
    return 0;
  }
}

int pilaVacia(Pila *p) {
  if (p == NULL) {
    return -1;
  } else if ((*p) == NULL) {
    return 1;
  } else {
    return 0;
  }
}

int pilaInserta(tipoElemento elemento, Pila *p) {
  tipoCelda *temp = NULL;

  if (p == NULL) {
    return -1;
  } else {
    if ((temp = (tipoCelda *) malloc(sizeof(tipoCelda))) == NULL)
      return -2;
    temp->elemento = elemento;
    if ((*p) != NULL) {
      temp->sig = (*p);
    } else {
      temp->sig = NULL;
    }
    (*p) = temp;

    return 0;
  }
}

// Se podría añadir un segundo parámetro para almacenar un código de error.
tipoElemento pilaSuprime(Pila *p) {
  tipoCelda *aBorrar = NULL;
  tipoElemento ret;

  if (p == NULL || (*p) == NULL) {
    return -1;
  } else {
    aBorrar = (*p);
    ret = aBorrar->elemento;
    if ((*p)->sig != NULL) {
      (*p) = aBorrar->sig;
      free(aBorrar);
    } else {
      free(aBorrar);
      (*p) = NULL;
    }

    return ret;
  }
}
