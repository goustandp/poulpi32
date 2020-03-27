library work;
  use work.poulpi32_pkg.all

entity poulpi32_alu is
  port(
    CLK         : in  std_logic;
    RSTN        : in  std_logic;
    
    -- registers and immediat values
    RS_1        : in  std_logic_vector(31 downto 0);
    RS_2        : in  std_logic_vector(31 downto 0);
    RD          : out std_logic_vector(31 downto 0);
    IMM         : in  std_logic_vector(31 downto 0); --signed extended
    IMMU        : in  std_logic_vector(31 downto 0);
    SHAMT       : in  std_logic_vector(4 downto 0);
    
    -- constrol signals
    READY       : out std_logic;
    START_REG   : in  std_logic;
    START_IMM   : in  std_logic;
    WE          : out std_logic;
    
    -- op codes
    OP_CODE_F3  : in  std_logic_vector(2 downto 0);
    OP_CODE_F7  : in  std_logic_vector(6 downto 0)
  );
end entity poulpi32_alu;


architecture rtl of poulpi32 _alu is

  -- signals for shifter
  signal cnt_shift        : unsigned(4 downto 0);
  signal shifter          : std_logic_vector(31 downto 0);
  signal bit_shift        : std_logic;
  
  -- bit reversed signals (mainly used for shifter)
  signal rs1_reverse      : std_logic_vector(31 downto 0);
  signal imm_reverse      : std_logic_vector(31 downto 0);
  signal immu_reverse     : std_logic_vector(31 downto 0);
  signal shifter_reverse  : std_logic_vector(31 downto 0);
  
  --signal for comp and sub
  signal operande_a       : std_logic_vector(31 downto 0);
  signal operande_b       : std_logic_vector(31 downto 0);
  signal comp_result      : std_logic;
  signal comp_resultu     : std_logic;
  signal adder_result     : unsigned(31 downto 0);
  signal or_result        : std_logic_vector(31 downto 0);
  signal xor_result       : std_logic_vector(31 downto 0);
  signal and_result       ; std_logic_vector(31 downto 0);
  

  signal ready_i          : std_logic;
  signal ready_i_r        : std_logic;
  
  
begin 

  -- assign revese signal
  rs1_reverse     <= slv_reverse_range(RS_1);
  imm_reverse     <= slv_reverse_range(IMM);
  immu_reverse    <= slv_reverse_range(IMMU);
  shifter_reverse <= slv_reverse_range(shifter);
  

  READY <= ready_i;
  
  P_ALU : process(CLK) 
  begin
    if rising_edge(CLK)
      if (RSTN = '0') then
        cnt_shift       <= (others => '0');
        WE              <= '0';
        ready_i         <= '1';
        ready_i_r       <= '1';
        operande_a      <= (others => '0');
        operande_b      <= (others => '0');
        comp_result     <= '0';
        adder_result    <= (others => '0');
        or_result       <= (others => '0');
        xor_result      <= (others => '0');
        and_result      <= (others => '0');
        
        -- no need to reset shifter
      else
        
        -- write enable pulse
        WE  <= '0';
        
        -- shifter (could be replace by a barrel shifter)
        if (cnt_shift  /=0) then
          shifter   <= shifter(31 downto 1)&bit_shift;
          cnt_shift <= cnt_shift-1;
        end if;
        
        -- adder
        adder_result  <= unsigned(operande_a) + unsigned(operande_b);
        
        --comp
        if (unsigned(operande_b) < unsigned(operande_a)) then
          comp_resultu <= '1';
        else
          comp_resultu <= '0';
        end if;
        
        if (signed(operande_b) < signed(operande_a)) then
          comp_result <= '1';
        else
          comp_result <= '0';
        end if;
        
        
        -- compute or bitwise
        or_result   <= slv_global_or(operande_a, operande_b);
        
        -- compute xor bitwise
        xor_result  <= slv_global_xor(operande_a, operande_b);
        
        -- compute and bitwise
        and_result  <= slv_global_and(operande_a, operande_b);
        
        -- register ready and manage op done
        if (ready_i_r = '0' and cnt_shift =0) then
          ready_i_r <= '1';
          ready_i   <= '1';
          WE        <= '1';
        else
          ready_i_r <= ready_i;
        end if;
        
        -- start immediat operation
        if (START_IMM = '1') then
          operande_a  <= RS_1;
          operande_b  <= IMM;
          ready_i     <= '0';
          RD          <= (others => '0');
        end if;
        
                
        -- start register operation
        if (START_REG = '1') then
          operande_b  <= RS_1;
          operande_a  <= RS_2;
          ready_i     <= '0';
          RD          <= (others => '0');
        end if;
        
        -- decode micro ops
        case OP_CODE_F3 is 
          -- add immediat
          when C_F3_ADD  =>
            --sub (to be improved)
            if (START_REG ='1' and C_F7_SUB = '1') then
              operande_b  <= std_logic_vector(unsigned(not(RS_1)) + 1); -- two's complement
            end if;
            
            if (ready_i_r = '0') then
              RD          <= adder_result;
            end if;
          
          -- set less than 
          when C_F3_SLT =>
            if (ready_i_r = '0') then
              RD(0)   <= comp_result;
            end if;
          
          
          --set less than unsigned
          when C_F3_SLTU => 
            if (START_IMM = '1') then
              operande_b  <= IMMU;
            end if;
            
            if (ready_i_r ='0') then
              RD(0)       <= comp_resultu;
            end if;
          
          -- xor immediat
          when C_F3_XOR => 
            if (ready_i_r ='0') then
              RD           <= xor_result;
            end if;
          
          -- or immediat
          when C_F3_OR   => 
            if (ready_i_r ='0') then
              RD(0)       <= or_result;
            end if;
          
          -- and immediat
          when C_F3_AND  =>
            if (ready_i_r ='0') then
              RD(0)       <= and_result;
            end if;
            
          -- shift left logical
          when C_F3_SLL  =>
            -- immediat operation
            if (START_IMM = '1') then
              cnt_shift <= unsigned(SHAMT);
              shifter   <= RS_1;
            end if;
            
            -- reg to reg
            if (START_REG = '1') then
              cnt_shift <= unsigned(RS_2(4 downto 0));
              shifter   <= RS_1;
              
            end if;
            
            -- logical shift
            bit_shift <= '0';
            
            if (ready_i_r = '0' and cnt_shift = 0) then
              RS  <= shifter;
            end if;
          
          -- shift right logical or arithmetic
          when C_F3_SRL =>
            -- immediat operation
            if (START_IMM = '1') then
              cnt_shift <= unsigned(SHAMT);
              shifter   <= rs1_reverse;
            end if;
            
            -- reg to reg
            if (START_REG = '1') then
              cnt_shift <= unsigned(RS_2(4 downto 0));
              shifter   <= rs1_reverse;
            end if;
            
            -- artihemetic or logical shift
            if (OP_CODE_F7 = C_F7_SRA) then
              bit_shift <= RS_1(31);
            else  
              bit_shift <= '0';
            end if;
            
            if (ready_i_r = '0' and cnt_shift = 0) then
              RS      <= shifter_reverse;
            end if;
            
          when others => 
            -- illegal instruction
            if (START_REG = '1' or START_IMM = '1') then
              ready_i   <= '0';
              ready_i_r <= '1';
            end if:
          end case;
      end if;
    end if;
  end process P_ALU;

end rtl;
