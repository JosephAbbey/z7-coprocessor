library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.float_pkg.all;

entity sqrt is
  port (
    clk   : in  STD_LOGIC;
    rst   : in  STD_LOGIC;
    new_a : in  STD_LOGIC; -- Signal to indicate new input
    a     : in  my_float;
    q     : out my_float;
    valid : out STD_LOGIC
  );
end entity;

architecture rtl of sqrt is

  signal x_n              : my_float             := ONE;

  signal frac             : my_float             := (others => '0');
  signal frac_invalid_cnt : UNSIGNED(2 downto 0) := "000";

  signal root_invalid_cnt : UNSIGNED(3 downto 0) := "0000";

  signal q_valid          : STD_LOGIC            := '0';

begin

  valid <= q_valid;

  -- could utilise more cycles here
  divider_inst : entity work.pipeline_divider
    generic map(
      pipeline_depth => 6
    )
    port map(
      clk => clk,
      rst => rst,
      a   => a,
      b   => x_n,
      q   => frac
    );

  process (clk, rst)
    variable x_n1 : my_float;
  begin
    if rising_edge(clk) then
      q       <= (others => '0');
      q_valid <= '0';
      if rst = '1' or new_a = '1' then
        x_n              <= ONE;
        frac_invalid_cnt <= to_unsigned(7, 3);
        root_invalid_cnt <= to_unsigned(15, 4);
      else
        if q_valid = '0' then
          if STD_LOGIC_VECTOR(frac_invalid_cnt) = "000" then
            frac_invalid_cnt <= to_unsigned(7, 3);
            -- this should minimize away the mantissa part of the
            -- multiplier and just decrement the exponent
            x_n1 := HALF * (x_n + frac);

            if STD_LOGIC_VECTOR(root_invalid_cnt) = "0000" or x_n1 = x_n then
              q       <= x_n1;
              q_valid <= '1';
            else
              root_invalid_cnt <= root_invalid_cnt - 1;
            end if;
          else
            frac_invalid_cnt <= frac_invalid_cnt - 1;
            x_n1 := x_n;
          end if;
          x_n <= x_n1;

          if a(31) = '1' then -- Negative input
            q       <= NaN;
            q_valid <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture rtl;
