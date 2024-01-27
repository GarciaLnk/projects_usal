CC = gcc
CFLAGS =
LIBS =

PROGS = suscriptor difusor

all: ${PROGS}

suscriptor: suscriptor.o
	${CC} ${CFLAGS} -o $@ suscriptor.o ${LIBS}

difusor: difusor.o
	${CC} ${CFLAGS} -o $@ difusor.o ${LIBS}

.PHONY: clean all
clean:
	rm -f *.o ${PROGS}
