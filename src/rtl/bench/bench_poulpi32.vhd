library work;
  use work.poulpi32_pkg.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.textio.all;


entity bench_poulpi32 is
end entity bench_poulpi32;

architecture behave of bench_poulpi32 is

  component poulpi32_core is
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
  end component poulpi32_core;
  
  
  component axi_bram is
    generic(
      G_ADDR_WIDTH      : integer;
      G_INIT_FILE_PATH  : string
      );
    port(
      -- clock and reset
      CLK               : in  std_logic;
      RSTN              : in  std_logic;
      -- PORT A
      -- write access
      AXI_A_AWVALID     : in  std_logic;
      AXI_A_AWREADY     : out std_logic;
      AXI_A_AWADDR      : in  std_logic_vector(31 downto 0);
      AXI_A_AWPROT      : in  std_logic_vector(2  downto 0);
      AXI_A_WVALID      : in  std_logic;
      AXI_A_WREADY      : out std_logic;
      AXI_A_WDATA       : in  std_logic_vector(31 downto 0);
      AXI_A_WSTRB       : in  std_logic_vector(3  downto 0);
      AXI_A_BVALID      : out std_logic;
      AXI_A_BREADY      : in  std_logic;
      AXI_A_BRESP       : out std_logic_vector(1  downto 0);
      --read access
      AXI_A_ARVALID     : in  std_logic;
      AXI_A_ARREADY     : out std_logic;
      AXI_A_ARADDR      : in  std_logic_vector(31 downto 0);
      AXI_A_ARPROT      : in  std_logic_vector(2  downto 0);
      AXI_A_RVALID      : out std_logic;
      AXI_A_RREADY      : in  std_logic;
      AXI_A_RDATA       : out std_logic_vector(31 downto 0);
      AXI_A_RESP        : out std_logic_vector(1  downto 0);
      
      -- PORT B
      -- write access
      AXI_B_AWVALID     : in  std_logic;
      AXI_B_AWREADY     : out std_logic;
      AXI_B_AWADDR      : in  std_logic_vector(31 downto 0);
      AXI_B_AWPROT      : in  std_logic_vector(2  downto 0);
      AXI_B_WVALID      : in  std_logic;
      AXI_B_WREADY      : out std_logic;
      AXI_B_WDATA       : in  std_logic_vector(31 downto 0);
      AXI_B_WSTRB       : in  std_logic_vector(3  downto 0);
      AXI_B_BVALID      : out std_logic;
      AXI_B_BREADY      : in  std_logic;
      AXI_B_BRESP       : out std_logic_vector(1 downto 0);
      --read access
      AXI_B_ARVALID     : in  std_logic;
      AXI_B_ARREADY     : out std_logic;
      AXI_B_ARADDR      : in  std_logic_vector(31 downto 0);
      AXI_B_ARPROT      : in  std_logic_vector(2  downto 0);
      AXI_B_RVALID      : out std_logic;
      AXI_B_RREADY      : in  std_logic;
      AXI_B_RDATA       : out std_logic_vector(31 downto 0);
      AXI_B_RESP        : out std_logic_vector(1  downto 0)
    );    
  end component axi_bram;
  
  constant C_PC_RST_VALUE         : std_logic_vector(31 downto 0):=x"00000000";
  constant C_ADDR_WIDTH           : integer :=10;
  constant C_PROGRAM_FILE_PATH    : string:="../software/mem.bin";
  constant C_CLK_PERIODE          : time:=1 us;
  
  
  signal clk                 : std_logic:='0';
  signal rstn                : std_logic:='0';
  signal axi_fetch_arvalid   : std_logic;
  signal axi_fetch_arready   : std_logic;
  signal axi_fetch_araddr    : std_logic_vector(31 downto 0);
  signal axi_fetch_arprot    : std_logic_vector(2 downto 0);
  signal axi_fetch_rvalid    : std_logic;
  signal axi_fetch_rready    : std_logic;
  signal axi_fetch_rdata     : std_logic_vector(31 downto 0);
  signal axi_fetch_resp      : std_logic_vector(1 downto 0);
  signal axi_lsu_awvalid     : std_logic;
  signal axi_lsu_awready     : std_logic;
  signal axi_lsu_awaddr      : std_logic_vector(31 downto 0);
  signal axi_lsu_awprot      : std_logic_vector(2 downto 0);
  signal axi_lsu_wvalid      : std_logic;
  signal axi_lsu_wready      : std_logic;
  signal axi_lsu_wdata       : std_logic_vector(31 downto 0);
  signal axi_lsu_wstrb       : std_logic_vector(3 downto 0);
  signal axi_lsu_bvalid      : std_logic;
  signal axi_lsu_bready      : std_logic;
  signal axi_lsu_bresp       : std_logic_vector(1 downto 0);
  signal axi_lsu_arvalid     : std_logic;
  signal axi_lsu_arready     : std_logic;
  signal axi_lsu_araddr      : std_logic_vector(31 downto 0);
  signal axi_lsu_arprot      : std_logic_vector(2 downto 0);
  signal axi_lsu_rvalid      : std_logic;
  signal axi_lsu_rready      : std_logic;
  signal axi_lsu_rdata       : std_logic_vector(31 downto 0);
  signal axi_lsu_resp        : std_logic_vector(1 downto 0);

begin

  rstn  <= '1'      after C_CLK_PERIODE;
  clk   <= not(clk) after C_CLK_PERIODE/2;
  
  inst_poulpi32_core : poulpi32_core
    generic map(
      G_PC_RST_VALUE      => C_PC_RST_VALUE
    )
    port map(
      CLK                 => clk,               
      RSTN                => rstn,              
      AXI_FETCH_ARVALID   => axi_fetch_arvalid, 
      AXI_FETCH_ARREADY   => axi_fetch_arready, 
      AXI_FETCH_ARADDR    => axi_fetch_araddr,  
      AXI_FETCH_ARPROT    => axi_fetch_arprot,  
      AXI_FETCH_RVALID    => axi_fetch_rvalid,  
      AXI_FETCH_RREADY    => axi_fetch_rready,  
      AXI_FETCH_RDATA     => axi_fetch_rdata,   
      AXI_FETCH_RESP      => axi_fetch_resp,    
      AXI_LSU_AWVALID     => axi_lsu_awvalid,   
      AXI_LSU_AWREADY     => axi_lsu_awready,   
      AXI_LSU_AWADDR      => axi_lsu_awaddr,    
      AXI_LSU_AWPROT      => axi_lsu_awprot,    
      AXI_LSU_WVALID      => axi_lsu_wvalid,    
      AXI_LSU_WREADY      => axi_lsu_wready,    
      AXI_LSU_WDATA       => axi_lsu_wdata,     
      AXI_LSU_WSTRB       => axi_lsu_wstrb,     
      AXI_LSU_BVALID      => axi_lsu_bvalid,    
      AXI_LSU_BREADY      => axi_lsu_bready,    
      AXI_LSU_BRESP       => axi_lsu_bresp,     
      AXI_LSU_ARVALID     => axi_lsu_arvalid,   
      AXI_LSU_ARREADY     => axi_lsu_arready,   
      AXI_LSU_ARADDR      => axi_lsu_araddr,    
      AXI_LSU_ARPROT      => axi_lsu_arprot,    
      AXI_LSU_RVALID      => axi_lsu_rvalid,    
      AXI_LSU_RREADY      => axi_lsu_rready,    
      AXI_LSU_RDATA       => axi_lsu_rdata,    
      AXI_LSU_RESP        => axi_lsu_resp      
    );

  inst_axi_bram : axi_bram
    generic map(
      G_ADDR_WIDTH      => C_ADDR_WIDTH,        
      G_INIT_FILE_PATH  => C_PROGRAM_FILE_PATH 
      )
    port map(
      -- clock and reset
      CLK               => clk,
      RSTN              => rstn,
      -- PORT A
      -- write access
      AXI_A_AWVALID     => '0',       
      AXI_A_AWREADY     =>  open,            
      AXI_A_AWADDR      => (others => '0'),  
      AXI_A_AWPROT      => (others => '0'), 
      AXI_A_WVALID      => '0',             
      AXI_A_WREADY      => open,            
      AXI_A_WDATA       => (others => '0'), 
      AXI_A_WSTRB       => (others => '0'), 
      AXI_A_BVALID      => open,            
      AXI_A_BREADY      => '0',             
      AXI_A_BRESP       =>  open,
      AXI_A_ARVALID     => axi_fetch_arvalid,  
      AXI_A_ARREADY     => axi_fetch_arready,  
      AXI_A_ARADDR      => axi_fetch_araddr,   
      AXI_A_ARPROT      => axi_fetch_arprot,   
      AXI_A_RVALID      => axi_fetch_rvalid,   
      AXI_A_RREADY      => axi_fetch_rready,   
      AXI_A_RDATA       => axi_fetch_rdata,    
      AXI_A_RESP        => axi_fetch_resp,     
      AXI_B_AWVALID     => axi_lsu_awvalid,  
      AXI_B_AWREADY     => axi_lsu_awready,  
      AXI_B_AWADDR      => axi_lsu_awaddr,   
      AXI_B_AWPROT      => axi_lsu_awprot,   
      AXI_B_WVALID      => axi_lsu_wvalid,   
      AXI_B_WREADY      => axi_lsu_wready,   
      AXI_B_WDATA       => axi_lsu_wdata,    
      AXI_B_WSTRB       => axi_lsu_wstrb,    
      AXI_B_BVALID      => axi_lsu_bvalid,   
      AXI_B_BREADY      => axi_lsu_bready,   
      AXI_B_BRESP       => axi_lsu_bresp,    
      AXI_B_ARVALID     => axi_lsu_arvalid,  
      AXI_B_ARREADY     => axi_lsu_arready,  
      AXI_B_ARADDR      => axi_lsu_araddr,   
      AXI_B_ARPROT      => axi_lsu_arprot,   
      AXI_B_RVALID      => axi_lsu_rvalid,   
      AXI_B_RREADY      => axi_lsu_rready,   
      AXI_B_RDATA       => axi_lsu_rdata,    
      AXI_B_RESP        => axi_lsu_resp     
    );    
    

  
end behave;
