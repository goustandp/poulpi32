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
    BRANCH_OP_CODE    : out std_logic_vector(2 downto 0);
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
    MUX_ID            : out std_logic_vector(1 downto 0)
  );

end entity poulpi32_decode;


    
