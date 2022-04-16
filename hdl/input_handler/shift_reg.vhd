-- clearable shift-reg for storing variable-width values

library ieee;
use ieee.std_logic_1164.ALL;



library ieee;
use ieee.std_logic_1164.ALL;


entity shift_reg is
    generic (
      WIDTH : integer := 10;
      LENGTH : integer := 10
  );
  port (
        clk      : in std_logic;
        srst     : in std_logic;
        
        shift_in : in std_logic_vector(WIDTH-1 downto 0);
        q_out    : out array(0 to LENGTH-1) of std_logic_vector(WIDTH-1 downto 0)
    );
end shift_reg;



architecture behavioral of shift_reg is
begin
    p1 : process(clk)
    begin
        if(clk'event and clk='1') then  
        if(srst='1') then 
            -- LE RESET
        else
            
        end if;
        end if;
    end process;
end behavioral;
