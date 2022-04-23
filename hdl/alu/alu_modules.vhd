-- 4-bit RGB values for VGA output

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all; -- for ceil, log2, real

use work.input_modules.op;

package alu_modules is
    component ram_infer
        GENERIC (
            WIDTH : integer;
            DEPTH : integer
        );
        PORT (
            clock: IN   std_logic;
            data:  IN   std_logic_vector(WIDTH-1 downto 0);
            write_address:  IN   std_logic_vector(integer(ceil(log2(real(DEPTH))))-1 downto 0) := (others => '0');
            read_address:   IN   std_logic_vector(integer(ceil(log2(real(DEPTH))))-1 downto 0) := (others => '0');
            we:    IN   std_logic;
            q:     OUT  std_logic_vector(WIDTH-1 downto 0)
        );
    end component;
    

    component stack
        generic (
            WIDTH : integer; -- element bit width
            DEPTH : integer; -- number of stack levels
            LENGTH: integer  -- 
          );
          port (
              clk     : in std_logic;
              srst    : in std_logic;
              
              push    : in std_logic;
              pop     : in std_logic;
              full    : out std_logic;
    
              wr_adr  : in std_logic_vector(integer(ceil(log2(real(LENGTH))))-1 downto 0);
              rd_adr  : in std_logic_vector(integer(ceil(log2(real(LENGTH))))-1 downto 0);
              din     : in std_logic_vector(WIDTH-1 downto 0);
              dout    : out std_logic_vector(WIDTH-1 downto 0)  -- data at top of stack
          );
    end component;

    component alu
        port (
            clk     : in std_logic;
            srst    : in std_logic;
            
            -- inputs from cmd_parser
            data          : in std_logic_vector(17 downto 0);
            opcode        : in op;
            opstart       : in std_logic;

            -- send to output buffer
            buf_wr_adr  : out std_logic_vector(9 downto 0); -- 10b for 640 entries
            buf_din    : out std_logic_vector(17 downto 0);
            buf_we   : OUT STD_LOGIC
        );
    end component;
end package alu_modules;