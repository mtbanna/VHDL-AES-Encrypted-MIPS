library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity clk_divide_tb is
end;

architecture bench of clk_divide_tb is

  component clk_divide
      port (
          clk : in std_logic;
          rst : in std_logic;
          clk_divider: in std_logic_vector(3 downto 0);
          clk_div: out std_logic
      );
  end component;

  signal clk: std_logic;
  signal rst: std_logic;
  signal clk_divider: std_logic_vector(3 downto 0);
  signal clk_div: std_logic ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean := false;

begin

  uut: clk_divide port map ( clk         => clk,
                             rst         => rst,
                             clk_divider => clk_divider,
                             clk_div     => clk_div );

  stimulus: process
  begin
    clk_divider <= x"A";
    rst <= '1'; wait for clock_period;
    rst <= '0'; wait for 300 ns;
    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
      while (not stop_the_clock) loop
        clk <= '0', '1' after clock_period / 2;
        wait for clock_period;
      end loop;
  end process;

end;