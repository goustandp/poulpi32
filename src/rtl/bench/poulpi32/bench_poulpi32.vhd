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
  
  
  component axil_crossbar is
    generic(
      G_ADDR_WIDTH          : integer := 32;
      G_DATA_WIDTH          : integer := 32;
      G_NB_SLAVE            : integer := 1;
      G_NB_MASTER            : integer := 1;
      G_MAPPING_FILE        : string  := "mapping.txt";
      G_EN_SLAVE_REGISTER   : boolean := false; --TODO: add sregister slice
      G_EN_MIDDLE_REGISTER  : boolean := false;
      G_EN_MASTER_REGISTER  : boolean := false
    );
    port(
      CLK               : in  std_logic;
      RSTN              : in  std_logic;
      -- slave interfaces
      -- write access
      S_AXI_AWVALID     : in  std_logic_vector(G_NB_SLAVE-1 downto 0);
      S_AXI_AWREADY     : out std_logic_vector(G_NB_SLAVE-1 downto 0);
      S_AXI_AWADDR      : in  std_logic_vector(G_ADDR_WIDTH*G_NB_SLAVE-1 downto 0);
      S_AXI_AWPROT      : in  std_logic_vector(3*G_NB_SLAVE-1 downto 0);
      S_AXI_WVALID      : in  std_logic_vector(G_NB_SLAVE-1 downto 0);
      S_AXI_WREADY      : out std_logic_vector(G_NB_SLAVE-1 downto 0);
      S_AXI_WDATA       : in  std_logic_vector(G_NB_SLAVE*G_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB       : in  std_logic_vector((G_DATA_WIDTH/8)*G_NB_SLAVE-1 downto 0);
      S_AXI_BVALID      : out std_logic_vector(G_NB_SLAVE-1 downto 0);
      S_AXI_BREADY      : in  std_logic_vector(G_NB_SLAVE-1 downto 0);
      S_AXI_BRESP       : out std_logic_vector(2*G_NB_SLAVE-1 downto 0);
      --read access
      S_AXI_ARVALID     : in  std_logic_vector(G_NB_SLAVE-1 downto 0);
      S_AXI_ARREADY     : out std_logic_vector(G_NB_SLAVE-1 downto 0);
      S_AXI_ARADDR      : in  std_logic_vector(G_ADDR_WIDTH*G_NB_SLAVE-1 downto 0);
      S_AXI_ARPROT      : in  std_logic_vector(3*G_NB_SLAVE-1 downto 0);
      S_AXI_RVALID      : out std_logic_vector(G_NB_SLAVE-1 downto 0);
      S_AXI_RREADY      : in  std_logic_vector(G_NB_SLAVE-1 downto 0);
      S_AXI_RDATA       : out std_logic_vector(G_NB_SLAVE*G_DATA_WIDTH-1 downto 0);
      S_AXI_RESP        : out std_logic_vector(2*G_NB_SLAVE-1 downto 0);
    
      -- master interfaces
      -- write access
      M_AXI_AWVALID     : out std_logic_vector(G_NB_MASTER-1 downto 0);
      M_AXI_AWREADY     : in  std_logic_vector(G_NB_MASTER-1 downto 0);
      M_AXI_AWADDR      : out std_logic_vector(G_ADDR_WIDTH*G_NB_MASTER-1 downto 0);
      M_AXI_AWPROT      : out std_logic_vector(3*G_NB_MASTER-1 downto 0);
      M_AXI_WVALID      : out std_logic_vector(G_NB_MASTER-1 downto 0);
      M_AXI_WREADY      : in  std_logic_vector(G_NB_MASTER-1 downto 0);
      M_AXI_WDATA       : out std_logic_vector(G_NB_MASTER*G_DATA_WIDTH-1 downto 0);
      M_AXI_WSTRB       : out std_logic_vector((G_DATA_WIDTH/8)*G_NB_MASTER-1 downto 0);
      M_AXI_BVALID      : in  std_logic_vector(G_NB_MASTER-1 downto 0);
      M_AXI_BREADY      : out std_logic_vector(G_NB_MASTER-1 downto 0);
      M_AXI_BRESP       : in  std_logic_vector(2*G_NB_MASTER-1 downto 0);
      --read access
      M_AXI_ARVALID     : out std_logic_vector(G_NB_MASTER-1 downto 0);
      M_AXI_ARREADY     : in  std_logic_vector(G_NB_MASTER-1 downto 0);
      M_AXI_ARADDR      : out std_logic_vector(G_ADDR_WIDTH*G_NB_MASTER-1 downto 0);
      M_AXI_ARPROT      : out std_logic_vector(3*G_NB_MASTER-1 downto 0);
      M_AXI_RVALID      : in  std_logic_vector(G_NB_MASTER-1 downto 0);
      M_AXI_RREADY      : out std_logic_vector(G_NB_MASTER-1 downto 0);
      M_AXI_RDATA       : in  std_logic_vector(G_NB_MASTER*G_DATA_WIDTH-1 downto 0);
      M_AXI_RESP        : in  std_logic_vector(2*G_NB_MASTER-1 downto 0)
    );
  end component axil_crossbar;
  
  component axil_bram is
    generic(
      G_ADDR_WIDTH      : integer;
      G_INIT_FILE_PATH  : string
      );
    port(
      -- clock and reset
      CLK_A             : in  std_logic;
      RSTN_A            : in  std_logic;
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
      CLK_B             : in  std_logic;
      RSTN_B            : in  std_logic;
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
  end component axil_bram;
  
  component uart_emulator is
    generic(
      G_FILE_PATH     : string:="out.txt"
    );
    port(
      -- clock and reset
      CLK               : in  std_logic;
      RSTN              : in  std_logic;
      -- write access
      AXI_AWVALID     : in  std_logic;
      AXI_AWREADY     : out std_logic;
      AXI_AWADDR      : in  std_logic_vector(31 downto 0);
      AXI_AWPROT      : in  std_logic_vector(2  downto 0);
      AXI_WVALID      : in  std_logic;
      AXI_WREADY      : out std_logic;
      AXI_WDATA       : in  std_logic_vector(31 downto 0);
      AXI_WSTRB       : in  std_logic_vector(3  downto 0);
      AXI_BVALID      : out std_logic;
      AXI_BREADY      : in  std_logic;
      AXI_BRESP       : out std_logic_vector(1  downto 0);
      -- unused 
      AXI_ARVALID     : in  std_logic;
      AXI_ARREADY     : out std_logic;
      AXI_ARADDR      : in  std_logic_vector(31 downto 0);
      AXI_ARPROT      : in  std_logic_vector(2  downto 0);
      AXI_RVALID      : out std_logic;
      AXI_RREADY      : in  std_logic;
      AXI_RDATA       : out std_logic_vector(31 downto 0);
      AXI_RESP        : out std_logic_vector(1  downto 0)
    );
  end component uart_emulator;
  
  
  constant C_PC_RST_VALUE           : std_logic_vector(31 downto 0):=x"00000000";
  constant C_ADDR_WIDTH             : integer :=10;
  constant C_PROGRAM_FILE_PATH      : string:="../../../software/mem.bin";
  constant C_CLK_PERIODE            : time:=1 us;
  
  
  signal clk                        : std_logic:='0';
  signal rstn                       : std_logic:='0';
          
  --fetch to bram       
  signal axi_fetch_arvalid          : std_logic;
  signal axi_fetch_arready          : std_logic;
  signal axi_fetch_araddr           : std_logic_vector(31 downto 0);
  signal axi_fetch_arprot           : std_logic_vector(2 downto 0);
  signal axi_fetch_rvalid           : std_logic;
  signal axi_fetch_rready           : std_logic;
  signal axi_fetch_rdata            : std_logic_vector(31 downto 0);
  signal axi_fetch_resp             : std_logic_vector(1 downto 0);
  
  
  -- lsu to crossbar
  signal axi_lsu_awvalid            : std_logic;
  signal axi_lsu_awready            : std_logic;
  signal axi_lsu_awaddr             : std_logic_vector(31 downto 0);
  signal axi_lsu_awprot             : std_logic_vector(2 downto 0);
  signal axi_lsu_wvalid             : std_logic;
  signal axi_lsu_wready             : std_logic;
  signal axi_lsu_wdata              : std_logic_vector(31 downto 0);
  signal axi_lsu_wstrb              : std_logic_vector(3 downto 0);
  signal axi_lsu_bvalid             : std_logic;
  signal axi_lsu_bready             : std_logic;
  signal axi_lsu_bresp              : std_logic_vector(1 downto 0);
  signal axi_lsu_arvalid            : std_logic;
  signal axi_lsu_arready            : std_logic;
  signal axi_lsu_araddr             : std_logic_vector(31 downto 0);
  signal axi_lsu_arprot             : std_logic_vector(2 downto 0);
  signal axi_lsu_rvalid             : std_logic;
  signal axi_lsu_rready             : std_logic;
  signal axi_lsu_rdata              : std_logic_vector(31 downto 0);
  signal axi_lsu_resp               : std_logic_vector(1 downto 0);
  
  -- crossbar to bram
  signal axi_cb_to_bram_awvalid     : std_logic;
  signal axi_cb_to_bram_awready     : std_logic;
  signal axi_cb_to_bram_awaddr      : std_logic_vector(31 downto 0);
  signal axi_cb_to_bram_awprot      : std_logic_vector(2 downto 0);
  signal axi_cb_to_bram_wvalid      : std_logic;
  signal axi_cb_to_bram_wready      : std_logic;
  signal axi_cb_to_bram_wdata       : std_logic_vector(31 downto 0);
  signal axi_cb_to_bram_wstrb       : std_logic_vector(3 downto 0);
  signal axi_cb_to_bram_bvalid      : std_logic;
  signal axi_cb_to_bram_bready      : std_logic;
  signal axi_cb_to_bram_bresp       : std_logic_vector(1 downto 0);
  signal axi_cb_to_bram_arvalid     : std_logic;
  signal axi_cb_to_bram_arready     : std_logic;
  signal axi_cb_to_bram_araddr      : std_logic_vector(31 downto 0);
  signal axi_cb_to_bram_arprot      : std_logic_vector(2 downto 0);
  signal axi_cb_to_bram_rvalid      : std_logic;
  signal axi_cb_to_bram_rready      : std_logic;
  signal axi_cb_to_bram_rdata       : std_logic_vector(31 downto 0);
  signal axi_cb_to_bram_resp        : std_logic_vector(1 downto 0);
  
    -- crossbar to uart emulator
  signal axi_cb_to_uart_awvalid     : std_logic;
  signal axi_cb_to_uart_awready     : std_logic;
  signal axi_cb_to_uart_awaddr      : std_logic_vector(31 downto 0);
  signal axi_cb_to_uart_awprot      : std_logic_vector(2 downto 0);
  signal axi_cb_to_uart_wvalid      : std_logic;
  signal axi_cb_to_uart_wready      : std_logic;
  signal axi_cb_to_uart_wdata       : std_logic_vector(31 downto 0);
  signal axi_cb_to_uart_wstrb       : std_logic_vector(3 downto 0);
  signal axi_cb_to_uart_bvalid      : std_logic;
  signal axi_cb_to_uart_bready      : std_logic;
  signal axi_cb_to_uart_bresp       : std_logic_vector(1 downto 0);
  signal axi_cb_to_uart_arvalid     : std_logic;
  signal axi_cb_to_uart_arready     : std_logic;
  signal axi_cb_to_uart_araddr      : std_logic_vector(31 downto 0);
  signal axi_cb_to_uart_arprot      : std_logic_vector(2 downto 0);
  signal axi_cb_to_uart_rvalid      : std_logic;
  signal axi_cb_to_uart_rready      : std_logic;
  signal axi_cb_to_uart_rdata       : std_logic_vector(31 downto 0);
  signal axi_cb_to_uart_resp        : std_logic_vector(1 downto 0);


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


  inst_axil_crossbar : axil_crossbar
    generic map(
      G_ADDR_WIDTH          => 32,
      G_DATA_WIDTH          => 32,
      G_NB_SLAVE            => 1,
      G_NB_MASTER           => 2,
      G_MAPPING_FILE        => "bench_mapping.txt",
      G_EN_SLAVE_REGISTER   => false,
      G_EN_MIDDLE_REGISTER  => false,
      G_EN_MASTER_REGISTER  => false
    )
    port map(
      CLK                         => CLK,
      RSTN                        => RSTN,
      S_AXI_AWVALID(0)            => axi_lsu_awvalid,   
      S_AXI_AWREADY(0)            => axi_lsu_awready,   
      S_AXI_AWADDR                => axi_lsu_awaddr,    
      S_AXI_AWPROT                => axi_lsu_awprot,    
      S_AXI_WVALID(0)             => axi_lsu_wvalid,    
      S_AXI_WREADY(0)             => axi_lsu_wready,    
      S_AXI_WDATA                 => axi_lsu_wdata,     
      S_AXI_WSTRB                 => axi_lsu_wstrb,     
      S_AXI_BVALID(0)             => axi_lsu_bvalid,    
      S_AXI_BREADY(0)             => axi_lsu_bready,    
      S_AXI_BRESP                 => axi_lsu_bresp,     
      S_AXI_ARVALID(0)            => axi_lsu_arvalid,   
      S_AXI_ARREADY(0)            => axi_lsu_arready,   
      S_AXI_ARADDR                => axi_lsu_araddr,    
      S_AXI_ARPROT                => axi_lsu_arprot,    
      S_AXI_RVALID(0)             => axi_lsu_rvalid,    
      S_AXI_RREADY(0)             => axi_lsu_rready,    
      S_AXI_RDATA                 => axi_lsu_rdata,    
      S_AXI_RESP                  => axi_lsu_resp,      
    
      M_AXI_AWVALID(0)            => axi_cb_to_bram_awvalid,  
      M_AXI_AWVALID(1)            => axi_cb_to_uart_awvalid,  
      
      M_AXI_AWREADY(0)            => axi_cb_to_bram_awready,  
      M_AXI_AWREADY(1)            => axi_cb_to_uart_awready,  
      
      
      M_AXI_AWADDR(31 downto 0)   => axi_cb_to_bram_awaddr,   
      M_AXI_AWADDR(63 downto 32)  => axi_cb_to_uart_awaddr,  
      
      M_AXI_AWPROT(2 downto 0)    => axi_cb_to_bram_awprot,   
      M_AXI_AWPROT(5 downto 3)    => axi_cb_to_uart_awprot,  
      
      M_AXI_WVALID(0)             => axi_cb_to_bram_wvalid,   
      M_AXI_WVALID(1)             => axi_cb_to_uart_wvalid,   
      
      M_AXI_WREADY(0)             => axi_cb_to_bram_wready,   
      M_AXI_WREADY(1)             => axi_cb_to_uart_wready,  
      
      M_AXI_WDATA(31 downto 0)    => axi_cb_to_bram_wdata,    
      M_AXI_WDATA(63 downto 32)   => axi_cb_to_uart_wdata,   
      
      M_AXI_WSTRB(3 downto 0)     => axi_cb_to_bram_wstrb,    
      M_AXI_WSTRB(7 downto 4)     => axi_cb_to_uart_wstrb, 
      
      M_AXI_BVALID(0)             => axi_cb_to_bram_bvalid,   
      M_AXI_BVALID(1)             => axi_cb_to_uart_bvalid,   
      
      M_AXI_BREADY(0)             => axi_cb_to_bram_bready,   
      M_AXI_BREADY(1)             => axi_cb_to_uart_bready, 
      
      M_AXI_BRESP(1 downto 0)     => axi_cb_to_bram_bresp,    
      M_AXI_BRESP(3 downto 2)     => axi_cb_to_uart_bresp,    
      
      M_AXI_ARVALID(0)            => axi_cb_to_bram_arvalid,  
      M_AXI_ARVALID(1)            => axi_cb_to_uart_arvalid,  
      
      M_AXI_ARREADY(0)            => axi_cb_to_bram_arready,  
      M_AXI_ARREADY(1)            => axi_cb_to_uart_arready,  
      
      M_AXI_ARADDR(31 downto 0)   => axi_cb_to_bram_araddr,   
      M_AXI_ARADDR(63 downto 32)  => axi_cb_to_uart_araddr,   
      
      M_AXI_ARPROT(2 downto 0)    => axi_cb_to_bram_arprot,   
      M_AXI_ARPROT(5 downto 3)    => axi_cb_to_uart_arprot,   
      
      M_AXI_RVALID(0)             => axi_cb_to_bram_rvalid,   
      M_AXI_RVALID(1)             => axi_cb_to_uart_rvalid,   
      
      M_AXI_RREADY(0)             => axi_cb_to_bram_rready,   
      M_AXI_RREADY(1)             => axi_cb_to_uart_rready,   
      
      M_AXI_RDATA(31 downto 0)    => axi_cb_to_bram_rdata,    
      M_AXI_RDATA(63 downto 32)   => axi_cb_to_uart_rdata,   
      
      M_AXI_RESP(1 downto 0)      => axi_cb_to_bram_resp,
      M_AXI_RESP(3 downto 2)      => axi_cb_to_uart_resp  
    );


  inst_axil_bram : axil_bram
    generic map(
      G_ADDR_WIDTH      => C_ADDR_WIDTH,        
      G_INIT_FILE_PATH  => C_PROGRAM_FILE_PATH 
      )
    port map(
      CLK_A             => clk,
      RSTN_A            => rstn,
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
      CLK_B             => clk,
      RSTN_B            => rstn,
      AXI_B_AWVALID     => axi_cb_to_bram_awvalid,  
      AXI_B_AWREADY     => axi_cb_to_bram_awready,  
      AXI_B_AWADDR      => axi_cb_to_bram_awaddr,   
      AXI_B_AWPROT      => axi_cb_to_bram_awprot,   
      AXI_B_WVALID      => axi_cb_to_bram_wvalid,   
      AXI_B_WREADY      => axi_cb_to_bram_wready,   
      AXI_B_WDATA       => axi_cb_to_bram_wdata,    
      AXI_B_WSTRB       => axi_cb_to_bram_wstrb,    
      AXI_B_BVALID      => axi_cb_to_bram_bvalid,   
      AXI_B_BREADY      => axi_cb_to_bram_bready,   
      AXI_B_BRESP       => axi_cb_to_bram_bresp,    
      AXI_B_ARVALID     => axi_cb_to_bram_arvalid,  
      AXI_B_ARREADY     => axi_cb_to_bram_arready,  
      AXI_B_ARADDR      => axi_cb_to_bram_araddr,   
      AXI_B_ARPROT      => axi_cb_to_bram_arprot,   
      AXI_B_RVALID      => axi_cb_to_bram_rvalid,   
      AXI_B_RREADY      => axi_cb_to_bram_rready,   
      AXI_B_RDATA       => axi_cb_to_bram_rdata,    
      AXI_B_RESP        => axi_cb_to_bram_resp     
    );    
    
    
  inst_uart_emulator: uart_emulator
    generic map(
      G_FILE_PATH     => "bench_out.txt"
    )
    port map(
      CLK               => clk,
      RSTN              => rstn,
      AXI_AWVALID       => axi_cb_to_uart_awvalid,  
      AXI_AWREADY       => axi_cb_to_uart_awready,  
      AXI_AWADDR        => axi_cb_to_uart_awaddr,   
      AXI_AWPROT        => axi_cb_to_uart_awprot,   
      AXI_WVALID        => axi_cb_to_uart_wvalid,   
      AXI_WREADY        => axi_cb_to_uart_wready,   
      AXI_WDATA         => axi_cb_to_uart_wdata,    
      AXI_WSTRB         => axi_cb_to_uart_wstrb,    
      AXI_BVALID        => axi_cb_to_uart_bvalid,   
      AXI_BREADY        => axi_cb_to_uart_bready,   
      AXI_BRESP         => axi_cb_to_uart_bresp,    
      AXI_ARVALID       => axi_cb_to_uart_arvalid,  
      AXI_ARREADY       => axi_cb_to_uart_arready,  
      AXI_ARADDR        => axi_cb_to_uart_araddr,   
      AXI_ARPROT        => axi_cb_to_uart_arprot,   
      AXI_RVALID        => axi_cb_to_uart_rvalid,   
      AXI_RREADY        => axi_cb_to_uart_rready,   
      AXI_RDATA         => axi_cb_to_uart_rdata,    
      AXI_RESP          => axi_cb_to_uart_resp  
    );
  

  
end behave;
