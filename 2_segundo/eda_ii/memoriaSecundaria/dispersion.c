#include "dispersion.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Crea un fichero hash inicialmente vacio segun los criterios especificados en la practica
// Primera tarea a realizar para  crear un fichero organizado mediante DISPERSION
void creaHvacio(char* fichHash)
{
    FILE* fHash;
    tipoCubo cubo;
    int j;
    int numCubos = CUBOS + CUBOSDESBORDE;

    memset(&cubo, 0, sizeof(cubo));

    fHash = fopen(fichHash, "wb");
    for (j = 0; j < numCubos; j++)
        fwrite(&cubo, sizeof(cubo), 1, fHash);
    fclose(fHash);
}

// Lee el contenido del fichero hash organizado mediante el metodo de DISPERSION segun los criterios
// especificados en la practica. Se leen todos los cubos completos tengan registros asignados o no. La
// salida que produce esta funcion permite visualizar el metodo de DISPERSION
int leeHash(char* fichHash)
{
    FILE* f;
    tipoCubo cubo;
    int j, i = 0;
    size_t numLee;

    f = fopen(fichHash, "rb");
    rewind(f);
    fread(&cubo, sizeof(cubo), 1, f);
    while (!feof(f)) {
        for (j = 0; j < C; j++) {
            if (j == 0)
                printf("Cubo %2d (%2d reg. ASIGNADOS)", i, cubo.numRegAsignados);
            else
                printf("\t\t\t");

            if (j < cubo.numRegAsignados)
                printf("\t%s %s %s %s %s\n",
                    cubo.reg[j].dni,
                    cubo.reg[j].nombre,
                    cubo.reg[j].ape1,
                    cubo.reg[j].ape2,
                    cubo.reg[j].provincia);
            else
                printf("\n");
        }

        i++;
        fread(&cubo, sizeof(cubo), 1, f);
    }

    fclose(f);
    return i;
}

int creaHash(char* fichEntrada, char* fichHash)
{
    FILE *fEntrada, *fHash;
    tipoCubo cubo;
    tipoAlumno reg;
    int numCubo, i = 0, j;

    creaHvacio(fichHash);

    fHash = fopen(fichHash, "r+b");
    rewind(fHash);

    fEntrada = fopen(fichEntrada, "rb");
    rewind(fEntrada);

    fread(&reg, sizeof(reg), 1, fEntrada);
    while (!feof(fEntrada)) {
        numCubo = atoi(reg.dni) % CUBOS;
        fseek(fHash, numCubo * sizeof(cubo), SEEK_SET);
        fread(&cubo, sizeof(cubo), 1, fHash);

        if (cubo.numRegAsignados < C) {
            cubo.reg[cubo.numRegAsignados] = reg;
            cubo.numRegAsignados++;
            fseek(fHash, numCubo * sizeof(cubo), SEEK_SET);
            fwrite(&cubo, sizeof(cubo), 1, fHash);
        } else {
            cubo.numRegAsignados++;
            fseek(fHash, numCubo * sizeof(cubo), SEEK_SET);
            fwrite(&cubo, sizeof(cubo), 1, fHash);

            fseek(fHash, CUBOS * sizeof(cubo), SEEK_SET);
            fread(&cubo, sizeof(cubo), 1, fHash);
            j = 0;
            while (cubo.numRegAsignados >= C) {
                cubo.numRegAsignados++;
                fseek(fHash, (CUBOS + j) * sizeof(cubo), SEEK_SET);
                fwrite(&cubo, sizeof(cubo), 1, fHash);
                j++;
                fseek(fHash, (CUBOS + j) * sizeof(cubo), SEEK_SET);
                fread(&cubo, sizeof(cubo), 1, fHash);
            }

            if (j < CUBOSDESBORDE) {
                cubo.reg[cubo.numRegAsignados] = reg;
                cubo.numRegAsignados++;
                fseek(fHash, (CUBOS + j) * sizeof(cubo), SEEK_SET);
                fwrite(&cubo, sizeof(cubo), 1, fHash);
            }
            i++;
        }

        fread(&reg, sizeof(reg), 1, fEntrada);
    }

    fclose(fEntrada);
    fclose(fHash);

    return i;
}

int buscaReg(FILE* fHash, tipoAlumno* reg, char* dni)
{
    int numCubo, i, j = 0, numReg, desborde;
    tipoCubo cubo;

    numCubo = atoi(dni) % CUBOS;
    fseek(fHash, numCubo * sizeof(cubo), SEEK_SET);
    fread(&cubo, sizeof(cubo), 1, fHash);
    if (cubo.numRegAsignados > C) {
        numReg = C;
        desborde = 1;
    } else {
        numReg = cubo.numRegAsignados;
        desborde = 0;
    }

    for (i = 0; i < numReg; i++) {
        if (!strcmp(cubo.reg[i].dni, dni)) {
            *reg = cubo.reg[i];
            return numCubo;
        }
    }

    while (desborde) {
        fseek(fHash, (CUBOS + j) * sizeof(cubo), SEEK_SET);
        fread(&cubo, sizeof(cubo), 1, fHash);
        if (cubo.numRegAsignados > C) {
            numReg = C;
            desborde = 1;
        } else {
            numReg = cubo.numRegAsignados;
            desborde = 0;
        }

        for (i = 0; i < numReg; i++) {
            if (!strcmp(cubo.reg[i].dni, dni)) {
                *reg = cubo.reg[i];
                return CUBOS + j;
            }
        }

        if (++j >= CUBOSDESBORDE)
            break;
    }

    return -1;
}

int insertarReg(FILE* fHash, tipoAlumno* reg)
{
}
