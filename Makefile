asm:
	make -f Makefile.asm $(P).bin

clean:
	rm -f $(P).bin $(P).o

cleanall:
	rm -f *.bin *.o
