
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.textio.all;


entity axis_slice is
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
end entity;



architecture rtl of axis_slice is

  signal s_tdata      : std_logic_vector(G_TDATA_WIDTH+G_TDATA_WIDTH/8+G_TUSER_WIDTH+G_TID_WIDTH+G_TDEST_WIDTH-1 downto 0);
  signal s_tready     : std_logic;
  signal m_tdata      : std_logic_vector(G_TDATA_WIDTH+G_TDATA_WIDTH/8+G_TUSER_WIDTH+G_TID_WIDTH+G_TDEST_WIDTH-1 downto 0);
  signal m_tvalid     : std_logic;

begin

  s_tdata <=  S_AXIS_TDATA&S_AXIS_TKEEP&S_AXIS_TUSER&S_AXIS_TID&S_AXIS_TDEST;
  
  M_AXIS_TDATA  <= m_tdata(G_TDEST_WIDTH+G_TID_WIDTH+G_TUSER_WIDTH+G_TDATA_WIDTH/8+G_TDATA_WIDTH-1 downto G_TDEST_WIDTH+G_TID_WIDTH+G_TUSER_WIDTH+G_TDATA_WIDTH/8);
  M_AXIS_TKEEP  <= m_tdata(G_TDEST_WIDTH+G_TID_WIDTH+G_TUSER_WIDTH+G_TDATA_WIDTH/8-1 downto G_TDEST_WIDTH+G_TID_WIDTH+G_TUSER_WIDTH);
  M_AXIS_TUSER  <= m_tdata(G_TDEST_WIDTH+G_TID_WIDTH+G_TUSER_WIDTH-1 downto G_TDEST_WIDTH+G_TID_WIDTH);
  M_AXIS_TID    <= m_tdata(G_TDEST_WIDTH+G_TID_WIDTH-1 downto G_TDEST_WIDTH);
  M_AXIS_TDEST  <= m_tdata(G_TDEST_WIDTH-1 downto 0);
  
  S_AXIS_TREADY <= s_tready;
  M_AXIS_TVALID <= m_tvalid;
              
    
  
  P_REG : process(CLK)
  begin
    if rising_edge(CLK) then
      if (RSTN = '0') then
        s_tready  <= '0';
        m_tvalid  <= '0';
        m_tdata   <= (others => '0');
      else
        
        --data taken on master interface
        if (m_tvalid = '1' and M_AXIS_TREADY = '1') then
          m_tvalid  <= '0';
        end if;
        
        -- take data on slave interface
        if (s_tready = '1' and S_AXIS_TVALID = '1') then
          s_tready <= '0';
          m_tvalid <= '1';
          m_tdata  <= s_tdata;
        end if;
        
        if ((M_AXIS_TREADY = '1') or (m_tvalid = '0' and S_AXIS_TVALID = '0')) then
          s_tready  <= '1';
        end if;
    
      end if;
    end if;
  
  end process;
  
end rtl;  
