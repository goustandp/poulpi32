library work;
  use work.poulpi32_pkg.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.textio.all;


entity axis_demux is
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
end entity;


architecture rtl of axis_demux is


  constant C_TKEEP_WIDTH : integer:= G_TDATA_WIDTH/8;
  signal   dest          : integer;
   
begin
  
  dest  <= to_integer(unsigned(S_AXIS_TDEST));
  
  P_ARBITRATION : process(S_AXIS_TDEST)
  begin 
    -- set valid to zeros if master is not the selected one (use VHDL priority)
    M_AXIS_TVALID                                                       <= (others => '0');
  
    M_AXIS_TDATA(G_TDATA_WIDTH*(dest+1)-1 downto G_TDATA_WIDTH*dest)    <= S_AXIS_TDATA;
    M_AXIS_TVALID(dest)                                                 <= S_AXIS_TVALID;
    S_AXIS_TREADY                                                       <= M_AXIS_TREADY(dest);
    M_AXIS_TKEEP(C_TKEEP_WIDTH*(dest+1)-1 downto C_TKEEP_WIDTH*dest)    <= S_AXIS_TKEEP;
    M_AXIS_TUSER(G_TUSER_WIDTH*(dest+1)-1 downto G_TUSER_WIDTH*dest)    <= S_AXIS_TUSER;
    M_AXIS_TDEST(G_TDEST_WIDTH*(dest+1)-1 downto G_TDEST_WIDTH*dest)    <= S_AXIS_TDEST;
    M_AXIS_TID(G_TID_WIDTH(dest+1)-1      downto G_TID_WIDTH*dest)      <= S_AXIS_TID;
  end process;

end rtl;
