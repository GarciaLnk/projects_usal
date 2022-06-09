#ifdef DLL_EXPORTS
#define DLL_API __declspec(dllexport)
#else
#define DLL_API __declspec(dllimport)
#endif

#define PERROR(a) \
    {             \
        LPVOID lpMsgBuf;                                         \
        FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER |           \
                   FORMAT_MESSAGE_FROM_SYSTEM |                  \
                   FORMAT_MESSAGE_IGNORE_INSERTS, NULL,          \
                   GetLastError(),                               \
                   MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),    \
                   (LPTSTR) &lpMsgBuf,0,NULL );                  \
        fprintf(stderr,"%s:(%d)%s\n",a,GetLastError(),lpMsgBuf); \
        LocalFree( lpMsgBuf );                                   \
    }

#define NEGRO    0
#define ROJO     1
#define VERDE    2
#define AMARILLO 3
#define AZUL     4
#define MAGENTA  5
#define CYAN     6
#define BLANCO   7

#define CARRIL_DERECHO       0
#define CARRIL_IZQUIERDO     1

#define HORIZONTAL   0
#define VERTICAL     1

#ifdef DLL_EXPORTS
extern "C" DLL_API int FALONSO2_inicio(int ret);
extern "C" DLL_API int FALONSO2_fin(int *cuenta);
extern "C" DLL_API int FALONSO2_luz_semAforo(int direcciOn, int color);
extern "C" DLL_API int FALONSO2_estado_semAforo(int direcciOn);
extern "C" DLL_API int FALONSO2_inicio_coche(int *carril, int *desp, int color);
extern "C" DLL_API int FALONSO2_avance_coche(int *carril, int *desp, int color);
extern "C" DLL_API int FALONSO2_velocidad(int v, int carril, int desp);
extern "C" DLL_API int FALONSO2_cambio_carril(int *carril, int *desp, int color);
extern "C" DLL_API int FALONSO2_posiciOn_ocupada(int carril, int desp);
extern "C" DLL_API int FALONSO2_pausa(void);
extern "C" DLL_API void pon_error(const char *mensaje);
#endif

