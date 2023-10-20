
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity instruction_fetch_and_memory_access_and_crypto_tb is

end instruction_fetch_and_memory_access_and_crypto_tb;

architecture Behavioral of instruction_fetch_and_memory_access_and_crypto_tb is

  component instruction_fetch_and_memory_access_and_crypto is
  Port (
    clk, clk2, rst, enable_reading_instructions :in std_logic;
    op_code : in std_logic_vector (2 downto 0);
    store_or_read_address, program_counter :in STD_LOGIC_VECTOR(7 downto 0); 
    compiler_input, instruction_or_data_to_be_written:STD_LOGIC_VECTOR (127 downto 0) ;
    compiler_store_address:STD_LOGIC_VECTOR (7 downto 0);
    
    write_enable_in_registers: out std_logic_vector(1 downto 0);
    instruction_output, loaded_data : out STD_LOGIC_VECTOR (127 downto 0);
    next_program_counter: out STD_LOGIC_VECTOR (7 downto 0)   
    );
end component;

signal clk,clk2, rst, enable_reading_instructions : std_logic;
signal write_enable_in_registers: std_logic_vector(1 downto 0);
signal op_code :std_logic_vector (2 downto 0);
signal store_or_read_address, program_counter, compiler_store_address, next_program_counter : STD_LOGIC_VECTOR(7 downto 0); 
signal compiler_input, instruction_or_data_to_be_written, instruction_output, loaded_data :STD_LOGIC_VECTOR (127 downto 0);
constant clk_period : time := 60 ns;

begin

  uut: instruction_fetch_and_memory_access_and_crypto port map (
   rst=>rst,
   clk=>clk,
   clk2=>clk2,
   enable_reading_instructions=>enable_reading_instructions,
   program_counter=> program_counter,
   op_code=>op_code,
   store_or_read_address=>store_or_read_address,
   instruction_or_data_to_be_written=>instruction_or_data_to_be_written,
   compiler_input=>compiler_input,
   compiler_store_address=>compiler_store_address,
   write_enable_in_registers=>write_enable_in_registers,
   loaded_data=>loaded_data,
   instruction_output=> instruction_output,
   next_program_counter=> next_program_counter
   );

  clk_stimulus: process 
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;
  
  clk2_stimulus: process 
  begin
    clk2 <= '0';
    wait for clk_period/100;
    clk2 <= '1';
    wait for clk_period/100;
  end process;
  
  logic_stimulation: process
  begin 
    rst<='1';
    compiler_input<=x"00000000000000000000000000000000";
    enable_reading_instructions<='0';
    compiler_store_address<="00000000";
    program_counter<="00000000";
    op_code<="100";
    store_or_read_address<="00000000";
    instruction_or_data_to_be_written<=x"00000000000000000000000000000111";
    wait for clk_period/2;
    rst<='0';

    wait for clk_period;
    compiler_input<=x"00000000000000000000000000000011";

    wait for clk_period;
    enable_reading_instructions<='1';
    compiler_input<=x"00000000000000000000000000000000";

    wait for clk_period;
    op_code<="101";

    wait;

  end process;        

end Behavioral;
