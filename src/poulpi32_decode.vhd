entity poulpi32_decode is
  generic(
    G_PC_RST_VALUE  : std_logic_vector(31 downto 0)
    );
  
  port(
    -- clock and reset
    CLK               : in  std_logic;
    RSTN              : in  std_logic;
    -- fectch signals
    FETCH_PC          : out std_logic_vector(31 downto 0);
    FETCH_INSTR       : in  std_logic_vector(31 downto 0);
    FETCH_START       : out std_logic;
    FETCH_READY       : in  std_logic;
    -- branch signals
    BRANCH_IMM        : out std_logic_vector(31 downto 0);
    BRANCH_PC         : out std_logic_vector(31 downto 0);
    BRANCH_NEXT_PC    : in  std_logic_vector(31 downto 0);
    BRANCH_OP_CODE    : out std_logic_vector(2 downto  0);
    BRANCH_START      : out std_logic;
    BRANCH_READY      : in  std_logic
    -- load store signals
    LSU_OP_CODE       : out std_logic_vector(2 downto 0);
    LSU_IMM           : out std_logic_vector(31 downto 0); 
    LSU_START_LOAD    : out std_logic;
    LSU_START_STORE   : out std_logic;
    LSU_READY         : in  std_logic;
    --alu signals
    ALU_IMM           : out std_logic_vector(31 downto 0); --signed extended
    ALU_IMMU          : out std_logic_vector(31 downto 0);
    ALU_SHAMT         : out std_logic_vector(4 downto 0);
    ALU_READY         : in  std_logic;
    ALU_START_REG     : out std_logic;
    ALU_START_IMM     : out std_logic;
    ALU_OP_CODE       : out std_logic_vector(2 downto 0);
    ALU_OP_CODE_F7    : out std_logic_vector(6 downto 0);
    -- mux signals
    MUX_ID            : out std_logic_vector(1 downto 0);
    -- register signals
    RS1_ID            : out std_logic_vector(4 downto 0);
    RS2_ID            : out std_logic_vector(4 downto 0);
    RD_ID             : out std_logic_vector(4 downto 0);
    -- decode register
    RS_1              : in  std_logic_vector(31 downto 0);
    RS_2              : in  std_logic_vector(31 downto 0);
    RD                : out std_logic_vector(31 downto 0);
    WE                : out std_logic
  );

end entity poulpi32_decode;


architecture rtl of poulpi32_decode is

  type t_state is  (ST_START, 
                    ST_FETCH_WAIT,
                    ST_FETCH_WB,
                    ST_DECODE,
                    ST_AUIPC_WB,
                    ST_JAL_WB,
                    ST_JALR,
                    ST_JALR_WB,
                    ST_ALU_WAIT,
                    ST_LSU_WAIT,
                    ST_BR_WAIT,
                    ST_BR_WB);
  
  signal decode_state : t_state;
  signal pc             : unsigned(31 downto 0);
  signal pc_jump        : unsigned(31 downto 0);
  signal operande_a     : unsigned(31 downto 0);
  signal operande_b     : unsigned(31 downto 0);
  signal current_instr  : std_logic_vector(31 downto 0);

  signal op_code        : std_logic_vector(6 downto 0);
  signal op_code_f3     : std_logic_vector(2 downto 0);
  signal op_code_f7     : std_logic_vector(6 downto 0);

  
  signal i_imm          : std_logic_vector(11 downto 0);
  signal b_imm          : std_logic_vector(12 downto 0);
  signal j_imm          : std_logic_vector(11 downto 0);
  signal s_imm          : std_logic_vector(11 downto 0);
  signal u_imm          : std_logic_vector(31 downto 0);
  signal shamt          : std_logic_vector(4 downto 0);
  
begin 
  
  -- immediat value assignement
  i_imm         <= current_instr(31 downto 20);
  s_imm         <= current_instr(31 downto 25)&current_instr(11 downto 7);
  u_imm         <= current_instr(31 downto 12)&x"000";
  b_imm         <= current_instr(12)&current_instr(7)&current_instr(30 downto 25)&current_instr(11 downto 8)&"0";
  j_imm         <= current_instr(31)&current_instr(19 downto 12)&current_instr(20)&current_instr(30 downto 21);
  shamt         <= current_instr(23 downot 20);
  
  --op code asignement
  op_code       <= current_instr(6 downto 0);
  op_code_f3    <= current_instr(14 downto 12);
  op_code_f7    <= current_instr(31 downto 25);
  
  FETCH_PC      <= std_logic_vector(pc);
  BRANCH_PC     <= std_logic_vector(pc);
  
  RS1_ID        <= current_instr(19 downto 15);
  RS2_ID        <= current_instr(24 downto 20);
  RD_ID         <= current_instr(11 downto 7);
  
  P_DECODE : process(CLK)
  begin
    if rising_edge(CLK) then
      if (RSTN = '0') then
        --internal signals
        decode_state      <= ST_START;
        pc                <= (others => '0');
        pc_next           <= (others => '0');
        current_instr     <= (others => '0');
        -- output
        FETCH_START       <= '0';
        BRANCH_IMM        <= (others => '0');
        BRANCH_OP_CODE    <= (others => '0');
        BRANCH_START      <= '0';
        LSU_OP_CODE       <= (others => '0');
        LSU_IMM           <= (others => '0');
        LSU_START_LOAD    <= '0';
        LSU_START_STORE   <= '0';
        ALU_IMM           <= (others => '0');
        ALU_IMMU          <= (others => '0');
        ALU_SHAMT         <= (others => '0');
        ALU_START_REG     <= '0';
        ALU_START_IMM     <= '0';
        ALU_OP_CODE       <= (others => '0');
        ALU_OP_CODE_F7    <= (others => '0');
        MUX_ID            <= (others => '0');
        WE                <= '0';
      
      else
        -- pulse control signals
        FETCH_START       <= '0';
        BRANCH_START      <= '0';
        LSU_START_LOAD    <= '0';
        LSU_START_STORE   <= '0';
        ALU_START_REG     <= '0';
        ALU_START_IMM     <= '0';
        WE                <= '0';
        
        -- next pc if jump 
        pc_jump           <= operande_a + operande_b;
        
        -- main state machine
        case decode_state is
          init state
          when ST_START =>
            pc            <= unsigned(G_PC_RST_VALUE);
            FETCH_START   <= '1';
            decode_state  <= ST_FETCH_WAIT:
          
          -- wait for fetch unit
          when ST_FETCH_WAIT  =>
            decode_state  <= ST_FETCH_WB;
          
          -- wait for unit to be ready
          when ST_FETCH_WB =>
            if (FETCH_READY = '1' and ALU_READY ='1' and and LSU_READY = '1') then
              current_instr <= FETCH_INSTR;
              decode_state  <= ST_DECODE;
            end if;
          
          -- decode current instruction
          when ST_DECODE  =>
            case op_code is 
            -- load upper immediate
            -- rd <= imm &"000...0"
              when C_OP_LUI =>
                  MUX_ID        <= C_DC_ID;
                  RD            <= u_imm;
                  WE            <= '1';
                  FETCH_START   <= '1';
                  decode_state  <= ST_FETCH_WAIT;
            

            -- add upper immediate
            -- RD <= PC+imm &"000...0"
             when C_OP_AUIPC  =>
                operande_a    <= pc;
                operande_b    <= unsigned(u_imm);
                MUX_ID        <= C_DC_ID;
                decode_state  <= ST_AUIPC_WB;
                pc            <= BRANCH_PC_NEXT;
                FETCH_START   <= '1';
                
            -- jump and link
            -- PC=PC+signed(imm)
            -- store the address of pc+4 to rd
             when C_OP_JAL  =>
              operande_a    <= pc;
              operande_b    <= unsigned(resize(signed(j_imm), 32));
              MUX_ID        <= C_DC_ID;
              decode_state  <= ST_JAL_WB;
            
            -- jump and link register
            --ad offset to PC
            -- offset=signed(rs1)+signed(imm)
            -- store the address of pc+1 to rd
             when C_OP_JALR  => 
              MUX_ID          <= C_DC_ID;
              decode_state    <= ST_JALR;
            

            -- consditionnal branch
            -- PC <= PC+imm if condition
            when  C_OP_BRANCH =>
              BRANCH_OP_CODE  <= op_code_f3;
              BRANCH_IMM      <= std_logic_vector(resize(signed(b_imm), 32));
              BRANCH_START    <= '1';
              MUX_ID          <= C_BR_ID;
              decode_state    <= ST_BR_WAIT;

            -- load byte, half or word from memory
            when  C_OP_LOAD =>
              MUX_ID          <= C_LSU_ID;
              LSU_START_LOAD  <= '1';
              LSU_OP_CODE     <= op_code_f3;
              LSU_IMM         <= std_logic_vector(resize(signed(i_imm), 32));
              decode_state    <= ST_LSU_WAIT;
              pc              <= BRANCH_PC_NEXT;
              FETCH_START     <= '1';
            

            -- store byte, half or word in memory
            when C_OP_STORE =>
              MUX_ID          <= C_LSU_ID;
              LSU_START_STORE <= '1';
              LSU_OP_CODE     <= op_code_f3;
              LSU_IMM         <= std_logic_vector(resize(signed(s_imm), 32));
              decode_state    <= ST_LSU_WAIT;
              pc              <= BRANCH_PC_NEXT;
              FETCH_START     <= '1';
            

            -- arithmetic operation using immediate values
            when C_OP_ARTHI =>
              MUX_ID          <= C_ALU_ID;
              ALU_START_IMM   <= '1';
              ALU_OP_CODE     <= op_code_f3;
              ALU_OP_CODE_F7  <= op_code_f7;
              ALU_IMM         <= std_logic_vector(resize(signed(i_imm), 32));
              ALU_IMMU        <= std_logic_vector(resize(unsigned(i_imm), 32));
              ALU_SHAMT       <= shamt;
              decode_state    <= ST_ALU_WAIT;
              pc              <= BRANCH_PC_NEXT;
              FETCH_START     <= '1';
            

            -- arithemtic operations using registers values
            when C_OP_ARTH    =>
              MUX_ID          <= C_ALU_ID;
              ALU_START_IMM   <= '1';
              ALU_OP_CODE     <= op_code_f3;
              ALU_OP_CODE_F7  <= op_code_f7;
              decode_state    <= ST_ALU_WAIT;
              pc              <= BRANCH_PC_NEXT;
              FETCH_START     <= '1';
            

            -- external operation (ecall, ebreak..)
             when C_OP_EXT  =>
                decode_state  <= ST_DECODE;
            -- fence operation (needed for rv32i???)
            when C_OP_FENCE   =>
              pc            <= BRANCH_PC_NEXT;
              FETCH_START   <= '1';
              decode_state  <= ST_FETCH_WAIT;
            when others =>
              decode_state  <= ST_DECODE;
            end case;
      
      -- add upper immediat write back
      when ST_AUIPC_WB =>
        RD            <=  pc_jump;
        we            <= '1';
        decode_state  <= ST_FETCH_WB;
      
      -- jump and link write back
      when ST_JAL_WB  => 
        RD            <= pc_next;
        pc            <= pc_jump;
        FETCH_START   <= '1';
        WE            <= '1';
        decode_state  <= ST_FETCH_WAIT;
        
      -- execute jump and link
      when ST_JALR  =>
        operande_a    <= unsigned(resize(signed(i_imm, 32)));
        operande_b    <= unsigned(RS_1);
        decode_state  <= ST_JALR_WB;
      
      -- jump and link write back
      when ST_JALR_WB =>
        pc            <= pc_jump;
        RD            <= pc_next;
        WE            <= '1';
        FETCH_START   <= '1';
        decode_state  <= ST_FETCH_WAIT;
        
      -- wait for branch unit
      when ST_BR_WAIT =>
        decode_state  <= ST_BR_WB;
        
      -- branch write back
      when ST_BR_WB =>
        if (BRANCH_READY = '1') =>
          pc            <= unsigned(BRANCH_PC_NEXT);
          FETCH_START   <= '1';
          decode_state  <= ST_FETCH_WAIT;
        end if;
      
      -- wait foir load store unit
      when  ST_LSU_WAIT => 
        decode_state  <= ST_FETCH_WB;
      
      -- wait for alu
      when  ST_ALU_WAIT =>
        decode_state  <= ST_FETCH_WB;
        
      when others =>
        decode_state  <= ST_FETCH_WAIT;
      end case
    end if;
  end if;
  
  end process P_DECODE;


end rtl;

      
      
