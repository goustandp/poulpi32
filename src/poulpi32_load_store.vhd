library work;
  use work.poulpi32_pkg.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity poulpi32_load_store is
  port(
    -- clock and reset
    CLK             : in  std_logic;
    RSTN            : in  std_logic;
    -- core signals
    OP_CODE_F3      : in  std_logic_vector(2 downto 0);
    RS_1            : in  std_logic_vector(31 downto 0);
    RS_2            : in  std_logic_vector(31 downto 0);
    IMM             : in  std_logic_vector(31 downto 0); -- immediate value signed extended
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
end entity poulpi32_load_store;

architecture rtl of poulpi32_load_store is
  -- signals for axi
  signal axi_addr_i               : std_logic_vector(31 downto 0);
  signal axi_awvalid_i            : std_logic;
  signal axi_wvalid_i             : std_logic;
  signal axi_bready_i             : std_logic;
  signal axi_arvalid_i            : std_logic;
  signal axi_rready_i             : std_logic;

  signal addr_offset              : integer range 0 to 3;



begin
  -- axi4 lite protocol is used in half dupex
  AXI_ARADDR            <= axi_addr_i;
  AXI_AWADDR            <= axi_addr_i;
  

  AXI_AWPROT            <= C_DACCESS;
  AXI_ARPROT            <= C_DACCESS;

  -- ready and valid signals
  AXI_AWVALID           <= axi_awvalid_i;
  AXI_WVALID            <= axi_wvalid_i;
  AXI_BREADY            <= axi_bready_i;
  AXI_ARVALID           <= axi_arvalid_i;
  AXI_RREADY            <= axi_rready_i;


  P_LOAD_STORE  : process(CLK)
    variable v_axi_addr  : signed(31 downto 0);
  begin
    if rising_edge(CLK) then
      if (RSTN = '0') then
        --outputs
        RD              <= (others => '0');
        AXI_WDATA       <= (others => '0');
        AXI_WSTRB       <= (others => '0');
        READY           <= '1';
        WE              <= '0';
        -- internals signals
        axi_addr_i         <= (others => '0');
        axi_awvalid_i      <= '0';
        axi_wvalid_i       <= '0';
        axi_bready_i       <= '0';
        axi_arvalid_i      <= '0';
        axi_rready_i       <= '0';
        addr_offset        <= 0;
      else
      
        WE  <= '0';
      
        if (START_LOAD ='1' or START_STORE = '1') then
          v_axi_addr      :=signed(RS_1)+signed(IMM);
          axi_addr_i      <= std_logic_vector(v_axi_addr(31 downto 2))&"00";
          addr_offset     <= to_integer(unsigned(v_axi_addr(1 downto 0)));
          AXI_WDATA       <= (others => '0');
          READY           <= '0';
        end if;
        
        --start load
        if (START_LOAD = '1') then
          axi_arvalid_i   <= '1';
          axi_rready_i    <= '1';
        end if;
        
        --begin store by sending address
        if (START_STORE = '1') then
          axi_awvalid_i   <= '1';
          axi_bready_i    <= '1';
        end if;

        if (axi_rready_i = '1' and AXI_RVALID = '1') then --load started
          WE            <= '1';
          READY         <= '1';
          axi_rready_i  <= '0';
          --decode instruction
          case OP_CODE_F3 is
          -- load signed byte
            when C_F3_LB  =>
              RD            <= std_logic_vector(resize(signed(AXI_RDATA((addr_offset+1)*8-1 downto addr_offset*8)), 32));
              
            --load signed half
            when C_F3_LH => 
              RD            <= std_logic_vector(resize(signed(AXI_RDATA((addr_offset+2)*8-1 downto addr_offset*8)), 32));
            
            -- load word
            when C_F3_LW => 
              RD            <= AXI_RDATA;

            --load byte as unsigned
            when C_F3_LBU => 
              RD            <= std_logic_vector(resize(unsigned(AXI_RDATA((addr_offset+1)*8-1 downto addr_offset*8)), 32));

            when C_F3_LHU => 
              -- load half as unsigned
              RD            <= std_logic_vector(resize(unsigned(AXI_RDATA((addr_offset+2)*8-1 downto addr_offset*8)), 32));
                
            when others => 
              READY <= '0';
            end case;
        end if;

         -- store started
        if (axi_awvalid_i = '1') then 
          axi_wvalid_i                        <= '1';
          --decode instruction
          case OP_CODE_F3 is 
          -- store byte
            when C_F3_SB =>
              AXI_WDATA(8*(addr_offset+1)-1 downto (8*addr_offset)) <= RS_2(7 downto 0);
              AXI_WSTRB(addr_offset)                                <= '1';
                
            -- store half 
            when C_F3_SH  =>  
              AXI_WDATA(8*(addr_offset+2)-1 downto (8*addr_offset)) <= RS_2(15 downto 0);
              AXI_WSTRB(addr_offset+1 downto addr_offset)           <= "11";
              
            -- store word
            when C_F3_SW  => 
              AXI_WDATA       <= RS_2;
              AXI_WSTRB       <= "1111";
                         
            when others =>
              READY <= '0';
          end case;
        end if;
  
        -- store OK
        if (axi_wvalid_i = '1' and AXI_WREADY = '1') then
          axi_wvalid_i  <= '0';
          READY         <= '1';
          AXI_WSTRB     <= (others => '0');
        end if;


        -- read adress ok
        if (axi_arvalid_i = '1' and AXI_ARREADY = '1') then
          axi_arvalid_i <= '0';
        end if;
        
        --write adress ok 
        if (axi_awvalid_i = '1' and AXI_AWREADY = '1') then
          axi_awvalid_i <= '0';
        end if;
        
        -- write resp 
        if (axi_bready_i =  '1' and AXI_BVALID  = '1') then
          axi_bready_i  <= '0';
          if (AXI_BRESP /= C_OKAY or AXI_BRESP /=C_EXOKAY) then
            READY <= '0';
          end if;
        end if;
        
        -- read resp
        if (axi_rready_i = '1' and AXI_RVALID = '1') then
          if (AXI_RESP /= C_OKAY or AXI_RESP /= C_EXOKAY) then
            READY <= '0';
          end if;
        end if;
        

        
      end if;
    end if;
  end process P_LOAD_STORE;

end rtl;
