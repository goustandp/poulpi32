library ieee;
  use ieee.std_logic_1164.all;
  

package axis_utils is

  ----------------------------------------------------------------------
  -- basic write procedure
  ----------------------------------------------------------------------
  procedure AXIS_WRITE(signal CLK : in std_logic; signal TVALID : out std_logic; signal TREADY : in std_logic);
  
  
  ----------------------------------------------------------------------
  -- basic read procedure
  ----------------------------------------------------------------------
  procedure AXIS_READ(signal CLK : in std_logic; signal TVALID : in std_logic; signal TREADY : out std_logic);
  
end package axis_utils;

package body axis_utils is
  
  procedure AXIS_WRITE(signal CLK : in std_logic; signal TVALID : out std_logic; signal TREADY : in std_logic) is
  begin
    wait until rising_edge(CLK);
    TVALID  <= '1';
    wait for 1 ps;
    wait until rising_edge(CLK) and TREADY = '1';
    TVALID  <= '0';
  
  end AXIS_WRITE;


  procedure AXIS_READ(signal CLK : in std_logic; signal TVALID : in std_logic; signal TREADY : out std_logic) is
  begin
    wait until rising_edge(CLK);
    TREADY  <= '1';
    wait for 1 ps;
    wait until rising_edge(CLK) and TVALID = '1';
    TREADY <= '0';
    
  end AXIS_READ;
  

end package body;
