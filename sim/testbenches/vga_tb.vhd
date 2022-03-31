-- CPE 526
-- Edwin Estep

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.vga_graphing.all;


entity vga_tb is
end vga_tb;


architecture tb of vga_tb is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    signal hsync, vsync : std_logic;


    signal p_din : std_logic := '1';
    signal p_dout : std_logic;
    signal p_wraddr : std_logic_vector(18 downto 0) := X"0000"&"000";
    signal p_rdaddr : std_logic_vector(18 downto 0);
    signal p_we : std_logic;

    signal color : rgb;
begin   
    process(clk) begin
        clk <= not clk after 10 ns;
    end process;

    process(rst) begin
        rst <= '0' after 30 ns;
        p_we <= '1' after 30 ns;
    end process;

    process(clk) begin
        if(clk'event and clk='1') then
            p_wraddr <= p_wraddr + "1";
            if(p_rdaddr(0)='1')then
            p_dout <= p_wraddr(4);
            else
                p_dout <= '0';
            end if;
        end if;
    end process;

    vga0 : vga
        port map(clk, rst, p_rdaddr, p_dout, color, HSYNC, VSYNC);
end tb;
