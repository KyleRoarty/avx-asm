AS = as
CC = cc

ASFLAGS = -g
LDFLAGS = -nostartfiles
LDLIBS = strs.o

%.bin: %.o $(LDLIBS)
	$(CC) $(LDFLAGS) $< $(LDLIBS) -o $@
