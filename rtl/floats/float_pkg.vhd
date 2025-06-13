library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package float_pkg is

  subtype my_float is STD_LOGIC_VECTOR(31 downto 0);

  function "+" (a, b : my_float) return my_float;
  function "-" (a    : my_float) return my_float;
  function "-" (a, b : my_float) return my_float;

end package float_pkg;

-- f32 = seeeeeeeemmmmmmmmmmmmmmmmmmmmmmm

package body float_pkg is

  function safe_add(a, b : my_float) return my_float is
    variable a_sign        : STD_LOGIC                     := a(31);
    variable a_exp         : STD_LOGIC_VECTOR(7 downto 0)  := a(30 downto 23);
    variable a_man         : STD_LOGIC_VECTOR(22 downto 0) := a(22 downto 0);
    variable b_sign        : STD_LOGIC                     := b(31);
    variable b_exp         : STD_LOGIC_VECTOR(7 downto 0)  := b(30 downto 23);
    variable b_man         : STD_LOGIC_VECTOR(22 downto 0) := b(22 downto 0);
    variable exp           : UNSIGNED(7 downto 0)          := UNSIGNED(a_exp) - UNSIGNED(b_exp);

    constant zero_exp      : STD_LOGIC_VECTOR(a_exp'range) := (others => '0');
    constant ones_exp      : STD_LOGIC_VECTOR(a_exp'range) := (others => '1');

    variable a_man_1       : UNSIGNED(23 downto 0);
    variable b_man_1       : UNSIGNED(23 downto 0);

    variable signed_man    : SIGNED(25 downto 0);

    variable overflow_man  : STD_LOGIC_VECTOR(24 downto 0);

    variable output_sign   : STD_LOGIC;
  begin

    -- Underflow:
    --   If the exponent has minimum value (all zero), special rules for denormalized values are followed.
    --   The exponent value is set to 2-126 and the "invisible" leading bit for the mantissa is no longer used.
    if a_exp = zero_exp then
      a_man_1 := UNSIGNED('0' & a_man);
    else
      a_man_1 := UNSIGNED('1' & a_man);
    end if;
    if b_exp = zero_exp then
      b_man_1 := UNSIGNED('0' & b_man);
    else
      b_man_1 := UNSIGNED('1' & b_man);
    end if;

    if a_sign = b_sign then
      -- Simple addition case and maintain the sign
      output_sign := a_sign;
      if exp = 0 then
        overflow_man := STD_LOGIC_VECTOR(('0' & b_man_1) + ('0' & a_man_1));
      else
        -- Shift the mantissa so that both a and b have the same exponent
        overflow_man := STD_LOGIC_VECTOR(('0' & shift_right(b_man_1, TO_INTEGER(exp))) + ('0' & a_man_1));
      end if;
    elsif a_sign = '1' then
      if exp = 0 then
        signed_man := SIGNED("00" & b_man_1) - SIGNED("00" & a_man_1);
        -- Convert twos compliment into sign and magnitude
        if signed_man(25) = '1' then
          output_sign  := '1';
          overflow_man := STD_LOGIC_VECTOR(not(UNSIGNED(signed_man(24 downto 0))) + 1);
        else
          output_sign  := '0';
          overflow_man := STD_LOGIC_VECTOR(signed_man(24 downto 0));
        end if;
      else
        -- Shift the mantissa so that both a and b have the same exponent
        signed_man := SIGNED("00" & shift_right(b_man_1, TO_INTEGER(exp))) - SIGNED("00" & a_man_1);
        -- Convert twos compliment into sign and magnitude
        if signed_man(25) = '1' then
          output_sign  := '1';
          overflow_man := STD_LOGIC_VECTOR(not(UNSIGNED(signed_man(24 downto 0))) + 1);
        else
          output_sign  := '0';
          overflow_man := STD_LOGIC_VECTOR(signed_man(24 downto 0));
        end if;
      end if;
    else
      if exp = 0 then
        signed_man := SIGNED("00" & a_man_1) - SIGNED("00" & b_man_1);
        -- Convert twos compliment into sign and magnitude
        if signed_man(25) = '1' then
          output_sign  := '1';
          overflow_man := STD_LOGIC_VECTOR(not(UNSIGNED(signed_man(24 downto 0))) + 1);
        else
          output_sign  := '0';
          overflow_man := STD_LOGIC_VECTOR(signed_man(24 downto 0));
        end if;
      else
        -- Convert twos compliment into sign and magnitude
        signed_man := SIGNED("00" & a_man_1) - SIGNED("00" & shift_right(b_man_1, TO_INTEGER(exp)));
        -- Convert twos compliment into sign and magnitude
        if signed_man(25) = '1' then
          output_sign  := '1';
          overflow_man := STD_LOGIC_VECTOR(not(UNSIGNED(signed_man(24 downto 0))) + 1);
        else
          output_sign  := '0';
          overflow_man := STD_LOGIC_VECTOR(signed_man(24 downto 0));
        end if;
      end if;
    end if;

    -- TODO: Handle 0

    if overflow_man(24) = '1' then
      -- If the output requires a lower exponent to be normalised
      return output_sign & STD_LOGIC_VECTOR(UNSIGNED(a_exp) + 1) & overflow_man(23 downto 1);
    elsif overflow_man(23) = '0' then
      -- If the output requires a higher exponent to be normalised
      for I in 22 downto 0 loop
        if overflow_man(I) = '1' then
          return output_sign
          & STD_LOGIC_VECTOR(UNSIGNED(a_exp) - (23 - I))
          & STD_LOGIC_VECTOR(SHIFT_LEFT(UNSIGNED(overflow_man(22 downto 0)), TO_INTEGER(23 - to_unsigned(I, 4))));
        end if;
      end loop;
      -- If overflow mantissa does not contain a '1', output 0
      return (others => '0');
    else
      -- Simple case where the output is already normalised
      return output_sign & a_exp & overflow_man(22 downto 0);
    end if;
  end function safe_add;

  function "+" (a, b    : my_float) return my_float is
    variable a_sign       : STD_LOGIC                     := a(31);
    variable a_exp        : STD_LOGIC_VECTOR(7 downto 0)  := a(30 downto 23);
    variable a_man        : STD_LOGIC_VECTOR(22 downto 0) := a(22 downto 0);
    variable b_sign       : STD_LOGIC                     := b(31);
    variable b_exp        : STD_LOGIC_VECTOR(7 downto 0)  := b(30 downto 23);
    variable b_man        : STD_LOGIC_VECTOR(22 downto 0) := b(22 downto 0);
    variable exp          : UNSIGNED(7 downto 0)          := UNSIGNED(a_exp) - UNSIGNED(b_exp);

    constant zero_exp     : STD_LOGIC_VECTOR(a_exp'range) := (others => '0');
    constant ones_exp     : STD_LOGIC_VECTOR(a_exp'range) := (others => '1');

    variable a_man_1      : UNSIGNED(23 downto 0);
    variable b_man_1      : UNSIGNED(23 downto 0);

    variable signed_man   : SIGNED(25 downto 0);

    variable overflow_man : STD_LOGIC_VECTOR(24 downto 0);

    variable output_sign  : STD_LOGIC;
  begin

    -- Handle +-infinity and +-NaN
    if a_exp = ones_exp then
      return a;
    end if;
    if b_exp = ones_exp then
      return b;
    end if;

    -- Always use the biggest exponent to prevent losing the most significant data.
    if UNSIGNED(a_exp) < UNSIGNED(b_exp) then
      return safe_add(b, a);
    end if;

    return safe_add(a, b);
  end function "+";

  function "-" (a : my_float) return my_float is
  begin
    return not(a(31)) & a(30 downto 0);
  end function "-";

  function "-" (a, b : my_float) return my_float is
  begin
    return a + (-b);
  end function "-";

end package body float_pkg;
