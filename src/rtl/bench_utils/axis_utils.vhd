library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  

package axis_utils is

  ----------------------------------------------------------------------
  -- basic write procedure
  ----------------------------------------------------------------------
  procedure AXIS_WRITE(signal CLK : in std_logic; signal TVALID : out std_logic; signal TREADY : in std_logic);
  
  ----------------------------------------------------------------------
  -- write a ramp of nb_data started at start_data, with an interval 
  ----------------------------------------------------------------------
  procedure AXIS_WRITE(signal CLK : in std_logic; signal TVALID : out std_logic; signal TREADY : in std_logic; 
                      signal TDATA: out std_logic_vector; constant interval : integer; 
                      constant nb_data: integer; constant start_data : integer);
  
  
  ----------------------------------------------------------------------
  -- basic read procedure
  ----------------------------------------------------------------------
  procedure AXIS_READ(signal CLK : in std_logic; signal TVALID : in std_logic; signal TREADY : out std_logic);
  
  ----------------------------------------------------------------------
  -- read nb_data with an interval
  ----------------------------------------------------------------------
  procedure AXIS_READ(signal CLK : in std_logic; signal TVALID : in std_logic; signal TREADY : out std_logic; constant interval: integer; constant nb_data : integer);
  
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

  procedure AXIS_WRITE(signal CLK : in std_logic; signal TVALID : out std_logic; signal TREADY : in std_logic; 
                      signal TDATA: out std_logic_vector; constant INTERVAL : integer; 
                      constant NB_DATA: integer; constant START_DATA : integer) is
    variable v_current_data : integer;
  begin
    wait until rising_edge(CLK);
    v_current_data := START_DATA;
    for i in 0 to NB_DATA-1 loop
      TVALID  <= '1';
      TDATA   <= std_logic_vector(to_unsigned(v_current_data, TDATA'length));
      wait for 1 ps;
      wait until rising_edge(CLK) and TREADY = '1';
      v_current_data  := v_current_data+1;
      for k in 0 to INTERVAL-1 loop
        TVALID  <= '0';
        wait for 1 ps;
        wait until rising_edge(CLK);
      end loop;
    end loop;
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
  
  procedure AXIS_READ(signal CLK : in std_logic; signal TVALID : in std_logic; signal TREADY : out std_logic; 
                    constant INTERVAL: integer; constant NB_DATA : integer) is
  begin
    wait until rising_edge(CLK);
    for i in 0 to NB_DATA-1 loop
      TREADY  <= '1';
      wait for 1 ps;
      wait until rising_edge(CLK) and TVALID = '1';
      for k in 0 to INTERVAL-1 loop
        TREADY <= '0';
        wait until rising_edge(CLK);
        wait for 1 ps;
      end loop;
      
    end loop;
    TREADY  <= '0';
    
  end AXIS_READ;
  

end package body;
