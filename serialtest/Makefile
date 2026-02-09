all: firmware

main.o: 63b50_main.s
	ca65 -g -s -o $@ -l $(@:.o=.lst) $(DEFINES) $<

firmware: main.o $(SOURCES:.s=.o)
	ld65 -vm -C firmware.cfg $(LIBS) -o $@ -m firmware.map -Ln firmware.vice $^

clean:
	 rm -f firmware *.o *.lst *map *vice
