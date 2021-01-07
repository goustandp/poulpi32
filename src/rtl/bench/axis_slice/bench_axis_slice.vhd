library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.textio.all;
  
library work;
  use work.axis_utils.all;
  
entity bench_axis_slice is
end entity;

architecture behave of bench_axis_slice is

  component axis_slice is
    generic(
      G_TDATA_WIDTH     : integer := 1;
      G_TUSER_WIDTH     : integer := 1;
      G_TDEST_WIDTH     : integer := 1;
      G_TID_WIDTH       : integer :=1
    );
    
    port(
      -- clock and reset
      CLK             : in  std_logic;
      RSTN            : in  std_logic;
      
      -- slaves interfaces
      S_AXIS_TDATA    : in  std_logic_vector(G_TDATA_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TVALID   : in  std_logic:='-';
      S_AXIS_TREADY   : out std_logic;
      S_AXIS_TKEEP    : in  std_logic_vector((G_TDATA_WIDTH/8)-1 downto 0):=(others => '-');
      S_AXIS_TUSER    : in  std_logic_vector(G_TUSER_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TID      : in  std_logic_vector(G_TID_WIDTH-1 downto 0):=(others => '-');
      S_AXIS_TDEST    : in  std_logic_vector(G_TDEST_WIDTH-1 downto 0):=(others => '-');

      
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

  constant C_TDATA_WIDTH                : integer := 16;
  constant C_TUSER_WIDTH                : integer := 4;
  constant C_TDEST_WIDTH                : integer := 2;
  constant C_TID_WIDTH                  : integer := 2;
  
  signal m_axis_tdata                   : std_logic_vector(C_TDATA_WIDTH-1 downto 0);
  signal m_axis_tvalid                  : std_logic;
  signal m_axis_tready                  : std_logic;
  signal m_axis_tkeep                   : std_logic_vector((C_TDATA_WIDTH/8)-1 downto 0);
  signal m_axis_tuser                   : std_logic_vector(C_TUSER_WIDTH-1 downto 0);
  signal m_axis_tdest                   : std_logic_vector(C_TDEST_WIDTH-1 downto 0);
  signal m_axis_tid                     : std_logic_vector(C_TID_WIDTH-1 downto 0);
  signal s_axis_tdata                   : std_logic_vector(C_TDATA_WIDTH-1 downto 0);
  signal s_axis_tvalid                  : std_logic;
  signal s_axis_tready                  : std_logic;
  signal s_axis_tkeep                   : std_logic_vector((C_TDATA_WIDTH/8)-1 downto 0);
  signal s_axis_tuser                   : std_logic_vector(C_TUSER_WIDTH-1 downto 0);
  signal s_axis_tdest                   : std_logic_vector(C_TDEST_WIDTH-1 downto 0);
  signal s_axis_tid                     : std_logic_vector(C_TID_WIDTH-1 downto 0);
  
  signal clk                            : std_logic := '0';
  signal rstn                           : std_logic := '0';
  
begin



  inst_axis_slice : axis_slice
    generic map(
      G_TDATA_WIDTH     => C_TDATA_WIDTH,
      G_TUSER_WIDTH     => C_TUSER_WIDTH, 
      G_TDEST_WIDTH     => C_TDEST_WIDTH, 
      G_TID_WIDTH       => C_TID_WIDTH   
    )
    port map(
      CLK             => clk,           
      RSTN            => rstn,           
      S_AXIS_TDATA    => s_axis_tdata,   
      S_AXIS_TVALID   => s_axis_tvalid,  
      S_AXIS_TREADY   => s_axis_tready,  
      S_AXIS_TKEEP    => s_axis_tkeep,   
      S_AXIS_TUSER    => s_axis_tuser,   
      S_AXIS_TID      => s_axis_tid,     
      S_AXIS_TDEST    => s_axis_tdest,   
      M_AXIS_TDATA    => m_axis_tdata,   
      M_AXIS_TVALID   => m_axis_tvalid,  
      M_AXIS_TREADY   => m_axis_tready,  
      M_AXIS_TKEEP    => m_axis_tkeep,   
      M_AXIS_TUSER    => m_axis_tuser,   
      M_AXIS_TID      => m_axis_tid,     
      M_AXIS_TDEST    => m_axis_tdest   
    );                



  clk     <= not(clk) after 1 us;
  rstn    <= '1' after 3 us;

  P_WRITE : process
  begin

    s_axis_tdata    <= x"BEEF";
    s_axis_tvalid   <= '0';
    s_axis_tkeep    <= "11";
    s_axis_tuser    <= x"A";
    s_axis_tdest    <= "01";
    s_axis_tid      <= "00";
  
    wait until rising_edge(CLK);
    

    wait for 4 us;
    AXIS_WRITE(CLK, s_axis_tvalid, s_axis_tready, s_axis_tdata, 0, 10, 10);
    
    wait for 10 us;
    AXIS_WRITE(CLK, s_axis_tvalid, s_axis_tready, s_axis_tdata, 2, 10, 1);

    wait for 10 us;
    AXIS_WRITE(CLK, s_axis_tvalid, s_axis_tready, s_axis_tdata, 3, 10, 100);
    wait for 2 us;
    AXIS_WRITE(CLK, s_axis_tvalid, s_axis_tready, s_axis_tdata, 1, 10, 20);
    wait for 200 us;
  
  end process;
  
  
 
  P_READ : process
  begin
    m_axis_tready  <= '0';
    wait until rising_edge(CLK);
    wait for 4 us;
    AXIS_READ(CLK, m_axis_tvalid, m_axis_tready, 0, 10);
    wait for 8 us;
    AXIS_READ(CLK, m_axis_tvalid, m_axis_tready, 2, 10);
    wait for 2 us;
    AXIS_READ(CLK, m_axis_tvalid, m_axis_tready, 2, 10);
    wait for 10 us;
    AXIS_READ(CLK, m_axis_tvalid, m_axis_tready, 4, 10);
    wait for 200 us;
  
  end process;


end behave;
  
