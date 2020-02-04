package poulpi32_pkg is
	-------------------------------------------------------------------------------------------------
	-- main op codes
	------------------------------------------------------------------------------------------------
	
	
	------------------------------------------------------------------------------------------------
	-- load upper immediate
	-- rd <= imm &"000...0"
	constant C_OP_LUI 			: std_logic_vector(6 downto 0):="0110111";
	
	--------------------------------------------------------------------------------------------------
	-- add upper immediate
	-- PC <= imm &"000...0"
	constant C_OP_AUIPC 		: std_logic_vector(6 downto 0):="0010111";
	
	--------------------------------------------------------------------------------------------------
	-- jump and link
	-- PC=PC+signed(imm)
	-- store the address of pc+1 to rd
	constant C_OP_JAL 			: std_logic_vector(6 downto 0):="1101111";
	
	-------------------------------------------------------------------------------------------------
	-- jump and link register
	--ad offset to PC
	-- offset=signed(rs1)+signed(imm)
	-- store the address of pc+1 to rd
	constant C_OP_JALR 		: std_logic_vector(6 downto 0):="1100111";
	
	-------------------------------------------------------------------------------------------------
	-- consditionnal branch
	-- PC <= PC+imm if condition
	constant C_OP_BRANCH 	: std_logic_vector(6 downto 0):="1100011";
	
	-------------------------------------------------------------------------------------------------
	-- load byte, half or word from memory
	constant C_OP_LOAD 		: std_logic_vector(6 downto 0):="0000011";
	
	-------------------------------------------------------------------------------------------------
	-- store byte, half or word in memory
	constant C_OP_STORE 	: std_logic_vector(6 downto 0):="0100011";
	
	--------------------------------------------------------------------------------------------------
	-- arithmetic operation using immediate values
	constant C_OP_ARTHI 		: std_logic_vector(6 downto 0):="0010011";
	
	--------------------------------------------------------------------------------------------------
	-- arithemtic operations using registers values
	constant C_OP_ARTH 		: std_logic_vector(6 downto 0):="0110011";
	
	-------------------------------------------------------------------------------------------------
	-- external operation (ecall, ebreak..)
	constant C_OP_EXT			: std_logic_vector(6 downto 0):="1110011";
	
	-------------------------------------------------------------------------------------------------
	-- fence operation (needed for rv32i???)
	constant C_OP_FENCE 	: std_logic_vector(6 downto 0):="0001111";
	
	
	
	
	--------------------------------------------------------------------------------------------------
	-- funct3 op codes
	--------------------------------------------------------------------------------------------------
	
	--  branch f3
	
	constant C_F3_BEQ		: std_logic_vector(2 downto 0):="000";
	constant C_F3_BNE 	: std_logic_vector(2 downto 0):="001";
	constant C_F3_BLT 		: std_logic_vector(2 downto 0):="100";
	constant C_F3_BGE 	: std_logic_vector(2 downto 0):="101";
	constant C_F3_BLTU 	: std_logic_vector(2 downto 0):="110";
	constant C_F3_BGEU 	: std_logic_vector(2 downto 0):="111";
	
	
	-- load f3
	constant C_F3_LB 		: std_logic_vector(2 downto 0):="000";
	constant C_F3_LH 		: std_logic_vector(2 downto 0):="001";
	constant C_F3_LW 		: std_logic_vector(2 downto 0):="010";
	constant C_F3_LBU 	: std_logic_vector(2 downto 0):="100";
	constant C_F3_LHU 	: std_logic_vector(2 downto 0):="101";
	
	-- store f3
	constant C_F3_SB 		: std_logic_vector(2 downto 0):="000";
	constant C_F3_SH 		: std_logic_vector(2 downto 0):="001";
	constant C_F3_SW 		: std_logic_vector(2 downto 0):="010";
	
	-- imediat arithemtic 
	constant C_F3_ADDI 	: std_logic_vector(2 downto 0):="000";
	constant C_F3_SLTI  	: std_logic_vector(2 downto 0):="010";
	constant C_F3_SLTIU 	: std_logic_vector(2 downto 0):="011";
	constant C_F3_XORI 	: std_logic_vector(2 downto 0):="100";
	constant C_F3_ORI 		: std_logic_vector(2 downto 0):="110";
	constant C_F3_ANDI 	: std_logic_vector(2 downto 0):="111";
	constant C_F3_SLLI 	: std_logic_vector(2 downto 0):="001";
	constant C_F3_SRLI 	: std_logic_vector(2 downto 0):="101";
	constant  C_F3_SRAI 	: std_logic_vector(2 downto 0):="101"; --f5 is different...
	
	-- register arithmetic
	constant C_F3_ADD 	: std_logic_vector(2 downto 0):="000";
	constant C_F3_SUB 	: std_logic_vector(2 downto 0):="000";
	constant C_F3_SLL 		: std_logic_vector(2 downto 0):="001";
	constant C_F3_SLT 		: std_logic_vector(2 downto 0):="010";
	constant C_F3_SLTU  	: std_logic_vector(2 downto 0):="011";
	constant C_F3_XOR 	: std_logic_vector(2 downto 0):="100";
	constant C_F3_SRL 		: std_logic_vector(2 downto 0):="101";
	constant C_F3_SRA 	: std_logic_vector(2 downto 0):="101";
	constant C_F3_OR 		: std_logic_vector(2 downto 0):="110";
	constant C_F3_AND 	: std_logic_vector(2 downto 0):="111";
	
	-- external
	constant C_F3_EXT 	: std_logic_vector(2 downto 0):="000";
	
	--fence 
	constant C_F3_FENCE 	: std_logic_vector(2 downto 0):="000";
	
	
	---------------------------------------------------------------------------------
	-- f7 op code
	
	-- immediat arithmetic
	constant C_F7_SLLI  	: std_logic_vector(6 downto 0):="0000000";
	constant C_F7_SRLI		: std_logic_vector(6 downto 0):="0000000";
	constant C_F7_SRAI 	: std_logic_vector(6 downto 0):="0100000";
	
	-- arithemtic 
	constant C_F7_ADD		: std_logic_vector(6 downto 0):="0000000";
	constant C_F7_SUB 	: std_logic_vector(6 downto 0):="0100000";
	constant C_F7_SLL		: std_logic_vector(6 downto 0):="0000000";
	constant C_F7_SLT		: std_logic_vector(6 downto 0):="0000000";
	constant C_F7_SLTU	: std_logic_vector(6 downto 0):="0000000";
	constant C_F7_XOR		: std_logic_vector(6 downto 0):="0000000";
	constant C_F7_SRL		: std_logic_vector(6 downto 0):="0000000";
	constant C_F7_SRA		: std_logic_vector(6 downto 0):="0100000";
	constant C_F7_OR		: std_logic_vector(6 downto 0):="0000000";
	constant C_F7_AND		: std_logic_vector(6 downto 0):="0000000";
	
end poulpi32_pkg;
	
