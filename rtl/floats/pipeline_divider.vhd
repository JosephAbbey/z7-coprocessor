library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.float_pkg.all;

entity pipeline_divider is
  generic (
    pipeline_depth : INTEGER := 4 -- Number of pipeline stages
  );
  port (
    clk  : in  STD_LOGIC;
    rst  : in  STD_LOGIC;
    a, b : in  my_float;
    q    : out my_float
  );
end entity;

architecture rtl of pipeline_divider is

  type stage_rec is record
    skip  : STD_LOGIC; -- used to skip stages for zero, infinity, NaN
    sign  : STD_LOGIC;
    exp   : UNSIGNED(7 downto 0);
    rema  : UNSIGNED(24 downto 0);
    divi  : UNSIGNED(24 downto 0);
    mfull : STD_LOGIC_VECTOR(23 downto 0);
  end record;

  type stage_array is array (0 to pipeline_depth - 1) of stage_rec;
  signal pipeline          : stage_array;

  function init_stage(a, b : my_float) return stage_rec is
    variable r               : stage_rec;

    variable a_sign          : STD_LOGIC                     := a(31);
    variable a_exp           : STD_LOGIC_VECTOR(7 downto 0)  := a(30 downto 23);
    variable a_man           : STD_LOGIC_VECTOR(22 downto 0) := a(22 downto 0);
    variable b_sign          : STD_LOGIC                     := b(31);
    variable b_exp           : STD_LOGIC_VECTOR(7 downto 0)  := b(30 downto 23);
    variable b_man           : STD_LOGIC_VECTOR(22 downto 0) := b(22 downto 0);
  begin
    -- Division by zero, return NaN
    if b(30 downto 0) = fill('0', 31) then
      r.skip  := '1';
      r.sign  := a_sign xor b_sign;
      r.exp   := UNSIGNED(fill('1', 8)); -- NaN
      r.mfull := fill('0', 24);
    end if;
    -- Handle zero
    if a(30 downto 0) = fill('0', 31) then
      r.skip  := '1';
      r.sign  := a_sign xor b_sign;
      r.exp   := (others => '0');
      r.mfull := fill('0', 24);
      return r;
    end if;

    -- Handle +-infinity and +-NaN
    if a_exp = fill('1', 8) then
      r.skip  := '1';
      r.sign  := a_sign xor b_sign;
      r.exp   := UNSIGNED(fill('1', 8));
      r.mfull := '1' & a_man;
      return r;
    end if;
    if b_exp = fill('1', 8) then
      if b_man /= fill('0', 23) then
        -- Division by NaN, return NaN
        r.skip  := '1';
        r.sign  := a_sign xor b_sign;
        r.exp   := UNSIGNED(fill('1', 8)); -- NaN
        r.mfull := '1' & b_man;
        return r;
      else
        -- Division by infinity, return zero
        r.skip  := '1';
        r.sign  := a_sign xor b_sign;
        r.exp   := UNSIGNED(fill('0', 8));
        r.mfull := fill('0', 24);
        return r;
      end if;
    end if;

    -- Normal case: initialize stage record
    r.skip  := '0';
    r.sign  := a_sign xor b_sign;
    r.exp   := UNSIGNED(a_exp) - UNSIGNED(b_exp) + "01111111";
    r.rema  := UNSIGNED('1' & a_man & '0');
    r.divi  := UNSIGNED('1' & b_man & '0');
    r.mfull := (others => '0');
    return r;
  end function;

  function do(s : stage_rec; hi, lo : INTEGER)
    return stage_rec is
    variable t : stage_rec := s;
  begin
    if t.skip = '1' then
      return t; -- skip processing if already marked to skip
    end if;
    for i in hi downto lo loop
      if t.rema >= t.divi then
        t.mfull(i) := '1';
        t.rema     := t.rema - t.divi;
      end if;
      t.divi := '0' & t.divi(24 downto 1);
    end loop;
    return t;
  end function;

  function pack(s : stage_rec) return my_float is
  begin
    if s.skip = '1' then
      return s.sign & STD_LOGIC_VECTOR(s.exp) & s.mfull(22 downto 0);
    end if;

    if s.mfull(23) = '1' then
      -- Simple case where the output is already normalised
      return s.sign & STD_LOGIC_VECTOR(s.exp) & s.mfull(22 downto 0);
    else
      -- If the output requires a lower exponent to be normalised
      for I in 22 downto 0 loop
        if s.mfull(I) = '1' then
          return s.sign
          & STD_LOGIC_VECTOR(s.exp - (23 - I))
          & s.mfull((I - 1) downto 0) & fill('0', 23 - I);
        end if;
      end loop;
      -- If overflow mantissa does not contain a '1', output 0
      return (others => '0');
    end if;
  end function;

begin

  -- pipeline registers
  process (clk) is
    variable p0 : stage_rec;
  begin
    if rst = '1' then
      for i in 0 to pipeline_depth - 1 loop
        pipeline(0) <= (
          skip  => '0',
          sign  => '0',
          exp   => (others => '0'),
          rema  => (others => '0'),
          divi  => (others => '0'),
          mfull => (others => '0')
          );
      end loop;
      q <= (others => '0');
    elsif rising_edge(clk) then
      p0 := init_stage(a, b);
      pipeline(0) <=
                    do(
                    p0,
                    24 / pipeline_depth * (pipeline_depth) - 1,
                    24 / pipeline_depth * (pipeline_depth - 1)
                    );
      for i in 1 to pipeline_depth - 1 loop
        pipeline(i) <=
                      do(
                      pipeline(i - 1),
                      24 / pipeline_depth * (pipeline_depth - i) - 1,
                      24 / pipeline_depth * (pipeline_depth - i - 1)
                      );
      end loop;
      q <= pack(pipeline(pipeline_depth - 1));
    end if;
  end process;

end architecture;
