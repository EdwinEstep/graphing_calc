-- Takes uart input commands and distributes data to
-- 1. BCD->fixed-point binary converter
-- 2. RPN Data stack



library ieee;
use ieee.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;


entity cmd_parser is
  port (
    clk           : in std_logic;
    srst          : in std_logic;
    
    rx_dv         : in std_logic; -- uart data valid
    rx_byte       : in std_logic_vector(7 downto 0); -- uart byte

    dec_out       : out std_logic_vector(39 downto 0); -- 10 BCD digits(+radix=1010)

    stack_wr_data : out std_logic_vector(31 downto 0);
    stack_wr_en   : out std_logic;

    -- initiate operation
    opcode        : out std_logic_vector(4 downto 0);
    op_start      : out std_logic
    );
end cmd_parser;



architecture behavioral of cmd_parser is
  signal digit_count : integer := 0;
  signal bcd2 : std_logic_vector(7 downto 0);
  signal bcd  : std_logic_vector(3 downto 0);
begin
  p1 : process(clk)
  begin
    if(clk'event and clk='1') then
      if(srst='1') then 
        digit_count <= 10;
      elsif(rx_dv='1') then -- handle input byte
        -- either numerical or decimal point
        if((rx_byte < x"3A" and rx_byte > x"30") or rx_byte = x"2E") then
          dec_out(4*digit_count-1 downto 4*digit_count-4) <= bcd;
        
        -- some other character
        else
          opcode <= rx_byte(4 downto 0);
          op_start <= '1';
        end if;
      end if;

      if(op_start='1') then
        op_start <= '0';
      end if;
    end if;
  end process;


  -- offset to get BCD ('.' becomes FE)
  bcd2 <= rx_byte - x"30";
  bcd <= bcd2(3 downto 0);
end behavioral;
