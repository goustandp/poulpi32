
SIMTIME= 200us
GHDL=ghdl
GHDLFLAGS= -v
GHDLRUNFLAGS=--wave=./interconnect.ghw --stop-time=$(SIMTIME)


# Default target : elaborate
all : run
	gtkwave ./interconnect.ghw

# Elaborate target.  Almost useless
elab : init
	$(GHDL) -c $(GHDLFLAGS) -e bench_axis_interconnect

# Run target
run : elab
	$(GHDL) -c $(GHDLFLAGS) -r bench_axis_interconnect $(GHDLRUNFLAGS)

# Targets to analyze libraries
init: 
	$(GHDL) -a $(GHDLFLAGS) ../../bench_utils/axis_utils.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/axis_demux.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/axis_mux.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/axis_interconnect.vhd
	$(GHDL) -a $(GHDLFLAGS) bench_axis_interconnect.vhd
	
	

