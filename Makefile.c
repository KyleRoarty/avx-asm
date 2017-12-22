CC=gcc

CFLAGS= -g -Wall -std=gnu11
LDLIBS= -lm
OBJECTS= avx_aes.o

$(P): $(OBJECTS)
