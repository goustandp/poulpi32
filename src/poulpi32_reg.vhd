entity poulpi32_reg is
  port(
    CLK     : in std_logic;
    RSTN    : in std_logic;
      
    RS_1    : out std_logic_vector(31 downto 0);
    RS_2    : out std_logic_vector(31 downto 0)
    RD      : in std_logic_vector(31 downto 0);
     
    RS1_ID  : in std_logic_vector(4 downto 0);
    RS2_ID  : in std_logic_vector(4 downto 0);
    RD_ID   : in std_logic_vector(4 downto 0);
    WE      : in std_logic
  );

end entity poulpi32_reg;

architecture rtl of poulpi32_reg is
  type t_reg is array range <> of std_logic_vector(31 downto 0);
  
  signal register_file                  : t_reg(31 downto 0);
  attribute ram_stype                   : string;
  attribute ram_style of register_file  : signal is "auto";
  
  signal r0                             : std_logic_vector(31 downto 0);

begin

  --hardwired 
  r0  <= (others => '0');

  P_REG : process(CLK)
  begin
  if rising_edge(CLK) then
    -- RS1
    if (unsigned(RS1_ID) /= 0) then
      RS_1  <= register_file(to_integer(unsigned(RS1_ID)));
    else
      RS_1  <= r0;
    end if;
    
    -- RS2
    if (unsigned(RS2_ID) /= 0) then
      RS_1  <= register_file(to_integer(unsigned(RS2_ID)));
    else
      RS_1  <= r0;
    end if;
    
    -- RD
    if (WE  = '1' and unsigned(RD_ID) /= 0) then
      register_file(to_integer(unsigned(RD_ID)))  <= RD;
    end if;
  end if;

  end process P_REG;

end rtl;
