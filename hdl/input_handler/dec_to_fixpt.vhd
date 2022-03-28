-- Converts 10-digt (40bit) BCD to fixed-point binary.
--  Radix placed according to generic


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity dec_to_fixpt is
    generic(
        radix_pos : integer := 0
    );
    port (
        clk     : in std_logic;
        srst    : in std_logic;
        start   : in std_logic;

        bcd_in  : in std_logic_vector(39 downto 0);
        bcd_out : out std_logic_vector(31 downto 0)
    );
end dec_to_fixpt;


architecture behavioral of dec_to_fixpt is

begin
  
end behavioral;
