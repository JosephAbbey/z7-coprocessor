-- ---------------------------------------------------------------------------------
--  Distributed under MIT Licence
--    See https://github.com/josephabbey/z7-coprocessor/blob/main/LICENCE.
-- ---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_float_divider is
end test_float_divider;

architecture tb of test_float_divider is

  -- DUT AXI signals
  signal S_AXI_ACLK    : STD_LOGIC                     := '0';
  signal S_AXI_ARESETN : STD_LOGIC                     := '0';
  signal S_AXI_AWADDR  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
  signal S_AXI_AWVALID : STD_LOGIC                     := '0';
  signal S_AXI_AWREADY : STD_LOGIC;
  signal S_AXI_WDATA   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
  signal S_AXI_WVALID  : STD_LOGIC                     := '0';
  signal S_AXI_WREADY  : STD_LOGIC;
  signal S_AXI_BRESP   : STD_LOGIC_VECTOR(1 downto 0);
  signal S_AXI_BVALID  : STD_LOGIC;
  signal S_AXI_BREADY  : STD_LOGIC                     := '0';
  signal S_AXI_ARADDR  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
  signal S_AXI_ARVALID : STD_LOGIC                     := '0';
  signal S_AXI_ARREADY : STD_LOGIC;
  signal S_AXI_RDATA   : STD_LOGIC_VECTOR(31 downto 0);
  signal S_AXI_RRESP   : STD_LOGIC_VECTOR(1 downto 0);
  signal S_AXI_RVALID  : STD_LOGIC;
  signal S_AXI_RREADY  : STD_LOGIC := '0';

  constant CLK_PERIOD  : TIME      := 10 ns;

begin

  -- Clock generation
  clk_gen : process
  begin
    S_AXI_ACLK <= '0';
    wait for CLK_PERIOD/2;
    S_AXI_ACLK <= '1';
    wait for CLK_PERIOD/2;
  end process;

  -- Clock generation
  rst_gen : process
  begin
    S_AXI_ARESETN <= '0';
    wait for CLK_PERIOD * 2;
    S_AXI_ARESETN <= '1';
    wait;
  end process;

  -- DUT instantiation
  dut : entity work.float_divider(arch_imp)
    port map(
      S_AXI_ACLK    => S_AXI_ACLK,
      S_AXI_ARESETN => S_AXI_ARESETN,
      S_AXI_AWADDR  => S_AXI_AWADDR,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_WDATA   => S_AXI_WDATA,
      S_AXI_WVALID  => S_AXI_WVALID,
      S_AXI_WREADY  => S_AXI_WREADY,
      S_AXI_BRESP   => S_AXI_BRESP,
      S_AXI_BVALID  => S_AXI_BVALID,
      S_AXI_BREADY  => S_AXI_BREADY,
      S_AXI_ARADDR  => S_AXI_ARADDR,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_RDATA   => S_AXI_RDATA,
      S_AXI_RRESP   => S_AXI_RRESP,
      S_AXI_RVALID  => S_AXI_RVALID,
      S_AXI_RREADY  => S_AXI_RREADY
    );

  stimulus : process
  begin
    wait until S_AXI_ARESETN = '1';

    -- Always ready to accept write response
    S_AXI_BREADY  <= '1';

    -- write reg0 @ addr 0 := 1.0 (0x3F800000)
    S_AXI_AWADDR  <= x"00000000";
    S_AXI_AWVALID <= '1';
    S_AXI_WDATA   <= x"3F800000";
    S_AXI_WVALID  <= '1';
    wait until S_AXI_AWREADY = '1' and S_AXI_WREADY = '1';
    wait until S_AXI_BVALID = '1';
    S_AXI_AWVALID <= '0';
    S_AXI_WVALID  <= '0';
    wait for CLK_PERIOD;

    -- write reg1 @ addr 4 := 2.0 (0x40000000)
    S_AXI_AWADDR  <= x"00000004";
    S_AXI_AWVALID <= '1';
    S_AXI_WDATA   <= x"40000000";
    S_AXI_WVALID  <= '1';
    wait until S_AXI_AWREADY = '1' and S_AXI_WREADY = '1';
    wait until S_AXI_BVALID = '1';
    S_AXI_AWVALID <= '0';
    S_AXI_WVALID  <= '0';
    wait for CLK_PERIOD;

    -- attempt to read reg2 @ addr 8, ARREADY should stay low for 5 clocks
    S_AXI_ARADDR  <= x"00000008";
    S_AXI_ARVALID <= '1';
    S_AXI_RREADY  <= '1';

    -- for i in 1 to 7 loop
    --   wait until rising_edge(S_AXI_ACLK);
    --   assert S_AXI_ARREADY = '0'
    --   report "ARREADY came high too early!" severity error;
    -- end loop;

    -- now ARREADY must handshake
    wait until S_AXI_ARREADY = '1';
    wait for CLK_PERIOD;
    S_AXI_ARVALID <= '0';

    -- wait for read data
    wait until S_AXI_RVALID = '1';
    assert S_AXI_RDATA = x"3f000000"
    report "Read data from reg2 should be 0x3f000000" severity error;
    -- report "RDATA = " & STD_LOGIC_VECTOR'image(S_AXI_RDATA);
    wait for CLK_PERIOD;
    S_AXI_RREADY <= '0';

    report "TEST COMPLETE" severity note;
    wait;
  end process;

end architecture;
