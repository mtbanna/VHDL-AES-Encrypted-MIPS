library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_fetch_and_memory_access_tb is

end instruction_fetch_and_memory_access_tb;

architecture simulation of instruction_fetch_and_memory_access_tb is

    component instruction_fetch_and_memory_access is
    Port ( rst : in std_logic;
     enable_reading_instructions: in STD_LOGIC; 
     program_counter : in STD_LOGIC_VECTOR (7 downto 0); 
     op_code : in STD_LOGIC_Vector(2 downto 0);                       
     store_or_read_address, compiler_store_address :in STD_LOGIC_VECTOR(7 downto 0);
     instruction_or_data_to_be_written, compiler_input : in STD_LOGIC_VECTOR (127 downto 0);
     write_enable_in_registers : out STD_LOGIC_Vector(1 downto 0);
     loaded_data: out STD_LOGIC_VECTOR(127 downto 0);
     instruction_output : out STD_LOGIC_VECTOR (127 downto 0);
     next_program_counter: out STD_LOGIC_VECTOR (7 downto 0));
end component;

signal rst_test, enable_reading_instructions_test : std_logic;
signal write_enable_in_registers_test : STD_LOGIC_Vector(1 downto 0);
signal program_counter_test, next_program_counter_test, store_or_read_address_test, compiler_store_address_test : std_logic_vector(7 downto 0);
signal op_code_test : std_logic_vector(2 downto 0);
signal loaded_data_test,instruction_or_data_to_be_written_test, instruction_output_test, compiler_input_test: std_logic_vector(127 downto 0);

begin

    instruction_fetch_and_memory_access_test: instruction_fetch_and_memory_access port map(compiler_store_address=>compiler_store_address_test, compiler_input=>compiler_input_test, rst=>rst_test, enable_reading_instructions=> enable_reading_instructions_test, program_counter=>program_counter_test, op_code=>op_code_test, store_or_read_address=>store_or_read_address_test, instruction_or_data_to_be_written=>instruction_or_data_to_be_written_test, write_enable_in_registers=> write_enable_in_registers_test,loaded_data=>loaded_data_test, instruction_output=>instruction_output_test, next_program_counter=> next_program_counter_test);

    logic_stimulation: process
    begin
        rst_test<='1';
        wait for 200ns;
        rst_test<='0';

        compiler_input_test<=x"11111111111111111111111111100000";
        compiler_store_address_test<=x"02";
        enable_reading_instructions_test<='0';
        program_counter_test<=x"02";
        op_code_test<="101";
        store_or_read_address_test<=x"02"; 
        instruction_or_data_to_be_written_test<=x"11111111111111111111111111111110";
        wait for 200ns;


        enable_reading_instructions_test<='1';
        program_counter_test<=x"02";
        op_code_test<="101";
        store_or_read_address_test<=x"02"; 
        instruction_or_data_to_be_written_test<=x"10000000000000000000000000000000";
        wait for 200ns;


        enable_reading_instructions_test<='1';
        program_counter_test<=x"02";
        op_code_test<="000";
        store_or_read_address_test<=x"02"; 
        instruction_or_data_to_be_written_test<=x"00000000000000000000000000000001";
        wait;

    end process;
end simulation;