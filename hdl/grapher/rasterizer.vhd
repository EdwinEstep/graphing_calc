

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity rasterizer is
    port (
        clk     : in std_logic;
        srst    : in std_logic;
        
        -- read from alu buffer
        buf_rd_adr  : in std_logic_vector(9 downto 0); -- 10b for 640 entries
        buf_dout    : in std_logic_vector(17 downto 0);

        -- write to pixel buffer
        pbuf_wr_adr  : out std_logic_vector(19 downto 0); -- 10b horizontal, 10b vertical
        pbuf_din    : out std_logic; -- 1b color
        pbuf_we   : OUT STD_LOGIC
    );
end rasterizer;



architecture rtl of rasterizer is

begin


    process(clk)
    begin
        if(clk'event and clk='1') then
            if(srst='1') then

            else
                
            end if;
        end if;
    end process;

end rtl;
