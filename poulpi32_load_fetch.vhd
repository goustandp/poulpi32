entity poulpi32_load_fetch is
	generic(
		G_ADDR_WIDTH : integer:= 32
	);
	port(
		-- clock and reset
		CLK 						: in std_logic;
		RSTN						: in std_logic;
		-- core signals
		PROGAM_COUNTER	: in   std_logic_vector(G_ADDR_WIDTH-1 downto 0);
		OP_CODE				: in  	std_logic_vector(2 downto 0);
		RS	_1						: in   std_logic_vector(31 downto 0);
		RS_2						: in   std_logic_vector(31 downto 0);
		IMM						: in   std_logic_vector(11 downto 0);
		OUT_VALUE				: out std_logic_vector(31 downto 0);
		-- control signals
		START_FECTH			: in  std_logic;
		START_LOAD 			: in  std_logic;
		START_STORE			: in  std_logic;
		READY					: out std_logic;
		-- AXI4 lite memory signals	
		AXI_AWVALID			: out std_logic;
		AXI_AWREADY        	: in   std_logic;
		AXI_AWADDR         	: out std_logic_vector(G_ADDR_WIDTH-1 downto 0);
		AXI_AWPROT           : out std_logic_vector(2 downto 0);
		AXI_WVALID            : out std_logic;
		AXI_WREADY          	: in  std_logic;
		AXI_WDATA            	: out std_logic_vector(31 downto 0);
		AXI_WSTRB            	: out std_logic_vector(3 downto 0);
		AXI_BVALID             : in  std_logic;
		AXI_BREADY           	: out std_logic;
		AXI_ARVALID          	: out std_logic;
		AXI_ARREADY          : in 	std_logic;
		AXI_ARADDR          	: out std_logic_vector(G_ADDR_WIDTH-1 downto 0);
		AXI_ARPROT           	: out std_logic_vector(2 downto 0);
		AXI_RVALID            	: in  	std_logic;
		AXI_RREADY          	: out std_logic;
		AXI_RDATA             	: in 	std_logic_vector(31 downto 0)
	);
end entity poulpi32_load_fetch;

architecture rtl of poulpi32_load_fetch is 
	signal axi_addr			: std_logic_vector(G_ADDR_WIDTH-1 downto 0);
	signal mem_started 	: std_logic;
	signal transfer_done	: std_logic;	

	P_LOAD_STORE_FETCH	: process(CLK)
	begin
		if risign_edge(CLK) then
			if (RSTN = '0') then
			else
			end if;
		end if;
	end process;
end rtl;
