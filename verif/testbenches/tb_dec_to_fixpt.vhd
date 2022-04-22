-- CPE 526
-- Edwin Estep

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.input_modules.dec_to_fixpt;


entity tb_dec_to_fixpt is
end tb_dec_to_fixpt;


architecture tb of tb_dec_to_fixpt is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    -- port signals for parser
    signal start   : std_logic := '0';
    signal done    : std_logic;

    signal bcd_in  : std_logic_vector(27 downto 0);
    signal bin_out : std_logic_vector(17 downto 0);
begin   
    process(clk) begin
        clk <= not clk after 10 ns; 
    end process;

    -- initial updates
    process begin
        rst <= '0' after 30 ns;

        -- send byte
        start <= '1' after 40 ns;
        bcd_in <= x"0123456";
    end process;

    process(clk) begin
        if(clk'event and clk='1') then
            
        end if;
    end process;

    UUT : dec_to_fixpt
        port map(clk, rst, start, done, bcd_in, bin_out);
end tb;
