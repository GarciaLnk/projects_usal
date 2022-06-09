#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dispersion.h"

/*
 *  Autor:  Alberto Garcia Martin
 */
int modificarReg(char *fichero, char *dni, char *provincia) {
  FILE *fHash;
  tipoCubo cubo;
  int numCubo, numReg, desborde, i, j;

  fHash = fopen(fichero, "r+b");
  numCubo = strtol(dni, NULL, 10) % CUBOS;
  
  fseek(fHash, numCubo * sizeof(cubo), SEEK_SET);
  fread(&cubo, sizeof(cubo), 1, fHash);
  if(cubo.numRegAsignados > C) {
    numReg = C;
    desborde = 1;
  } else {
    numReg = cubo.numRegAsignados;
    desborde = 0;
  }

  for(i = 0; i < numReg; i++) {
    if(!strcmp(cubo.reg[i].dni, dni)) {
      strcpy(cubo.reg[i].provincia, provincia);
      fseek(fHash, numCubo * sizeof(cubo), SEEK_SET);
      fwrite(&cubo, sizeof(cubo), 1, fHash);
      fclose(fHash);
      return numCubo;
    }
  }

  j = 0;
  while(desborde && j < CUBOSDESBORDE) {
    fseek(fHash, (CUBOS + j) * sizeof(cubo), SEEK_SET);
    fread(&cubo, sizeof(cubo), 1, fHash);
    if(cubo.numRegAsignados > C) {
      numReg = C;
      desborde = 1;
    } else {
      numReg = cubo.numRegAsignados;
      desborde = 0;
    }

    for(i = 0; i < numReg; i++) {
      if(!strcmp(cubo.reg[i].dni, dni)) {
        strcpy(cubo.reg[i].provincia, provincia);
        fseek(fHash, (CUBOS + j) * sizeof(cubo), SEEK_SET);
        fwrite(&cubo, sizeof(cubo), 1, fHash);
        fclose(fHash);
        return CUBOS + j;
      }
    }

    j++;
  }

  fclose(fHash);
  return -1;
}
