

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
      S_AXIS_TDATA    : in  std_logic_vector(G_NB_SLAVE_INPUT*G_TDATA_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TVALID   : in  std_logic_vector(G_NB_SLAVE_INPUT-1 downto 0):=(others => '-');
      S_AXIS_TREADY   : out std_logic_vector(G_NB_SLAVE_INPUT-1 downto 0);
      S_AXIS_TKEEP    : in  std_logic_vector(G_NB_SLAVE_INPUT*(G_TDATA_WIDTH/8)-1 downto 0):=(others => '-');
      S_AXIS_TUSER    : in  std_logic_vector(G_NB_SLAVE_INPUT*G_TUSER_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TID      : in  std_logic_vector(G_NB_MASTER_INPUT*G_TID_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TDEST    : in  std_logic_vector(G_NB_MASTER_INPUT*G_TDEST_WIDTH-1 downto 0):=(others => '-');

      
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
      G_MAPPING_FILE        : string  := "mapping.txt";
      G_TDEST_WIDTH         : integer := 1
    );
    port(
      -- address
      ADDR_TDATA          : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
      ADDR_TVALID         : in  std_logic;
      -- decoded tdest
      TDEST               : out std_logic_vector(G_TDEST_WIDTH-1 downto 0)
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

  constant C_TDEST_WIDTH : integer:= ceil(log2(real(max(G_NB_SLAVE, G_NB_MASTER)));

  -- address write channel
  -- demux signals
  signal m_axis_awvalid     : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal m_axis_awready     : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal m_axis_awaddr      : std_logic_vector(G_ADDR_WIDTH*G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal m_axis_awprot      : std_logic_vector(3*G_NB_SLAVE*G_NB_MASTER-1 downto 0); --tuser
  signal m_axis_arwtid      : std_logic_vector(C_TDEST_WIDTH*G_NB_SLAVE*G_NB_MASTER-1 downto 0); --tid is the same for adress and data 
  -- mux signals
  signal s_axis_awvalid     : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal s_axis_awready     : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal s_axis_awaddr      : std_logic_vector(G_ADDR_WIDTH*G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal s_axis_awprot      : std_logic_vector(3*G_NB_SLAVE*G_NB_MASTER-1 downto 0); --tuser
  signal s_axis_arwtid      : std_logic_vector(C_TDEST_WIDTH*G_NB_SLAVE*G_NB_MASTER-1 downto 0); --tid is the same for adress and data 
  
  signal axis_arwtdest    : std_logic_vector(C_TDEST_WIDTH*G_NB_SLAVE-1 downto 0); --tdest is the same for adress and data 
  

  -- data write channel
  -- demux signals
  signal m_axis_wvalid      : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal m_axis_wready      : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal m_axis_wdata       : std_logic_vector(G_NB_SLAVE*G_NB_MASTER*G_DATA_WIDTH-1 downto 0);
  signal m_axis_wstrb       : std_logic_vector((G_DATA_WIDTH/8)*G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  --mux signals
  signal s_axis_wvalid      : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal s_axis_wready      : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal s_axis_wdata       : std_logic_vector(G_NB_SLAVE*G_NB_MASTER*G_DATA_WIDTH-1 downto 0);
  signal s_axis_wstrb       : std_logic_vector((G_DATA_WIDTH/8)*G_NB_SLAVE*G_NB_MASTER-1 downto 0);


  -- bresp channel 
  signal axis_bvalid      : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal axis_bready      : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal axis_bresp       : std_logic_vector(2*G_NB_SLAVE*G_NB_MASTER-1 downto 0); -- tdata
  signal axis_btdest      : std_logic_vector(C_TDEST_WIDTH*G_NB_MASTER-1 downto 0); 

  -- address read channel
  signal axis_arvalid     : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal axis_arready     : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal axis_araddr      : std_logic_vector(G_ADDR_WIDTH*G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal axis_arprot      : std_logic_vector(3*G_NB_SLAVE*G_NB_MASTER-1 downto 0); --tuser
  signal axis_artid       : std_logic_vector(C_TDEST_WIDTH*G_NB_SLAVE*G_NB_MASTER-1 downto 0); 
  signal axis_artdest     : std_logic_vector(C_TDEST_WIDTH*G_NB_SLAVE-1 downto 0); 
  
  
  -- read data channel
  signal axis_rvalid      : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal axis_rready      : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal axis_rdata       : std_logic_vector(G_NB_SLAVE*G_DATA_WIDTH*G_NB_MASTER-1 downto 0);
  signal axis_resp        : std_logic_vector(2*G_NB_SLAVE*G_NB_MASTER-1 downto 0); --tuser
  signal axis_rtdest      : std_logic_vector(C_TDEST_WIDTH*G_NB_MASTER-1 downto 0); 
  
begin

  GEN_SLAVE_WRITE: 
    for i in 0 to G_NB_SLAVE-1 generate
      
      -- decode address for write channel
      inst_address_decoder_wa : address_decoder
        generic map( 
          G_ADDR_WIDTH          => G_ADDR_WIDTH,
          G_NB_SLAVE            => G_NB_SLAVE,
          G_MAPPING_FILE        => G_MAPPING_FILE,
          G_TDEST_WIDTH         => C_TDEST_WIDTH,
        )
        port map(
          ADDR_TDATA            => S_AXI_AWADDR(S_AXI_AWADDR*G_ADDR_WIDTH*(i+1)-1 downto S_AXI_AWADDR*G_ADDR_WIDTH*i), 
          ADDR_TVALID           => S_AXI_AWVALID(i)
          TDEST                 => axis_arwtdest(C_TDEST_WIDTH*(i+1)-1 downto C_TDEST_WIDTH*i)
        );
        
    -- demux for write address
    inst_axis_demux_aw : axis_demux
      generic map(
        G_NB_MASTER_OUTPUT  => G_NB_MASTER,
        G_TDATA_WIDTH       => G_ADDR_WIDTH,
        G_TUSER_WIDTH       => 3, -- awprot
        G_TID_WIDTH         => C_TDEST_WIDTH,
      )
      port map(
        M_AXIS_TDATA    => m_axis_awaddr(G_ADDR_WIDTH*G_NB_MASTER(i+1)-1 downto G_ADDR_WIDTH*G_NB_MASTER*i);
        M_AXIS_TVALID   => m_axis_awvalid(G_NB_MASTER(i+1)-1 downto G_NB_MASTER*i);
        M_AXIS_TREADY   => m_axis_awready(G_NB_MASTER(i+1)-1 downto G_NB_MASTER*i);
        M_AXIS_TUSER    => m_axis_awprot(3*G_NB_MASTER(i+1)-1 downto 3*G_NB_MASTER*i);
        M_AXIS_TID      => m_axis_arwtid(C_TDEST_WIDTH*G_NB_MASTER(i+1)-1 downto C_TDEST_WIDTH*G_NB_MASTER*i);
        S_AXIS_TDATA    => S_AXI_AWADDR(G_ADDR_WIDTH*i-1 downto G_ADDR_WIDTH*i),
        S_AXIS_TVALID   => S_AXI_WVALID(i),
        S_AXIS_TREADY   => S_AXI_WREADY(i),
        S_AXIS_TUSER    => S_AXI_AWPROT(3*(i+1)-1 downto 3*i),
        S_AXIS_TDEST    => axis_arwtdest(C_TDEST_WIDTH*(i+1)-1 downto C_TDEST_WIDTH*i),
        S_AXIS_TID      => std_logic_vector(to_unsigned(i, C_TDEST_WIDTH)
      );
    
    
    -- demux for write data
    inst_axis_demux_w : axis_demux
      generic map(
        G_NB_MASTER_OUTPUT  => G_NB_MASTER,
        G_TDATA_WIDTH       => G_ADDR_WIDTH,
        G_TUSER_WIDTH       => 3, -- awprot
        G_TID_WIDTH         => C_TDEST_WIDTH,
      )
      port map(
        M_AXIS_TDATA    => m_axis_awaddr(G_ADDR_WIDTH*G_NB_MASTER(i+1)-1 downto G_ADDR_WIDTH*G_NB_MASTER*i);
        M_AXIS_TVALID   => m_axis_wvalid(G_NB_MASTER(i+1)-1 downto G_NB_MASTER*i);
        M_AXIS_TREADY   => m_axis_wready(G_NB_MASTER(i+1)-1 downto G_NB_MASTER*i);
        M_AXIS_TKEEP    => m_axis_wstrb((G_DATA_WIDTH/8)*G_NB_MASTER(i+1)-1 downto (G_DATA_WIDTH/8)*G_NB_MASTER*i);
        S_AXIS_TDATA    => S_AXI_WDATA(G_DATA_WIDTH*(i+1)-i downto G_DATA_WIDTH*i),
        S_AXIS_TVALID   => S_AXI_WVALID(i),
        S_AXIS_TREADY   => S_AXI_WREADY(i),
        S_AXIS_TKEEP    => S_AXI_WSTRB((G_DATA_WIDTH/8)*(i+1)-1 downto (G_DATA_WIDTH/8)*i),
        S_AXIS_TDEST    => axis_arwtdest(C_TDEST_WIDTH*(i+1)-1 downto C_TDEST_WIDTH*i)
      );
    
    -- connect axil slave i to axil master j
    GEN_SLAVE_TO_MASTER:
    for j in 0 to G_NB_MASTER generate
    
    end generate GEN_SLAVE_TO_MASTER;
  
  end generate GEN_SLAVE_WRITE;


  
end rtl;
