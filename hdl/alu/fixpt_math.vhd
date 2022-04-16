-- fixed-point math operations
-- sources:  ...

library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;

package fixpt_math is

    -- 1-cycle 
    component adder
        generic (
            WIDTH : integer
        );
        port (
            op1 : std_logic_vector(WIDTH-1 downto 0);
            op2 : std_logic_vector(WIDTH-1 downto 0);
            result : std_logic_vector(WIDTH-1 downto 0)
        );
    end component;
end package fixpt_math;