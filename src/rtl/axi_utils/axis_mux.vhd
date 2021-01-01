
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.textio.all;


entity axis_mux is
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
end entity;


    

architecture rtl of axis_mux is

begin

  P_ARBITRATION : process(S_AXIS_TVALID, M_AXIS_TREADY)
  begin 
    -- set output
    S_AXIS_TREADY <= (others => '0');
    M_AXIS_TVALID <= '0';
    -- arbitration
    --the higher is the port number, the higher is the priority
    for i in G_NB_SLAVE_INPUT-1 downto 0 loop
      if (M_AXIS_TREADY = '1' and S_AXIS_TVALID(i) = '1') then -- handshake
        M_AXIS_TDATA      <= S_AXIS_TDATA(G_TDATA_WIDTH*(i+1)-1 downto G_TDATA_WIDTH*i);
        S_AXIS_TREADY(i)  <= '1';
        M_AXIS_TVALID     <= '1';
        M_AXIS_TKEEP      <= S_AXIS_TKEEP((G_TDATA_WIDTH/8)*(i+1)-1 downto (G_TDATA_WIDTH/8)*i);
        M_AXIS_TUSER      <= S_AXIS_TUSER(G_TUSER_WIDTH*(i+1)-1 downto G_TUSER_WIDTH*i);
        M_AXIS_TID        <= S_AXIS_TID(G_TID_WIDTH*(i+1)-1 downto G_TID_WIDTH*i);
        M_AXIS_TDEST      <= S_AXIS_TDEST(G_TDEST_WIDTH*(i+1)-1 downto G_TDEST_WIDTH*i);
        exit;
      end if;
    end loop;
  end process;

end rtl;
