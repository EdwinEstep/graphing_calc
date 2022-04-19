-- clearable shift-reg for storing variable-width values


library ieee;
use ieee.std_logic_1164.all;

package sreg_types is
    -- declare index range and width later
    type vec_array is array(natural range <>) of std_logic_vector;
end package sreg_types;


library ieee;
use ieee.std_logic_1164.ALL;
use work.sreg_types.all;


entity shift_reg is
    generic (
      WIDTH : integer := 10;
      LENGTH : integer := 10
  );
  port (
        clk      : in std_logic;
        srst     : in std_logic;
        ctrl    : in std_logic_vector(1 downto 0);
        
        shift_in : in std_logic_vector(WIDTH-1 downto 0);

        rdy      : out std_logic;
        q_out    : out vec_array(0 to LENGTH-1)(WIDTH-1 downto 0)
    );
end shift_reg;


architecture behavioral of shift_reg is
    signal i_reg : vec_array(0 to LENGTH-1)(WIDTH-1 downto 0);
    signal i_cntr : integer range 0 to LENGTH-1;
begin
    p1 : process(clk)
    begin
        if(clk'event and clk='1') then 
            if(srst='1') then 
                -- LE RESET
                i_cntr <= 0;
            else
                case ctrl is
                    when "00" => -- CLEAR
                        i_cntr <= 0;
                    when "01" => -- SHIFT IN
                        for i in 1 to LENGTH-1 loop
                            i_reg(i) <= i_reg(i-1);
                        end loop;
                        i_reg(0) <= shift_in;
                        i_cntr <= i_cntr + 1;
                    when "10" => -- SHIFT BACK BY 1
                        for i in LENGTH-2 downto 0 loop
                            i_reg(i) <= i_reg(i-1);
                        end loop;
                        i_reg(LENGTH-1) <= (others => '0');
                        i_cntr <= i_cntr - 1;
                    when others =>
                        i_reg <= i_reg;
                end case;
            end if;
        end if;
    end process;

    q_out <= i_reg;
end behavioral;
