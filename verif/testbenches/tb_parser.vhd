-- CPE 526
-- Edwin Estep

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.input_modules.all;


entity tb_parser is
end tb_parser;


architecture tb of tb_parser is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    -- port signals for parser
    signal rx_dv : std_logic := '0';
    signal rx_byte : std_logic_vector(7 downto 0);
    signal data : std_logic_vector(17 downto 0);

    signal opcode  : op;
    signal opstart :  std_logic;    
begin   
    process(clk) begin
        clk <= not clk after 10 ns; 
    end process;

    -- initial updates
    process begin
        rst <= '0' after 30 ns;
        wait on rst;

        -- send byte
        rx_dv <= '1' after 40 ns;
        rx_byte <= x"39";
    end process;


    UUT : cmd_parser
        port map(clk, rst, rx_dv, rx_byte, data, opcode, opstart);
end tb;
