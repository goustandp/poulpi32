library work;
  use work.poulpi32_pkg.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.textio.all;


entity axi_bram is
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
end entity axi_bram;

architecture rtl of axi_bram is
  type t_ram is array (integer range <>) of std_logic_vector(31 downto 0);
  type t_char_file is file of integer;

  
  function init_ram(addr_width : in integer; file_path : in string) return t_ram is
    file file_ptr      : t_char_file;
    variable v_ram_size   : integer:= 2**addr_width;
    variable v_ram        : t_ram(2**addr_width-1 downto 0);
    variable v_data       : integer;
    begin
      file_open(file_ptr, file_path, read_mode);
      for i in 0 to v_ram_size-1 loop
        if not(endfile(file_ptr)) then
          read(file_ptr, v_data);
        else
          v_data  := 0; --fill with zeros
        end if;
        v_ram(i):= std_logic_vector(to_signed(v_data, 32));
      end loop;
      file_close(file_ptr);
      return v_ram;
    end function;
  
  
  
  shared variable ram : t_ram(2**G_ADDR_WIDTH-1 downto 0):=init_ram(G_ADDR_WIDTH, G_INIT_FILE_PATH);
    
  signal axi_a_awready_i     : std_logic;
  signal axi_a_wready_i      : std_logic;
  signal axi_a_bvalid_i      : std_logic;
  signal axi_a_arready_i     : std_logic;
  signal axi_a_rvalid_i      : std_logic;
  signal addr_a              : unsigned(G_ADDR_WIDTH-1 downto 0);
    
  signal axi_b_awready_i     : std_logic;
  signal axi_b_wready_i      : std_logic;
  signal axi_b_bvalid_i      : std_logic;
  signal axi_b_arready_i     : std_logic;
  signal axi_b_rvalid_i      : std_logic;
  signal addr_b              : unsigned(G_ADDR_WIDTH-1 downto 0);
  
  
begin
  
  -- PORT A assignement
    AXI_A_AWREADY     <= '1';
    AXI_A_WREADY      <= axi_a_wready_i;   
    AXI_A_BVALID      <= axi_a_bvalid_i;   
    AXI_A_BRESP       <= C_OKAY;    
    AXI_A_ARREADY     <= '1';  
    AXI_A_RVALID      <= axi_a_rvalid_i;   
    AXI_A_RESP        <= C_OKAY;     
    
    -- PORT B assignement
    AXI_B_AWREADY     <= '1';
    AXI_B_WREADY      <= axi_b_wready_i;   
    AXI_B_BVALID      <= axi_b_bvalid_i;   
    AXI_B_BRESP       <= C_OKAY;    
    AXI_B_ARREADY     <= '1';  
    AXI_B_RVALID      <= axi_b_rvalid_i;   
    AXI_B_RESP        <= C_OKAY;     
  
  P_PORT_A  : process(CLK) 
  begin 
    if rising_edge(CLK) then
      if (RSTN = '0') then
        axi_a_wready_i  <= '0';
        axi_a_bvalid_i  <= '0';
        axi_a_rvalid_i  <= '0';
        addr_a          <= (others => '0');
      else
        
        
        if (axi_a_rvalid_i = '1' and AXI_A_RREADY = '1') then
          axi_a_rvalid_i  <= '0';
        end if;
        
        -- bresp
        if (axi_a_bvalid_i  = '1' and AXI_A_BREADY = '1') then
          axi_a_bvalid_i  <= '0';
        end if;
        
        -- write access
        if (AXI_A_AWVALID = '1') then
          addr_a          <= unsigned(AXI_A_AWADDR(G_ADDR_WIDTH+1 downto 2));
          axi_a_wready_i  <= '1';
        end if;
        
        if (AXI_A_WVALID = '1' and axi_a_wready_i = '1') then
          axi_a_wready_i  <= '0';
          axi_a_bvalid_i  <= '1';
          for i in 0 to 3 loop
            if (AXI_A_WSTRB(i) = '1') then
              ram(to_integer(addr_a))(i*8+7 downto i*8)  := AXI_A_WDATA(i*8+7 downto i*8);
            end if;
          end loop;
        end if;
        
        -- read access 
        if (AXI_A_ARVALID = '1') then
          AXI_A_RDATA     <= ram(to_integer(unsigned(AXI_A_ARADDR(G_ADDR_WIDTH+1 downto 2))));
          axi_a_rvalid_i  <= '1';
        end if;
        
      
      end if;
    end if;
  end process;
        
  P_PORT_B  : process(CLK) 
  begin 
    if rising_edge(CLK) then
      if (RSTN = '0') then
        axi_b_wready_i  <= '0';
        axi_b_bvalid_i  <= '0';
        axi_b_rvalid_i  <= '0';
        addr_b          <= (others => '0');
      else
        
        
        if (axi_b_rvalid_i = '1' and AXI_B_RREADY = '1') then
          axi_b_rvalid_i  <= '0';
        end if;
        
        -- bresp
        if (axi_b_bvalid_i  = '1' and AXI_B_BREADY = '1') then
          axi_b_bvalid_i  <= '0';
        end if;
        
        
        -- write access
        if (AXI_B_AWVALID = '1') then
          addr_b          <= unsigned(AXI_B_AWADDR(G_ADDR_WIDTH+1 downto 2));
          axi_b_wready_i  <= '1';
        end if;
        
        if (AXI_B_WVALID = '1' and axi_b_wready_i = '1') then
          axi_b_wready_i  <= '0';
          axi_b_bvalid_i  <= '1';
          for i in 0 to 3 loop
            if (AXI_B_WSTRB(i) = '1') then
              ram(to_integer(addr_b))(i*8+7 downto i*8)  := AXI_B_WDATA(i*8+7 downto i*8);
            end if;
          end loop;
        end if;
        
        -- read access 
        if (AXI_B_ARVALID = '1') then
          AXI_B_RDATA     <= ram(to_integer(unsigned(AXI_B_ARADDR(G_ADDR_WIDTH+1 downto 2))));
          axi_b_rvalid_i  <= '1';
        end if;
        
      
      
      end if;
    end if;
  end process;

end rtl;
