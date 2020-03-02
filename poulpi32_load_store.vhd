entity poulpi32_load_fetch is
  generic(
    G_ADDR_WIDTH : integer:= 32
  );
  port(
    -- clock and reset
    CLK             : in  std_logic;
    RSTN            : in  std_logic;
    -- core signals
    PROGAM_COUNTER  : in   std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    OP_CODE       : in    std_logic_vector(2 downto 0);
    RS  _1            : in   std_logic_vector(31 downto 0);
    RS_2            : in   std_logic_vector(31 downto 0);
    IMM           : in   std_logic_vector(11 downto 0);
    OUT_VALUE       : out std_logic_vector(31 downto 0);
    -- control signals
    START_LOAD      : in  std_logic;
    START_STORE     : in  std_logic;
    READY         : out std_logic;
    -- AXI4 lite memory signals
    -- write adress
    AXI_AWVALID     : out std_logic;
    AXI_AWREADY         : in   std_logic;
    AXI_AWADDR          : out std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    AXI_AWPROT           : out std_logic_vector(2 downto 0);
    AXI_WVALID            : out std_logic;
    AXI_WREADY            : in  std_logic;
    AXI_WDATA             : out std_logic_vector(31 downto 0);
    AXI_WSTRB             : out std_logic_vector(3 downto 0);
    AXI_BVALID             : in  std_logic;
    AXI_BREADY            : out std_logic;
    AXI_ARVALID           : out std_logic;
    AXI_ARREADY          : in   std_logic;
    AXI_ARADDR            : out std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    AXI_ARPROT            : out std_logic_vector(2 downto 0);
    AXI_RVALID              : in    std_logic;
    AXI_RREADY            : out std_logic;
    AXI_RDATA               : in  std_logic_vector(31 downto 0)
  );
end entity poulpi32_load_fetch;

architecture rtl of poulpi32_load_fetch is
  -- signals for axi
  signal axi_addr_i             : std_logic_vector(G_ADDR_WIDTH-1 downto 0)
  signal axi_awvalid_i          : std_logic;
  signal axi_wvalid_i         : std_logic;
  signal axi_bready_i         : std_logic;
  signal axi_arvalid_i        : std_logic;
  signal axi_rready_i         : std_logic;




begin
  -- axi4 lite protocol is used in half dupex
  AXI_ARADDR            <= axi_addr;
  AXI_AWADDR            <= axi_addr;

  AXI_AWPROT            <= C_DACCESS;

  -- ready and valid signals
  AXI_AWVALID           <= axi_awvalid_i;
  AXI_WVALID            <= axi_wvalid_i;
  AXI_BREADY            <= axi_bready_i;
  AXI_ARVALID           <= axi_arvalid_i;
  AXI_RREADY            <= axi_rready_i;


  P_LOAD_STORE_FETCH  : process(CLK)
  variable v_loaded_value   : std_logic_vector(63 downto 0);
  begin
    if risign_edge(CLK) then
      if (RSTN = '0') then
        --outputs
        OUT_VALUE       <= (others => '0');
        AXI_WDATA       <= (others => '0');
        AXI_WSTRB       <= (others => '0');
        READY             <= '1';
        -- internals signals
        axi_addr_i            <= (others => '0');
        axi_awvalid_i       <= '0';
        axi_wvalid _i       <= '0';
        axi_bready_i       <= '0';
        axi_arvalid_i       <= '0';
        axi_rready_i        <= '0';
      else
        if (START_LOAD = '1') then
          axi_arvalid_i <= '1';
          axi_addr_i    <= PC(31 downto 2)&"00";
          axi_rready_i  <= '1';
          axi_bready_i  <= '1';
          READY     <= '0';
        end if;

        case OP_CODE is
        C_F3_LB
        C_F3_LH
        C_F3_LW
        C_F3_LBU
        C_F3_LHU
        C_F3_SB
                C_F3_SH
                C_F3_SW
        others =>
        end case;

      end if;
    end if;
  end process;
