CC = gcc 
CFLAGS =
LIBS =
# Descomentar la siguiente linea para olivo
#LIBS := $(LIBS) -lsocket -lnsl

DEBUG ?= 0
ifeq ($(DEBUG),1)
  CFLAGS := $(CFLAGS) -DDEBUG
endif

PROGS = servidor cliente

all: ${PROGS}

servidor: servidor.o
	${CC}${CFLAGS} -o $@ servidor.o ${LIBS}
	
cliente: cliente.o
	${CC}${CFLAGS} -o $@ cliente.o ${LIBS}

.PHONY: clean all
clean:
	rm -f *.o *.log ${PROGS}
