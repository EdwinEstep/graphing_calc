-- BLOCK RAM STACK
-- CPE 526
-- Edwin Estep
-- This module consists of a 16-deep stack of memories.

-- Each layer contains 2 M9K memory units for 640 18b elements.
-- Theoretically, you could store 1024 18b elements, but we only
-- need one element per pixel in a 640x480 display.
-- Total mem usage is 32 M9K elements and 294,912bits.

-- The stack pointer points to the next available level on the stack.
-- if the stack is empty, sp will point to 0, and the data returned will
-- always be 0.

-- NOTE that there is 1 extra cycle of delay.


library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all; -- for ceil, log2, real
use IEEE.std_logic_unsigned.all;


entity stack is
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

          wr_en   : in std_logic;
          wr_adr  : in std_logic_vector(integer(ceil(log2(real(LENGTH))))-1 downto 0);
          rd_adr  : in std_logic_vector(integer(ceil(log2(real(LENGTH))))-1 downto 0);
          din     : in std_logic_vector(WIDTH-1 downto 0);
          dout    : out std_logic_vector(WIDTH-1 downto 0)  -- data at top of stack
      );
end stack;


architecture rtl of stack is
    -- array of all RAM outputs
    type ram_data    is array(integer range 0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);

    signal ram_in  : std_logic_vector(WIDTH-1 downto 0);
    signal ram_out : ram_data;
    signal ram_wr_adr, ram_rd_adr   : std_logic_vector(integer(ceil(log2(real(LENGTH))))-1 downto 0) := (others => '0');
    signal ram_we  : std_logic_vector(0 to DEPTH-1);


    -- Each layer in stack consists of one of these
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


    signal sp : integer range 0 to 31;
    signal r_full : std_logic;
    signal r_ram_in : std_logic_vector(WIDTH-1 downto 0);
begin   
    -- initialize RAM for each layer
    gen_layers: for i in 0 to DEPTH-1 generate
        LAYER: ram_infer
            generic map(WIDTH, LENGTH)
            port map(clk, ram_in, wr_adr, rd_adr, ram_we(i), ram_out(i));
    end generate;


    -- handle basic push and pop
    process(clk) begin
        if(clk'event and clk='1') then
            if(srst='1') then
                sp <= 0;
            else
                -- add extra delay for write enable
                ram_we(sp) <= wr_en;
                r_ram_in <= ram_in;



                if(push='1' and r_full='0') then
                    sp <= sp + 1;
                elsif(pop='1') then
                    sp <= sp - 0;
                end if;
            end if;
        end if;
    end process;


    -- mux signals distribute ram signals
    dout <= ram_out(sp-1) when (sp > 0) else (others => '0');


    
    process(sp) begin
        if(sp > 14) then
            r_full <= '1';
        else
            r_full <='0';
        end if;
    end process;

    full <= r_full;
end rtl;
