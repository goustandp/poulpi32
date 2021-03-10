library work;
  use work.poulpi32_pkg.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity poulpi32_mux is
  port(
    
    REG_RS_1  : in  std_logic_vector(31 downto 0);
    REG_RS_2  : in  std_logic_vector(31 downto 0);
    REG_RD    : out std_logic_vector(31 downto 0);
    REG_WE    : out std_logic;
    
    LSU_RS_1  : out std_logic_vector(31 downto 0);
    LSU_RS_2  : out std_logic_vector(31 downto 0);
    LSU_RD    : in  std_logic_vector(31 downto 0);
    LSU_WE    : in  std_logic;
    
    ALU_RS_1  : out std_logic_vector(31 downto 0);
    ALU_RS_2  : out std_logic_vector(31 downto 0);
    ALU_RD    : in  std_logic_vector(31 downto 0);
    ALU_WE    : in  std_logic;
    
    BR_RS_1   : out std_logic_vector(31 downto 0);
    BR_RS_2   : out std_logic_vector(31 downto 0);
    BR_RD     : in  std_logic_vector(31 downto 0);
    BR_WE     : in  std_logic;
    
    DC_RD     : in  std_logic_vector(31 downto 0);
    DC_WE     : in  std_logic
  );
end entity poulpi32_mux;


architecture rtl of poulpi32_mux is

begin
  
  -- no need to mux source reg
  LSU_RS_1  <= REG_RS_1;
  LSU_RS_2  <= REG_RS_2;
  
  ALU_RS_1  <= REG_RS_1;
  ALU_RS_2  <= REG_RS_2;
    
  BR_RS_1   <= REG_RS_1;
  BR_RS_2   <= REG_RS_2;
  

  -- mux rd reg
  REG_RD    <=  LSU_RD  when  (LSU_WE = '1') else
                ALU_RD  when  (ALU_WE = '1') else
                BR_RD   when  (BR_WE  = '1')  else
                DC_RD;
      
    
  REG_WE    <=  LSU_WE or ALU_WE or BR_WE or DC_WE;
     
  end rtl;
