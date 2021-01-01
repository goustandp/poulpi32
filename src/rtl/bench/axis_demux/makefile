
SIMTIME= 200us
GHDL=ghdl
GHDLFLAGS=
GHDLRUNFLAGS=--wave=./demux.ghw --stop-time=$(SIMTIME)


# Default target : elaborate
all : run
	gtkwave ./demux.ghw

# Elaborate target.  Almost useless
elab : init
	$(GHDL) -c $(GHDLFLAGS) -e bench_axis_demux

# Run target
run : elab
	$(GHDL) -c $(GHDLFLAGS) -r bench_axis_demux $(GHDLRUNFLAGS)

# Targets to analyze libraries
init: 
	$(GHDL) -a $(GHDLFLAGS) ../../bench_utils/axis_utils.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/axis_demux.vhd
	$(GHDL) -a $(GHDLFLAGS) bench_axis_demux.vhd
	
	

