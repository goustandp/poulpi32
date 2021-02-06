

SIMTIME= 4000us
GHDL=ghdl
GHDLFLAGS=-frelaxed --std=02
GHDLRUNFLAGS=--wave=./toto.ghw --stop-time=$(SIMTIME)


# Default target : elaborate
all : run
	gtkwave ./toto.ghw &

# Elaborate target.  Almost useless
elab : init
	$(GHDL) -c $(GHDLFLAGS) -e bench_poulpi32

# Run target
run : elab
	$(GHDL) -c $(GHDLFLAGS) -r bench_poulpi32 $(GHDLRUNFLAGS)

# Targets to analyze libraries
init: 
	$(GHDL) -a $(GHDLFLAGS) ../../poulpi32/poulpi32_pkg.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../poulpi32/poulpi32_core.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../poulpi32/poulpi32_decode.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../poulpi32/poulpi32_reg.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../poulpi32/poulpi32_load_store.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../poulpi32/poulpi32_branch.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../poulpi32/poulpi32_fetch.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../poulpi32/poulpi32_alu.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../poulpi32/poulpi32_mux.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/axil_bram.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/axis_demux.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/axis_mux.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/address_decoder.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/resp_manager.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/axis_interconnect.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../axi_utils/axil_crossbar.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../bench_utils/uart_emulator.vhd
	$(GHDL) -a $(GHDLFLAGS) bench_poulpi32.vhd

