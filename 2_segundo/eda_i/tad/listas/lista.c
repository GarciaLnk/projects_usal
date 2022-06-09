/**
 * lista.c	Implementación del tipo abstracto de dato lista con nodo ficticio.
 *
 *      Autor: Alberto García Martín <albertogm@usal.es>
 */

#include <stdio.h>
#include <stdlib.h>
#include "lista.h"

int creaVacia(Lista *l) {
  if (l == NULL) {
    return -2;
  } else if ((l->raiz = l->ultimo = (tipoCelda *) malloc(sizeof(tipoCelda)))
      == NULL) {
    return -1;
  } else {
    l->raiz->sig = NULL;
    return 0;
  }
}

int vacia(Lista *l) {
  if (l == NULL || l->raiz == NULL) {
    return -1;
  } else if (l->raiz->sig == NULL) {
    return 1;
  } else {
    return 0;
  }
}

int destruye(Lista *l) {
  if (l == NULL || l->raiz == NULL) {
    return -1;
  } else if (l->raiz->sig != NULL) {
    return -2;
  } else {
    free(l->raiz);
    l->raiz = l->ultimo = NULL;
    return 0;
  }
}

void imprime(Lista *l) {
  tipoCelda *aImprimir;
  int posicion;

  if (l == NULL || l->raiz == NULL) {
    return;
  } else {
    posicion = 1;
    aImprimir = l->raiz->sig;
    while (aImprimir != NULL) {
      printf("Valor: %d en posición: %d\n", aImprimir->elemento, posicion++);
      aImprimir = aImprimir->sig;
    }
    printf("%d valores en la lista\n", posicion - 1);
  }
}

tipoPosicion anterior(tipoPosicion p, Lista *l) {
  tipoCelda *anterior;

  if (l == NULL || l->raiz == NULL || p == NULL) {
    return NULL;
  } else if (p == l->raiz) {
    return l->raiz;
  } else {
    anterior = l->raiz;

    // Modificación en el bucle while para evitar un comportamiento
    // indeterminado si p no está en la lista.
    while (anterior != NULL && anterior->sig != p)
      anterior = anterior->sig;
    return anterior;
  }
}

/**
 * Inicio de la implementación de las funciones no proporcionadas.
 * Las funciones emplean bucles si se pasa una variable tipoPosicion
 * por referencia para comprobar que pertenece a la lista y así evitar
 * comportamientos indeterminados.
 */

tipoPosicion primero(Lista *l) {
  if (l == NULL)
    return NULL;
  else
    return l->raiz;
}

tipoPosicion fin(Lista *l) {
  if (l == NULL)
    return NULL;
  else
    return l->ultimo;
}

int inserta(tipoElemento x, tipoPosicion p, Lista *l) {
  tipoCelda *temp = NULL, *aux;

  if (l == NULL || l->raiz == NULL || p == NULL) {
    return -1;
  } else {
    aux = l->raiz;
    while (aux != NULL && aux != p)
      aux = aux->sig;
    if (aux == p) {
      if ((temp = (tipoCelda *) malloc(sizeof(tipoCelda))) == NULL)
        return -2;
      temp->elemento = x;
      temp->sig = p->sig;
      p->sig = temp;
      if (p == l->ultimo)
        l->ultimo = temp;
      return 0;
    } else {
      return 1;
    }
  }
}

int suprime(tipoPosicion p, Lista *l) {
  tipoCelda *aBorrar = NULL, *aux;

  if (l == NULL || l->raiz == NULL || p == NULL || p == l->ultimo) {
    return -1;
  } else {
    aux = l->raiz;
    while (aux != NULL && aux != p)
      aux = aux->sig;
    if (aux == p) {
      aBorrar = aux->sig;
      aux->sig = aBorrar->sig;
      if (aBorrar == l->ultimo)
        l->ultimo = aux;
      free(aBorrar);
      return 0;
    } else {
      return 1;
    }
  }
}

tipoPosicion siguiente(tipoPosicion p, Lista *l) {
  tipoCelda *siguiente;

  if (l == NULL || l->raiz == NULL || p == NULL) {
    return NULL;
  } else if (p == l->ultimo) {
    return l->ultimo;
  } else {
    siguiente = l->raiz;
    while (siguiente->sig != NULL && siguiente != p)
      siguiente = siguiente->sig;
    return siguiente->sig;
  }
}

tipoPosicion localiza(tipoElemento x, Lista *l) {
  tipoCelda *aux;

  if (l == NULL || l->raiz == NULL) {
    return NULL;
  } else {
    aux = l->raiz;
    while (aux->sig != NULL && aux->sig->elemento != x)
      aux = aux->sig;
    return aux;
  }
}

// Se podría añadir un tercer parámetro para almacenar un código de error y
// así evitar confundir un resultado con un posible error, pero habría que
// modificar el prototipo de la función.
tipoElemento recupera(tipoPosicion p, Lista *l) {
  tipoCelda *aux;

  if (l == NULL || l->raiz == NULL || p == NULL || p == l->ultimo) {
    return -1;
  } else {
    aux = l->raiz;
    while (aux != NULL && aux != p)
      aux = aux->sig;
    if (aux == p)
      return aux->sig->elemento;
    else
      return -2;
  }
}

int anula(Lista *l) {
  tipoCelda *aBorrar = NULL, *aux;

  if (l == NULL || l->raiz == NULL) {
    return -1;
  } else if (l->raiz->sig == NULL) {
    return 0;
  } else {
    aux = l->raiz->sig;
    while (aux != NULL) {
      aBorrar = aux;
      aux = aux->sig;
      free(aBorrar);
    }
    l->raiz->sig = NULL;
    l->ultimo = l->raiz;

    return 0;
  }
}
