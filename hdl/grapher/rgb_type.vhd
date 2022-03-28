-- 4-bit RGB values for VGA output

library ieee;
use ieee.std_logic_1164.all;

package rgb_type is
    -- RGB(0) = R, RGB(1) = G, RGB(2) = B
    type rgb is array(0 to 2) of std_logic_vector (3 downto 0);

    constant WHITE : rgb := (
        others => X"F"
    );

    constant BLACK : rgb := (
        others => X"0"
    );
end package rgb_type;