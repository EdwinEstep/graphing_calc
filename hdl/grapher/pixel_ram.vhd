-- https://www.intel.com/content/www/us/en/programmable/quartushelp/13.0/mergedProjects/hdl/vhdl/vhdl_pro_ram_inferred.htm
-- This dual-port RAM has been adapted for use with a
-- 1-bit color pixel RAM. 640x480
-- It can be 


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;


ENTITY pixel_ram IS
   PORT (
      clock: IN   std_logic;
      data:  IN   std_logic;
      write_address:  IN   std_logic_vector(19 downto 0);
      read_address:   IN   std_logic_vector(19 downto 0);
      we:    IN   std_logic;
      q:     OUT  std_logic
   );
END pixel_ram;


ARCHITECTURE rtl OF pixel_ram IS
   TYPE mem IS ARRAY(0 TO 1048575) OF std_logic;
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