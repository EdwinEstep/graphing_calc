-- Converts 10-digt (40bit) BCD to fixed-point binary.
--  Radix placed according to generic


library ieee;
use ieee.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;


entity dec_to_fixpt is
    port (
        clk     : in std_logic;
        srst    : in std_logic;
        start   : in std_logic;
        done    : out std_logic;

        bcd_in  : in std_logic_vector(27 downto 0);
        bin_out : out std_logic_vector(17 downto 0)
    );
end dec_to_fixpt;


architecture behavioral of dec_to_fixpt is
    type state_type is (IDLE, CALC);

    signal state : state_type;
    signal temp : std_logic_vector(27 downto 0);
    signal temp_sr : std_logic_vector(27 downto 0);     -- temp shifted right
    signal temp_next : std_logic_vector(27 downto 0);   -- temp shifted right & some 4-bit fields reduced

    signal temp_bin : std_logic_vector(27 downto 0);

    signal down_counter : std_logic_vector(4 downto 0);

begin
  

    seq_logic : process(clk) begin
        if(clk'event and clk='1') then
            if(srst='1') then
                done <= '0';
                state <= IDLE;
            else
                case state is
                    when IDLE =>
                        down_counter <= "11100";
                        done <= '0';
                        temp <= bcd_in;

                        if(start) then
                            state <= CALC;
                        end if;
                    when CALC =>
                        if(down_counter > "00000") then
                            -- shift LSB of temp into MSB of bin
                            temp_bin <= temp(0) & temp_bin(27 downto 1);
                            temp <= temp_next;

                            down_counter <= down_counter - '1';
                        else
                            done <= '1';
                            bin_out <= temp_bin(17 downto 0);
                            state <= IDLE;
                        end if;
                    when others =>
                        done <= '0';
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

    
    -- subtract 3 from each 4-bit bcd block that's larger than 4'b0111
    combo_logic : process(temp_sr) 
        variable K : integer;
    begin
        for I in 0 to 28/4-1 loop   -- for every 4-bit BCD value
            K := 4*I;

            if(temp_sr(K+3 downto K) > "0111") then
                temp_next(K+3 downto K) <= temp_sr(K+3 downto K) - "0011";
            else
                temp_next(K+3 downto K) <= temp_sr(K+3 downto K);
            end if;
        end loop;
   end process;


   -- shifted right by 1
   temp_sr <= '0' & temp(27 downto 1);
end behavioral;




