-- Takes uart input commands and distributes data to
-- 1. BCD->fixed-point binary converter
-- 2. RPN Data stack


library ieee;
use ieee.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;

use work.input_modules.all;
use work.sreg_types.all;        -- shift reg output

entity cmd_parser is
  port (
    clk           : in std_logic;
    srst          : in std_logic;
    
    rx_dv         : in std_logic; -- uart data valid
    rx_byte       : in std_logic_vector(7 downto 0); -- uart byte

    data          : out std_logic_vector(17 downto 0); -- 18b data for aithmetic module
    opcode        : out op;
    opstart       : out std_logic
  );
end cmd_parser;



architecture behavioral of cmd_parser is
  signal bcd2 : std_logic_vector(7 downto 0);
  signal bcd  : std_logic_vector(3 downto 0);


  signal num_reg_rdy : std_logic;
  signal num_reg_ctrl : std_logic_vector(1 downto 0);
  signal num_reg_in : std_logic_vector(3 downto 0);
  signal num_reg_out : array_2d(0 to 7-1, 3 downto 0);
  signal num_reg_vec    : std_logic_vector(4*7-1 downto 0);
  signal num_reg_cnt : natural range 0 to 7;

  signal cmd_reg_rdy : std_logic;
  signal cmd_reg_ctrl : std_logic_vector(1 downto 0);
  signal cmd_reg_in : std_logic_vector(4 downto 0);
  signal cmd_reg_out : array_2d(0 to 3-1, 4 downto 0);
  signal cmd_reg_vec    : std_logic_vector(14 downto 0);
  signal cmd_reg_cnt : natural range 0 to 3;


  signal fixpt_start : std_logic;
  signal fixpt_done : std_logic;
  signal fixpt_rdy : std_logic;
  signal fixpt_fail : std_logic;
  signal fixpt_out  : std_logic_vector(17 downto 0);

  signal cmd_op : op;

  type state_type is (RESET, DATA_ENTRY, NEW_CMD, NEW_NUM, ONECHAR_OP);
  signal state : state_type;
begin
  -- store numeric inputs as they come in
  num_reg : shift_reg
    generic map (4, 7) -- 4bit entries, x7
    port map(clk, srst, num_reg_ctrl, num_reg_in, num_reg_rdy, num_reg_out, num_reg_cnt);

  -- store characters and turn them into commands
  cmd_reg : shift_reg
    generic map (5, 3) -- 5bit entries (26 eng letters), x3
    port map(clk, srst, cmd_reg_ctrl, cmd_reg_in, cmd_reg_rdy, cmd_reg_out, cmd_reg_cnt);

  fixpt_converter : dec_to_fixpt
      port map(clk, srst, fixpt_start, fixpt_done, fixpt_rdy, fixpt_fail, num_reg_vec, fixpt_out);



  p1 : process(clk)
  begin
    if(clk'event and clk='1') then  
      if(srst='1') then 
        state <= RESET;
        cmd_reg_ctrl <= "11";
        num_reg_ctrl <= "11";
      else
        case state is
          when RESET =>
            -- wait til reges have finished resetting
            if(num_reg_rdy='1' and cmd_reg_rdy='1') then
              state <= DATA_ENTRY;
            end if;
          when DATA_ENTRY =>
            cmd_reg_ctrl <= "11";
            num_reg_ctrl <= "11";
            opstart <= '0';

            if(rx_dv='1') then -- handle input byte
              if((rx_byte < x"3A" and rx_byte > x"30") or rx_byte = x"2E") then
                -- WRITE NUMERIC/DECIMAL TO NUMBER BUFFER

                num_reg_in <= bcd;
                num_reg_ctrl <= "01";
                state <= NEW_NUM;
              elsif(rx_byte = x"2a" or rx_byte = x"2b" or rx_byte = x"2d" or rx_byte = x"2f") then
                opstart <= '1';
                state <= ONECHAR_OP; -- 

                case rx_byte(3 downto 0) is
                  when X"a" =>
                    opcode <= ADD;
                  when X"b" =>
                    opcode <= SUB;
                  when X"d" =>
                    opcode <= MUL;
                  when X"f" =>
                    opcode <= DIV;
                  when others =>
                    opcode <= NUL;
                end case;
              elsif(rx_byte > x"40" and rx_byte < x"5b") then -- uppercase char
                -- WRITE ALPHA CHAR TO CHAR BUFFER.
                cmd_reg_in <= rx_byte(4 downto 0);
                cmd_reg_ctrl <= "01";
                state <= NEW_CMD;
              end if;
            end if;

          when NEW_CMD => -- don't shift in new values
            state <= DATA_ENTRY;

            if(cmd_reg_cnt < 3) then
              cmd_reg_ctrl <= "11"; -- no op

              if(num_reg_cnt > 0) then  -- 
                num_reg_ctrl <= "00"; -- clear the reg
                opcode <= NUM;    -- opcode to put num on stack
                data <= fixpt_out;
              end if;
            else
              cmd_reg_ctrl <= "00"; -- clear the reg
              opstart <= '1';
              data <= fixpt_out;

              opcode <= cmd_op;
            end if;

          when NEW_NUM =>
            state <= DATA_ENTRY;

            if(num_reg_cnt < 7) then
              num_reg_ctrl <= "11"; -- no op
            else
              num_reg_ctrl <= "00"; -- clear the reg
              opcode <= NUM;    -- opcode to put num on stack
              data <= fixpt_out;
              opstart <= '1';
            end if;

          when ONECHAR_OP => -- reset signals while transmitting data for one pulse
            opstart <= '0';
            state <= DATA_ENTRY;
          when others =>
            state <= RESET;
            opstart <= '0';
          end case;
      end if;
    end if;
  end process;



  -- turn the stupid 2D array outputs into vectors
  -- honestly, they should have been vectors in the first place,
  -- but ehh
  to_vec : process(num_reg_out, cmd_reg_out)
  begin
    for i in 0 to 7-1 loop
      for k in 0 to 4-1 loop
        num_reg_vec(4*i+k) <= num_reg_out(i, k);
      end loop; --
    end loop; -- 

    for i in 0 to 3-1 loop
      for k in 0 to 5-1 loop
        cmd_reg_vec(5*i+k) <= cmd_reg_out(i, k);
      end loop; --
    end loop; --    
  end process;


  -- select opcode from CMD reg
  vec_to_op : process(cmd_reg_vec)
  begin
    case cmd_reg_vec is
      when "100"&X"84" => -- ADD
        opcode <= ADD;
      
      -- fill in the rest of the opcodes
        
      when others =>
        opcode <= NUL;

    end case;
  end process;


  -- offset to get BCD ('.' becomes 0xE)
  bcd2 <= rx_byte - x"30";
  bcd <= bcd2(3 downto 0);
end behavioral;
