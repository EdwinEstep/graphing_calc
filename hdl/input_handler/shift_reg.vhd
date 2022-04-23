-- clearable shift-reg for storing variable-width values


library ieee;
use ieee.std_logic_1164.all;

package sreg_types is
    -- declare index range and width later
    type array_2d is array(natural range <>, natural range <>) of std_logic;
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
        ctrl     : in std_logic_vector(1 downto 0);
        
        shift_in : in std_logic_vector(WIDTH-1 downto 0);

        rdy      : out std_logic;
        q_out    : out array_2d(0 to LENGTH-1, WIDTH-1 downto 0);
        cnt      : out natural range 0 to LENGTH
    );
end shift_reg;


architecture behavioral of shift_reg is
    signal i_reg : array_2d(0 to LENGTH-1, WIDTH-1 downto 0);
    signal i_cntr : integer range 0 to LENGTH;

    type state_type is (RESET, READY);
    signal state : state_type;
begin
    p1 : process(clk)
    begin
        if(clk'event and clk='1') then 
            if(srst='1') then -- srst must be deasserted to complete reset
                state <= RESET;
                i_cntr <= 0;
            else
                report "srst='0'";
                if(state=RESET) then
                    -- increment cntr through range, resetting each element
                    report "ahhh, hell nah" severity warning;

                    if(i_cntr > LENGTH-1) then
                        state <= READY;
                        i_cntr <= 0;
                    else
                        for k in 0 to WIDTH-1 loop
                            i_reg(i_cntr, k) <= '0';
                        end loop; -- dumb loop 1
                        i_cntr <= i_cntr + 1;
                    end if;
                elsif(state=READY) then
                    case ctrl is
                        when "00" => -- CLEAR   
                            i_cntr <= 0;
                            state <= RESET;
                        when "01" => -- SHIFT IN
                            for i in 1 to LENGTH-1 loop
                                for k in 0 to WIDTH-1 loop
                                    i_reg(i, k) <= i_reg(i-1, k);
                                end loop; -- dumb loop 2
                            end loop;

                            -- i_reg(0) <= shift_in;
                            for k in 0 to WIDTH-1 loop
                                i_reg(0, k) <= shift_in(k);
                            end loop; -- dumb loop 3
                        when "10" => -- SHIFT BACK BY 1
                            for i in LENGTH-2 downto 0 loop

                                -- i_reg(i) <= i_reg(i-1);
                                for k in 0 to WIDTH-1 loop
                                    i_reg(i, k) <= i_reg(i+1, k);
                                end loop; -- dumb loop 3
                            end loop;

                            -- i_reg(LENGTH-1) <= (others => '0');
                            for k in 0 to WIDTH-1 loop
                                i_reg(LENGTH-1, k) <= '0';
                            end loop; -- dumb loop 3
                        when others =>
                            i_reg <= i_reg;
                    end case;
                else
                    state <= RESET; -- reset if unknown state encountered
                    i_cntr <= 0;
                end if;
            end if;
        end if;
    end process;

    cnt <= i_cntr;

    q_out <= i_reg;
    rdy <= '1' when state=READY else '0';
end behavioral;
