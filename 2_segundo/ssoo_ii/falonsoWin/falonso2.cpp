#include "falonso2.h"
#include <Windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

HINSTANCE falonso2Dll;

int (*FALONSO2_inicio)(int);
int (*FALONSO2_fin)(int*);
int (*FALONSO2_luz_semAforo)(int, int);
int (*FALONSO2_inicio_coche)(int*, int*, int);
int (*FALONSO2_avance_coche)(int*, int*, int);
int (*FALONSO2_velocidad)(int, int, int);
int (*FALONSO2_cambio_carril)(int*, int*, int);
int (*FALONSO2_pausa)(void);
int (*FALONSO2_estado_semAforo)(int);
int (*FALONSO2_posiciOn_ocupada)(int, int);
void (*pon_error)(const char*);

DWORD WINAPI funcionCoches(LPVOID iCoche);
void cargarTablaCambioCarril();
int comprobarCruce(int carril, int desp);
int comprobarSemaforo(int carril, int desp, int cambio);

typedef struct infoCoche {
    int color;
    int desp;
    int carril;
    int vel;
} infoCoche;

HANDLE hTimer, mutex[274], sem[4];
LONG lContador;
int cambioCarril[137][2];

int main(int argc, char* argv[])
{
    int nCoches, ret, i, iContador;
    int colores[] = { 0, 4, 2, 6, 5, 3, 7 };
    infoCoche iCoche[40];
    HANDLE coche[40];
    LARGE_INTEGER tiempoEspera;
    tiempoEspera.QuadPart = -300000000LL;

    lContador = 0;

    falonso2Dll = LoadLibrary("falonso2.dll");
    if (falonso2Dll == NULL) {
        printf("ERROR: No se pudo leer la libreria");
        ExitProcess(0);
    }

    pon_error = (void (*)(const char*))GetProcAddress(falonso2Dll, "pon_error");
    if (pon_error == NULL) {
        printf("ERROR: GetProcAddress pon_error");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    FALONSO2_inicio = (int (*)(int))GetProcAddress(falonso2Dll, "FALONSO2_inicio");
    if (FALONSO2_inicio == NULL) {
        pon_error("ERROR: GetProcAddress FALONSO2_inicio");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    FALONSO2_fin = (int (*)(int*))GetProcAddress(falonso2Dll, "FALONSO2_fin");
    if (FALONSO2_fin == NULL) {
        pon_error("ERROR: GetProcAddress FALONSO2_fin");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    FALONSO2_luz_semAforo = (int (*)(int, int))GetProcAddress(falonso2Dll, "FALONSO2_luz_semAforo");
    if (FALONSO2_luz_semAforo == NULL) {
        pon_error("ERROR: GetProcAddress FALONSO2_luz_semAforo");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    FALONSO2_inicio_coche = (int (*)(int*, int*, int))GetProcAddress(falonso2Dll, "FALONSO2_inicio_coche");
    if (FALONSO2_inicio_coche == NULL) {
        pon_error("ERROR: GetProcAddress FALONSO2_inicio_coche");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    FALONSO2_avance_coche = (int (*)(int*, int*, int))GetProcAddress(falonso2Dll, "FALONSO2_avance_coche");
    if (FALONSO2_avance_coche == NULL) {
        pon_error("ERROR: GetProcAddress FALONSO2_avance_coche");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    FALONSO2_velocidad = (int (*)(int, int, int))GetProcAddress(falonso2Dll, "FALONSO2_velocidad");
    if (FALONSO2_velocidad == NULL) {
        pon_error("ERROR: GetProcAddress FALONSO2_velocidad");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    FALONSO2_cambio_carril = (int (*)(int*, int*, int))GetProcAddress(falonso2Dll, "FALONSO2_cambio_carril");
    if (FALONSO2_cambio_carril == NULL) {
        pon_error("ERROR: GetProcAddress FALONSO2_cambio_carril");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    FALONSO2_pausa = (int (*)(void))GetProcAddress(falonso2Dll, "FALONSO2_pausa");
    if (FALONSO2_pausa == NULL) {
        pon_error("ERROR: GetProcAddress FALONSO2_pausa");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    FALONSO2_estado_semAforo = (int (*)(int))GetProcAddress(falonso2Dll, "FALONSO2_estado_semAforo");
    if (FALONSO2_estado_semAforo == NULL) {
        pon_error("ERROR: GetProcAddress FALONSO2_estado_semAforo");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    FALONSO2_posiciOn_ocupada = (int (*)(int, int))GetProcAddress(falonso2Dll, "FALONSO2_posiciOn_ocupada");
    if (FALONSO2_posiciOn_ocupada == NULL) {
        pon_error("ERROR: GetProcAddress FALONSO2_posiciOn_ocupada");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    cargarTablaCambioCarril();

    if (argc < 3) {
        printf("no hay suficientes argumentos\n");
        printf("\nUso: falonso2.exe [num_coches] [velocidad]\n");
        return 1;
    }
    nCoches = atoi(argv[1]);
    if (nCoches < 1 || nCoches > 40) {
        printf("numero de coches invalido, use un numero entre 1 y 40\n");
        return 1;
    }
    ret = atoi(argv[2]);
    if (ret != 1 && ret != 0) {
        printf("velocidad invalida, introduzca 0 o 1\n");
        return 1;
    }

    hTimer = CreateWaitableTimer(NULL, TRUE, NULL);
    if (hTimer == NULL) {
        pon_error("ERROR al crear el temporizador");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }
    sem[0] = CreateSemaphore(NULL, 0, nCoches, NULL);
    if (sem[0] == NULL) {
        pon_error("ERROR al crear sem[0]");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }
    sem[1] = CreateSemaphore(NULL, 0, nCoches, NULL);
    if (sem[1] == NULL) {
        pon_error("ERROR al crear sem[1]");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }
    sem[2] = CreateSemaphore(NULL, 1, 1, NULL);
    if (sem[2] == NULL) {
        pon_error("ERROR al crear sem[2]");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }
    sem[3] = CreateSemaphore(NULL, 1, 1, NULL);
    if (sem[3] == NULL) {
        pon_error("ERROR al crear sem[3]");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    for (i = 0; i < 274; i++) {
        mutex[i] = CreateMutex(NULL, FALSE, NULL);
        if (mutex[i] == NULL) {
            pon_error("ERROR al crear mutex");
            if (FreeLibrary(falonso2Dll) == 0)
                printf("ERROR: No se pudo liberar la libreria");
            ExitProcess(0);
        }
    }

    if (FALONSO2_inicio(ret) == -1) {
        pon_error("ERROR al iniciar el circuito");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }

    for (i = 0; i < nCoches; i++) {
        srand(i * 100 + (int)time(NULL));
        iCoche[i].carril = i % 2;
        iCoche[i].desp = i;
        iCoche[i].color = colores[rand() % 7];
        iCoche[i].vel = 40 + rand() % 50;
        coche[i] = CreateThread(NULL, 0, funcionCoches, &iCoche[i], 0, NULL);
        if (coche[i] == NULL) {
            pon_error("ERROR al crear el hilo de un coche");
            if (FreeLibrary(falonso2Dll) == 0)
                printf("ERROR: No se pudo liberar la libreria");
            ExitProcess(0);
        }
    }

    for (i = 0; i < nCoches; i++)
        WaitForSingleObject(sem[0], INFINITE);
    FALONSO2_luz_semAforo(HORIZONTAL, VERDE);
    FALONSO2_luz_semAforo(VERTICAL, VERDE);
    if (SetWaitableTimer(hTimer, &tiempoEspera, 0, NULL, NULL, 0) == 0) {
        pon_error("ERROR iniciar el temporizador");
        if (FreeLibrary(falonso2Dll) == 0)
            printf("ERROR: No se pudo liberar la libreria");
        ExitProcess(0);
    }
    ReleaseSemaphore(sem[1], nCoches, NULL);

    while (WaitForSingleObject(hTimer, 0) != WAIT_OBJECT_0) {
        FALONSO2_luz_semAforo(HORIZONTAL, AMARILLO);
        WaitForSingleObject(sem[2], INFINITE);
        FALONSO2_pausa();
        FALONSO2_luz_semAforo(HORIZONTAL, ROJO);

        WaitForSingleObject(hTimer, 3000);

        FALONSO2_luz_semAforo(HORIZONTAL, AMARILLO);
        FALONSO2_luz_semAforo(VERTICAL, AMARILLO);
        FALONSO2_pausa();
        FALONSO2_luz_semAforo(HORIZONTAL, VERDE);
        ReleaseSemaphore(sem[2], 1, NULL);
        WaitForSingleObject(sem[3], INFINITE);
        FALONSO2_luz_semAforo(VERTICAL, ROJO);

        WaitForSingleObject(hTimer, 3000);

        FALONSO2_luz_semAforo(VERTICAL, AMARILLO);
        FALONSO2_pausa();
        FALONSO2_luz_semAforo(VERTICAL, VERDE);
        ReleaseSemaphore(sem[3], 1, NULL);
    }

    WaitForMultipleObjects(nCoches, coche, TRUE, INFINITE);

    iContador = (int)lContador;
    FALONSO2_fin(&iContador);

    if (FreeLibrary(falonso2Dll) == 0)
        printf("ERROR: No se pudo liberar la libreria");

    ExitProcess(0);
}

DWORD WINAPI funcionCoches(LPVOID iCoche)
{
    infoCoche* piCoche = (infoCoche*)iCoche;
    int carril = piCoche->carril;
    int desp = piCoche->desp;
    int color = piCoche->color;
    int vel = piCoche->vel;
    int despSig, despAntes, despCambio, despSigCambio, carrilCambio, carrilAntes;
    int cambio, cruce, cruceSig, cruceCambio, semaforo;
    HANDLE mutexCruce[2];

    cruce = comprobarCruce(carril, desp);
    if (cruce) {
        mutexCruce[0] = mutex[desp + 137 * carril];
        mutexCruce[1] = mutex[cruce];
        WaitForMultipleObjects(2, mutexCruce, TRUE, INFINITE);
    } else {
        WaitForSingleObject(mutex[desp + 137 * carril], INFINITE);
    }

    FALONSO2_inicio_coche(&carril, &desp, color);
    ReleaseSemaphore(sem[0], 1, NULL);
    WaitForSingleObject(sem[1], INFINITE);

    while (WaitForSingleObject(hTimer, 0) != WAIT_OBJECT_0) {
        despSig = (desp == 136) ? 0 : desp + 1;
        despAntes = desp;
        despCambio = cambioCarril[desp][carril];
        despSigCambio = (despCambio == 136) ? 0 : despCambio + 1;
        carrilCambio = carril ? 0 : 1;
        carrilAntes = carril;

        cambio = 0;
        cruce = comprobarCruce(carril, desp);
        semaforo = 0;

        if (FALONSO2_posiciOn_ocupada(carril, despSig)
            && !FALONSO2_posiciOn_ocupada(carrilCambio, despCambio)
            && !FALONSO2_posiciOn_ocupada(carrilCambio, despSigCambio))
            cambio = 1;

        if (!cambio) {
            semaforo = comprobarSemaforo(carril, despSig, cambio);
            cruceSig = comprobarCruce(carril, despSig);

            if (semaforo)
                WaitForSingleObject(sem[semaforo], INFINITE);

            if (cruceSig) {
                mutexCruce[0] = mutex[despSig + 137 * carril];
                mutexCruce[1] = mutex[cruceSig];
                WaitForMultipleObjects(2, mutexCruce, TRUE, INFINITE);
            } else {
                WaitForSingleObject(mutex[despSig + 137 * carril], INFINITE);
            }

            if (WaitForSingleObject(hTimer, 0) != WAIT_OBJECT_0)
                FALONSO2_avance_coche(&carril, &desp, color);
        } else {
            cruceCambio = comprobarCruce(carrilCambio, despCambio);
            semaforo = comprobarSemaforo(carrilCambio, despCambio, cambio);

            if (semaforo)
                WaitForSingleObject(sem[semaforo], INFINITE);

            if (cruceCambio) {
                mutexCruce[0] = mutex[despCambio + 137 * carrilCambio];
                mutexCruce[1] = mutex[cruceCambio];
                WaitForMultipleObjects(2, mutexCruce, TRUE, INFINITE);
            } else {
                WaitForSingleObject(mutex[despCambio + 137 * carrilCambio], INFINITE);
            }

            if (WaitForSingleObject(hTimer, 0) != WAIT_OBJECT_0)
                FALONSO2_cambio_carril(&carril, &desp, color);
        }

        if (cruce) {
            ReleaseMutex(mutex[cruce]);
            ReleaseMutex(mutex[despAntes + 137 * carrilAntes]);
        } else {
            ReleaseMutex(mutex[despAntes + 137 * carrilAntes]);
        }

        if (semaforo)
            ReleaseSemaphore(sem[semaforo], 1, NULL);

        if (!cambio) {
            if (!carril && desp == 133)
                InterlockedIncrement(&lContador);
            else if (carril && desp == 131)
                InterlockedIncrement(&lContador);
        }

        FALONSO2_velocidad(vel, carril, desp);
    }

    ExitThread(0);
}

void cargarTablaCambioCarril()
{
    int i;

    for (i = 0; i < 137; i++) {
        if (i >= 0 && i <= 13)
            cambioCarril[i][CARRIL_DERECHO] = i;
        else if (i >= 14 && i <= 28)
            cambioCarril[i][CARRIL_DERECHO] = i + 1;
        else if (i >= 29 && i <= 60)
            cambioCarril[i][CARRIL_DERECHO] = i;
        else if (i >= 61 && i <= 62)
            cambioCarril[i][CARRIL_DERECHO] = i - 1;
        else if (i >= 63 && i <= 65)
            cambioCarril[i][CARRIL_DERECHO] = i - 2;
        else if (i >= 66 && i <= 67)
            cambioCarril[i][CARRIL_DERECHO] = i - 3;
        else if (i == 68)
            cambioCarril[i][CARRIL_DERECHO] = i - 4;
        else if (i >= 69 && i <= 129)
            cambioCarril[i][CARRIL_DERECHO] = i - 5;
        else if (i == 130)
            cambioCarril[i][CARRIL_DERECHO] = i - 3;
        else if (i >= 131 && i <= 134)
            cambioCarril[i][CARRIL_DERECHO] = i - 2;
        else if (i >= 135 && i <= 136)
            cambioCarril[i][CARRIL_DERECHO] = i - 1;

        if (i >= 0 && i <= 15)
            cambioCarril[i][CARRIL_IZQUIERDO] = i;
        else if (i >= 16 && i <= 28)
            cambioCarril[i][CARRIL_IZQUIERDO] = i - 1;
        else if (i >= 29 && i <= 58)
            cambioCarril[i][CARRIL_IZQUIERDO] = i;
        else if (i >= 59 && i <= 60)
            cambioCarril[i][CARRIL_IZQUIERDO] = i + 1;
        else if (i >= 61 && i <= 62)
            cambioCarril[i][CARRIL_IZQUIERDO] = i + 2;
        else if (i >= 63 && i <= 64)
            cambioCarril[i][CARRIL_IZQUIERDO] = i + 4;
        else if (i >= 65 && i <= 125)
            cambioCarril[i][CARRIL_IZQUIERDO] = i + 5;
        else if (i == 126)
            cambioCarril[i][CARRIL_IZQUIERDO] = i + 4;
        else if (i >= 127 && i <= 128)
            cambioCarril[i][CARRIL_IZQUIERDO] = i + 3;
        else if (i >= 129 && i <= 133)
            cambioCarril[i][CARRIL_IZQUIERDO] = i + 2;
        else if (i >= 134 && i <= 136)
            cambioCarril[i][CARRIL_IZQUIERDO] = 136;
    }
}

int comprobarCruce(int carril, int desp)
{
    if (desp == 21 && carril == CARRIL_DERECHO)
        return 108;
    else if (desp == 23 && carril == CARRIL_DERECHO)
        return 101 + 137;
    else if (desp == 106 && carril == CARRIL_DERECHO)
        return 33 + 137;
    else if (desp == 108 && carril == CARRIL_DERECHO)
        return 31;
    else if (desp == 23 && carril == CARRIL_IZQUIERDO)
        return 106;
    else if (desp == 25 && carril == CARRIL_IZQUIERDO)
        return 99 + 137;
    else if (desp == 99 && carril == CARRIL_IZQUIERDO)
        return 35 + 137;
    else if (desp == 101 && carril == CARRIL_IZQUIERDO)
        return 33;
    else
        return 0;
}

int comprobarSemaforo(int carril, int desp, int cambio)
{
    if (desp == 21 && carril == CARRIL_DERECHO)
        return 3;
    else if (desp == 106 && carril == CARRIL_DERECHO && !cambio)
        return 2;
    else if (desp == 23 && carril == CARRIL_IZQUIERDO && !cambio)
        return 3;
    else if (desp == 99 && carril == CARRIL_IZQUIERDO)
        return 2;
    else
        return 0;
}
