library ieee;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

use work.vga_graphing.all;

entity vga is
    port (
        clk : in std_logic; -- assumes 50Mhz
        srst : in std_logic;

        -- ram signals for pixel buffer
        r_adr : inout std_logic_vector(18 downto 0); -- 10b for H, 9b for V
        r_din : in std_logic;

        color : out rgb;
        hsync, vsync : out std_logic
    );
end vga;


-- added generic for pulse length
architecture behavioral of vga is
    type state_type is (FRONT_PORCH_H, GRAPHING, IDLE);
    signal state : state_type;

    signal hsync2, vsync2, hsync_prev : std_logic;

    signal pixel : std_logic;
    signal vcnt : std_logic_vector(8 downto 0);
    signal hcnt : std_logic_vector(9 downto 0);
    signal porch_cnt : std_logic_vector(4 downto 0);

    
    component vga_sync
        port(
            clk, srst : in std_logic;
            hsync, vsync : out std_logic;
            hcount, vcount : inout std_logic_vector(9 downto 0)
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
                hcnt <= x"00"&"00";
                vcnt <= X"00"&"0";
            else
                case state is
                    when FRONT_PORCH_H=>
                        if(porch_cnt >= "01110") then
                            state <= GRAPHING;
                        end if;

                        porch_cnt <= porch_cnt + "1";
                    when GRAPHING=>
                        if(hcnt > X"27E") then
                            hcnt <= x"00"&"00";
                            state <= IDLE;
                            if(vcnt > X"20C") then
                                vcnt <= X"00"&"0";
                            else
                                vcnt <= vcnt + "1";
                            end if;
                        else
                            hcnt <= hcnt + "1";
                        end if;
                    when IDLE=>
                        if(hsync2 = '1' and hsync_prev = '0') then -- detect rising edge of hsync
                            state <= FRONT_PORCH_H;
                            porch_cnt <= "00000";
                        end if;
                    when OTHERS=>
                        state <= IDLE;
                end case;

                hsync_prev <= hsync2;
            end if;
        end if;
    end process;

    vsync <= vsync2;
    hsync <= hsync2;

    r_adr <= vcnt & hcnt;
    pixel <= r_din when (hsync2='1' and hcnt < X"280") and (vsync2='1' and vcnt < X"1E0")
        else '0';

    -- assign monochromatic color
    with pixel select color <=
        WHITE when '1',
        BLACK when others;
end behavioral;