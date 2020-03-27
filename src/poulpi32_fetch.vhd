library work;
  use work.poulpi32_pkg.all;
library ieee;
  use ieee.std_logic_1164.all;

entity poulpi32_fetch is
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
end entity poulpi32_fetch;

architecture rtl of poulpi32_fetch is 
  signal axi_addr         : std_logic_vector(31 downto 0);
  signal axi_arvalid_i    : std_logic;
  signal axi_rready_i     : std_logic;

  

begin

  -- fetch module can only do I access
  AXI_ARPROT  <= C_IACCESS;
  AXI_RREADY  <= axi_rready_i;
  AXI_ARVALID <= axi_arvalid_i;

  

  
  P_FETCH : process(CLK)
  begin
    if rising_edge(CLK) then
      if (RSTN = '0') then
        --outputs
        FETCH_INSTR     <= (others => '0');
        AXI_ARADDR      <= (others => '0');
        -- internals signals
        axi_arvalid_i   <= '0';
        axi_rready_i    <= '0';
        READY           <= '1';
      else
        -- fetch stage 
        if (START_FECTH = '1') then     
          AXI_ARADDR    <= PROGRAM_COUNTER;
          READY         <= '0';
          axi_rready_i  <= '1';
          axi_arvalid_i <= '1';
        end if;
        
        -- adress OK
        if (AXI_ARREADY = '1' and axi_arvalid_i  = '1') then
          axi_arvalid_i <= '0'; 
        end if;
        
        -- read data OK
        if (axi_rready_i = '1' and AXI_RVALID = '1') then
          axi_rready_i  <= '0';
          FETCH_INSTR   <= AXI_RDATA;
          READY         <= '1';
        end if;
        
        -- read resp
        if (axi_rready_i = '1' and AXI_RVALID = '1') then
          if (AXI_RESP /= C_OKAY or AXI_RESP /= C_EXOKAY) then
            READY <= '0';
          end if;
        end if;
        
      end if;
    end if;
  end process;
  
end rtl;
