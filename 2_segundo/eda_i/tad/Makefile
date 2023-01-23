CC=gcc
CFLAGS=-Wall -Wextra -Wmissing-prototypes -Wundef -Werror=implicit-int \
       -Werror-implicit-function-declaration -Wdeclaration-after-statement\
       -std=gnu89 -g -I.

SRCS=%.c
DEPS=listas/lista.h pilas/pila.h colas/cola.h
OBJ=main.o listas/lista.o pilas/pila.o colas/cola.o
TARGET=entregaTAD

%.o: $(SRCS) $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

$(TARGET): $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)

.PHONY: clean

clean:
	rm -f *.o listas/*.o pilas/*.o colas/*.o $(TARGET) $(TARGET).exe
