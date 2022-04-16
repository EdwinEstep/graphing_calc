
library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- assumes an input clock of 25Mhz
-- as well as a resolution of 640x480
-- Horizontal:  frontporch=18, backporch=50
-- Vertical:    frontporch=10, backporch=33
entity vga_sync is
    port(
        clk, srst : in std_logic;
        hsync, vsync : out std_logic;
        hcount : inout std_logic_vector(9 downto 0);
        vcount : inout std_logic_vector(9 downto 0)
    );
end vga_sync;


-- added generic for pulse length
architecture behavioral of vga_sync is
    begin
    p : process(clk)
        begin
            if(clk'event and clk='1') then
                if(srst='1') then
                    hcount <= "0000000000";
                    vcount <= "0000000000";
                else
                    -- count up to max value and reset
                    if(hcount >= x"31F") then           -- d799
                        hcount <= "0000000000";

                        if(vcount >= x"20C") then       -- d524
                            vcount <= "0000000000";
                        else
                            vcount <= vcount + "1";
                        end if;
                    else
                        hcount <= hcount + "1";
                    end if;
                end if;
            end if;
    end process;

    --pulse is only high when pixels are in range
    hsync <= '1' when hcount < X"2C4" else '0';     -- d708 (accounts for porches)
    vsync <= '1' when vcount < X"20B" else '0';     -- d523 (accounts for porches)
end behavioral;