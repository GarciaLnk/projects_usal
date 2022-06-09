#ifndef __COLA_H
#define __COLA_H

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

typedef struct {
  tipoCelda *frente, *fondo;
} Cola;

int colaCreaVacia(Cola *c);

// En vacía no sería necesario el paso por referencia
// pero por mantener la misma interfaz con la implementación
// de matrices
int colaVacia(Cola *c);

int colaInsertaC(tipoElemento elemento, Cola *c);

tipoElemento colaSuprime(Cola *c);

#endif
