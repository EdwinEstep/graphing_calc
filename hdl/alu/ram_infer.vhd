-- https://www.intel.com/content/www/us/en/programmable/quartushelp/13.0/mergedProjects/hdl/vhdl/vhdl_pro_ram_inferred.htm
-- single-port RAM for 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.math_real.all; -- for ceil, log2, real
use ieee.numeric_std.all;


ENTITY ram_infer IS
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
END ram_infer;


ARCHITECTURE rtl OF ram_infer IS
    TYPE mem IS ARRAY(0 TO DEPTH-1) OF std_logic_vector(WIDTH-1 downto 0);
    SIGNAL ram_block : mem;
BEGIN
    PROCESS (clock)
    BEGIN
        IF (clock'event AND clock = '1') THEN
            IF (we = '1') THEN
                ram_block(to_integer(unsigned(write_address))) <= data;
            END IF;
         q <= ram_block(to_integer(unsigned(read_address)));
        END IF;
    END PROCESS;
END rtl;