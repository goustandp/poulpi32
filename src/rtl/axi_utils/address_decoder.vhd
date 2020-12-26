library work;
  use work.poulpi32_pkg.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;


entity address_decoder is 
  generic(
    G_ADDR_WIDTH          : integer := 32;
    G_NB_SLAVE            : integer := 1;
    G_MAPPING_FILE        : string  := "mapping.txt";
    G_TDEST_WIDTH         : integer :=1
  );
  port(
    -- address
    ADDR_TDATA          : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    ADDR_TVALID         : in  std_logic;
    -- decoded tdest
    TDEST               : out std_logic_vector(ceil(log2(real(G_NB_SLAVE)))-1 downto 0);
  );
end entity;

architecture rtl of address_decoder is


  type t_addr_array is array(0 to 2*G_NB_SLAVE-1) of std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    
  function init_addr_array(file_path : in string) return t_addr_array is
    file file_ptr           : text;
    variable v_line         : line;
    variable v_addr_array   : t_addr_array;
    variable v_addr         : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    begin
      file_open(file_ptr, file_path, read_mode);
      for i in 0 to G_NB_SLAVE-1 loop
        if not(endfile(file_ptr)) then
          readline(file_ptr, v_line);
          hread(v_line, v_addr)
          v_addr_array(i) := to_integer(unsigned(v_addr)); --low addr for slave i
          hread(v_line, v_addr)
          v_addr_array(i) := to_integer(unsigned(v_addr)); -- high addr for slave i
        end if;
      end loop;
      file_close(file_ptr);
    return v_addr_array;
  end function;
    
  signal addr_array :  t_addr_array:=init_addr_array(G_MAPPING_FILE);
  
  signal addr_int   : integer;
  
begin
  
  addr_int    <=  to_integer(unsigned(ADDR_TDATA));
  
  P_DECODE : process(ADDR_TDATA, ADDR_TVALID)
  begin
    if (ADDR_TVALID = '1') then
      for i in 0 to G_NB_SLAVE loop
        if (addr_int>=addr_array(2*i) and addr_int<=addr_int(2*i+1)) then
          TDEST <= std_logic_vector(to_unsigned(i, G_TDEST_WIDTH));
          exit;
        end if;
      end loop;
    end if;
  end process P_DECODE;

end rtl;
  
  
  
  
  
