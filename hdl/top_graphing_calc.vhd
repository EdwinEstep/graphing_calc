-- TOP LEVEL FILE
-- CPE 526
-- Edwin Estep

-- This system is a graphing calculator which
-- reads user data via a UART terminal and
-- outputs a graphed function via VGA.          <-- re-write this


library ieee;
use ieee.std_logic_1164.all;

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
    -- INPUT MODULES
    signal rx_valid : std_logic;
    signal rx_byte  : std_logic_vector(7 downto 0);

    component uart_rx
        generic (
            g_CLKS_PER_BIT : integer
        );
        port (
          i_Clk       : in  std_logic;
          i_RX_Serial : in  std_logic;
          o_RX_DV     : out std_logic;
          o_RX_Byte   : out std_logic_vector(7 downto 0)
        );
    end component;

    -- INSERT COMMAND PARSER, connect to uart
    for uart0 : uart_rx use entity work.uart_rx(RTL);



    -- ARITHMETIC MODULES



    -- GRAPHING MODULES
    signal pixel_ram2_dout : std_logic_vector(9 downto 0);
    signal pixel_ram2_addr : std_logic_vector(19 downto 0);
    signal color : rgb;

    component vga
        port (
            clk : in std_logic;     -- Use 25Mhz PLL
            srst : in std_logic;
    
            -- ram signals for pixel buffer
            r_adr : out std_logic_vector(19 downto 0); -- 10b for H, 10b for V
            r_din : in std_logic_vector(9 downto 0);
    
            color : out rgb;
            hsync, vsync : out std_logic
        );
    end component;

    component pixel_ram
        PORT (
            clock: IN   std_logic;
            data:  IN   std_logic_vector(9 downto 0);
            write_address:  IN   integer RANGE 0 to 9;
            read_address:   IN   integer RANGE 0 to 9;
            we:    IN   std_logic;
            q:     OUT  std_logic_vector (31 DOWNTO 0)
        );
    end component;
    

    for vga0 : vga use entity work.vga(behavioral);
    for pixel_ram0 : pixel_ram use entity work.pixel_ram(rtl);
begin   

    uart0 : uart_rx 
        generic map (434)   -- assumes a 50Mhz input clk
        port map (CLOCK_50, UART_IN, rx_valid, rx_byte);

    vga0 : vga
        port map(CLOCK_50, RESET, pixel_ram2_addr, pixel_ram2_dout, VGA_RGB, HSYNC, VSYNC);

    pixel_ram0 : pixel_ram
        port map(CLOCK_50, r_din, )

    
        

    -- parser0 : cmd_parser
    --     port map(
    --         clk
    --         srst
            
    --         rx_dv
    --         rx_byte
        
    --         dec_out
        
    --         stack_wr_data
    --         stack_wr_en 
        
    --         -- initiate 
    --         opcode
    --         op_start
    --     );
end structural;
