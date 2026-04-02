CC=g++
CFLAGS=-O2
EXECS=DUO_fault_sim

.PHONY: all clean
all: $(EXECS)

%: %.cpp
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f $(EXECS)
