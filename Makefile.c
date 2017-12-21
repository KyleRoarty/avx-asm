CC=gcc

CFLAGS= -g -Wall -std=gnu11
LDLIBS= avx_aes.o

$(P): $(LDLIBS)
