-- RGB definition and modules for VGA

library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;

package vga_graphing is
    -- RGB(0) = R, RGB(1) = G, RGB(2) = B
    type rgb is array(0 to 2) of std_logic_vector (3 downto 0);

    constant WHITE : rgb := (
        others => X"F"
    );

    constant BLACK : rgb := (
        others => X"0"
    );

    
    -- RAM for 4-bit RGB pixel data
    component pixel_ram
        PORT (
            clock: IN   std_logic;
            data:  IN   std_logic;
            write_address:  IN   std_logic_vector(18 downto 0);
            read_address:   IN   std_logic_vector(18 downto 0);
            we:    IN   std_logic;
            q:     OUT  std_logic
        );
    end component;


    component vga
        port (
            clk : in std_logic; -- assumes 50Mhz
            srst : in std_logic;
    
            -- ram signals for pixel buffer
            r_adr : inout std_logic_vector(18 downto 0); -- 10b for H, 10b for V
            r_din : in std_logic;
    
            color : out rgb;
            hsync, vsync : out std_logic
        );
    end component;
end package vga_graphing;