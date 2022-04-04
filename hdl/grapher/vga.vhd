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
    type state_type is (V_PORCH_F, V_PORCH_B, H_PORCH_F, H_PORCH_B, GRAPHING);
    signal state : state_type;

    signal hsync2, vsync2 : std_logic;

    signal pixel : std_logic;
    signal vcnt : std_logic_vector(8 downto 0);
    signal hcnt : std_logic_vector(9 downto 0);

    signal pattern : std_logic;
    
    component vga_sync
        port(
            clk, srst : in std_logic;
            hsync, vsync : out std_logic;
            hcount : inout std_logic_vector(9 downto 0);
            vcount : inout std_logic_vector(8 downto 0)
        );
    end component;

    for u1 : vga_sync use entity work.vga_sync(behavioral);
begin
    u1 : vga_sync port map(clk, srst, hsync2, vsync2, hcnt, vcnt);


    assign_state : process(clk)
    begin
        if(clk'event and clk='1') then
            if(srst='1') then
                state <= V_PORCH_F;
            else
                case state is
                    when V_PORCH_F =>
                        if(vcnt > "01001") then -- 10 front porch lines
                            state <= H_PORCH_F;
                        end if;
                    when H_PORCH_F =>
                        if(hcnt > "10000") then -- 18 front porch pixels
                            state <= GRAPHING;
                        end if;
                    when GRAPHING  =>
                        if(hcnt > X"290") then  -- 640 horizontal pixels
                            state <= H_PORCH_B;
                        end if;
                    when H_PORCH_B =>
                        if(hcnt="0") then
                            if(vsync2='0') then
                                state <= V_PORCH_F;
                            else
                                state <= H_PORCH_F;
                            end if;
                        end if;
                    when V_PORCH_B =>
                        
                end case;
            end if;
        end if;
    end process;


    vsync <= vsync2;
    hsync <= hsync2;

    r_adr <= vcnt & hcnt;
    pixel <= pattern when state=GRAPHING
        else '0';

    -- assign a VGA test pattern
    pattern <= '1' when (hcnt > (vcnt-"10") and hcnt < (vcnt+"10"))
        else '0';

    -- assign monochromatic color
    with pixel select color <=
        WHITE when '1',
        BLACK when others;
end behavioral;