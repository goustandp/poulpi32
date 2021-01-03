

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.textio.all;

library work;
  use work.axis_utils.all;

entity bench_axis_interconnect is 
end entity;


architecture behave of bench_axis_interconnect is


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
      
  constant C_NB_SLAVE          : integer := 2;
  constant C_NB_MASTER         : integer := 3;
  constant C_TDATA_WIDTH       : integer := 8;
  constant C_TUSER_WIDTH       : integer := 1;
  constant C_TDEST_WIDTH       : integer := 2;
  constant C_TID_WIDTH         : integer := 2;
  
  
  signal s_axis_tdata           :  std_logic_vector(C_NB_SLAVE*C_TDATA_WIDTH-1 downto 0);
  signal s_axis_tvalid          :  std_logic_vector(C_NB_SLAVE-1 downto 0);
  signal s_axis_tready          :  std_logic_vector(C_NB_SLAVE-1 downto 0);
  signal s_axis_tkeep           :  std_logic_vector(C_NB_SLAVE*(C_TDATA_WIDTH/8)-1 downto 0);
  signal s_axis_tuser           :  std_logic_vector(C_NB_SLAVE*C_TUSER_WIDTH-1 downto 0);
  signal s_axis_tid             :  std_logic_vector(C_NB_SLAVE*C_TID_WIDTH-1 downto 0);
  signal s_axis_tdest           :  std_logic_vector(C_NB_SLAVE*C_TDEST_WIDTH-1 downto 0);
  signal m_axis_tdata           :  std_logic_vector(C_NB_MASTER*C_TDATA_WIDTH-1 downto 0);
  signal m_axis_tvalid          :  std_logic_vector(C_NB_MASTER-1 downto 0);
  signal m_axis_tready          :  std_logic_vector(C_NB_MASTER-1 downto 0);
  signal m_axis_tkeep           :  std_logic_vector(C_NB_MASTER*(C_TDATA_WIDTH/8)-1 downto 0);
  signal m_axis_tuser           :  std_logic_vector(C_NB_MASTER*C_TUSER_WIDTH-1 downto 0);
  signal m_axis_tdest           :  std_logic_vector(C_NB_MASTER*C_TDEST_WIDTH-1 downto 0);
  signal m_axis_tid             :  std_logic_vector(C_NB_MASTER*C_TID_WIDTH-1 downto 0);

  signal clk                    : std_logic:='0';
  
  
begin


  inst_axis_interconnect : axis_interconnect
    generic map(
      G_NB_SLAVE            => C_NB_SLAVE,    
      G_NB_MASTER           => C_NB_MASTER,    
      G_TDATA_WIDTH         => C_TDATA_WIDTH,  
      G_TUSER_WIDTH         => C_TUSER_WIDTH,  
      G_TDEST_WIDTH         => C_TDEST_WIDTH,  
      G_TID_WIDTH           => C_TID_WIDTH    
    )
    port map(
      S_AXIS_TDATA          => s_axis_tdata,    
      S_AXIS_TVALID         => s_axis_tvalid,   
      S_AXIS_TREADY         => s_axis_tready,   
      S_AXIS_TKEEP          => s_axis_tkeep,    
      S_AXIS_TUSER          => s_axis_tuser,    
      S_AXIS_TID            => s_axis_tid,      
      S_AXIS_TDEST          => s_axis_tdest,    
      M_AXIS_TDATA          => m_axis_tdata,    
      M_AXIS_TVALID         => m_axis_tvalid,   
      M_AXIS_TREADY         => m_axis_tready,   
      M_AXIS_TKEEP          => m_axis_tkeep,    
      M_AXIS_TUSER          => m_axis_tuser,    
      M_AXIS_TDEST          => m_axis_tdest,    
      M_AXIS_TID            => m_axis_tid      
    );      


  clk <= not(clk) after 1 us;

  P_WRITE : process
  begin

    s_axis_tdata    <= x"CAFE";
    s_axis_tvalid   <= "00";
    s_axis_tkeep    <= "11";
    s_axis_tuser    <= "01";
    s_axis_tdest    <= "0000";
    s_axis_tid      <= "0100";
  
    wait until rising_edge(CLK);
    
    
    -- slave 0 to master 0 1 and 2
    s_axis_tdest(1 downto 0)    <= "00";
    wait for 1 ps;
    AXIS_WRITE(CLK, s_axis_tvalid(0), s_axis_tready(0));
    wait for 1 us;
    
    s_axis_tdest(1 downto 0)    <= "01";
    wait for 1 ps;
    AXIS_WRITE(CLK, s_axis_tvalid(0), s_axis_tready(0));
    wait for 1 us;
    
    s_axis_tdest(1 downto 0)    <= "10";
    wait for 1 ps;
    AXIS_WRITE(CLK, s_axis_tvalid(0), s_axis_tready(0));
    wait for 1 us;
    
    -- slave 1 to master 0 1 and 2
    s_axis_tdest(3 downto 2)    <= "00";
    wait for 1 ps;
    AXIS_WRITE(CLK, s_axis_tvalid(1), s_axis_tready(1));
    wait for 1 us;
    
    s_axis_tdest(3 downto 2)    <= "01";
    wait for 1 ps;
    AXIS_WRITE(CLK, s_axis_tvalid(1), s_axis_tready(1));
    wait for 1 us;
    
    s_axis_tdest(3 downto 2)    <= "10";
    wait for 1 ps;
    AXIS_WRITE(CLK, s_axis_tvalid(1), s_axis_tready(1));
    wait for 200 us;

  
  end process;
  
  
 
  P_READ : process
  begin
    m_axis_tready <= (others =>'0');
    wait until rising_edge(CLK);
    
    AXIS_READ(CLK, m_axis_tvalid(0), m_axis_tready(0));
    AXIS_READ(CLK, m_axis_tvalid(1), m_axis_tready(1));
    AXIS_READ(CLK, m_axis_tvalid(2), m_axis_tready(2));
    
    AXIS_READ(CLK, m_axis_tvalid(0), m_axis_tready(0));
    AXIS_READ(CLK, m_axis_tvalid(1), m_axis_tready(1));
    AXIS_READ(CLK, m_axis_tvalid(2), m_axis_tready(2));
    
    wait for 200 us;
  
  end process;


end behave;
