
-- First of all, we reset the module then set reset to 0,then we write instructions and data in the memory, while disabling reading instructions.
-- After that, we enable reading instructions and the program counter specified which instruction is read ("intruction_output").
-- If write, or read opcodes are given as inputs (memmory access stage), loaded data returns the value stored in "store_or_read_address" (read) (also "write_enable_in_registers" is set to '1')
-- while writing would change the value in "store_or_read_address" (note: hazards are handled in hazards detector)


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory is                 --256 X 32 bit memory 
Port ( 
           rst : in std_logic; 
           enable_reading_instructions, take_forwarded_data: in STD_LOGIC;       --enable_reading_instructions>>set to '1' to read instructions__ take_forwarded_data>> set to 1 to take forwarded data from mem
           program_counter : in STD_LOGIC_VECTOR (7 downto 0); --specifies which instruction to be read
           op_code : in STD_LOGIC_Vector(3 downto 0);           -- (write=101, load=100 else do nothing)
           store_or_read_address, compiler_store_address:in STD_LOGIC_VECTOR(7 downto 0); --address where data/instructions is stored or loaded
           instruction_or_data_to_be_written, compiler_input, forwarded_data : in STD_LOGIC_VECTOR (127 downto 0);

           
           write_enable_in_registers : out STD_LOGIC_Vector(1 downto 0);    -- revisit it in write back stage
           loaded_data: out STD_LOGIC_VECTOR(127 downto 0);
           instruction_output : out STD_LOGIC_VECTOR (127 downto 0));
end memory;

architecture Behavioral of memory is

    type memory_storage is array (255 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
    signal memory_storage_lines: memory_storage;                          

    begin
        instruction_output<= memory_storage_lines(to_integer(unsigned(program_counter))+3)&memory_storage_lines(to_integer(unsigned(program_counter))+2)&memory_storage_lines(to_integer(unsigned(program_counter))+1)&memory_storage_lines(to_integer(unsigned(program_counter))) when ((enable_reading_instructions='1')and (rst='0')) else
       x"2e2b34ca59fa4c883b2c8aefd44be966";
      --  (others=>'0'); 
        
        
        loaded_data<= memory_storage_lines(to_integer(unsigned(store_or_read_address))+3)&memory_storage_lines(to_integer(unsigned(store_or_read_address))+2)&memory_storage_lines(to_integer(unsigned(store_or_read_address))+1)&memory_storage_lines(to_integer(unsigned(store_or_read_address))) when ((op_code="0100")and(rst='0') ) else
        (others=>'0');    

        write_enable_in_registers<= "01" when ((op_code="0100")and(rst='0') and (enable_reading_instructions='1')) else
        "11" when ( (op_code/="0000") and (op_code/="0101") and (op_code/="0110") and (op_code/="0111")  and (rst='0') and (enable_reading_instructions='1')) else   --Handle jump and branch
        "00";
        
        process(rst,instruction_or_data_to_be_written,store_or_read_address,enable_reading_instructions,compiler_store_address,compiler_input)
        begin
            if(rst='1') then
                 for i in 0 to 63 loop
                memory_storage_lines((4*i)+3)<=x"2e2b34ca";
                memory_storage_lines((4*i)+2)<=x"59fa4c88";
                memory_storage_lines((4*i)+1)<=x"3b2c8aef";
                memory_storage_lines(4*i)<=x"d44be966";
                end loop;
                elsif(enable_reading_instructions='0') then
                    for i in 0 to 3 loop
                        memory_storage_lines(to_integer(unsigned(compiler_store_address))+i)<= compiler_input((31+32*i) downto (0+32*i));
                    end loop;
                    elsif(op_code="0101") then 
                        for i in 0 to 3 loop
                            if(take_forwarded_data='0') then
                            memory_storage_lines(to_integer(unsigned(store_or_read_address))+i)<= instruction_or_data_to_be_written((31+32*i) downto (0+32*i));
                            else
                             memory_storage_lines(to_integer(unsigned(store_or_read_address))+i)<= forwarded_data((31+32*i) downto (0+32*i));
                        end if;
                        end loop;
                    end if;
                end process;            
                
                
                
            end Behavioral;

--signal memory_storage_lines : memory_storage := ((others=> (others=>'0')));
--  (op_code/="000") and 