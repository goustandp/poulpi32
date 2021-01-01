library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.textio.all;
  
library work;
  use work.axis_utils.all;
  
entity bench_axis_mux is
end entity;

architecture behave of bench_axis_mux is

  component axis_mux is
    generic(
      G_NB_SLAVE_INPUT  : integer := 1;
      G_TDATA_WIDTH     : integer := 1;
      G_TUSER_WIDTH     : integer := 1;
      G_TDEST_WIDTH     : integer := 1;
      G_TID_WIDTH       : integer := 1
    );
    
    port(
      -- slaves interfaces
      S_AXIS_TDATA    : in  std_logic_vector(G_NB_SLAVE_INPUT*G_TDATA_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TVALID   : in  std_logic_vector(G_NB_SLAVE_INPUT-1 downto 0):=(others => '-');
      S_AXIS_TREADY   : out std_logic_vector(G_NB_SLAVE_INPUT-1 downto 0);
      S_AXIS_TKEEP    : in  std_logic_vector(G_NB_SLAVE_INPUT*(G_TDATA_WIDTH/8)-1 downto 0):=(others => '-');
      S_AXIS_TUSER    : in  std_logic_vector(G_NB_SLAVE_INPUT*G_TUSER_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TID      : in  std_logic_vector(G_NB_SLAVE_INPUT*G_TID_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TDEST    : in  std_logic_vector(G_NB_SLAVE_INPUT*G_TDEST_WIDTH-1 downto 0):=(others => '-');

      
      -- master interface
      M_AXIS_TDATA    : out std_logic_vector(G_TDATA_WIDTH-1 downto 0);
      M_AXIS_TVALID   : out std_logic;
      M_AXIS_TREADY   : in  std_logic:='-';
      M_AXIS_TKEEP    : out std_logic_vector((G_TDATA_WIDTH/8)-1 downto 0);
      M_AXIS_TUSER    : out std_logic_vector(G_TUSER_WIDTH-1 downto 0);
      M_AXIS_TID      : out std_logic_vector(G_TID_WIDTH-1 downto 0);
      M_AXIS_TDEST    : out std_logic_vector(G_TDEST_WIDTH-1 downto 0)
    );
  end component;
  
  constant C_NB_SLAVE_INPUT   : integer := 3;
  constant C_TDATA_WIDTH      : integer := 16;
  constant C_TUSER_WIDTH      : integer := 4;
  constant C_TDEST_WIDTH      : integer := 4;
  constant C_TID_WIDTH        : integer := 4;
  

  signal s_axis_tdata         : std_logic_vector(C_NB_SLAVE_INPUT*C_TDATA_WIDTH-1 downto 0);
  signal s_axis_tvalid        : std_logic_vector(C_NB_SLAVE_INPUT-1 downto 0);
  signal s_axis_tready        : std_logic_vector(C_NB_SLAVE_INPUT-1 downto 0);
  signal s_axis_tkeep         : std_logic_vector(C_NB_SLAVE_INPUT*(C_TDATA_WIDTH/8)-1 downto 0);
  signal s_axis_tuser         : std_logic_vector(C_NB_SLAVE_INPUT*C_TUSER_WIDTH-1 downto 0);
  signal s_axis_tid           : std_logic_vector(C_NB_SLAVE_INPUT*C_TID_WIDTH-1 downto 0);
  signal s_axis_tdest         : std_logic_vector(C_NB_SLAVE_INPUT*C_TDEST_WIDTH-1 downto 0);
  signal m_axis_tdata         : std_logic_vector(C_TDATA_WIDTH-1 downto 0);
  signal m_axis_tvalid        : std_logic;
  signal m_axis_tready        : std_logic;
  signal m_axis_tkeep         : std_logic_vector((C_TDATA_WIDTH/8)-1 downto 0);
  signal m_axis_tuser         : std_logic_vector(C_TUSER_WIDTH-1 downto 0);
  signal m_axis_tid           : std_logic_vector(C_TID_WIDTH-1 downto 0);
  signal m_axis_tdest         : std_logic_vector(C_TDEST_WIDTH-1 downto 0);
  
  signal clk                  : std_logic := '0';
  
begin

  inst_axis_mux : axis_mux
    generic map(
      G_NB_SLAVE_INPUT  => C_NB_SLAVE_INPUT, 
      G_TDATA_WIDTH     => C_TDATA_WIDTH,    
      G_TUSER_WIDTH     => C_TUSER_WIDTH,    
      G_TDEST_WIDTH     => C_TDEST_WIDTH,    
      G_TID_WIDTH       => C_TID_WIDTH      
    )
    port map(
      S_AXIS_TDATA      => s_axis_tdata,  
      S_AXIS_TVALID     => s_axis_tvalid, 
      S_AXIS_TREADY     => s_axis_tready, 
      S_AXIS_TKEEP      => s_axis_tkeep,  
      S_AXIS_TUSER      => s_axis_tuser,  
      S_AXIS_TID        => s_axis_tid,    
      S_AXIS_TDEST      => s_axis_tdest,  
      M_AXIS_TDATA      => m_axis_tdata,  
      M_AXIS_TVALID     => m_axis_tvalid, 
      M_AXIS_TREADY     => m_axis_tready, 
      M_AXIS_TKEEP      => m_axis_tkeep,  
      M_AXIS_TUSER      => m_axis_tuser,  
      M_AXIS_TID        => m_axis_tid,    
      M_AXIS_TDEST      => m_axis_tdest  
    );


  CLK <= not(CLK) after 1 us;


  P_WRITE : process
  begin
    s_axis_tdata      <= x"CA11BABEBEEF";
    s_axis_tvalid     <= (others => '0');
    s_axis_tkeep      <= "111111";
    s_axis_tuser      <= x"ABC";
    s_axis_tid        <= x"123";
    s_axis_tdest      <= x"EF0";
  
    wait until rising_edge(CLK);
    
    AXIS_WRITE(CLK, s_axis_tvalid(0), s_axis_tready(0));
    wait for 1 us;
    
    AXIS_WRITE(CLK, s_axis_tvalid(1), s_axis_tready(1));
    wait for 1 us;
    
    AXIS_WRITE(CLK, s_axis_tvalid(2), s_axis_tready(2));
    wait for 200 us;
  
  end process;
  
  
 
  P_READ : process
  begin
    m_axis_tready <= '0';
    wait until rising_edge(CLK);
    
    AXIS_READ(CLK, m_axis_tvalid, m_axis_tready);
    AXIS_READ(CLK, m_axis_tvalid, m_axis_tready);
    AXIS_READ(CLK, m_axis_tvalid, m_axis_tready);
    wait for 200 us;
  
  end process;


end behave;
  
