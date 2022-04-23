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
    signal done, fail, rdy    : std_logic;

    signal bcd_in  : std_logic_vector(27 downto 0);
    signal bin_out : std_logic_vector(17 downto 0);
begin   
    process(clk) begin
        clk <= not clk after 10 ns; 
    end process;

    
    -- test stimulation
    process begin
        -- 
        rst <= '0' after 30 ns;
        wait on rst;


        -- === TEST GOOD INPUT DATA ===
        start <= '1' after 20 ns;
        bcd_in <= x"0123456";

        wait on start;
        start <= '0' after 20 ns;

        wait until rdy='1';



        -- === TEST OVERFLOW ===
        start <= '1' after 20 ns;
        bcd_in <= x"9999999";

        wait on start;
        start <= '0' after 20 ns;

        wait until rdy='1';



        -- === TEST NON-BCD INPUT ===
        start <= '1' after 40 ns;
        bcd_in <= x"000000A";

        wait on start;
        start <= '0' after 20 ns;

        wait until rdy='1';
    end process;


    UUT : dec_to_fixpt
        port map(clk, rst, start, done, rdy, fail, bcd_in, bin_out);
end tb;
