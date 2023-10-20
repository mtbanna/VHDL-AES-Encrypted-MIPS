library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity pipeline_tb is
end;

architecture bench of pipeline_tb is

  component pipeline
      port (
          clk : in std_logic;
          rst : in std_logic;
          store_or_read_address :in std_logic_vector(7 downto 0);
          instruction_or_data_to_be_written : in std_logic_vector (127 downto 0);
          enable_reading_instructions : in std_logic;
          r_w: in std_logic;
          data_out : out std_logic_vector(127 downto 0)
      );
  end component;

  signal clk: std_logic;
  signal rst: std_logic;
  signal store_or_read_address: std_logic_vector(7 downto 0);
  signal instruction_or_data_to_be_written: std_logic_vector (127 downto 0);
  signal enable_reading_instructions: std_logic;
  signal r_w: std_logic;
  signal data_out: std_logic_vector(127 downto 0) ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: pipeline port map ( clk                               => clk,
                           rst                               => rst,
                           store_or_read_address             => store_or_read_address,
                           instruction_or_data_to_be_written => instruction_or_data_to_be_written,
                           enable_reading_instructions       => enable_reading_instructions,
                           r_w                               => r_w,
                           data_out                          => data_out );

  stimulus: process
  begin
  
    -- Put initialisation code here
    enable_reading_instructions <= '0'; r_w <= '1';
    rst <= '1';
    wait for 5 ns;
    rst <= '0';
    wait for 5 ns;

    -- Put test bench stimulus code here
    store_or_read_address <= x"00"; instruction_or_data_to_be_written <= x"53edea10241aea2d54ae7a91240001e7";
    wait for 5 ns; -- ADD R1, R0, 5 (R1 = 5)


--    store_or_read_address <= x"04"; instruction_or_data_to_be_written <= x"53edea10241aea2d54ae7a91240001e7";
--    wait for 5 ns; -- SUB R2, R1, 6 (R2 = -1 = 0x1F)
--    store_or_read_address <= x"08"; instruction_or_data_to_be_written <= x"53edea10241aea2d54ae7a91240001e7";
--    wait for 5 ns; -- SW R1, 29, R2 (store 5 in address 0x3c)
--    store_or_read_address <= x"0c"; instruction_or_data_to_be_written <= x"53edea10241aea2d54ae7a91240001e7";
--    wait for 5 ns; -- LW R3, R2, 4  (R3 = data in address 0x24 = 0xa95cd4f1)
--    store_or_read_address <= x"10"; instruction_or_data_to_be_written <= x"53edea10241aea2d54ae7a91240001e7";
--    wait for 5 ns; -- ADD R4, R3, R1 (R4 = 0xa95cd4f6)
--    store_or_read_address <= x"14"; instruction_or_data_to_be_written <= x"53edea10241aea2d54ae7a91240001e7";
--    wait for 5 ns; -- SW R4, 28, R0 (address 1c = 0xa95cd4f6)
--    store_or_read_address <= x"24"; instruction_or_data_to_be_written <= x"53edea10241aea2d54ae7a91240001e7";
--    wait for 5 ns; -- 0xa95cd4f1

    enable_reading_instructions <= '1';
    wait for 1 us; 

    stop_the_clock <= true;

    r_w <= '0'; enable_reading_instructions <= '0';
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