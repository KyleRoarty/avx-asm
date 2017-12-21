CC=gcc

CFLAGS= -g -Wall -std=gnu11
LDLIBS=
OBJECTS= avx_aes.o

$(P): $(OBJECTS)
