CC=g++
CFLAGS=-O2
EXECS=HBM4_fault_sim

.PHONY: all clean
all: $(EXECS)

%: %.cpp
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f $(EXECS)
