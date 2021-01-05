library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.textio.all;

entity resp_manager is
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
end entity;


architecture rtl of resp_manager is

  -- to support axi4 full, architecture must be modified

begin

  P_RESP : process(CLK)
  begin
    if rising_edge(CLK) then
      if (RSTN = '0') then
        TDEST <= (others => '0');
      else
        if (AXIS_TREADY = '1' and AXIS_TVALID = '1') then
          TDEST <= TID;
        end if;
      end if;
    end if;
  end process;
  
end rtl;
