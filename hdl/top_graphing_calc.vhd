-- TOP LEVEL FILE
-- CPE 526
-- Edwin Estep

-- This system is a graphing calculator which
-- reads user data via a UART terminal and
-- outputs a graphed function via VGA.          <-- re-write this


library ieee;
use ieee.std_logic_1164.all;

use work.input_modules.all;
use work.vga_graphing.all;


entity top_graphing_calc is
    port(
        CLOCK_50 : in std_logic;    -- PIN_P11
        RESET : in std_logic;       -- PIN_B8   (KEY0)
        UART_IN : in std_logic;     -- PIN_V5   (GPIO)

        -- vga signals
        VGA_RGB : out rgb;          -- 12 pins, just look at page 36 of manual
        HSYNC, VSYNC : out std_logic-- PIN_N3, PIN_N1
    );
end top_graphing_calc;


architecture structural of top_graphing_calc is
    -- INPUT
    signal rx_valid : std_logic;
    signal rx_byte  : std_logic_vector(7 downto 0);


    -- ARITHMETIC



    -- GRAPHING
    signal p_din : std_logic;
    signal p_dout : std_logic;
    signal p_wraddr : std_logic_vector(18 downto 0);
    signal p_rdaddr : std_logic_vector(18 downto 0);
    signal p_we : std_logic;

    signal color : rgb;
begin   

    uart0 : uart_rx
        generic map (434)   -- assumes a 50Mhz input clk
        port map (CLOCK_50, UART_IN, rx_valid, rx_byte);

    pixel_ram0 : pixel_ram
        port map(CLOCK_50, p_din, p_wraddr, p_rdaddr, p_we);

    vga0 : vga
        port map(CLOCK_50, RESET, p_rdaddr, p_dout, VGA_RGB, HSYNC, VSYNC);
end structural;
