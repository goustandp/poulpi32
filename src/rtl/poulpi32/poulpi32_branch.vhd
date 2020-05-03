library work;
  use work.poulpi32_pkg.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity poulpi32_branch is 
  port(
    CLK       : in  std_logic;
    RSTN      : in  std_logic;
        
    RS_1      : in  std_logic_vector(31 downto 0);
    RS_2      : in  std_logic_vector(31 downto 0);
    RD        : out std_logic_vector(31 downto 0);
    WE        : out std_logic;
        
    IMM       : in  std_logic_vector(31 downto 0);
    PC        : in  std_logic_vector(31 downto 0);
    NEXT_PC   : out std_logic_vector(31 downto 0);
    
    OP_CODE_F3: in  std_logic_vector(2 downto 0);
    OP_CODE   : in  std_logic_vector(6 downto 0);
    START     : in  std_logic;
    READY     : out std_logic
  );
end entity poulpi32_branch;


architecture rtl of poulpi32_branch is
  
  signal operande_a     : std_logic_vector(31 downto 0);
  signal operande_b     : std_logic_vector(31 downto 0);
  signal add_operande_a : unsigned(31 downto 0);
  signal add_operande_b : unsigned(31 downto 0);
  signal branch_pc      : std_logic_vector(31 downto 0);
  signal not_branch_pc  : std_logic_vector(31 downto 0);
  
  signal comp_result    : std_logic;
  signal comp_resultu   : std_logic;
  signal is_equal       : std_logic;
  signal ready_i        : std_logic;
  signal ready_i_r      : std_logic;
  
  

begin
  
  READY <=  ready_i;
  
  P_BRANCH  : process(CLK) 
  begin
  
  if rising_edge(CLK) then
    if (RSTN = '0') then
      -- internals signals
      operande_a    <= (others => '0');
      operande_b    <= (others => '0');
      is_equal      <= '0';
      comp_result   <= '0';
      comp_resultu  <= '0';
      branch_pc     <= (others =>'0');
      not_branch_pc <= (others =>'0');
      ready_i       <= '1';
      ready_i_r     <= '1';
      -- output
      RD            <= (others => '0');
      WE            <= '0';
      NEXT_PC       <= (others => '0');
    else
      
      -- compute next pc
      branch_pc     <= std_logic_vector(add_operande_a + add_operande_b); 
      not_branch_pc <= std_logic_vector(unsigned(PC) + 4);
      
      -- comp result 
      if (unsigned(operande_b) < unsigned(operande_a)) then
        comp_resultu  <= '1';
      else
        comp_resultu  <= '0';
      end if;
      
      if (signed(operande_b) < signed(operande_a)) then
        comp_result   <= '1';
      else
        comp_result   <= '0';
      end if;
      
      -- equal result 
      if (operande_a = operande_b) then
        is_equal  <= '1';
      else
        is_equal  <= '0';
      end if;
      
      -- end op
      if (ready_i_r = '0') then
        ready_i   <= '1';
        ready_i_r <= '1';
      else
        ready_i_r <= ready_i;
      end if;
      
      -- start op
      if (START = '1') then
        operande_b      <= RS_1;
        operande_a      <= RS_2;  
        add_operande_a  <= unsigned(IMM);
        add_operande_b  <= unsigned(PC);
        ready_i         <= '0';
      end if;
      
      -- defalut is branch not taken
      NEXT_PC <= not_branch_pc;
      
      -- WE pulse
      WE    <= '0';
      
      case OP_CODE_F3 is 
        -- branch if equal
        when C_F3_BEQ   => 
          if (ready_i_r = '0') then
            if (is_equal = '1') then
              NEXT_PC <= branch_pc;
            end if;
          end if;
        
        -- branch if not equal
        when C_F3_BNE   => 
          if (ready_i_r = '0') then
            if (is_equal = '0') then
              NEXT_PC <= branch_pc;
            end if;
          end if;
          
        -- branch if less than
        when C_F3_BLT   => 
          if (ready_i_r = '0') then
            if (comp_result = '1') then
              NEXT_PC <= branch_pc;
            end if;
          end if;
        
        -- branch if greater
        when C_F3_BGE   => 
          if (ready_i_r = '0') then
            if (comp_result = '0') then
              NEXT_PC <= branch_pc;
            end if;
          end if;
        
        -- branch if less than unsigned
        when C_F3_BLTU  => 
          if (ready_i_r = '0') then
            if (comp_resultu = '1') then
              NEXT_PC <= branch_pc;
            end if;
          end if;
        
        -- branch if greater unsigned
        when C_F3_BGEU  => 
          if (ready_i_r = '0') then
            if (comp_resultu = '0') then
              NEXT_PC <= branch_pc;
            end if;
          end if;
        
        -- illegal instruction
        when others     => 
          if (START = '1') then
            ready_i   <= '0';
            ready_i_r <= '1';
          end if;
        end case;
      
      -- jal, auipc and jalr
      case OP_CODE is
        -- add upper immefiat to pc
        when C_OP_AUIPC =>
          if (ready_i_r = '0') then
            RD  <= branch_pc;
            WE  <= '1';
            NEXT_PC <= not_branch_pc;
          end if;
        
        -- jump and link immediat
        when C_OP_JAL =>
          if (ready_i_r = '0') then
            RD      <= not_branch_pc;
            WE      <= '1';
            NEXT_PC <= branch_pc;
          end if;
        
        -- jump and link register 
        when  C_OP_JALR =>
          if (START = '1') then
            add_operande_b  <= unsigned(RS_1);
          end if;
          
          if (ready_i_r = '0') then
            WE  <= '1';
            RD  <= not_branch_pc;
            NEXT_PC <= branch_pc;
          end if;
        
        when others =>
          WE  <= '0';
        end case;
        
      end if;
    end if;
  end process P_BRANCH;

end rtl;
