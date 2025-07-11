-- ---------------------------------------------------------------------------------
--  Distributed under MIT Licence
--    See https://github.com/josephabbey/z7-coprocessor/blob/main/LICENCE.
-- ---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package float_pkg is

  subtype my_float is STD_LOGIC_VECTOR(31 downto 0);

  function "+" (a, b  : my_float) return my_float;
  function "-" (a     : my_float) return my_float;
  function "-" (a, b  : my_float) return my_float;

  function "*" (a, b  : my_float) return my_float;
  function "/" (a, b  : my_float) return my_float;

  constant ZERO       : my_float := (others => '0');
  constant ONE        : my_float := "00111111100000000000000000000000"; -- 1.0 in IEEE 754 format
  constant HALF       : my_float := "00111111000000000000000000000000";

  constant NaN        : my_float := "01111111111111111111111111111111"; -- Not a Number (NaN)
  constant INF        : my_float := "00000000000000000000000011111111"; -- Infinity
  constant NEG_INF    : my_float := "10000000000000000000000011111111"; -- Negative Infinity
  constant MIN_NORMAL : my_float := "00000000000000000000000000000001"; -- Smallest normal number (2^-126)

  function fill(val   : STD_LOGIC; len : INTEGER) return STD_LOGIC_VECTOR;

end package float_pkg;

-- f32 = seeeeeeeemmmmmmmmmmmmmmmmmmmmmmm (1 sign bit, 8 exponent bits, 23 mantissa bits)
-- ieee754 single precision floating point format

-- normalisation:
--   1. The exponent is stored with a bias of 127.
--   2. The mantissa is stored without the leading 1, which is assumed to be there.
-- special cases:
--   1. Zero: 0 00000000 00000000000000000000000
--   2. Infinity: 0 11111111 00000000000000000000000
--   3. NaN: 0 11111111 10000000000000000000000 (or any other mantissa with exponent all ones)

package body float_pkg is

  function fill(val : STD_LOGIC; len : INTEGER) return STD_LOGIC_VECTOR is
    variable result   : STD_LOGIC_VECTOR(len - 1 downto 0) := (others => val);
  begin
    return result;
  end function;

  -- Decode inputs:
  -- variable a_sign       : STD_LOGIC                     := a(31);
  -- variable a_exp        : STD_LOGIC_VECTOR(7 downto 0)  := a(30 downto 23);
  -- variable a_man        : STD_LOGIC_VECTOR(22 downto 0) := a(22 downto 0);
  -- variable b_sign       : STD_LOGIC                     := b(31);
  -- variable b_exp        : STD_LOGIC_VECTOR(7 downto 0)  := b(30 downto 23);
  -- variable b_man        : STD_LOGIC_VECTOR(22 downto 0) := b(22 downto 0);

  --#region "Addition and Subtraction (my own design and implementation)"

  function safe_add(a, b : my_float) return my_float is
    variable a_sign        : STD_LOGIC                     := a(31);
    variable a_exp         : STD_LOGIC_VECTOR(7 downto 0)  := a(30 downto 23);
    variable a_man         : STD_LOGIC_VECTOR(22 downto 0) := a(22 downto 0);
    variable b_sign        : STD_LOGIC                     := b(31);
    variable b_exp         : STD_LOGIC_VECTOR(7 downto 0)  := b(30 downto 23);
    variable b_man         : STD_LOGIC_VECTOR(22 downto 0) := b(22 downto 0);
    variable exp_diff      : UNSIGNED(7 downto 0)          := UNSIGNED(a_exp) - UNSIGNED(b_exp);

    variable a_man_1       : UNSIGNED(23 downto 0);
    variable b_man_1       : UNSIGNED(23 downto 0);

    variable signed_man    : SIGNED(25 downto 0);

    variable overflow_man  : STD_LOGIC_VECTOR(24 downto 0);

    variable sign          : STD_LOGIC;
  begin

    -- Underflow:
    --   If the exponent has minimum value (all zero), special rules for denormalized values are followed.
    --   The exponent value is set to 2-126 and the "invisible" leading bit for the mantissa is no longer used.
    if a_exp = fill('0', 8) then
      a_man_1 := UNSIGNED('0' & a_man);
      a_exp   := "00000001"; -- Set exponent to 2-126
    else
      a_man_1 := UNSIGNED('1' & a_man);
    end if;
    if b_exp = fill('0', 8) then
      b_man_1 := UNSIGNED('0' & b_man);
      b_exp   := "00000001"; -- Set exponent to 2-126
    else
      b_man_1 := UNSIGNED('1' & b_man);
    end if;

    if a_sign = b_sign then
      -- Simple addition case and maintain the sign
      sign := a_sign;
      if exp_diff = 0 then
        overflow_man := STD_LOGIC_VECTOR(('0' & b_man_1) + ('0' & a_man_1));
      else
        -- Shift the mantissa so that both a and b have the same exponent
        overflow_man := STD_LOGIC_VECTOR(('0' & shift_right(b_man_1, TO_INTEGER(exp_diff))) + ('0' & a_man_1));
      end if;
    elsif a_sign = '1' then
      if exp_diff = 0 then
        signed_man := SIGNED("00" & b_man_1) - SIGNED("00" & a_man_1);
        -- Convert twos compliment into sign and magnitude
        if signed_man(25) = '1' then
          sign         := '1';
          overflow_man := STD_LOGIC_VECTOR(not(UNSIGNED(signed_man(24 downto 0))) + 1);
        else
          sign         := '0';
          overflow_man := STD_LOGIC_VECTOR(signed_man(24 downto 0));
        end if;
      else
        -- Shift the mantissa so that both a and b have the same exponent
        signed_man := SIGNED("00" & shift_right(b_man_1, TO_INTEGER(exp_diff))) - SIGNED("00" & a_man_1);
        -- Convert twos compliment into sign and magnitude
        if signed_man(25) = '1' then
          sign         := '1';
          overflow_man := STD_LOGIC_VECTOR(not(UNSIGNED(signed_man(24 downto 0))) + 1);
        else
          sign         := '0';
          overflow_man := STD_LOGIC_VECTOR(signed_man(24 downto 0));
        end if;
      end if;
    else
      if exp_diff = 0 then
        signed_man := SIGNED("00" & a_man_1) - SIGNED("00" & b_man_1);
        -- Convert twos compliment into sign and magnitude
        if signed_man(25) = '1' then
          sign         := '1';
          overflow_man := STD_LOGIC_VECTOR(not(UNSIGNED(signed_man(24 downto 0))) + 1);
        else
          sign         := '0';
          overflow_man := STD_LOGIC_VECTOR(signed_man(24 downto 0));
        end if;
      else
        -- Convert twos compliment into sign and magnitude
        signed_man := SIGNED("00" & a_man_1) - SIGNED("00" & shift_right(b_man_1, TO_INTEGER(exp_diff)));
        -- Convert twos compliment into sign and magnitude
        if signed_man(25) = '1' then
          sign         := '1';
          overflow_man := STD_LOGIC_VECTOR(not(UNSIGNED(signed_man(24 downto 0))) + 1);
        else
          sign         := '0';
          overflow_man := STD_LOGIC_VECTOR(signed_man(24 downto 0));
        end if;
      end if;
    end if;

    if overflow_man(24) = '1' then
      -- If the output requires a higher exponent to be normalised
      return sign & STD_LOGIC_VECTOR(UNSIGNED(a_exp) + 1) & overflow_man(23 downto 1);
    elsif overflow_man(23) = '0' then
      -- If the output requires a lower exponent to be normalised
      for I in 22 downto 0 loop
        if overflow_man(I) = '1' then
          return sign
          & STD_LOGIC_VECTOR(UNSIGNED(a_exp) - (23 - I))
          & overflow_man((I - 1) downto 0) & fill('0', 23 - I);
        end if;
      end loop;
      -- If overflow mantissa does not contain a '1', output 0
      return (others => '0');
    else
      -- Simple case where the output is already normalised
      return my_float(sign & a_exp & overflow_man(22 downto 0)); -- for some reason xsim does not like the return type, thus the cast
    end if;
  end function safe_add;

  function "+" (a, b : my_float) return my_float is
    variable a_exp     : STD_LOGIC_VECTOR(7 downto 0) := a(30 downto 23);
    variable b_exp     : STD_LOGIC_VECTOR(7 downto 0) := b(30 downto 23);
  begin

    -- Handle +-infinity and +-NaN
    if a_exp = fill('1', 8) then
      return a;
    end if;
    if b_exp = fill('1', 8) then
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

  --#endregion

  --#region "Multiplication (my own design and implementation)"

  function "*" (a, b : my_float) return my_float is
    variable a_sign    : STD_LOGIC                     := a(31);
    variable a_exp     : STD_LOGIC_VECTOR(7 downto 0)  := a(30 downto 23);
    variable a_man     : STD_LOGIC_VECTOR(22 downto 0) := a(22 downto 0);
    variable b_sign    : STD_LOGIC                     := b(31);
    variable b_exp     : STD_LOGIC_VECTOR(7 downto 0)  := b(30 downto 23);
    variable b_man     : STD_LOGIC_VECTOR(22 downto 0) := b(22 downto 0);

    -- 1 bit for overflow (1 <= x,y < 2 so 1 <= x * y < 4), leading 1 is implicit, 24 bits for the mantissa
    variable man_sum   : UNSIGNED(24 downto 0)         := UNSIGNED("01" & a_man);

    variable sign      : STD_LOGIC                     := a_sign xor b_sign;
    variable man       : STD_LOGIC_VECTOR(22 downto 0);
    variable exp       : UNSIGNED(7 downto 0) := UNSIGNED(a_exp) + UNSIGNED(b_exp) - "01111111"; -- Subtract the bias of 127
  begin

    -- TODO: denormalized numbers

    -- Handle zero
    if a(30 downto 0) = fill('0', 31) or a(30 downto 0) = fill('0', 31) then
      return fill('0', 32);
    end if;

    -- Handle +-infinity and +-NaN
    if a_exp = fill('1', 8) then
      return sign & a(30 downto 0);
    end if;
    if b_exp = fill('1', 8) then
      return my_float(sign & b(30 downto 0)); -- for some reason xsim does not like the return type, thus the cast
    end if;

    -- (a1 * 2^a2) * (b1 * 2^b2) = (a1 * b1) * 2^(a2 + b2) = (a1 * b1) * 2^(a2 + b2)

    -- a1 * b1 is the sum of a1 bit shifted to all of the bits in b1 that are 1

    -- Long multiplication of the mantissa
    -- We start with the leading 1 in the variable already.
    G1 : for I in 0 to 22 loop
      if b_man(22 - I) = '1' then
        man_sum := man_sum + UNSIGNED(fill('0', I + 1) & '1' & a_man(22 downto I + 1));
      else
        man_sum := man_sum;
      end if;
    end loop;

    -- Handle overflow
    if man_sum(24) = '1' then
      -- If the mantissa overflows, shift it right and increment the exponent
      -- we check for the leading 1, so we can safely take the 23 bits and omit the leading 1
      man := STD_LOGIC_VECTOR(man_sum(23 downto 1));
      exp := exp + 1;
    else
      -- If the mantissa does not overflow, just take the lower
      -- there will always be a leading 1, so we can safely take the lower 23 bits
      man := STD_LOGIC_VECTOR(man_sum(22 downto 0));
    end if;

    return my_float(sign & STD_LOGIC_VECTOR(exp) & man); -- for some reason xsim does not like the return type, thus the cast

  end function "*";

  --#endregion

  --#region "Division (my own design and implementation)"

  function "/" (a, b  : my_float) return my_float is
    variable a_sign     : STD_LOGIC                     := a(31);
    variable a_exp      : STD_LOGIC_VECTOR(7 downto 0)  := a(30 downto 23);
    variable a_man      : STD_LOGIC_VECTOR(22 downto 0) := a(22 downto 0);
    variable b_sign     : STD_LOGIC                     := b(31);
    variable b_exp      : STD_LOGIC_VECTOR(7 downto 0)  := b(30 downto 23);
    variable b_man      : STD_LOGIC_VECTOR(22 downto 0) := b(22 downto 0);

    -- TODO: denormalized numbers
    -- Add the leading 1 for normalised numbers
    variable a_man_full : UNSIGNED(23 downto 0)         := UNSIGNED('1' & a_man);
    variable b_man_full : UNSIGNED(23 downto 0)         := UNSIGNED('1' & b_man);

    variable remainder  : UNSIGNED(24 downto 0)         := UNSIGNED(a_man_full & '0'); -- leading 1 + mantissa + 1 bit for underflow
    variable divisor    : UNSIGNED(24 downto 0)         := UNSIGNED(b_man_full & '0');

    variable man_full   : STD_LOGIC_VECTOR(23 downto 0) := (others => '0'); -- Result mantissa, 24 bits to hold the leading 1 and 23 bits of the mantissa

    variable sign       : STD_LOGIC                     := a_sign xor b_sign;
    variable man        : STD_LOGIC_VECTOR(22 downto 0);
    variable exp        : UNSIGNED(7 downto 0) := UNSIGNED(a_exp) - UNSIGNED(b_exp) + "01111111"; -- Add back the bias of 127
  begin

    -- Division by zero, return NaN
    if b(30 downto 0) = fill('0', 31) then
      return sign & fill('1', 8) & fill('0', 23);
    end if;
    -- Handle zero
    if a(30 downto 0) = fill('0', 31) then
      return ZERO;
    end if;

    -- Handle +-infinity and +-NaN
    if a_exp = fill('1', 8) then
      return sign & a(30 downto 0);
    end if;
    if b_exp = fill('1', 8) then
      if b_man /= fill('0', 23) then
        -- Division by NaN, return NaN
        return sign & b(30 downto 0);
      else
        -- Division by infinity, return zero
        return sign & fill('0', 31);
      end if;
    end if;

    -- (a1 * 2^a2) / (b1 * 2^b2) = (a1 / b1) * 2^(a2 - b2)

    -- Binary long division: a1 / b1
    for I in 23 downto 0 loop
      if remainder > divisor then
        man_full(I) := '1';
        remainder   := remainder - divisor;
      else
        man_full(I) := '0';
        remainder   := remainder;
      end if;
      divisor := '0' & divisor(24 downto 1); -- Shift right
    end loop;

    if man_full(23) = '1' then
      -- Simple case where the output is already normalised
      return sign & STD_LOGIC_VECTOR(exp) & man_full(22 downto 0);
    else
      -- If the output requires a lower exponent to be normalised
      for I in 22 downto 0 loop
        if man_full(I) = '1' then
          return sign
          & STD_LOGIC_VECTOR(exp - (23 - I))
          & man_full((I - 1) downto 0) & fill('0', 23 - I);
        end if;
      end loop;
      -- If overflow mantissa does not contain a '1', output 0
      return (others => '0');
    end if;

  end function "/";

  -- Alternative way to divide that minimises to slightly better than the original
  -- function reciprocal(a : my_float) return my_float is
  -- begin
  --   return full_divide(ONE, a);
  -- end function reciprocal;
  -- function "/" (a, b : my_float) return my_float is
  -- begin
  --   return a * reciprocal(b);
  -- end function "/";

  --#endregion

end package body float_pkg;
