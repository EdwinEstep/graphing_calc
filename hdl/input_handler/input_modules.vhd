-- 4-bit RGB values for VGA output

library ieee;
use ieee.std_logic_1164.all;

package input_modules is
    component uart_rx
        generic (
            g_CLKS_PER_BIT : integer
        );
        port (
          i_Clk       : in  std_logic;
          i_RX_Serial : in  std_logic;
          o_RX_DV     : out std_logic;
          o_RX_Byte   : out std_logic_vector(7 downto 0)
        );
    end component;


    
end package input_modules;