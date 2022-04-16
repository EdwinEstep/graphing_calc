


library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;


entity adder is
    generic (
        WIDTH : integer
    );
    port (
        op1 : std_logic_vector(WIDTH-1 downto 0);
        op2 : std_logic_vector(WIDTH-1 downto 0);
        result : std_logic_vector(WIDTH-1 downto 0)
    );
end entity;


architecture rtl of adder is

begin
    
end architecture;
