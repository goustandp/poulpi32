
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;
  use std.textio.all;


entity uart_emulator is
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
end entity uart_emulator;


architecture behave of uart_emulator is
  
  type t_ascii_table is array(32 to 126) of character;
  
  constant ascii_table : t_ascii_table:= (' ',  '!',  ''',  '#', '$', '%', '&', ''', '(', ')', '*', '+', ',', '-', '.', '/', '0', '1', '2',  '3', '4', '5', '6', '7', '8', '9', ':', ';', '<',
                                                      '=', '>', '?', '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V','W', 'X', 'Y', 'Z',
                                                      '[', '\', ']', '^', '_', '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',  'u', 'v', 'w', 'x',
                                                      'y', 'z', '{', '|', '}', '~');

  signal axi_bvalid_s     : std_logic;

begin
  
  
  AXI_ARREADY <= '0';
  AXI_RVALID  <= '0';
  AXI_RDATA   <= (others => '0');
  AXI_RESP    <= (others => '0');
  
  AXI_BRESP   <= "00";  -- ok
  
  AXI_BVALID    <= axi_bvalid_s;

  P_WRITE : process(CLK)
   variable v_line      : line;
   variable v_data      : integer;
   file file_ptr        : text;
  begin
    if rising_edge(CLK) then
      if (RSTN = '0') then
        AXI_AWREADY       <= '0';
        AXI_WREADY        <= '0';
        axi_bvalid_s      <= '0';
        file_open(file_ptr, G_FILE_PATH, write_mode);
      else
        -- always ready 
        AXI_AWREADY       <= '1';
        AXI_WREADY        <= '1';
        
        if (axi_bvalid_s = '1' and AXI_BREADY = '1') then
          axi_bvalid_s  <= '0';
        end if;
        
        if (AXI_WVALID = '1') then
          axi_bvalid_s  <= '1';
          

            if (AXI_WSTRB = "0001") then
              v_data := to_integer(unsigned(AXI_WDATA));
              if (v_data = 0) then
                writeline(file_ptr, v_line);
              else
                if (v_data>=32 and v_data<=126) then
                  write(v_line, ascii_table(v_data));
                else
                  report "unknow ascii caracter with code "&integer'image(v_data) severity note;
                end if;
              end if;
            else
              report "print integer: "&integer'image(v_data) severity note;
            end if;

        end if;
      end if;
    end if;
  end process;
  
  
  



end behave;
