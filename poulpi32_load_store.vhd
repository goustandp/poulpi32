entity poulpi32_load_fetch is
	generic(
		G_ADDR_WIDTH : integer:= 32
	);
	port(
		-- clock and reset
		CLK 						: in  std_logic;
		RSTN						: in  std_logic;
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
		-- write adress
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
	signal axi_addr			: std_logic_vector(G_ADDR_WIDTH-1 downto 0)
	signal axi_arvalid		: std_logic;
	signal axi_awvalid		: std_logic;
	signal ready_i		 	: std_logic;


begin
	-- axi4 lite protocol is used in half dupex
	AXI_ARADDR 		<= axi_addr;
	AXI_AWADDR  	<= axi_addr;
	AXI_ARVALID		<= axi_arvalid_i;
	AXI_AWVALID		<= axi_awvalid_i;
	
	P_LOAD_STORE_FETCH	: process(CLK)
	begin
		if risign_edge(CLK) then
			if (RSTN = '0') then
				--outputs
				OUT_VALUE			<= (others => '0');
				READY				<= '0';
				AXI_AWVALID		<= '0';
				AXI_AWPROT  		<= (others => '0');
				AXI_WVALID   		<= '0';
				AXI_WDATA   		<= (others => '0');
				AXI_WSTRB   		<= (others => '0');
				AXI_BREADY  		<= '0';
				AXI_RREADY    	<= '0';
				-- internals signals
				axi_addr				<= (others => '0');
				ready_i				<= '0';
			else
				-- fetch stage 
				if (START_FECTH = '1') then
					if (ready_i = '1') then
						axi_addr			<= PC;
						AXI_RREADY	<= '1';
						axi_arvalid_i	<= '1';
						AXI_ARPROT	<= C_IACCESS;
						ready_i			<= '0';
					elsif (AXI_RVALID = '1') then -- RREADY is 1
						OUTPUT_VALUE	<= AXI_RDATA;
						AXI_RREADY		<= '0';
						ready_i				<= '1';
					end if;
				-- load stage (part of execute)
				elsif (START_LOAD = '1') then
					if  (ready_i = '1') then
						axi_addr			<= unsigned(RS1)+resize(signed(IMM), 32);
						AXI_RREADY	<= '1';
						axi_arvalid_i	<= '1';
						AXI_ARPROT	<= C_IACCESS;
						ready_i			<= '0';
					elsif (AXI_RVALID = '1') then
						AXI_RREADY	<= '0';
						ready_i			<= '1';
						case OP_CODE is 
							when C_F3_LB 	=>
								OUTPUT_VALUE	<= std_logic_vector(resize(signed(AXI_RDATA(7 downto 0)) , 32));
							when C_F3_LBU	=>
								OUTPUT_VALUE	<= std_logic_vector(resize(unsigned(AXI_RDATA(7 downto 0)) , 32));
							when C_F3_LH	=>
								OUTPUT_VALUE	<= std_logic_vector(resize(signed(AXI_RDATA(15 downto 0)) , 32));
							when C_F3_LHU	=> 
								OUTPUT_VALUE	<= std_logic_vector(resize(unsigned(AXI_RDATA(15 downto 0)) , 32));
							when C_F3_LW	=>
								OUTPUT_VALUE	<= AXI_RDATA;
							when others => -- not normal
								OUTPUT_VALUE	<= AXI_RDATA;
						end case;
					end if;
				-- store stage (part of execute)
				elsif (START_STORE = '1') then
				end if;
				-- read adress is OK
				if (AXI_AREADY = '1' and axi_arvalid_i  = '1') then
					axi_avralid_i	<= '0'; 
				end if;
				
			end if;
		end if;
	end process;
