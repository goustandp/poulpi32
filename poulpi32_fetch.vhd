entity poulpi32_fetch is
	port(
		-- clock and reset
		CLK 						: in  std_logic;
		RSTN						: in  std_logic;
		-- core signals
		PROGAM_COUNTER	: in   std_logic_vector(31 downto 0);
		FETCH_INSTR			: out std_logic_vector(31 downto 0);
		-- control signals
		START_FECTH			: in  std_logic;
		READY					: out std_logic;
		-- AXI4 lite memory signals (only read acces)
		AXI_BVALID             : in  std_logic;
		AXI_BREADY           	: out std_logic;
		AXI_ARVALID          	: out std_logic;
		AXI_ARREADY          : in 	std_logic;
		AXI_ARADDR          	: out std_logic_vector(31 downto 0);
		AXI_ARPROT           	: out std_logic_vector(2 downto 0);
		AXI_RVALID            	: in  	std_logic;
		AXI_RREADY          	: out std_logic;
		AXI_RDATA             	: in 	std_logic_vector(31 downto 0)
	);
end entity poulpi32_fetch;

architecture rtl of poulpi32_fetch is 
	signal axi_addr			: std_logic_vector(G_ADDR_WIDTH-1 downto 0)
	signal axi_arvalid_i		: std_logic;
	signal axi_rready_i 		: std_logic;
	signal axi_bready_i		: std_logic;


begin

	-- fetch module can only do I access
	AXI_ARPROT 	<= C_IACCESS;
	AXI_RREADY 	<= axi_rready_i;
	AXI_ARVALID	<= axi_arvalid_i;
	AXI_BREADY	<= axi_bready_i;
	
	READY 	<= not(axi_avralid_i) and not(axi_rready_i) and not(axi_bready_i);
	
	P_FETCH	: process(CLK)
	begin
		if risign_edge(CLK) then
			if (RSTN = '0') then
				--outputs
				FETCH_INSTR  	<= (others => '0');
				AXI_ARADDR		<= (others => '0');
				-- internals signals
				axi_arvalid_i		<= '0';
				axi_rready_i		<= '0';
				axi_bready_i		<= '0';
			else
				-- fetch stage 
				if (START_FECTH = '1') then
					AXI_ARADDR	<= PC;
					axi_rready_i	<= '1';
					axi_arvalid_i	<= '1';
					axi_bready_i	<='1';
				end if;
				
				-- adress OK
				if (AXI_AREADY = '1' and axi_arvalid_i  = '1') then
					axi_avralid_i	<= '0'; 
				end if;
				-- read data OK
				if (axi_rready_i = '1' and AXI_RVALID = '1') then
					axi_rready_i	<= '0';
					FETCH_INSTR	<= AXI_RDATA;
				end if,
				
				-- breasp OK (needed???)
				if (axi_bready_i = '1' and AXI_BVALID = '1') then
					axi_bready_i	<= '0';
				end if;
			end if;
		end if;
	end process;
end rtl;
