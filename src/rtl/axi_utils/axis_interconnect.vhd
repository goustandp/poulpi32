library work;
  use work.poulpi32_pkg.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.textio.all;


entity axis_interconnect is
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
    S_AXIS_TID      : in  std_logic_vector(G_NB_MASTER*G_TID_WIDTH-1 downto 0):=(others => '-');
    S_AXIS_TDEST    : in  std_logic_vector(G_NB_MASTER*G_TDEST_WIDTH-1 downto 0):=(others => '-');

    
    -- masters interfaces
    M_AXIS_TDATA    : out std_logic_vector(G_NB_MASTER*G_TDATA_WIDTH-1 downto 0);
    M_AXIS_TVALID   : out std_logic_vector(G_NB_MASTER-1 downto 0);
    M_AXIS_TREADY   : in  std_logic_vector(G_NB_MASTER-1 downto 0):='-';
    M_AXIS_TKEEP    : out std_logic_vector(G_NB_MASTER*(G_TDATA_WIDTH/8)-1 downto 0);
    M_AXIS_TUSER    : out std_logic_vector(G_NB_MASTER*G_TUSER_WIDTH-1 downto 0);
    M_AXIS_TDEST    : out std_logic_vector(G_NB_MASTER*G_TDEST_WIDTH-1 downto 0);
    M_AXIS_TID      : out std_logic_vector(G_NB_MASTER*G_TID_WIDTH-1 downto 0)

  );
end entity;

architecture rtl of axis_interconnect is

  component axis_demux is
    generic(
      G_NB_MASTER_OUTPUT  : integer := 1;
      G_TDATA_WIDTH       : integer := 1
      G_TUSER_WIDTH       : integer := 1;
      G_TDEST_WIDTH       : integer := 1:
      G_TID_WIDTH         : integer := 1
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
      G_TID_WIDTH       : integer :=1
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
  
  signal axis_from_slave_tdata    : std_logic_vector(G_NB_SLAVE*G_NB_MASTER*G_TDATA_WIDTH-1 downto 0);
  signal axis_from_slave_tvalid   : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal axis_from_slave_tready   : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal axis_from_slave_tkeep    : std_logic_vector(G_NB_SLAVE*G_NB_MASTER*(G_TDATA_WIDTH/8)-1 downto 0);
  signal axis_from_slave_tuser    : std_logic_vector(G_NB_SLAVE*G_NB_MASTER*G_TUSER_WIDTH-1 downto 0);
  signal axis_from_slave_tid      : std_logic_vector(G_NB_MASTER*G_NB_SLAVE*G_TID_WIDTH-1 downto 0);
  signal axis_from_slave_tdest    : std_logic_vector(G_NB_MASTER*G_NB_SLAVE*G_TDEST_WIDTH-1 downto 0);
  
  signal axis_to_master_tdata     : std_logic_vector(G_NB_SLAVE*G_NB_MASTER*G_TDATA_WIDTH-1 downto 0);
  signal axis_to_master_tvalid    : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal axis_to_master_tready    : std_logic_vector(G_NB_SLAVE*G_NB_MASTER-1 downto 0);
  signal axis_to_master_tkeep     : std_logic_vector(G_NB_SLAVE*G_NB_MASTER*(G_TDATA_WIDTH/8)-1 downto 0);
  signal axis_to_master_tuser     : std_logic_vector(G_NB_SLAVE*G_NB_MASTER*G_TUSER_WIDTH-1 downto 0);
  signal axis_to_master_tid       : std_logic_vector(G_NB_MASTER*G_NB_SLAVE*G_TID_WIDTH-1 downto 0);
  signal axis_to_master_tdest     : std_logic_vector(G_NB_MASTER*G_NB_SLAVE*G_TDEST_WIDTH-1 downto 0);
  
  
  
begin

  GEN_SLAVE_WRITE: for i in 0 to G_NB_SLAVE-1 generate
      
    inst_axis_demux_slave : axis_demux
      generic map(
        G_NB_MASTER_OUTPUT  => G_NB_MASTER,
        G_TDATA_WIDTH       => G_TDATA_WIDTH,
        G_TUSER_WIDTH       => G_TUSER_WIDTH,
        G_TDEST_WIDTH       => G_TDEST_WIDTH,
        G_TID_WIDTH         => G_TID_WIDTH
      )
      port map(

        M_AXIS_TDATA    => axis_from_slave_tdata(G_TDATA_WIDTH*G_NB_MASTER*(i+1)-1 downto G_TDATA_WIDTH*G_NB_MASTER*i), 
        M_AXIS_TVALID   => axis_from_slave_tvalid(G_NB_MASTER*(i+1)-1 downto G_NB_MASTER*i),
        M_AXIS_TREADY   => axis_from_slave_tready(G_NB_MASTER*(i+1)-1 downto G_NB_MASTER*i),
        M_AXIS_TKEEP    => axis_from_slave_tkeep((G_TDATA_WIDTH/8)*G_NB_MASTER*(i+1)-1 downto (G_TDATA_WIDTH/8)*G_NB_MASTER*i);
        M_AXIS_TUSER    => axis_from_slave_tuser(G_TUSER_WIDTH*G_NB_MASTER*(i+1)-1 downto G_TUSER_WIDTH*G_NB_MASTER*i);
        M_AXIS_TDEST    => axis_from_slave_tdest(G_TDEST_WIDTH*G_NB_MASTER*(i+1)-1 downto G_TDEST_WIDTH*G_NB_MASTER*i);
        M_AXIS_TID      => axis_from_slave_tid(G_TID_WIDTH*G_NB_MASTER*(i+1)-1 downto G_TID_WIDTH*G_NB_MASTER*i);   
        S_AXIS_TDATA    => S_AXIS_TDATA(G_TDATA_WIDTH(i+1)-1 downto G_TDATA_WIDTH*i), 
        S_AXIS_TVALID   => S_AXIS_TVALID(i),
        S_AXIS_TREADY   => S_AXIS_TREADY(i),
        S_AXIS_TKEEP    => S_AXIS_TKEEP((G_TDATA_WIDTH/8)*(i+1)-1 downto (G_TDATA_WIDTH/8)*i);
        S_AXIS_TUSER    => S_AXIS_TUSER(G_TUSER_WIDTH*(i+1)-1 downto G_TUSER_WIDTH*i);
        S_AXIS_TDEST    => S_AXIS_TDEST(G_TDEST_WIDTH*(i+1)-1 downto G_TDEST_WIDTH*i);
        S_AXIS_TID      => S_AXIS_TID(G_TID_WIDTH*(i+1)-1 downto G_TID_WIDTH*i)
      );


    
    -- connect axis slave i to axis master j
    GEN_SLAVE_TO_MASTER: for j in 0 to G_NB_MASTER generate
      axis_to_master_tdata((j*G_NB_MASTER+1+i)*G_TDATA_WIDTH-1 downto G_TDATA_WIDTH*(j*G_NB_MASTER+i))          <= axis_from_slave_tdata(G_TDATA_WIDTH*(j+1+i*G_NB_SLAVE)-1 downto G_TDATA_WIDTH*(j+i*G_NB_SLAVE));
      axis_to_master_tvalid((j*G_NB_MASTER+1+i)-1 downto (j*G_NB_MASTER+i))                                     <= axis_from_slave_tvalid((j+1+i*G_NB_SLAVE)-1 downto (j+i*G_NB_SLAVE));
      axis_from_slave_tready((j+1+i*G_NB_SLAVE)-1 downto (j+i*G_NB_SLAVE))                                      <= axis_to_master_tready((j*G_NB_MASTER+1+i)-1 downto (j*G_NB_MASTER+i));
      axis_to_master_tkeep((j*G_NB_MASTER+1+i)*(G_TDATA_WIDTH/8)-1 downto (G_TDATA_WIDTH/8)*(j*G_NB_MASTER+i))  <= axis_from_slave_tdata((G_TDATA_WIDTH/8)*(j+1+i*G_NB_SLAVE)-1 downto (G_TDATA_WIDTH/8)*(j+i*G_NB_SLAVE));
      axis_to_master_tuser((j*G_NB_MASTER+1+i)*G_TUSER_WIDTH-1 downto G_USER_WIDTH*(j*G_NB_MASTER+i))           <= axis_from_slave_tdata(G_TUSER_WIDTH*(j+1+i*G_NB_SLAVE)-1 downto G_TUSER_WIDTH*(j+i*G_NB_SLAVE));
      axis_to_master_tdest((j*G_NB_MASTER+1+i)*G_TDEST_WIDTH-1 downto G_TDEST_WIDTH*(j*G_NB_MASTER+i))          <= axis_from_slave_tdest(G_TDEST_WIDTH*(j+1+i*G_NB_SLAVE)-1 downto G_TDEST_WIDTH*(j+i*G_NB_SLAVE));
      axis_to_master_tdid((j*G_NB_MASTER+1+i)*G_TID_WIDTH-1 downto G_TID_WIDTH*(j*G_NB_MASTER+i))               <= axis_from_slave_tdest(G_TID_WIDTH*(j+1+i*G_NB_SLAVE)-1 downto G_TID_WIDTH*(j+i*G_NB_SLAVE));
    end generate GEN_SLAVE_TO_MASTER;
  
  end generate GEN_SLAVE_WRITE;
  
  
  
  GEN_MASTER_WRITE: for i in 0 to G_NB_MASTER-1 generate
      
    inst_axis_mux_slave : axis_mux
      generic map(
        G_NB_SLAVE_INPUT    => G_NB_SLAVE,
        G_TDATA_WIDTH       => G_TDATA_WIDTH,
        G_TUSER_WIDTH       => G_TUSER_WIDTH,
        G_TDEST_WIDTH       => G_TDEST_WIDTH,
        G_TID_WIDTH         => G_TID_WIDTH
      )
      port map(

        S_AXIS_TDATA    => axis_to_master_tdata(G_TDATA_WIDTH*G_NB_SLAVE*(i+1)-1 downto G_TDATA_WIDTH*G_NB_SLAVE*i), 
        S_AXIS_TVALID   => axis_to_master_tvalid(G_NB_SLAVE*(i+1)-1 downto G_NB_SLAVE*i),
        S_AXIS_TREADY   => axis_to_master_tready(G_NB_SLAVE*(i+1)-1 downto G_NB_SLAVE*i),
        S_AXIS_TKEEP    => axis_to_master_tkeep((G_TDATA_WIDTH/8)*G_NB_SLAVE*(i+1)-1 downto (G_TDATA_WIDTH/8)*G_NB_SLAVE*i);
        S_AXIS_TUSER    => axis_to_master_tuser(G_TUSER_WIDTH*G_NB_SLAVE*(i+1)-1 downto G_TUSER_WIDTH*G_NB_SLAVE*i);
        S_AXIS_TDEST    => axis_to_master_tdest(G_TDEST_WIDTH*G_NB_SLAVE*(i+1)-1 downto G_TDEST_WIDTH*G_NB_SLAVE*i);
        S_AXIS_TID      => axis_to_master_tid(G_TID_WIDTH*G_NB_SLAVE*(i+1)-1 downto G_TID_WIDTH*G_NB_SLAVE*i);   
        M_AXIS_TDATA    => M_AXIS_TDATA(G_TDATA_WIDTH(i+1)-1 downto G_TDATA_WIDTH*i), 
        M_AXIS_TVALID   => M_AXIS_TVALID(i),
        M_AXIS_TREADY   => M_AXIS_TREADY(i),
        M_AXIS_TKEEP    => M_AXIS_TKEEP((G_TDATA_WIDTH/8)*(i+1)-1 downto (G_TDATA_WIDTH/8)*i);
        M_AXIS_TUSER    => M_AXIS_TUSER(G_TUSER_WIDTH*(i+1)-1 downto G_TUSER_WIDTH*i);
        M_AXIS_TDEST    => M_AXIS_TDEST(G_TDEST_WIDTH*(i+1)-1 downto G_TDEST_WIDTH*i);
        M_AXIS_TID      => M_AXIS_TID(G_TID_WIDTH*(i+1)-1 downto G_TID_WIDTH*i)
      );
  end generate GEN_MASTER_WRITE;
  
  
end rtl;
