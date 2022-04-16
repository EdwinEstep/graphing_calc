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

    component cmd_parser
        generic (
            BUFSIZE : integer := 10
        );
        port (
            clk           : in std_logic;
            srst          : in std_logic;
            
            rx_dv         : in std_logic; -- uart data valid
            rx_byte       : in std_logic_vector(7 downto 0); -- uart byte
        
            dec_out       : out std_logic_vector(BUFSIZE*4-1 downto 0); -- 10 BCD digits (radix represented as 0b1010)
        
            stack_wr_data : out std_logic_vector(BUFSIZE*4-1 downto 0);
            stack_wr_en   : out std_logic;
        
            -- initiate operation
            opcode        : out std_logic_vector(4 downto 0);
            op_start      : out std_logic
            );
    end component;
    
end package input_modules;