-- Takes uart input commands and distributes data to
-- 1. BCD->fixed-point binary converter
-- 2. RPN Data stack



library ieee;
use ieee.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;

use work.input_modules.shift_reg;
use work.sreg_types.all;        -- shift reg output

entity cmd_parser is
    generic (
      BUFSIZE : integer := 10
  );
  port (
      clk           : in std_logic;
      srst          : in std_logic;
      
      rx_dv         : in std_logic; -- uart data valid
      rx_byte       : in std_logic_vector(7 downto 0); -- uart byte

      dec_out       : out std_logic_vector(BUFSIZE*4-1 downto 0); -- 10 BCD digits (radix represented as 0b1010)

      stack_wr_data : out std_logic_vector(BUFSIZE*4-1 downto 0);
      stack_wr_en   : out std_logic;

      -- initiate operation
      opcode        : out std_logic_vector(4 downto 0)
    );
end cmd_parser;



architecture behavioral of cmd_parser is
  signal bcd2 : std_logic_vector(7 downto 0);
  signal bcd  : std_logic_vector(3 downto 0);

  signal num_reg_rdy : std_logic;
  signal num_reg_ctrl : std_logic_vector(1 downto 0);
  signal num_reg_in : std_logic_vector(3 downto 0);
  signal num_reg_out : vec_array(0 to 9)(3 downto 0);
begin

  num_reg : shift_reg
    generic map (4, 10) -- 4bit entries, x10
    port map(clk, srst, num_reg_ctrl, num_reg_in, num_reg_rdy, num_reg_out);



  p1 : process(clk)
  begin
    if(clk'event and clk='1') then  
      if(srst='1') then 
        -- LE RESET
      elsif(rx_dv='1') then -- handle input byte
        if((rx_byte < x"3A" and rx_byte > x"30") or rx_byte = x"2E") then
          -- WRITE NUMERIC/DECIMAL TO NUMBER BUFFER
          -- AFTER 10 ENTRIES, BUFFER SHOULD BE SENT TO NUM STACK
        elsif(rx_byte = x"2a" or rx_byte = x"2b" or rx_byte = x"2d" or rx_byte = x"2f") then
          -- SEND '+', '-', '*', '/' TO CMD STACK
        elsif(rx_byte < x"3A" and rx_byte > x"30") then
          -- WRITE ALPHA CHAR TO CHAR BUFFER.
          -- AFTER 3 ENTRIES, BUFFER SHOULD BE FLUSHED TO CMD STACK
        end if;
      end if;
    end if;
  end process;

  -- offset to get BCD ('.' becomes 0xE)
  bcd2 <= rx_byte - x"30";
  bcd <= bcd2(3 downto 0);
end behavioral;
