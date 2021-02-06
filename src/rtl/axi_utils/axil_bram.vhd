library work;
  use work.poulpi32_pkg.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.textio.all;


entity axil_bram is
  generic(
    G_ADDR_WIDTH        : integer;
    G_INIT_FILE_PATH    : string;
    G_INIT_FILE_OFFSET  : integer:=0
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
    CLK_B             : in  std_logic;
    RSTN_B            : in  std_logic;
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
end entity axil_bram;

architecture rtl of axil_bram is
  
  -- cutoms type
  type t_ram is array (2**(G_ADDR_WIDTH-2)-1 downto 0) of std_logic_vector(31 downto 0);
    
  type t_char_file is file of integer;
  

  -- init function
  impure function init_ram return t_ram is
  file file_ptr         : t_char_file;
  variable v_ram        : t_ram;
  variable v_data       : integer;
  begin
    file_open(file_ptr, G_INIT_FILE_PATH, read_mode);
    for i in 0 to (G_INIT_FILE_OFFSET/4)-1 loop
      v_ram(i):= std_logic_vector(to_signed(0, 32));
    end loop;
    
    for i in (G_INIT_FILE_OFFSET/4) to 2**(G_ADDR_WIDTH-2)-1 loop
      if not(endfile(file_ptr)) then
        read(file_ptr, v_data);
      else
        v_data  := 0; --fill with zeros
      end if;
      v_ram(i):= std_logic_vector(to_signed(v_data, 32));
    end loop;
    
    if not(endfile(file_ptr)) then
      report "code doesnt fit in RAM" severity failure;
    end if;
    
    file_close(file_ptr);
    return v_ram;
  end function;

  
  
  
  signal ram : t_ram:=init_ram;
    
  signal axi_a_awready_i     : std_logic;
  signal axi_a_wready_i      : std_logic;
  signal axi_a_bvalid_i      : std_logic;
  signal axi_a_arready_i     : std_logic;
  signal axi_a_rvalid_i      : std_logic;
    
  signal axi_b_awready_i     : std_logic;
  signal axi_b_wready_i      : std_logic;
  signal axi_b_bvalid_i      : std_logic;
  signal axi_b_arready_i     : std_logic;
  signal axi_b_rvalid_i      : std_logic;
  
  
begin
  
  -- PORT A assignement
    AXI_A_AWREADY     <= axi_a_awready_i;
    AXI_A_WREADY      <= axi_a_wready_i;   
    AXI_A_BVALID      <= axi_a_bvalid_i;   
    AXI_A_BRESP       <= C_OKAY;    
    AXI_A_ARREADY     <= axi_a_arready_i;  
    AXI_A_RVALID      <= axi_a_rvalid_i;   
    AXI_A_RESP        <= C_OKAY;     
  
    
    -- PORT B assignement
    AXI_B_AWREADY     <= axi_b_awready_i;
    AXI_B_WREADY      <= axi_b_wready_i;   
    AXI_B_BVALID      <= axi_b_bvalid_i;   
    AXI_B_BRESP       <= C_OKAY;    
    AXI_B_ARREADY     <= axi_b_arready_i;  
    AXI_B_RVALID      <= axi_b_rvalid_i;   
    AXI_B_RESP        <= C_OKAY;     
  
  P_PORT  : process(CLK_A, CLK_B) 
    variable v_awaddr   : integer;
    variable v_araddr   : integer;
    variable v_astrb    : std_logic_vector(3 downto 0);
    variable v_bwaddr   : integer;
    variable v_braddr   : integer;
    variable v_bstrb    : std_logic_vector(3 downto 0);
  begin 
  
    -- port A
    if rising_edge(CLK_A) then
      if (RSTN_A = '0') then
        axi_a_awready_i <= '0';
        axi_a_wready_i  <= '0';
        axi_a_bvalid_i  <= '0';
        axi_a_rvalid_i  <= '0';
        axi_a_arready_i <= '0';
        v_awaddr        := 0;
        v_araddr        := 0; 
        v_astrb         := (others => '0');
      else
        
        -- init
        if (axi_a_arready_i = '0' and axi_a_rvalid_i = '0') then
          axi_a_arready_i <= '1';
        end if;
        
        if (axi_a_wready_i = '0' and axi_a_bvalid_i ='0') then
          axi_a_wready_i  <= '1';
          axi_a_awready_i <= '1';
        end if;
        
        -- read resp
        if (axi_a_rvalid_i = '1' and AXI_A_RREADY = '1') then
          axi_a_rvalid_i  <= '0';
          axi_a_arready_i <= '1';
        end if;
        
        -- bresp
        if (axi_a_bvalid_i  = '1' and AXI_A_BREADY = '1') then
          axi_a_bvalid_i  <= '0';
          axi_a_wready_i  <= '1';
          axi_a_awready_i <= '1';
        end if;
        
        -- write access address
        if (AXI_A_AWVALID = '1' and axi_a_awready_i = '1') then
          v_astrb          := AXI_A_WSTRB;
          v_awaddr         := to_integer(unsigned(AXI_A_AWADDR(G_ADDR_WIDTH+1 downto 2)));
          axi_a_awready_i  <= '0';
        end if;
        
        -- write access data
        if (AXI_A_WVALID = '1' and axi_a_wready_i = '1') then
          axi_a_wready_i  <= '0';
          axi_a_bvalid_i  <= '1';
          ram(v_awaddr)  <= AXI_A_WDATA;
          for i in 0 to 3 loop
            if (v_astrb(i) = '1') then
              ram(v_awaddr)(8*(i+1)-1 downto i*8)  <= AXI_A_WDATA(8*(i+1)-1 downto i*8);
            end if;
          end loop;
        end if;
        
        -- read access address
        if (AXI_A_ARVALID = '1' and axi_a_arready_i = '1') then
          v_araddr        := to_integer(unsigned(AXI_A_ARADDR(G_ADDR_WIDTH+1 downto 2)));
          axi_a_rvalid_i  <= '1';
          axi_a_arready_i <= '0';
          AXI_A_RDATA     <= ram(v_araddr);
        end if;
      end if;
    end if;
    
    
    
    -- port B
    if rising_edge(CLK_B) then
      if (RSTN_B = '0') then
        axi_b_awready_i <= '0';
        axi_b_wready_i  <= '0';
        axi_b_bvalid_i  <= '0';
        axi_b_rvalid_i  <= '0';
        axi_b_arready_i <= '0';
        v_bwaddr        := 0;
        v_braddr        := 0; 
        v_bstrb         := (others => '0');
      else
        
        -- init
        if (axi_b_arready_i = '0' and axi_b_rvalid_i = '0') then
          axi_b_arready_i <= '1';
        end if;
        
        if (axi_b_wready_i = '0' and axi_b_bvalid_i ='0') then
          axi_b_awready_i <= '1';
          axi_b_wready_i  <= '1';
        end if;
        
        -- read resp
        if (axi_b_rvalid_i = '1' and AXI_B_RREADY = '1') then
          axi_b_rvalid_i  <= '0';
          axi_b_arready_i <= '1';
        end if;
        
        -- bresp
        if (axi_b_bvalid_i  = '1' and AXI_B_BREADY = '1') then
          axi_b_bvalid_i  <= '0';
          axi_b_wready_i  <= '1';
          axi_b_awready_i <= '1';
        end if;
        
        -- write access address
        if (AXI_B_AWVALID = '1' and axi_b_awready_i = '1') then
          v_bstrb          := AXI_B_WSTRB;
          v_bwaddr         := to_integer(unsigned(AXI_B_AWADDR(G_ADDR_WIDTH+1 downto 2)));
          axi_b_awready_i  <= '0';
        end if;
        
        -- write access data
        if (AXI_B_WVALID = '1' and axi_b_wready_i = '1') then
          axi_b_wready_i  <= '0';
          axi_b_bvalid_i  <= '1';
          ram(v_bwaddr)   <= AXI_B_WDATA;
          for i in 0 to 3 loop
            if (v_bstrb(i) = '1') then
              ram(v_bwaddr)(8*(i+1)-1 downto i*8)  <= AXI_B_WDATA(8*(i+1)-1 downto i*8);
            end if;
          end loop;
        end if;
        
        -- read access address
        if (AXI_B_ARVALID = '1' and axi_b_arready_i = '1') then
          v_braddr        := to_integer(unsigned(AXI_B_ARADDR(G_ADDR_WIDTH+1 downto 2)));
          axi_b_rvalid_i  <= '1';
          axi_b_arready_i <= '0';
          AXI_B_RDATA     <= ram(v_braddr);
        end if;
      end if;
    end if;
    
    
  end process;
        
        

end rtl;
