CC=gcc
CFLAGS=-g -Wall -Wextra -I.

DEPS=esquemas.h salida.h
OBJ=hanoi.o esquemas.o salida.o
TARGET=hanoi

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

$(TARGET): $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)

.PHONY: clean

clean:
	rm -f *.o $(TARGET)
