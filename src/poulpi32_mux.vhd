entity poulpi32_mux is
  port(
    ID        : in  std_logic_vector(1 downto 0);
    
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
    
    MU_RS_1   : out std_logic_vector(31 downto 0);
    MU_RS_2   : out std_logic_vector(31 downto 0);
    MU_RD     : in  std_logic_vector(31 downto 0);
    MU_WE     : in  std_logic
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
  
  MU_RS_1   <= REG_RS_1;
  MU_RS_2   <= REG_RS_2;

  -- mux rd reg
  REG_RD    <=  LSU_RD  when  (ID = C_LSU_ID) else
                ALU_RD  when  (ID = C_ALU_ID) else
                BR_RD   when  (ID = C_BR_ID)  else
                MU_RD;
      
    
  REG_WE    <=  LSU_WE  when  (ID = C_LSU_ID) else
                ALU_WE  when  (ID = C_ALU_ID) else
                BR_WE   when  (ID = C_BR_ID)  else
                MU_WE;
     
  end rtl;
