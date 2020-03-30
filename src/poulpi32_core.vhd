library work;
  use work.poulpi32_pkg.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity poulpi32_core is
  generic(
    G_PC_RST_VALUE  : std_logic_vector(31 downto 0)
  );
  port(
    CLK                 : in  std_logic;
    RSTN                : in  std_logic;
    
    -- AXI4 lite memory signals for fetch stage
    AXI_FETCH_ARVALID   : out std_logic;
    AXI_FETCH_ARREADY   : in  std_logic;
    AXI_FETCH_ARADDR    : out std_logic_vector(31 downto 0);
    AXI_FETCH_ARPROT    : out std_logic_vector(2 downto 0);
    AXI_FETCH_RVALID    : in  std_logic;
    AXI_FETCH_RREADY    : out std_logic;
    AXI_FETCH_RDATA     : in  std_logic_vector(31 downto 0);
    AXI_FETCH_RESP      : in  std_logic_vector(1 downto 0);
    
    -- AXI4 lite memory signals for lsu
    -- write access
    AXI_LSU_AWVALID     : out std_logic;
    AXI_LSU_AWREADY     : in  std_logic;
    AXI_LSU_AWADDR      : out std_logic_vector(31 downto 0);
    AXI_LSU_AWPROT      : out std_logic_vector(2 downto 0);
    AXI_LSU_WVALID      : out std_logic;
    AXI_LSU_WREADY      : in  std_logic;
    AXI_LSU_WDATA       : out std_logic_vector(31 downto 0);
    AXI_LSU_WSTRB       : out std_logic_vector(3 downto 0);
    AXI_LSU_BVALID      : in  std_logic;
    AXI_LSU_BREADY      : out std_logic;
    AXI_LSU_BRESP       : in std_logic_vector(1 downto 0);
    --read access
    AXI_LSU_ARVALID     : out std_logic;
    AXI_LSU_ARREADY     : in  std_logic;
    AXI_LSU_ARADDR      : out std_logic_vector(31 downto 0);
    AXI_LSU_ARPROT      : out std_logic_vector(2 downto 0);
    AXI_LSU_RVALID      : in  std_logic;
    AXI_LSU_RREADY      : out std_logic;
    AXI_LSU_RDATA       : in  std_logic_vector(31 downto 0);
    AXI_LSU_RESP        : in  std_logic_vector(1 downto 0)
  );
end entity poulpi32_core;

architecture rtl of poulpi32_core is
  ----------------------------------------------------------------------
  -- decode unit
  ----------------------------------------------------------------------
  component poulpi32_decode is
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
      BRANCH_OP_CODE_F3 : out std_logic_vector(2 downto  0);
      BRANCH_OP_CODE    : out std_logic_vector(6 downto  0);
      BRANCH_START      : out std_logic;
      BRANCH_READY      : in  std_logic;
      -- load store signals
      LSU_OP_CODE_F3    : out std_logic_vector(2 downto 0);
      LSU_IMM           : out std_logic_vector(31 downto 0); 
      LSU_START_LOAD    : out std_logic;
      LSU_START_STORE   : out std_logic;
      LSU_READY         : in  std_logic;
      --alu signals
      ALU_IMM           : out std_logic_vector(31 downto 0); 
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
  end component poulpi32_decode;
  
  ----------------------------------------------------------------------
  -- registers file
  ----------------------------------------------------------------------
  component poulpi32_reg is
    port(
      CLK     : in  std_logic;
      RSTN    : in  std_logic;
        
      RS_1    : out std_logic_vector(31 downto 0);
      RS_2    : out std_logic_vector(31 downto 0);
      RD      : in  std_logic_vector(31 downto 0);
       
      RS1_ID  : in  std_logic_vector(4 downto 0);
      RS2_ID  : in  std_logic_vector(4 downto 0);
      RD_ID   : in  std_logic_vector(4 downto 0);
      WE      : in  std_logic
    );
  end component poulpi32_reg;
  
  ----------------------------------------------------------------------
  -- load store unit 
  ----------------------------------------------------------------------
  component poulpi32_load_store is
    port(
      -- clock and reset
      CLK             : in  std_logic;
      RSTN            : in  std_logic;
      -- core signals
      OP_CODE_F3      : in  std_logic_vector(2 downto 0);
      RS_1            : in  std_logic_vector(31 downto 0);
      RS_2            : in  std_logic_vector(31 downto 0);
      IMM             : in  std_logic_vector(31 downto 0); 
      RD              : out std_logic_vector(31 downto 0);
      WE              : out std_logic;
      -- control signals
      START_LOAD      : in  std_logic;
      START_STORE     : in  std_logic;
      READY           : out std_logic;
      -- AXI4 lite memory signals
      -- write access
      AXI_AWVALID     : out std_logic;
      AXI_AWREADY     : in   std_logic;
      AXI_AWADDR      : out std_logic_vector(31 downto 0);
      AXI_AWPROT      : out std_logic_vector(2 downto 0);
      AXI_WVALID      : out std_logic;
      AXI_WREADY      : in  std_logic;
      AXI_WDATA       : out std_logic_vector(31 downto 0);
      AXI_WSTRB       : out std_logic_vector(3 downto 0);
      AXI_BVALID      : in  std_logic;
      AXI_BREADY      : out std_logic;
      AXI_BRESP       : in std_logic_vector(1 downto 0);
      --read access
      AXI_ARVALID     : out std_logic;
      AXI_ARREADY     : in  std_logic;
      AXI_ARADDR      : out std_logic_vector(31 downto 0);
      AXI_ARPROT      : out std_logic_vector(2 downto 0);
      AXI_RVALID      : in  std_logic;
      AXI_RREADY      : out std_logic;
      AXI_RDATA       : in  std_logic_vector(31 downto 0);
      AXI_RESP        : in  std_logic_vector(1 downto 0)
    );
  end component poulpi32_load_store;

  ----------------------------------------------------------------------
  -- branch unit
  ----------------------------------------------------------------------
  component poulpi32_branch is 
    port(
      CLK         : in  std_logic;
      RSTN        : in  std_logic;
            
      RS_1        : in  std_logic_vector(31 downto 0);
      RS_2        : in  std_logic_vector(31 downto 0);
      RD          : out std_logic_vector(31 downto 0);
      WE          : out std_logic;
            
      IMM         : in  std_logic_vector(31 downto 0);
      PC          : in  std_logic_vector(31 downto 0);
      NEXT_PC     : out std_logic_vector(31 downto 0);
        
      OP_CODE_F3  : in  std_logic_vector(2 downto 0);
      OP_CODE     : in  std_logic_vector(6 downto 0);
      START       : in  std_logic;
      READY       : out std_logic
    );
  end component poulpi32_branch;

  ----------------------------------------------------------------------
  -- fetch unit
  ----------------------------------------------------------------------
  component poulpi32_fetch is
    port(
      -- clock and reset
      CLK             : in  std_logic;
      RSTN            : in  std_logic;
      -- core signals
      PROGRAM_COUNTER : in  std_logic_vector(31 downto 0);
      FETCH_INSTR     : out std_logic_vector(31 downto 0);
      -- control signals
      START_FECTH     : in  std_logic;
      READY           : out std_logic;
      -- AXI4 lite memory signals (only read acces)
      AXI_ARVALID     : out std_logic;
      AXI_ARREADY     : in  std_logic;
      AXI_ARADDR      : out std_logic_vector(31 downto 0);
      AXI_ARPROT      : out std_logic_vector(2 downto 0);
      AXI_RVALID      : in  std_logic;
      AXI_RREADY      : out std_logic;
      AXI_RDATA       : in  std_logic_vector(31 downto 0);
      AXI_RESP        : in  std_logic_vector(1 downto 0)
    );
  end component poulpi32_fetch;
  
  
  ----------------------------------------------------------------------
  -- mux for registers access
  ----------------------------------------------------------------------
  component poulpi32_mux is
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
      
      DC_RS_1   : out std_logic_vector(31 downto 0);
      DC_RS_2   : out std_logic_vector(31 downto 0);
      DC_RD     : in  std_logic_vector(31 downto 0);
      DC_WE     : in  std_logic
    );
  end component poulpi32_mux;

  ----------------------------------------------------------------------
  -- alu unit
  ----------------------------------------------------------------------
  component poulpi32_alu is
    port(
      CLK         : in  std_logic;
      RSTN        : in  std_logic;
      
      RS_1        : in  std_logic_vector(31 downto 0);
      RS_2        : in  std_logic_vector(31 downto 0);
      RD          : out std_logic_vector(31 downto 0);
      IMM         : in  std_logic_vector(31 downto 0);
      IMMU        : in  std_logic_vector(31 downto 0);
      
      SHAMT       : in  std_logic_vector(4 downto 0);
      
      READY       : out std_logic;
      START_REG   : in  std_logic;
      START_IMM   : in  std_logic;
      WE          : out std_logic;
      
      OP_CODE_F3  : in  std_logic_vector(2 downto 0);
      OP_CODE_F7  : in  std_logic_vector(6 downto 0)
    );
  end component poulpi32_alu;
  
  ----------------------------------------------------------------------
  -- signals declarations
  ----------------------------------------------------------------------
  
  -- registers
  signal mux_id             : std_logic_vector(1  downto 0);
  signal reg_rs_1           : std_logic_vector(31 downto 0);
  signal reg_rs_2           : std_logic_vector(31 downto 0);
  signal reg_rd             : std_logic_vector(31 downto 0);
  signal reg_we             : std_logic;
  signal lsu_rs_1           : std_logic_vector(31 downto 0);
  signal lsu_rs_2           : std_logic_vector(31 downto 0);
  signal lsu_rd             : std_logic_vector(31 downto 0);
  signal lsu_we             : std_logic;
  signal alu_rs_1           : std_logic_vector(31 downto 0);
  signal alu_rs_2           : std_logic_vector(31 downto 0);
  signal alu_rd             : std_logic_vector(31 downto 0);
  signal alu_we             : std_logic;
  signal br_rs_1            : std_logic_vector(31 downto 0);
  signal br_rs_2            : std_logic_vector(31 downto 0);
  signal br_rd              : std_logic_vector(31 downto 0);
  signal br_we              : std_logic;
  signal dc_rs_1            : std_logic_vector(31 downto 0);
  signal dc_rs_2            : std_logic_vector(31 downto 0);
  signal dc_rd              : std_logic_vector(31 downto 0);
  signal dc_we              : std_logic;
  
  signal rs1_id             : std_logic_vector(4 downto 0);
  signal rs2_id             : std_logic_vector(4 downto 0);
  signal rd_id              : std_logic_vector(4 downto 0);
  
  --control signals
  signal fetch_pc           : std_logic_vector(31 downto 0);
  signal fetch_instr        : std_logic_vector(31 downto 0);
  signal fetch_start        : std_logic;
  signal fetch_ready        : std_logic;
  signal branch_imm         : std_logic_vector(31 downto 0);
  signal branch_pc          : std_logic_vector(31 downto 0);
  signal branch_next_pc     : std_logic_vector(31 downto 0);
  signal branch_op_code_f3  : std_logic_vector(2  downto 0);
  signal branch_op_code     : std_logic_vector(6  downto 0);
  signal branch_start       : std_logic;
  signal branch_ready       : std_logic;
  signal lsu_op_code_f3     : std_logic_vector(2  downto 0);
  signal lsu_imm            : std_logic_vector(31 downto 0); 
  signal lsu_start_load     : std_logic;
  signal lsu_start_store    : std_logic;
  signal lsu_ready          : std_logic;
  signal alu_imm            : std_logic_vector(31 downto 0); 
  signal alu_immu           : std_logic_vector(31 downto 0);
  signal alu_shamt          : std_logic_vector(4  downto 0);
  signal alu_ready          : std_logic;
  signal alu_start_reg      : std_logic;
  signal alu_start_imm      : std_logic;
  signal alu_op_code_f3     : std_logic_vector(2  downto 0);
  signal alu_op_code_f7     : std_logic_vector(6  downto 0);

begin
  
  ----------------------------------------------------------------------
  -- decode unit 
  ----------------------------------------------------------------------
  inst_poulpi32_decode : poulpi32_decode
    generic map(
      G_PC_RST_VALUE  => G_PC_RST_VALUE
      )
    port map(
      CLK               => CLK,  
      RSTN              => RSTN, 
      FETCH_PC          => fetch_pc,     
      FETCH_INSTR       => fetch_instr,  
      FETCH_START       => fetch_start,  
      FETCH_READY       => fetch_ready,  
      BRANCH_IMM        => branch_imm,     
      BRANCH_PC         => branch_pc,      
      BRANCH_NEXT_PC    => branch_next_pc, 
      BRANCH_OP_CODE    => branch_op_code, 
      BRANCH_OP_CODE_F3 => branch_op_code_f3, 
      BRANCH_START      => branch_start,   
      BRANCH_READY      => branch_ready,   
      LSU_OP_CODE_F3    => lsu_op_code_f3,     
      LSU_IMM           => lsu_imm,         
      LSU_START_LOAD    => lsu_start_load,  
      LSU_START_STORE   => lsu_start_store, 
      LSU_READY         => lsu_ready,       
      ALU_IMM           => alu_imm,         
      ALU_IMMU          => alu_immu,        
      ALU_SHAMT         => alu_shamt,       
      ALU_READY         => alu_ready,       
      ALU_START_REG     => alu_start_reg,   
      ALU_START_IMM     => alu_start_imm,   
      ALU_OP_CODE_F3    => alu_op_code_f3,     
      ALU_OP_CODE_F7    => alu_op_code_f7,  
      MUX_ID            => mux_id,
      RS1_ID            => rs1_id,
      RS2_ID            => rs2_id,
      RD_ID             => rd_id, 
      RS_1              => dc_rs_1,
      RS_2              => dc_rs_2,
      RD                => dc_rd,  
      WE                => dc_we  
    );



  ----------------------------------------------------------------------
  -- registers file
  ----------------------------------------------------------------------
  inst_poulpi32_reg : poulpi32_reg
    port map(
      CLK     => CLK,
      RSTN    => RSTN,
      RS_1    => reg_rs_1,  
      RS_2    => reg_rs_2,  
      RD      => reg_rd,    
      RS1_ID  => rs1_id,
      RS2_ID  => rs2_id,
      RD_ID   => rd_id, 
      WE      => reg_we
    );
    
  ----------------------------------------------------------------------
  -- load store unit 
  ----------------------------------------------------------------------
  inst_poulpi32_load_store : poulpi32_load_store
    port map(

      CLK             => CLK,
      RSTN            => RSTN,
      OP_CODE_F3      => lsu_op_code_f3,     
      RS_1            => lsu_rs_1,      
      RS_2            => lsu_rs_2,
      IMM             => lsu_imm,  
      RD              => lsu_rd,
      WE              => lsu_we,
      START_LOAD      => lsu_start_load,  
      START_STORE     => lsu_start_store, 
      READY           => lsu_ready,       
      AXI_AWVALID     => AXI_LSU_AWVALID,
      AXI_AWREADY     => AXI_LSU_AWREADY,
      AXI_AWADDR      => AXI_LSU_AWADDR, 
      AXI_AWPROT      => AXI_LSU_AWPROT, 
      AXI_WVALID      => AXI_LSU_WVALID, 
      AXI_WREADY      => AXI_LSU_WREADY, 
      AXI_WDATA       => AXI_LSU_WDATA,  
      AXI_WSTRB       => AXI_LSU_WSTRB,  
      AXI_BVALID      => AXI_LSU_BVALID, 
      AXI_BREADY      => AXI_LSU_BREADY, 
      AXI_BRESP       => AXI_LSU_BRESP,  
      AXI_ARVALID     => AXI_LSU_ARVALID,
      AXI_ARREADY     => AXI_LSU_ARREADY,
      AXI_ARADDR      => AXI_LSU_ARADDR, 
      AXI_ARPROT      => AXI_LSU_ARPROT, 
      AXI_RVALID      => AXI_LSU_RVALID, 
      AXI_RREADY      => AXI_LSU_RREADY, 
      AXI_RDATA       => AXI_LSU_RDATA, 
      AXI_RESP        => AXI_LSU_RESP   
    );

  ----------------------------------------------------------------------
  -- branch unit
  ----------------------------------------------------------------------
  inst_poulpi32_branch : poulpi32_branch
    port map(
      CLK         => CLK,
      RSTN        => RSTN,
      RS_1        => br_rs_1,
      RS_2        => br_rs_2,
      RD          => br_rd,
      WE          => br_we,
      IMM         => branch_imm,
      PC          => branch_pc,
      NEXT_PC     => branch_next_pc,
      OP_CODE_F3  => branch_op_code_f3,
      OP_CODE     => branch_op_code,
      START       => branch_start,
      READY       => branch_ready
    );


  ----------------------------------------------------------------------
  -- fetch unit
  ----------------------------------------------------------------------
  inst_poulpi32_fetch : poulpi32_fetch
    port map(
      CLK             => CLK,
      RSTN            => RSTN,
      PROGRAM_COUNTER => fetch_pc,
      FETCH_INSTR     => fetch_instr,
      START_FECTH     => fetch_start,
      READY           => fetch_ready,
      AXI_ARVALID     => AXI_FETCH_ARVALID,
      AXI_ARREADY     => AXI_FETCH_ARREADY, 
      AXI_ARADDR      => AXI_FETCH_ARADDR,  
      AXI_ARPROT      => AXI_FETCH_ARPROT,  
      AXI_RVALID      => AXI_FETCH_RVALID,  
      AXI_RREADY      => AXI_FETCH_RREADY,  
      AXI_RDATA       => AXI_FETCH_RDATA,
      AXI_RESP        => AXI_FETCH_RESP
    );



  ----------------------------------------------------------------------
  -- mux for registers access
  ----------------------------------------------------------------------
  inst_poulpi32_mux : poulpi32_mux
    port map(
      ID        => mux_id,
      REG_RS_1  => reg_rs_1,
      REG_RS_2  => reg_rs_2,
      REG_RD    => reg_rd,  
      REG_WE    => reg_we,  
      LSU_RS_1  => lsu_rs_1,
      LSU_RS_2  => lsu_rs_2,
      LSU_RD    => lsu_rd,  
      LSU_WE    => lsu_we,  
      ALU_RS_1  => alu_rs_1,
      ALU_RS_2  => alu_rs_2,
      ALU_RD    => alu_rd,  
      ALU_WE    => alu_we,  
      BR_RS_1   => br_rs_1, 
      BR_RS_2   => br_rs_2, 
      BR_RD     => br_rd,   
      BR_WE     => br_we,   
      DC_RS_1   => dc_rs_1, 
      DC_RS_2   => dc_rs_2, 
      DC_RD     => dc_rd,   
      DC_WE     => dc_we   
    );

  ----------------------------------------------------------------------
  -- alu unit
  ----------------------------------------------------------------------
  inst_poulpi32_alu : poulpi32_alu
    port map(
      CLK         => CLK,
      RSTN        => RSTN,
      RS_1        => alu_rs_1,
      RS_2        => alu_rs_2,
      RD          => alu_rd,
      IMM         => alu_imm,
      IMMU        => alu_immu,
      SHAMT       => alu_shamt,
      READY       => alu_ready,
      START_REG   => alu_start_reg,
      START_IMM   => alu_start_imm,
      WE          => alu_we,
      OP_CODE_F3  => alu_op_code_f3,
      OP_CODE_F7  => alu_op_code_f7
    );

end rtl;
