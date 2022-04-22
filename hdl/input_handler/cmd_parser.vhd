-- Takes uart input commands and distributes data to
-- 1. BCD->fixed-point binary converter
-- 2. RPN Data stack


library ieee;
use ieee.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;

use work.input_modules.dec_to_fixpt;
use work.input_modules.shift_reg;
use work.sreg_types.all;        -- shift reg output

entity cmd_parser is
  port (
    clk           : in std_logic;
    srst          : in std_logic;
    
    rx_dv         : in std_logic; -- uart data valid
    rx_byte       : in std_logic_vector(7 downto 0); -- uart byte

    data          : out std_logic_vector(17 downto 0); -- 18b data for aithmetic module
    opcode        : out std_logic_vector(4 downto 0);
    opstart       : out std_logic
  );
end cmd_parser;



architecture behavioral of cmd_parser is
  signal bcd2 : std_logic_vector(7 downto 0);
  signal bcd  : std_logic_vector(3 downto 0);

  signal num_reg_rdy : std_logic;
  signal num_reg_ctrl : std_logic_vector(1 downto 0);
  signal num_reg_in : std_logic_vector(3 downto 0);
  signal num_reg_out : array_2d(0 to 7-1, 3 downto 0);
  signal num_reg_vec    : std_logic_vector(4*7-1 downto 0);

  signal cmd_reg_rdy : std_logic;
  signal cmd_reg_ctrl : std_logic_vector(1 downto 0);
  signal cmd_reg_in : std_logic_vector(3 downto 0);
  signal cmd_reg_out : array_2d(0 to 3-1, 3 downto 0);
  signal cmd_reg_vec    : std_logic_vector(11 downto 0);

  signal fixpt_start : std_logic;
  signal fixpt_done : std_logic;
  signal fixpt_rdy : std_logic;
  signal fixpt_fail : std_logic;
  signal fixpt_out  : std_logic_vector(17 downto 0);


  
begin
  -- store numeric inputs as they come in
  num_reg : shift_reg
    generic map (4, 7) -- 4bit entries, x7
    port map(clk, srst, num_reg_ctrl, num_reg_in, num_reg_rdy, num_reg_out);

  -- store characters and turn them into commands
  cmd_reg : shift_reg
    generic map (5, 3) -- 5bit entries (26 eng letters), x3
    port map(clk, srst, cmd_reg_ctrl, cmd_reg_in, cmd_reg_rdy, cmd_reg_out);

  fixpt_converter : dec_to_fixpt
      port map(clk, srst, fixpt_start, fixpt_done, fixpt_rdy, fixpt_fail, num_reg_vec, fixpt_out);



  p1 : process(clk)
  begin
    if(clk'event and clk='1') then  
      if(srst='1') then 
        -- LE RESET
      elsif(rx_dv='1') then -- handle input byte
        if((rx_byte < x"3A" and rx_byte > x"30") or rx_byte = x"2E") then
          -- WRITE NUMERIC/DECIMAL TO NUMBER BUFFER
          -- AFTER 10 ENTRIES, BUFFER SHOULD BE SENT TO NUM STACK
          -- SEND CMD AND PLACE fixpt_out onto data out.
        elsif(rx_byte = x"2a" or rx_byte = x"2b" or rx_byte = x"2d" or rx_byte = x"2f") then
          -- SEND '+', '-', '*', '/' TO CMD STACK
        elsif(rx_byte < x"3A" and rx_byte > x"30") then
          -- WRITE ALPHA CHAR TO CHAR BUFFER.
          -- AFTER 3 ENTRIES, BUFFER SHOULD BE FLUSHED TO CMD STACK
        end if;
      end if;
    end if;
  end process;



  -- turn the stupid 2D array outputs into vectors
  -- honestly, they should have been vectors in the first place,
  -- but ehh
  to_vec : process(num_reg_out, cmd_reg_out)
  begin
    for i in 0 to 7-1 loop
      for k in 0 to 4-1 loop
        num_reg_vec(10*i+k) <= num_reg_out(i, k);
      end loop; --
    end loop; -- 

    for i in 0 to 3-1 loop
      for k in 0 to 4-1 loop
        cmd_reg_vec(3*i+k) <= cmd_reg_out(i, k);
      end loop; --
    end loop; --    
  end process;


  -- offset to get BCD ('.' becomes 0xE)
  bcd2 <= rx_byte - x"30";
  bcd <= bcd2(3 downto 0);
end behavioral;
