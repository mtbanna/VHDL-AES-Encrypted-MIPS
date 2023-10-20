library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity mips_controller_tb is
end;

architecture bench of mips_controller_tb is

  component mips_controller
      port (
          clk : in std_logic;
          rst : in std_logic;
          branch_taken : in std_logic;
          instruction : in std_logic_vector(31 downto 0);
          stall : out std_logic;
          forwarding_flags : out std_logic_vector(2 downto 0) 
      );
  end component;

  signal clk: std_logic;
  signal rst: std_logic;
  signal branch_taken: std_logic;
  signal instruction: std_logic_vector(31 downto 0);
  signal stall: std_logic;
  signal forwarding_flags: std_logic_vector(2 downto 0) ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: mips_controller port map ( clk              => clk,
                             rst              => rst,
                             branch_taken     => branch_taken,
                             instruction      => instruction,
                             stall            => stall,
                             forwarding_flags => forwarding_flags );

  stimulus: process
  begin
  
    -- Put initialisation code here
    branch_taken <= '0';
    instruction <= x"00000000";
    rst <= '1';
    wait for 5 ns;
    rst <= '0';
    wait for 5 ns;

    -- Put test bench stimulus code here
    --instruction <= x"00080433"; wait for clock_period; -- ADD R1, R2, R3
    --instruction <= x"00080823"; wait for clock_period; -- ADD R2, R1, R3
    instruction <= x"000404A2"; wait for clock_period; -- LW  R1, 5, R2
    instruction <= x"00080823"; wait for clock_period; -- ADD R2, R1, R3
    wait for clock_period*2;
    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;