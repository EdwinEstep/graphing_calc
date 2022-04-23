-- 4-bit RGB values for VGA output

library ieee;
use ieee.std_logic_1164.all;
use work.sreg_types.all;        -- shift reg output

package input_modules is
    type op is (ADD, SUB, MUL, DIV, NUL, XXX, NUM);


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


    component dec_to_fixpt
        port (
            clk     : in std_logic;
            srst    : in std_logic;
            start   : in std_logic;
            done    : out std_logic;
            rdy     : out std_logic;
            fail    : out std_logic; -- set when there is a failure in data interpretation
    
            bcd_in  : in std_logic_vector(27 downto 0);
            bin_out : out std_logic_vector(17 downto 0)
        );
    end component;

    component shift_reg
        generic (
            WIDTH : integer := 10;
            LENGTH : integer := 10
          );
          port (
              clk      : in std_logic;
              srst     : in std_logic;
              ctrl     : in std_logic_vector(1 downto 0);
              
              shift_in : in std_logic_vector(WIDTH-1 downto 0);
      
              rdy      : out std_logic;
              q_out    : out array_2d(0 to LENGTH-1, WIDTH-1 downto 0);
              cnt      : out natural range 0 to LENGTH
          );
    end component;

    component cmd_parser
        port (
            clk           : in std_logic;
            srst          : in std_logic;
            
            rx_dv         : in std_logic; -- uart data valid
            rx_byte       : in std_logic_vector(7 downto 0); -- uart byte
      
            data          : out std_logic_vector(17 downto 0); -- 18b data for aithmetic module
            opcode        : out op;
            opstart       : out std_logic
          );
    end component;
end package input_modules;