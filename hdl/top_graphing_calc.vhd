-- TOP LEVEL FILE
-- CPE 526
-- Edwin Estep

-- This system is a graphing calculator which
-- reads user data via a UART terminal and
-- outputs a graphed function via VGA.          <-- re-write this


library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


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
    signal arst : std_logic;

    -- INPUT
    signal rx_valid : std_logic;
    signal rx_byte  : std_logic_vector(7 downto 0);


    -- ARITHMETIC



    -- GRAPHING
    component pll_25M
        PORT
        (
            areset		: IN STD_LOGIC  := '0';
            inclk0		: IN STD_LOGIC  := '0'; 
            c0		: OUT STD_LOGIC ;
            locked		: OUT STD_LOGIC 
        );
    END component;

    signal CLOCK_25 : std_logic;
    signal locked : std_logic;
    

    signal p_din : std_logic;
    signal p_dout : std_logic;
    signal p_wraddr : std_logic_vector(19 downto 0);
    signal p_rdaddr : std_logic_vector(19 downto 0);
    signal p_we : std_logic;

    signal color : rgb;
begin   

    uart0 : uart_rx
        generic map (217)   -- clks per bit for 25Mhz @ 115200baud
        port map (CLOCK_25, UART_IN, rx_valid, rx_byte);



    -- graphing
    pll0 : pll_25M
        port map(arst, CLOCK_50, CLOCK_25, locked);

    pixel_ram0 : pixel_ram
        port map(CLOCK_25, p_din, p_wraddr, p_rdaddr, p_we, p_dout);

    vga0 : vga
        port map(CLOCK_25, arst, p_rdaddr, p_dout, VGA_RGB, HSYNC, VSYNC);

    
    process(CLOCK_25) begin
        if(CLOCK_25'event and CLOCK_25='1') then
            if(arst='1') then
                p_wraddr <= X"00000";
            else
                p_wraddr <= p_wraddr + "1";

                if(p_rdaddr(0)='1')then
                p_din <= p_wraddr(4);
                else
                    p_din <= '0';
                end if;
            end if;
        end if;
    end process;

    p_we <= '1';
    arst <= not RESET;
end structural;
