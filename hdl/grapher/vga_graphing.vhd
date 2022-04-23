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


    component rasterizer
        port (
            clk     : in std_logic;
            srst    : in std_logic;
            
            -- read from alu buffer
            buf_rd_adr  : out std_logic_vector(9 downto 0); -- 10b for 640 entries
            buf_dout    : out std_logic_vector(17 downto 0);
    
            -- write to pixel buffer
            pbuf_wr_adr  : out std_logic_vector(19 downto 0); -- 10b horizontal, 10b vertical
            pbuf_din    : out std_logic; -- 1b color
            pbuf_we   : OUT STD_LOGIC
        );
    end component;
    
    -- RAM for 4-bit RGB pixel data
    component pixel_ram
        PORT (
            clock: IN   std_logic;
            data:  IN   std_logic;
            write_address:  IN   std_logic_vector(19 downto 0);
            read_address:   IN   std_logic_vector(19 downto 0);
            we:    IN   std_logic;
            q:     OUT  std_logic
        );
    end component;


    component vga
        port (
            clk : in std_logic; -- assumes 50Mhz
            srst : in std_logic;
    
            -- ram signals for pixel buffer
            r_adr : inout std_logic_vector(19 downto 0); -- 10b for H, 10b for V
            r_din : in std_logic;
    
            color : out rgb;
            hsync, vsync : out std_logic
        );
    end component;
end package vga_graphing;