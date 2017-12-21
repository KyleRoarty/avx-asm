asm:
	make -f Makefile.asm $(P).bin

c:
	make -f Makefile.c

clean:
	rm -f $(P).bin $(P).o

cleanall:
	rm -f *.bin *.o
