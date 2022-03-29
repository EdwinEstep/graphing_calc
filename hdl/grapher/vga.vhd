library ieee;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

use work.rgb_type.all;

entity vga is
    port (
        clk : in std_logic;     -- Use 25Mhz PLL
        srst : in std_logic;

        -- ram signals for pixel buffer
        r_adr : out std_logic_vector(19 downto 0); -- 10b for H, 10b for V
        r_din : in std_logic_vector(9 downto 0);

        color : out rgb;
        hsync, vsync : out std_logic
    );
end vga;


-- added generic for pulse length
architecture behavioral of vga is
    signal pixel : std_logic;     
    
    component vga_sync
        port(
            clk, srst : in std_logic;
            hsync, vsync : out std_logic
        );
    end component;

    for u1 : vga_sync use entity work.vga_sync(behavioral);
begin
    u1 : vga_sync port map(clk, srst, hsync, vsync);


    p1 : process(clk)
    begin
        if(clk'event and clk='1') then
            if(srst='1') then
                pixel <= '0';
            else
                pixel <= not pixel;
            end if;
        end if;
    end process;


    -- assign monochromatic color
    with pixel select color <=
        WHITE when '1',
        BLACK when others;
end behavioral;