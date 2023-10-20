
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_fetch_and_memory_access is
    Port ( 
           rst, enable_reading_instructions, take_forwarded_data : in std_logic; 
           program_counter : in STD_LOGIC_VECTOR (7 downto 0); 
           op_code : in STD_LOGIC_Vector(3 downto 0);                       
           store_or_read_address, compiler_store_address :in STD_LOGIC_VECTOR(7 downto 0);
           instruction_or_data_to_be_written, compiler_input, forwarded_data : in STD_LOGIC_VECTOR (127 downto 0);

           write_enable_in_registers : out STD_LOGIC_Vector(1 downto 0);
           loaded_data: out STD_LOGIC_VECTOR(127 downto 0);
           instruction_output : out STD_LOGIC_VECTOR (127 downto 0);
           next_program_counter: out STD_LOGIC_VECTOR (7 downto 0));
end instruction_fetch_and_memory_access;

architecture Behavioral of instruction_fetch_and_memory_access is

component memory is
   Port (  rst : in std_logic; 
           enable_reading_instructions, take_forwarded_data: in STD_LOGIC;       --enable_reading_instructions>>set to '1' to read instructions__ take_forwarded_data>> set to 1 to take forwarded data from mem
           program_counter : in STD_LOGIC_VECTOR (7 downto 0); --specifies which instruction to be read
           op_code : in STD_LOGIC_Vector(3 downto 0);           -- (write=101, load=100 else do nothing)
           store_or_read_address, compiler_store_address:in STD_LOGIC_VECTOR(7 downto 0); --address where data/instructions is stored or loaded
           instruction_or_data_to_be_written, compiler_input, forwarded_data : in STD_LOGIC_VECTOR (127 downto 0);

           
           write_enable_in_registers : out STD_LOGIC_Vector(1 downto 0);    -- revisit it in write back stage
           loaded_data: out STD_LOGIC_VECTOR(127 downto 0);
           instruction_output : out STD_LOGIC_VECTOR (127 downto 0));
    end component;
    
begin
my_memory: memory port map(forwarded_data=>forwarded_data, take_forwarded_data=>take_forwarded_data, compiler_store_address=>compiler_store_address, compiler_input=>compiler_input, rst=>rst,enable_reading_instructions=> enable_reading_instructions, program_counter=>program_counter, op_code=>op_code, store_or_read_address=>store_or_read_address, instruction_or_data_to_be_written=>instruction_or_data_to_be_written, write_enable_in_registers=> write_enable_in_registers,loaded_data=>loaded_data, instruction_output=>instruction_output);    

next_program_counter<= std_logic_vector(unsigned(program_counter) + 4) when (enable_reading_instructions='1' and rst='0')  else 
                       (others=>'0');

end Behavioral;
