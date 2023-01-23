#ifndef __PILA_H
#define __PILA_H

#ifndef __TIPO_ELEMENTO
#define __TIPO_ELEMENTO
typedef int tipoElemento;
#endif

#ifndef __TIPO_CELDA
#define __TIPO_CELDA
typedef struct tipoCelda {
  tipoElemento elemento;
  struct tipoCelda *sig;
} tipoCelda;
#endif

typedef tipoCelda *Pila;

int pilaCreaVacia(Pila *p);

// En vacía no sería necesario el paso por referencia
// pero por mantener la misma interfaz con la implementación
// de matrices
int pilaVacia(Pila *p);

int pilaInserta(tipoElemento elemento, Pila *p);

tipoElemento pilaSuprime(Pila *p);

#endif
