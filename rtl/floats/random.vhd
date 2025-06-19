-- ---------------------------------------------------------------------------------
--  Distributed under MIT Licence
--    See https://github.com/josephabbey/z7-coprocessor/blob/main/LICENCE.
-- ---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.float_pkg.all;

entity random is
  generic (
    seed : STD_LOGIC_VECTOR(27 downto 0) := "0000000000000000000000000001"
  );
  port (
    clk : in  STD_LOGIC;
    rst : in  STD_LOGIC;
    rnd : out my_float
  );
end entity;

architecture rtl of random is

  constant lfsr_init : STD_LOGIC_VECTOR(27 downto 0) := seed;
  signal lfsr        : STD_LOGIC_VECTOR(27 downto 0) := lfsr_init;

  signal rnd_man     : STD_LOGIC_VECTOR(22 downto 0);

begin

  -- Pseudo-random number generation logic using an
  -- LFSR (Linear Feedback Shift Register), inspired
  -- by an example in scratch_vhdl.

  -- Implemented using Xorshift method.

  -- Random numbers between 0 and 1:
  -- - sign is always 0
  -- - exponent is always 01111111 (127 in decimal, which is 0 + bias)
  -- - mantissa is a random string of 23 bits

  -- Using LFSR tables from https://www.physics.otago.ac.nz/reports/electronics/ETR2012-1.pdf
  -- n=28; LFSR 2: 28, 25; LFSR 4: 28, 27, 24, 22;

  -- Better randomness can be achieved by using a bigger LFSR and taking the lower bits.

  process (clk)
    variable lfsr_i : STD_LOGIC_VECTOR(27 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        lfsr <= lfsr_init;
      else
        lfsr_i := lfsr;
        G1 : for i in 0 to 22 loop
          --                               27 and 24 here correspond to the taps in the LFSR
          --                               from the powers 28 and 25.
          lfsr_i := lfsr_i(26 downto 0) & (lfsr_i(27) xor lfsr_i(24));
          rnd_man(i) <= lfsr_i(0);
        end loop G1;
        lfsr <= lfsr_i;
      end if;
    end if;
  end process;

  -- Convert the LFSR output to a floating-point number
  -- Subtracting 1 to ensure the result is in the range (0, 1],
  -- this should get minimized away to very little extra logic.
  --                       sign +  exponent  + mantissa
  rnd <= (my_float("0" & "01111111" & rnd_man) - ONE);

end architecture;
