

entity axil_crossbar is
  generic(
    G_ADDR_WIDTH          : integer := 32;
    G_DATA_WIDTH          : integer := 32;
    G_NB_SLAVE            : integer := 1;
    G_NB_SLAVE            : integer := 1;
    G_MAPPING_FILE        : string  := "mapping.txt";
    G_EN_SLAVE_REGISTER   : boolean := false;
    G_EN_MIDDLE_REGISTER  : boolean := false;
    G_EN_MASTER_REGISTER  : boolean := false
  );
  port(
    CLK               : in  std_logic;
    RSTN              : in  std_logic;
    
  
    -- slave interfaces
    -- write access
    S_AXI_AWVALID     : in  std_logic_vector(G_NB_SLAVE-1 downto 0);
    S_AXI_AWREADY     : out std_logic_vector(G_NB_SLAVE-1 downto 0);
    S_AXI_AWADDR      : in  std_logic_vector(G_ADDR_WIDTH*G_NB_SLAVE-1 downto 0);
    S_AXI_AWPROT      : in  std_logic_vector(3*G_NB_SLAVE-1 downto 0);
    S_AXI_WVALID      : in  std_logic_vector(G_NB_SLAVE-1 downto 0);
    S_AXI_WREADY      : out std_logic_vector(G_NB_SLAVE-1 downto 0);
    S_AXI_WDATA       : in  std_logic_vector(G_NB_SLAVE*G_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB       : in  std_logic_vector((G_DATA_WIDTH/8)*G_NB_SLAVE-1 downto 0);
    S_AXI_BVALID      : out std_logic_vector(G_NB_SLAVE-1 downto 0);
    S_AXI_BREADY      : in  std_logic_vector(G_NB_SLAVE-1 downto 0);
    S_AXI_BRESP       : out std_logic_vector(2*G_NB_SLAVE-1 downto 0);
    --read access
    S_AXI_ARVALID     : in  std_logic_vector(G_NB_SLAVE-1 downto 0);
    S_AXI_ARREADY     : out std_logic_vector(G_NB_SLAVE-1 downto 0);
    S_AXI_ARADDR      : in  std_logic_vector(G_ADDR_WIDTH*G_NB_SLAVE-1 downto 0);
    S_AXI_ARPROT      : in  std_logic_vector(3*G_NB_SLAVE-1 downto 0);
    S_AXI_RVALID      : out std_logic_vector(G_NB_SLAVE-1 downto 0);
    S_AXI_RREADY      : in  std_logic_vector(G_NB_SLAVE-1 downto 0);
    S_AXI_RDATA       : out std_logic_vector(G_NB_SLAVE*G_DATA_WIDTH-1 downto 0);
    S_AXI_RESP        : out std_logic_vector(2*G_NB_SLAVE-1 downto 0);
  
    -- master interfaces
    -- write access
    M_AXI_AWVALID     : out std_logic_vector(G_NB_MASTER-1 downto 0);
    M_AXI_AWREADY     : in  std_logic_vector(G_NB_MASTER-1 downto 0);
    M_AXI_AWADDR      : out std_logic_vector(G_ADDR_WIDTH*G_NB_MASTER-1 downto 0);
    M_AXI_AWPROT      : out std_logic_vector(3*G_NB_MASTER-1 downto 0);
    M_AXI_WVALID      : out std_logic_vector(G_NB_MASTER-1 downto 0);
    M_AXI_WREADY      : in  std_logic_vector(G_NB_MASTER-1 downto 0);
    M_AXI_WDATA       : out std_logic_vector(G_NB_MASTER*G_DATA_WIDTH-1 downto 0);
    M_AXI_WSTRB       : out std_logic_vector((G_DATA_WIDTH/8)*G_NB_MASTER-1 downto 0);
    M_AXI_BVALID      : in  std_logic_vector(G_NB_MASTER-1 downto 0);
    M_AXI_BREADY      : out std_logic_vector(G_NB_MASTER-1 downto 0);
    M_AXI_BRESP       : in  std_logic_vector(2*G_NB_MASTER-1 downto 0);
    --read access
    M_AXI_ARVALID     : out std_logic_vector(G_NB_MASTER-1 downto 0);
    M_AXI_ARREADY     : in  std_logic_vector(G_NB_MASTER-1 downto 0);
    M_AXI_ARADDR      : out std_logic_vector(G_ADDR_WIDTH*G_NB_MASTER-1 downto 0);
    M_AXI_ARPROT      : out std_logic_vector(3*G_NB_MASTER-1 downto 0);
    M_AXI_RVALID      : in  std_logic_vector(G_NB_MASTER-1 downto 0);
    M_AXI_RREADY      : out std_logic_vector(G_NB_MASTER-1 downto 0);
    M_AXI_RDATA       : in  std_logic_vector(G_NB_MASTER*G_DATA_WIDTH-1 downto 0);
    M_AXI_RESP        : in  std_logic_vector(2*G_NB_MASTER-1 downto 0)
  );
end entity axil_crossbar;

architecture rtl of axil_crossbar is


  component axis_demux is
    generic(
      G_NB_MASTER_OUTPUT  : integer := 1;
      G_TDATA_WIDTH       : integer := 1
      G_TUSER_WIDTH       : integer := 1;
      G_TDEST_WIDTH       : integer := 1:
      G_TID_WIDTH         : integer := 1;
    );
    
    port(
      -- masters interfaces
      M_AXIS_TDATA    : out std_logic_vector(G_NB_MASTER_OUTPUT*G_TDATA_WIDTH-1 downto 0);
      M_AXIS_TVALID   : out std_logic_vector(G_NB_MASTER_OUTPUT-1 downto 0);
      M_AXIS_TREADY   : in  std_logic_vector(G_NB_MASTER_OUTPUT-1 downto 0):='-';
      M_AXIS_TKEEP    : out std_logic_vector(G_NB_MASTER_OUTPUT*(G_TDATA_WIDTH/8)-1 downto 0);
      M_AXIS_TUSER    : out std_logic_vector(G_NB_MASTER_OUTPUT*G_TUSER_WIDTH-1 downto 0);
      M_AXIS_TDEST    : out std_logic_vector(G_NB_MASTER_OUTPUT*G_TDEST_WIDTH-1 downto 0);
      M_AXIS_TID      : out std_logic_vector(G_NB_MASTER_OUTPUT*G_TID_WIDTH-1 downto 0);
      -- slave interface
      S_AXIS_TDATA    : in  std_logic_vector(G_TDATA_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TVALID   : in  std_logic:='-';
      S_AXIS_TREADY   : out std_logic;
      S_AXIS_TKEEP    : in  std_logic_vector((G_TDATA_WIDTH/8)-1 downto 0):=(others => '-');
      S_AXIS_TUSER    : in  std_logic_vector(G_TUSER_WIDTH-1 downto 0) :=(others => '-');
      S_AXIS_TDEST    : in  std_logic_vector(G_TDEST_WIDTH-1 downto 0):= (others => '-');
      S_AXIS_TID      : in  std_logic_vector(G_TID_WIDTH-1 downto 0):=(others => '-')
    );
  end component;
  
  component axis_mux is
    generic(
      G_NB_SLAVE_INPUT  : integer := 1;
      G_TDATA_WIDTH     : integer := 1;
      G_TUSER_WIDTH     : integer := 1;
      G_TDEST_WIDTH     : integer := 1;
      G_TID_WIDTH       : integer:=1
    );
    
    port(
      -- slaves interfaces
      S_AXIS_TDATA    : in  std_logic_vector(G_NB_SLAVE_INPUT*G_TDATA_WIDTH-1 downto 0):=(others => '-');;
      S_AXIS_TVALID   : in  std_logic_vector(G_NB_SLAVE_INPUT-1 downto 0):=(others => '-');;
      S_AXIS_TREADY   : out std_logic_vector(G_NB_SLAVE_INPUT-1 downto 0);
      S_AXIS_TKEEP    : in  std_logic_vector(G_NB_SLAVE_INPUT*(G_TDATA_WIDTH/8)-1 downto 0):=(others => '-');;
      S_AXIS_TUSER    : in  std_logic_vector(G_NB_SLAVE_INPUT*G_TUSER_WIDTH-1 downto 0):=(others => '-');;
      S_AXIS_TID      : in  std_logic_vector(G_NB_MASTER_INPUT*G_TID_WIDTH-1 downto 0):=(others => '-');;
      S_AXIS_TDEST    : in  std_logic_vector(G_NB_MASTER_INPUT*G_TDEST_WIDTH-1 downto 0):=(others => '-');;

      
      -- master interface
      M_AXIS_TDATA    : out std_logic_vector(G_TDATA_WIDTH-1 downto 0);
      M_AXIS_TVALID   : out std_logic;
      M_AXIS_TREADY   : in  std_logic:='-';
      M_AXIS_TKEEP    : out std_logic_vector((G_TDATA_WIDTH/8)-1 downto 0);
      M_AXIS_TUSER    : out std_logic_vector(G_TUSER_WIDTH-1 downto 0);
      M_AXIS_TID      : out std_logic_vector(G_TID_WIDTH-1 downto 0);
      M_AXIS_TDEST    : out std_logic_vector(G_TEST_WIDTH-1 downto 0)
    );
  end component;
  
  component address_decoder is 
    generic(
      G_ADDR_WIDTH          : integer := 32;
      G_NB_SLAVE            : integer := 1;
      G_MAPPING_FILE        : string  := "mapping.txt"
    );
    port(
      -- address
      ADDR_TDATA          : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
      ADDR_TVALID         : in  std_logic;
      -- decoded tdest
      TDEST               : out std_logic_vector(ceil(log2(real(G_NB_SLAVE)))-1 downto 0)
    );
  end component;
  
  component resp_manager is
    generic(
      G_TDEST_WIDTH : integer:=1;
    );
    port(
      CLK         : in  std_logic;
      RSTN        : in  std_logic;
      
      AXIS_TREADY : in std_logic;
      AXIS_TVALDI : in std_logic;
      
      TID         : in  std_logic_vector(G_TDEST_WIDTH-1 downto 0);
      TDEST       : out std_logic_vector(G_TDEST_WIDTH-1 downto 0)
    );
  end component;

begin

  --TODO: fill architecture
end rtl;
