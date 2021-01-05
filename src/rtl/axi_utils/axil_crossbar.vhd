
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

library std;
  use std.textio.all;

entity axil_crossbar is
  generic(
    G_ADDR_WIDTH          : integer := 32;
    G_DATA_WIDTH          : integer := 32;
    G_NB_SLAVE            : integer := 1;
    G_NB_MASTER            : integer := 1;
    G_MAPPING_FILE        : string  := "mapping.txt";
    G_EN_SLAVE_REGISTER   : boolean := false; --TODO: add sregister slice
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
      G_TDEST_WIDTH : integer:=1
    );
    port(
      CLK         : in  std_logic;
      RSTN        : in  std_logic;
      
      AXIS_TREADY : in std_logic;
      AXIS_TVALID : in std_logic;
      
      TID         : in  std_logic_vector(G_TDEST_WIDTH-1 downto 0);
      TDEST       : out std_logic_vector(G_TDEST_WIDTH-1 downto 0)
    );
  end component;
  
  component axis_interconnect is
    generic(
      G_NB_SLAVE          : integer := 1;
      G_NB_MASTER         : integer := 1;
      G_TDATA_WIDTH       : integer := 1;
      G_TUSER_WIDTH       : integer := 1;
      G_TDEST_WIDTH       : integer := 1;
      G_TID_WIDTH         : integer := 1
    );
    
    port(
      -- slaves interfaces
      S_AXIS_TDATA    : in  std_logic_vector(G_NB_SLAVE*G_TDATA_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TVALID   : in  std_logic_vector(G_NB_SLAVE-1 downto 0):=(others => '-');
      S_AXIS_TREADY   : out std_logic_vector(G_NB_SLAVE-1 downto 0);
      S_AXIS_TKEEP    : in  std_logic_vector(G_NB_SLAVE*(G_TDATA_WIDTH/8)-1 downto 0):=(others => '-');
      S_AXIS_TUSER    : in  std_logic_vector(G_NB_SLAVE*G_TUSER_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TID      : in  std_logic_vector(G_NB_SLAVE*G_TID_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TDEST    : in  std_logic_vector(G_NB_SLAVE*G_TDEST_WIDTH-1 downto 0):=(others => '-');

      
      -- masters interfaces
      M_AXIS_TDATA    : out std_logic_vector(G_NB_MASTER*G_TDATA_WIDTH-1 downto 0);
      M_AXIS_TVALID   : out std_logic_vector(G_NB_MASTER-1 downto 0);
      M_AXIS_TREADY   : in  std_logic_vector(G_NB_MASTER-1 downto 0):=(others => '-');
      M_AXIS_TKEEP    : out std_logic_vector(G_NB_MASTER*(G_TDATA_WIDTH/8)-1 downto 0);
      M_AXIS_TUSER    : out std_logic_vector(G_NB_MASTER*G_TUSER_WIDTH-1 downto 0);
      M_AXIS_TDEST    : out std_logic_vector(G_NB_MASTER*G_TDEST_WIDTH-1 downto 0);
      M_AXIS_TID      : out std_logic_vector(G_NB_MASTER*G_TID_WIDTH-1 downto 0)

    );
  end component;

  constant C_TDEST_WIDTH : integer:= integer(ceil(log2(realmax(real(G_NB_SLAVE), real(G_NB_MASTER)))));

  -- write access
  signal s_w_tid            : std_logic_vector(C_TDEST_WIDTH*G_NB_SLAVE-1 downto 0);
  signal s_w_tdest          : std_logic_vector(C_TDEST_WIDTH*G_NB_SLAVE-1 downto 0);
  signal m_w_tid            : std_logic_vector(C_TDEST_WIDTH*G_NB_MASTER-1 downto 0);
  signal m_w_tdest          : std_logic_vector(C_TDEST_WIDTH*G_NB_MASTER-1 downto 0);
  signal m_axi_awvalid_s    : std_logic_vector(G_NB_SLAVE-1 downto 0);
  
  
  signal s_r_tid            : std_logic_vector(C_TDEST_WIDTH*G_NB_SLAVE-1 downto 0);
  signal s_r_tdest          : std_logic_vector(C_TDEST_WIDTH*G_NB_SLAVE-1 downto 0);
  signal m_r_tid            : std_logic_vector(C_TDEST_WIDTH*G_NB_MASTER-1 downto 0);
  signal m_r_tdest          : std_logic_vector(C_TDEST_WIDTH*G_NB_MASTER-1 downto 0);
  signal m_axi_arvalid_s    : std_logic_vector(G_NB_SLAVE-1 downto 0);
  
begin

    GEN_SLAVE_WRITE : for i in 0 to G_NB_SLAVE-1 generate
      -- assign tid value
      s_w_tid(C_TDEST_WIDTH*(i+1)-1 downto C_TDEST_WIDTH*i) <= std_logic_vector(to_unsigned(i, C_TDEST_WIDTH));
      
      -- decode address
      inst_address_decoder :  address_decoder
        generic map(
          G_ADDR_WIDTH          => G_ADDR_WIDTH, 
          G_NB_SLAVE            => G_NB_SLAVE,    
          G_MAPPING_FILE        => G_MAPPING_FILE,
          G_TDEST_WIDTH         => C_TDEST_WIDTH 
        )
        port map(
          ADDR_TDATA            => S_AXI_AWADDR(G_ADDR_WIDTH*(i+1)-1 downto G_ADDR_WIDTH*i),
          ADDR_TVALID           => S_AXI_AWVALID(i),
          TDEST                 => s_w_tdest(C_TDEST_WIDTH*(i+1)-1 downto C_TDEST_WIDTH*i)
        );
    end generate;
    
    GEN_MASTER_WRITE : for i in 0 to G_NB_SLAVE-1 generate
      inst_resp_manager: resp_manager
        generic map(
          G_TDEST_WIDTH   => C_TDEST_WIDTH
        )
        port map(
          CLK             => CLK,
          RSTN            => RSTN,
          AXIS_TREADY     => M_AXI_AWREADY(i),
          AXIS_TVALID     => m_axi_awvalid_s(i),
          TID             => m_w_tid(C_TDEST_WIDTH*(i+1)-1 downto C_TDEST_WIDTH*i),
          TDEST           => m_w_tdest(C_TDEST_WIDTH*(i+1)-1 downto C_TDEST_WIDTH*i)
        );
    end generate;
  
    

    
    -- interconnect for axi write address
    inst_axis_interconnect_aw: axis_interconnect
      generic map(
        G_NB_SLAVE          => G_NB_SLAVE,
        G_NB_MASTER         => G_NB_MASTER,
        G_TDATA_WIDTH       => G_ADDR_WIDTH,
        G_TUSER_WIDTH       => 3,
        G_TDEST_WIDTH       => C_TDEST_WIDTH,
        G_TID_WIDTH         => C_TDEST_WIDTH
      )
      port map(
        S_AXIS_TDATA        => S_AXI_AWADDR, 
        S_AXIS_TVALID       => S_AXI_AWVALID,
        S_AXIS_TREADY       => S_AXI_AWREADY,
        S_AXIS_TUSER        => S_AXI_AWPROT,
        S_AXIS_TID          => s_w_tid,
        S_AXIS_TDEST        => s_w_tdest,
        M_AXIS_TDATA        => M_AXI_AWADDR,
        M_AXIS_TVALID       => m_axi_awvalid_s,
        M_AXIS_TREADY       => M_AXI_AWREADY,
        M_AXIS_TUSER        => M_AXI_AWPROT,
        M_AXIS_TID          => m_w_tid
      );
    
    M_AXI_AWVALID   <= m_axi_awvalid_s;
    
  
    -- interconnect for axi write data
    inst_axis_interconnect_w: axis_interconnect
      generic map(
        G_NB_SLAVE          => G_NB_SLAVE,
        G_NB_MASTER         => G_NB_MASTER,
        G_TDATA_WIDTH       => G_DATA_WIDTH,
        G_TDEST_WIDTH       => C_TDEST_WIDTH,
        G_TID_WIDTH         => C_TDEST_WIDTH
      )
      port map(
        S_AXIS_TDATA        => S_AXI_WDATA, 
        S_AXIS_TVALID       => S_AXI_WVALID,
        S_AXIS_TREADY       => S_AXI_WREADY,
        S_AXIS_TKEEP        => S_AXI_WSTRB,
        S_AXIS_TDEST        => s_w_tdest,
        M_AXIS_TDATA        => M_AXI_WDATA,
        M_AXIS_TVALID       => M_AXI_WVALID,
        M_AXIS_TREADY       => M_AXI_WREADY,
        M_AXIS_TKEEP        => M_AXI_WSTRB
      );
      
    -- interconnect for axi bresp
    inst_axis_interconnect_bresp: axis_interconnect
      generic map(
        G_NB_SLAVE          => G_NB_MASTER,
        G_NB_MASTER         => G_NB_SLAVE,
        G_TDATA_WIDTH       => 2,
        G_TDEST_WIDTH       => C_TDEST_WIDTH,
        G_TID_WIDTH         => C_TDEST_WIDTH
      )
      port map(
        S_AXIS_TDATA        => M_AXI_BRESP, 
        S_AXIS_TVALID       => M_AXI_BVALID,
        S_AXIS_TREADY       => M_AXI_BREADY,
        S_AXIS_TDEST        => m_w_tdest,
        M_AXIS_TDATA        => S_AXI_BRESP, 
        M_AXIS_TVALID       => S_AXI_BVALID,
        M_AXIS_TREADY       => S_AXI_BREADY
      );
    
    
    GEN_SLAVE_READ : for i in 0 to G_NB_SLAVE-1 generate
      -- assign tid value
      s_r_tid(C_TDEST_WIDTH*(i+1)-1 downto C_TDEST_WIDTH*i) <= std_logic_vector(to_unsigned(i, C_TDEST_WIDTH));
      
      -- decode address
      inst_address_decoder :  address_decoder
        generic map(
          G_ADDR_WIDTH          => G_ADDR_WIDTH, 
          G_NB_SLAVE            => G_NB_SLAVE,    
          G_MAPPING_FILE        => G_MAPPING_FILE,
          G_TDEST_WIDTH         => C_TDEST_WIDTH 
        )
        port map(
          ADDR_TDATA            => S_AXI_ARADDR(G_ADDR_WIDTH*(i+1)-1 downto G_ADDR_WIDTH*i),
          ADDR_TVALID           => S_AXI_ARVALID(i),
          TDEST                 => s_r_tdest(C_TDEST_WIDTH*(i+1)-1 downto C_TDEST_WIDTH*i)
        );
    end generate;
    
    GEN_MASTER_READ : for i in 0 to G_NB_SLAVE-1 generate
      inst_resp_manager: resp_manager
        generic map(
          G_TDEST_WIDTH   => C_TDEST_WIDTH
        )
        port map(
          CLK             => CLK,
          RSTN            => RSTN,
          AXIS_TREADY     => M_AXI_ARREADY(i),
          AXIS_TVALID     => m_axi_arvalid_s(i),
          TID             => m_r_tid(C_TDEST_WIDTH*(i+1)-1 downto C_TDEST_WIDTH*i),
          TDEST           => m_r_tdest(C_TDEST_WIDTH*(i+1)-1 downto C_TDEST_WIDTH*i)
        );
    end generate;
  
  
    -- interconnect for axi read address
    inst_axis_interconnect_ar: axis_interconnect
      generic map(
        G_NB_SLAVE          => G_NB_SLAVE,
        G_NB_MASTER         => G_NB_MASTER,
        G_TDATA_WIDTH       => G_ADDR_WIDTH,
        G_TUSER_WIDTH       => 3,
        G_TDEST_WIDTH       => C_TDEST_WIDTH,
        G_TID_WIDTH         => C_TDEST_WIDTH
      )
      port map(
        S_AXIS_TDATA        => S_AXI_ARADDR, 
        S_AXIS_TVALID       => S_AXI_ARVALID,
        S_AXIS_TREADY       => S_AXI_ARREADY,
        S_AXIS_TUSER        => S_AXI_ARPROT,
        S_AXIS_TID          => s_r_tid,
        S_AXIS_TDEST        => s_r_tdest,
        M_AXIS_TDATA        => M_AXI_ARADDR,
        M_AXIS_TVALID       => m_axi_arvalid_s,
        M_AXIS_TREADY       => M_AXI_ARREADY,
        M_AXIS_TUSER        => M_AXI_ARPROT,
        M_AXIS_TID          => m_r_tid
      );
    
    M_AXI_ARVALID   <= m_axi_arvalid_s;

  
    -- interconnect for axi read resp
    inst_axis_interconnect_resp: axis_interconnect
      generic map(
        G_NB_SLAVE          => G_NB_MASTER,
        G_NB_MASTER         => G_NB_SLAVE,
        G_TDATA_WIDTH       => G_DATA_WIDTH,
        G_TUSER_WIDTH       => 2,
        G_TDEST_WIDTH       => C_TDEST_WIDTH,
        G_TID_WIDTH         => C_TDEST_WIDTH
      )
      port map(
        S_AXIS_TDATA        => M_AXI_RDATA, 
        S_AXIS_TVALID       => M_AXI_RVALID,
        S_AXIS_TREADY       => M_AXI_RREADY,
        S_AXIS_TUSER        => M_AXI_RESP,
        S_AXIS_TDEST        => m_r_tdest,
        M_AXIS_TDATA        => S_AXI_RDATA,
        M_AXIS_TVALID       => S_AXI_RVALID,
        M_AXIS_TREADY       => S_AXI_RREADY,
        M_AXIS_TUSER        => S_AXI_RESP
      );
    
  
  
end rtl;
