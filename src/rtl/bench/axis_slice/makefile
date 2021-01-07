
SIMTIME= 300us
GHDL=ghdl
GHDLFLAGS=
GHDLRUNFLAGS=--wave=./slice.ghw --stop-time=$(SIMTIME)


# Default target : elaborate
all : run
	gtkwave ./slice.ghw &

# Elaborate target.  Almost useless
elab : init
	$(GHDL) -c $(GHDLFLAGS) -e bench_axis_slice

# Run target
run : elab
	$(GHDL) -c $(GHDLFLAGS) -r bench_axis_slice $(GHDLRUNFLAGS)

# Targets to analyze libraries
init: 
	$(GHDL) -a $(GHDLFLAGS) ../../bench_utils/axis_utils.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/axis_slice.vhd
	$(GHDL) -a $(GHDLFLAGS) bench_axis_slice.vhd
	
	

