/**
 * main.c	Utilizacion de los TAD lista, pila y cola
 *          como si se trataran de un tipo primitivo.
 *
 *      Autor: Alberto García Martín
 */

#include <stdlib.h>
#include <time.h>
#include <stdio.h>
#include "listas/lista.h"
#include "pilas/pila.h"
#include "colas/cola.h"

int main() {
  Lista miLista;
  tipoPosicion p = NULL, aux = NULL;
  Pila miPila;
  Cola miCola;
  int i, n, error;

  srand((unsigned) time(NULL));

  printf("TIPOS ABSTRACTOS DE DATOS\n\n");

  // Prueba del TAD lista
  creaVacia(&miLista);

  for (i = 0; i < 20; i++) {
    error = inserta(rand() % 10, fin(&miLista), &miLista);
    if (error != 0) return 1;
  }

  printf("Lista completa:\n");
  if (!vacia(&miLista))
    imprime(&miLista);

  p = primero(&miLista);
  while (p != fin(&miLista)) {
    aux = siguiente(p, &miLista);
    while (aux != fin(&miLista)) {
      if (recupera(p, &miLista) == recupera(aux, &miLista)) {
        suprime(aux, &miLista);
      } else {
        aux = siguiente(aux, &miLista);
      }
    }
    p = siguiente(p, &miLista);
  }

  printf("\nLista sin repetir:\n");
  if (!vacia(&miLista))
    imprime(&miLista);

  printf("\nÚltimo elemento: %d\n\n",
         recupera(localiza(recupera(anterior(fin(&miLista), &miLista),
                                    &miLista),
                           &miLista), &miLista));

  anula(&miLista);

  if (vacia(&miLista) == 1)
    destruye(&miLista);
  else
    return 1;

  // Prueba del TAD pila
  pilaCreaVacia(&miPila);

  printf("\nPila inserta:\n");
  for (i = 0; i < 10; i++) {
    n = rand() % 10;
    printf("%d ", n);
    error = pilaInserta(n, &miPila);
    if (error != 0) return 1;
  }

  printf("\n\nPila suprime:\n");
  if (!pilaVacia(&miPila)) {
    for (i = 0; i < 10; i++) {
      printf("%d ", pilaSuprime(&miPila));
    }
  }
  printf("\n");

  if (pilaVacia(&miPila) != 1)
    return 1;

  // Prueba del TAD cola
  colaCreaVacia(&miCola);

  printf("\n\nCola inserta:\n");
  for (i = 0; i < 10; i++) {
    n = rand() % 10;
    printf("%d ", n);
    error = colaInsertaC(n, &miCola);
    if (error != 0) return 1;
  }

  printf("\n\nCola suprime:\n");
  if (!colaVacia(&miCola)) {
    for (i = 0; i < 10; i++) {
      printf("%d ", colaSuprime(&miCola));
    }
  }
  printf("\n");

  if (colaVacia(&miCola) != 1)
    return 1;

  return 0;
}
