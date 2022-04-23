

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity rasterizer is
    port (
        clk     : in std_logic;
        srst    : in std_logic;
        
        -- read from alu buffer
        buf_rd_adr  : out std_logic_vector(9 downto 0); -- 10b for 640 entries
        buf_dout    : in std_logic_vector(17 downto 0);

        -- write to pixel buffer
        pbuf_wr_adr  : out std_logic_vector(19 downto 0); -- 10b horizontal, 10b vertical
        pbuf_din    : out std_logic; -- 1b color
        pbuf_we   : OUT STD_LOGIC
    );
end rasterizer;



architecture rtl of rasterizer is
    signal r_buf_rd_adr : std_logic_vector(9 downto 0);
    signal r_pbuf_wr_adr : std_logic_vector(19 downto 0);
begin


    -- process(clk)
    -- begin
    --     if(clk'event and clk='1') then
    --         if(srst='1') then

    --         else
                
    --         end if;
    --     end if;
    -- end process;


    -- TEST VGA WITH SIMPLE RASTERIZER REPLACEMENT
    pbuf_we <= '1';
    process(clk) begin
        if(clk'event and clk='1') then
            if(srst='1') then
                r_buf_rd_adr <= "00"&X"00";
                r_pbuf_wr_adr <= X"00000";
            else
                r_pbuf_wr_adr <= r_pbuf_wr_adr + "1";

                if(r_buf_rd_adr(0)='1')then
                pbuf_din <= r_buf_rd_adr(4);
                else
                    pbuf_din <= '0';
                end if;
            end if;
        end if;
    end process;

    buf_rd_adr <= r_buf_rd_adr;
    pbuf_wr_adr <= r_pbuf_wr_adr;
end rtl;
