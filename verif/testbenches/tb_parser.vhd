-- CPE 526
-- Edwin Estep

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.input_modules.all;


entity parser_tb is
end parser_tb;


architecture tb of parser_tb is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    -- port signals for parser
    signal rx_dv : std_logic := '0';
    signal rx_byte : std_logic_vector(7 downto 0);
    signal data : std_logic_vector(17 downto 0);

    signal opcode  : std_logic_vector( 4 downto 0);
    signal opstart :  std_logic;    
begin   
    process(clk) begin
        clk <= not clk after 10 ns; 
    end process;

    -- initial updates
    process begin
        rst <= '0' after 30 ns;

        -- send byte
        rx_dv <= '1' after 40 ns;
        rx_byte <= x"39";
    end process;

    process(clk) begin
        if(clk'event and clk='1') then
            
        end if;
    end process;

    UUT : cmd_parser
        port map(clk, rst, rx_dv, rx_byte, data, opcode, opstart);
end tb;
