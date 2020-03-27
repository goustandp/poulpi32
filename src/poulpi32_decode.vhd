library work;
  use work.poulpi32_pkg.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

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
    BRANCH_OP_CODE    : out std_logic_vector(6 downto  0);
    BRANCH_OP_CODE_F3 : out std_logic_vector(2 downto  0);
    BRANCH_START      : out std_logic;
    BRANCH_READY      : in  std_logic;
    -- load store signals
    LSU_OP_CODE_F3    : out std_logic_vector(2 downto 0);
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
    ALU_OP_CODE_F3    : out std_logic_vector(2 downto 0);
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
                    ST_WAIT,
                    ST_FETCH_WB,
                    ST_DECODE,
                    ST_BRANCH_WAIT,
                    ST_BRANCH_WB);
  
  signal decode_state : t_state;
  signal pc             : std_logic_vector(31 downto 0);

  signal op_code        : std_logic_vector(6 downto 0);
  signal op_code_f3     : std_logic_vector(2 downto 0);
  signal op_code_f7     : std_logic_vector(6 downto 0);

  
  signal i_imm          : std_logic_vector(11 downto 0);
  signal b_imm          : std_logic_vector(12 downto 0);
  signal j_imm          : std_logic_vector(11 downto 0);
  signal s_imm          : std_logic_vector(11 downto 0);
  signal u_imm          : std_logic_vector(31 downto 0);
  signal shamt          : std_logic_vector(4  downto 0);
  signal rs1_id_i       : std_logic_vector(4  downto 0);
  signal rs2_id_i       : std_logic_vector(4  downto 0);
  signal rd_id_i        : std_logic_vector(4  downto 0);  
  
begin 
  
  -- immediat value assignement
  i_imm         <= FETCH_INSTR(31 downto 20);
  s_imm         <= FETCH_INSTR(31 downto 25)&FETCH_INSTR(11 downto 7);
  u_imm         <= FETCH_INSTR(31 downto 12)&x"000";
  b_imm         <= FETCH_INSTR(12)&FETCH_INSTR(7)&FETCH_INSTR(30 downto 25)&FETCH_INSTR(11 downto 8)&"0";
  j_imm         <= FETCH_INSTR(31)&FETCH_INSTR(19 downto 12)&FETCH_INSTR(20)&FETCH_INSTR(30 downto 21);
  shamt         <= FETCH_INSTR(24 downto 20);
  
  --op code asignement
  op_code       <= FETCH_INSTR(6 downto 0);
  op_code_f3    <= FETCH_INSTR(14 downto 12);
  op_code_f7    <= FETCH_INSTR(31 downto 25);
  
  FETCH_PC      <= std_logic_vector(pc);
  BRANCH_PC     <= std_logic_vector(pc);
  
  rs1_id_i      <= FETCH_INSTR(19 downto 15);
  rs2_id_i      <= FETCH_INSTR(24 downto 20);
  rd_id_i       <= FETCH_INSTR(11 downto 7);
  
  P_DECODE : process(CLK)
  begin
    if rising_edge(CLK) then
      if (RSTN = '0') then
        --internal signals
        decode_state      <= ST_START;
        pc                <= (others => '0');
        -- output
        FETCH_START       <= '0';
        BRANCH_IMM        <= (others => '0');
        BRANCH_OP_CODE    <= (others => '0');
        BRANCH_OP_CODE_F3 <= (others => '0');
        BRANCH_START      <= '0';
        LSU_OP_CODE_F3    <= (others => '0');
        LSU_IMM           <= (others => '0');
        LSU_START_LOAD    <= '0';
        LSU_START_STORE   <= '0';
        ALU_IMM           <= (others => '0');
        ALU_IMMU          <= (others => '0');
        ALU_SHAMT         <= (others => '0');
        ALU_START_REG     <= '0';
        ALU_START_IMM     <= '0';
        ALU_OP_CODE_F3    <= (others => '0');
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
        

        -- main state machine
        case decode_state is
          -- init state
          when ST_START =>
            pc            <= G_PC_RST_VALUE;
            FETCH_START   <= '1';
            decode_state  <= ST_WAIT;
            
         
          when ST_FETCH_WB =>
            -- wait for unit to be ready
            if (FETCH_READY = '1' and ALU_READY ='1' and LSU_READY = '1') then
              --asign op code
              ALU_OP_CODE_F3    <= op_code_f3;
              ALU_OP_CODE_F7    <= op_code_f7;
              LSU_OP_CODE_F3    <= op_code_f3;
              BRANCH_OP_CODE_F3 <= op_code_f3;
              BRANCH_OP_CODE    <= op_code;
              
              -- assign reg id
              RS1_ID            <= rs1_id_i; 
              RS2_ID            <= rs2_id_i; 
              RD_ID             <= rd_id_i;
                
              decode_state      <= ST_DECODE;
            end if;
            
          -- decode instrcution
          when ST_DECODE =>
            -- decode op
            case op_code is 
              -- load upper immediate
              -- rd <= imm &"000...0"
              when C_OP_LUI =>
                MUX_ID        <= C_DC_ID;
                RD            <= u_imm;
                pc            <= BRANCH_NEXT_PC;
                WE            <= '1';
                FETCH_START   <= '1';
                decode_state  <= ST_WAIT;
            

              -- add upper immediate
              -- RD <= PC+imm &"000...0"
              when C_OP_AUIPC  =>
                MUX_ID        <= C_BR_ID;
                BRANCH_IMM    <= u_imm;
                pc            <= BRANCH_NEXT_PC;
                FETCH_START   <= '1';
                BRANCH_START  <= '1';
                decode_state  <= ST_WAIT;
              
            -- jump and link
            -- PC=PC+signed(imm)
            -- store the address of pc+4 to rd
              when C_OP_JAL  =>
                MUX_ID        <= C_BR_ID;
                BRANCH_IMM    <= std_logic_vector(resize(signed(j_imm), 32));
                BRANCH_START  <= '1';
                decode_state  <= ST_BRANCH_WAIT;
            
              -- jump and link register
              -- ad offset to PC
              -- offset=signed(rs1)+signed(imm)
              -- store the address of pc+1 to rd
              when C_OP_JALR  => 
                MUX_ID          <= C_BR_ID;
                BRANCH_START    <= '1';
                decode_state    <= ST_BRANCH_WAIT;
          

              -- consditionnal branch
              -- PC <= PC+imm if condition
              when  C_OP_BRANCH =>
                MUX_ID          <= C_BR_ID;
                BRANCH_IMM      <= std_logic_vector(resize(signed(b_imm), 32));
                BRANCH_START    <= '1';
                decode_state    <= ST_BRANCH_WAIT;

              -- load byte, half or word from memory
              when  C_OP_LOAD =>
                MUX_ID          <= C_LSU_ID;
                LSU_IMM         <= std_logic_vector(resize(signed(i_imm), 32));
                pc              <= BRANCH_NEXT_PC;
                FETCH_START     <= '1';
                LSU_START_LOAD  <= '1';
                decode_state    <= ST_WAIT;
          

              -- store byte, half or word in memory
              when C_OP_STORE =>
                MUX_ID          <= C_LSU_ID;
                LSU_IMM         <= std_logic_vector(resize(signed(s_imm), 32));
                pc              <= BRANCH_NEXT_PC;
                FETCH_START     <= '1';
                LSU_START_STORE <= '1';
                decode_state    <= ST_WAIT;
          

              -- arithmetic operation using immediate values
              when C_OP_ARTHI =>
                MUX_ID          <= C_ALU_ID;
                ALU_IMM         <= std_logic_vector(resize(signed(i_imm), 32));
                ALU_IMMU        <= std_logic_vector(resize(unsigned(i_imm), 32));
                ALU_SHAMT       <= shamt;
                pc              <= BRANCH_NEXT_PC;
                FETCH_START     <= '1';
                ALU_START_IMM   <= '1';
                decode_state    <= ST_WAIT;
          

              -- arithemtic operations using registers values
              when C_OP_ARTH    =>
                MUX_ID          <= C_ALU_ID;
                pc              <= BRANCH_NEXT_PC;
                FETCH_START     <= '1';
                ALU_START_IMM   <= '1';
                decode_state    <= ST_WAIT;

              -- external operation (ecall, ebreak..)
              when C_OP_EXT  =>
                decode_state  <= ST_FETCH_WB;
                
              -- fence operation (needed for rv32i???)
              when C_OP_FENCE   =>
                pc            <= BRANCH_NEXT_PC;
                FETCH_START   <= '1';
                decode_state  <= ST_WAIT;
              when others =>
                decode_state  <= ST_FETCH_WB;
              end case;
      
      -- wait for branch unit
      when ST_WAIT =>
        decode_state  <= ST_FETCH_WB;
        
      -- wait for branch unit
      when  ST_BRANCH_WAIT => 
        decode_state  <= ST_BRANCH_WB;
        
      -- branch write back
      when ST_BRANCH_WB =>
        if (BRANCH_READY = '1') then
          pc            <= BRANCH_NEXT_PC;
          FETCH_START   <= '1';
          decode_state  <= ST_WAIT;
        end if;
      end case;
    end if;
  end if;
  
  end process P_DECODE;


end rtl;

      
      
