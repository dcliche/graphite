VERILATOR = verilator

LDFLAGS := -LDFLAGS "$(shell sdl2-config --libs)"
CFLAGS := -CFLAGS "$(shell sdl2-config --cflags) -g -I ../../../common"

all: sim

clean:
	rm -rf obj_dir
	rm -f *.hex

sim: top.sv sim_main.cpp ../../common/graphite.c ../../common/graphite.h ../../common/cube.c ../../common/cube.h ../../common/teapot.c ../../common/teapot.h
	$(VERILATOR) -cc --exe $(CFLAGS) $(LDFLAGS) top.sv sim_main.cpp ../../common/graphite.c ../../common/cube.c ../../common/teapot.c -I..
	$(MAKE) -j 4 -C obj_dir -f Vtop.mk

run: sim
	cp ../*.hex .
	obj_dir/Vtop $(SERIAL)

.PHONY: all clean
