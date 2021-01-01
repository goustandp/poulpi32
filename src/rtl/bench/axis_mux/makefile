
SIMTIME= 200us
GHDL=ghdl
GHDLFLAGS=
GHDLRUNFLAGS=--wave=./mux.ghw --stop-time=$(SIMTIME)


# Default target : elaborate
all : run
	gtkwave ./mux.ghw

# Elaborate target.  Almost useless
elab : init
	$(GHDL) -c $(GHDLFLAGS) -e bench_axis_mux

# Run target
run : elab
	$(GHDL) -c $(GHDLFLAGS) -r bench_axis_mux $(GHDLRUNFLAGS)

# Targets to analyze libraries
init: 
	$(GHDL) -a $(GHDLFLAGS) ../../bench_utils/axis_utils.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/axis_mux.vhd
	$(GHDL) -a $(GHDLFLAGS) bench_axis_mux.vhd
	
	

