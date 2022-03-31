library ieee;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

use work.vga_graphing.all;

entity vga is
    port (
        clk : in std_logic; -- assumes 50Mhz
        srst : in std_logic;

        -- ram signals for pixel buffer
        r_adr : out std_logic_vector(18 downto 0); -- 10b for H, 9b for V
        r_din : in std_logic;

        color : out rgb;
        hsync, vsync : out std_logic
    );
end vga;


-- added generic for pulse length
architecture behavioral of vga is
    type state_type is (FRONT_PORCH, GRAPHING, IDLE);
    signal state : state_type;

    signal pixel : std_logic;
    signal hcnt : std_logic_vector(9 downto 0);
    signal vcnt : std_logic_vector(8 downto 0);
    signal porch_cnt : std_logic_vector(4 downto 0);

    signal hsync2, vsync2 : std_logic;
    
    component vga_sync
        port(
            clk, srst : in std_logic;
            hsync, vsync : out std_logic
        );
    end component;

    for u1 : vga_sync use entity work.vga_sync(behavioral);
begin
    u1 : vga_sync port map(clk, srst, hsync2, vsync2);


    assign_state : process(clk)
    begin
        if(clk'event and clk='1') then
            if(srst='1') then
                state <= IDLE;
            else
                case state is
                    when FRONT_PORCH=>
                        if(porch_cnt > "10000") then
                            state <= GRAPHING;
                            hcnt <= "0000000000";
                        end if;
                    when GRAPHING=>
                        if(hcnt > X"27E") then
                            state <= IDLE;
                        end if;
                    when IDLE=>
                        if(hsync2 = '1') then -- exit sync state
                            state <= FRONT_PORCH;
                            porch_cnt <= "00000";
                        end if;
                    when OTHERS=>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;


    hsync <= hsync2;
    vsync <= vsync2;


    -- assign monochromatic color
    with pixel select color <=
        WHITE when '1',
        BLACK when others;
end behavioral;