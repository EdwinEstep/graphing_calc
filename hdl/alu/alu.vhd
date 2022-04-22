

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use work.alu_modules.stack;

entity alu is
    port (
        clk     : in std_logic;
        srst    : in std_logic;
        
        -- inputs from cmd_parser
        data          : in std_logic_vector(17 downto 0);
        opcode        : in std_logic_vector(4 downto 0);
        opstart       : in std_logic;

        -- send to output buffer
        buf_wr_adr  : out std_logic_vector(9 downto 0); -- 10b for 640 entries
        buf_din    : out std_logic_vector(17 downto 0);
        buf_we   : OUT STD_LOGIC
    );
end alu;



architecture rtl of alu is


    -- signals for stack
    signal push, pop, full : std_logic;
    signal s_wr_adr, s_rd_adr : std_logic_vector(2 downto 0) := "000";
    signal s_din, s_dout : std_logic_vector(17 downto 0);
begin
    data_stack : stack
    generic map(18, 16, 8)
    port map(clk, srst, push, pop, full, s_wr_adr, s_rd_adr, s_din, s_dout);


    process(clk)
    begin
        if(clk'event and clk='1') then
            if(srst='1') then

            else
                
            end if;
        end if;
    end process;
end rtl;
