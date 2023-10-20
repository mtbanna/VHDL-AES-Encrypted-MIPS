-- pc at decode unit isn't the same size of memory's
-- initialize data in memory to decrypted value of zero


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipelined_mips is
  Port(
    clk, clk2, rst, enable_reading_instructions, stall, take_forwarded_data_for_memory: in std_logic;
    take_forwarded_data_for_alu  : in STD_LOGIC_VECTOR (1 downto 0);
    compiler_store_address : in STD_LOGIC_VECTOR (7 downto 0);
    compiler_input : in STD_LOGIC_VECTOR (127 downto 0);

    instruction_output_for_control_unit: out STD_LOGIC_VECTOR (127 downto 0);
    branch_taken : out std_logic
    );
end pipelined_mips;

architecture Behavioral of pipelined_mips is

  component instruction_fetch_and_memory_access_and_crypto is
  Port (
    clk, clk2, rst, enable_reading_instructions, take_forwarded_data :in std_logic;
    op_code : in std_logic_vector (3 downto 0);
    store_or_read_address, program_counter :in STD_LOGIC_VECTOR(7 downto 0); 
    compiler_input, instruction_or_data_to_be_written, forwarded_data:STD_LOGIC_VECTOR (127 downto 0) ;
    compiler_store_address:STD_LOGIC_VECTOR (7 downto 0);
    
    write_enable_in_registers: out std_logic_vector(1 downto 0);
    instruction_output, loaded_data : out STD_LOGIC_VECTOR (127 downto 0);
    next_program_counter: out STD_LOGIC_VECTOR (7 downto 0) 
    );
end component;

component decode_and_alu is
Port (
 clk, rst, write_enable : in std_logic;                           --normal inputs and from write back
 pc, instruction, write_data : in std_logic_vector (31 downto 0); --from fetch and write back 
 write_reg : in std_logic_vector (4 downto 0);                  --from write back
 load_register_out : out std_logic_vector (4 downto 0);         --return to memory access
 forwarded_data_from_alu, forwarded_data_from_memory : in STD_LOGIC_VECTOR (31 downto 0);
 take_forwarded_data : in STD_LOGIC_VECTOR (1 downto 0);

  result : out STD_LOGIC_VECTOR (31 downto 0);                  --return to memory access
  next_pc : out std_logic_vector (31 downto 0);                 --return to instruction decode
  op_code_out: out std_logic_vector (3 downto 0);
  out_1_out :  out std_logic_vector (31 downto 0)
  );
end component;

component  write_back_pipelined_alone is
Port (
 clk, rst : in std_logic; 
 enable_in : in STD_LOGIC_Vector(1 downto 0);
 loaded_data_dec_in, result_in: in STD_LOGIC_VECTOR (31 downto 0);
 register_address_in :in STD_LOGIC_VECTOR(4 downto 0);
 
 write_back_register_address_out: out STD_LOGIC_VECTOR (4 downto 0);
 data_out, loaded_data_to_enter_Write_back, result_out_to_write_back : out STD_LOGIC_VECTOR (31 downto 0); 
 enable_out_to_write_back: out STD_LOGIC_VECTOR (1 downto 0);
 enable_out: out std_logic
 );
end component;

component alu_and_memory_access_pipeline is
Port ( 
  clk,rst : in std_logic;
  opcode_in : in STD_LOGIC_Vector(3 downto 0);
  register_address_in :in STD_LOGIC_VECTOR(4 downto 0);
  result_in :  in STD_LOGIC_VECTOR (31 downto 0);          
  out_1_in :  in std_logic_vector (31 downto 0);          

  register_address_out :out STD_LOGIC_VECTOR(4 downto 0);
  opcode_out : out STD_LOGIC_Vector(3 downto 0);
  out_1_out :  out std_logic_vector (31 downto 0);
result_out :  out STD_LOGIC_VECTOR (31 downto 0) --it's store_or_read_address at the right opcode 
 );                                                --else pass to memory access and writeback pipeline
end component;

component instruction_fetch_and_decode_pipeline is
Port ( 
  clk, stall :in STD_LOGIC;
  rst :in STD_LOGIC;  
instruction_in : in STD_LOGIC_VECTOR (31 downto 0);      --after decryption
program_counter_in : in STD_LOGIC_VECTOR (7 downto 0);
instruction_out : out STD_LOGIC_VECTOR (31 downto 0);
program_counter_out : out STD_LOGIC_VECTOR (7 downto 0)
);
end component;

signal instruction_output_from_instruction_fetch, loaded_data_from_access,
convert_to_128_bits_for_store_in_memory, convert_to_128_bits_for_forward_in_memory :std_logic_vector(127 downto 0 ):=(others=>'0');

signal load_register_out_from_alu, register_address_out_from_alu_and_access_pipeline,
write_back_register_address_out_from_write_back  : std_logic_vector (4 downto 0):=(others=>'0');

signal next_program_counter_from_instruction_fetch,
program_counter_out_from_fetch_and_decode_pipeline : std_logic_vector (7 downto 0):=(others=>'0');

signal result_from_alu, result_out_from_alu_and_access_pipeline ,out_1_out_from_alu,
out_1_out_from_alu_and_access_pipeline, data_out_from_write_back,
instruction_out_from_instruction_fetch_and_decode_pipeline,   
next_pc_from_decode, convert_to_32_bits_for_pc_in_decode, loaded_data_to_enter_Write_back, 
result_out_to_enter_Write_back : std_logic_vector (31 downto 0):=(others=>'0');

signal op_code_out_from_alu, opcode_out_out_from_alu_and_access_pipeline: std_logic_vector (3 downto 0):=(others=>'0');

signal write_enable_in_registers_from_access, enable_out_to_write_back: std_logic_vector (1 downto 0):=(others=>'0');

signal enable_out_from_write_back: std_logic:='0';

begin

  my_instruction_fetch_and_memory_access_and_crypto: instruction_fetch_and_memory_access_and_crypto port map (
   rst=>rst,
   clk=>clk,
   clk2=>clk2,
   enable_reading_instructions=>enable_reading_instructions,
   take_forwarded_data=>take_forwarded_data_for_memory,
   program_counter=>next_pc_from_decode(7 downto 0),
   forwarded_data=>convert_to_128_bits_for_forward_in_memory,
   op_code=> opcode_out_out_from_alu_and_access_pipeline,
   store_or_read_address=>result_out_from_alu_and_access_pipeline(7 downto 0),
   instruction_or_data_to_be_written=>convert_to_128_bits_for_store_in_memory,   -- it should be renamed to data_to_be_written 
   compiler_input=>compiler_input,                                             --(instructions are written using the compiler) 
   compiler_store_address=>compiler_store_address,
   write_enable_in_registers=>write_enable_in_registers_from_access,
   loaded_data=>loaded_data_from_access,
   instruction_output=> instruction_output_from_instruction_fetch,
   next_program_counter=> next_program_counter_from_instruction_fetch
         );

  my_instruction_fetch_and_decode_pipeline: instruction_fetch_and_decode_pipeline port map(
    clk=>clk,
    stall=>stall, 
    rst=>rst,
    instruction_in=>instruction_output_from_instruction_fetch(31 downto 0),
    instruction_out=>instruction_out_from_instruction_fetch_and_decode_pipeline,
    program_counter_in=>next_program_counter_from_instruction_fetch,
    program_counter_out=>program_counter_out_from_fetch_and_decode_pipeline
    );

  my_decode_and_alu: decode_and_alu port map(
   clk=>clk,
   rst=>rst,
   write_enable=>enable_out_from_write_back,
   take_forwarded_data=>take_forwarded_data_for_alu,
   forwarded_data_from_alu=> result_out_from_alu_and_access_pipeline,
   forwarded_data_from_memory=> loaded_data_to_enter_Write_back,
   pc=> convert_to_32_bits_for_pc_in_decode,
   instruction=>instruction_out_from_instruction_fetch_and_decode_pipeline,
   write_data=>data_out_from_write_back,
   write_reg=>write_back_register_address_out_from_write_back,
   load_register_out=>load_register_out_from_alu,
   result=>result_from_alu,
   next_pc=>next_pc_from_decode,
   op_code_out=>op_code_out_from_alu,
   out_1_out=>out_1_out_from_alu
   );

  my_alu_and_memory_access_pipeline: alu_and_memory_access_pipeline port map(
    clk=>clk ,
    rst=>rst ,
    opcode_in=>op_code_out_from_alu ,
    register_address_in=>load_register_out_from_alu , 
    result_in=>result_from_alu ,
    out_1_in=>out_1_out_from_alu ,

    register_address_out=>register_address_out_from_alu_and_access_pipeline , 
    opcode_out=>opcode_out_out_from_alu_and_access_pipeline,
    result_out=>result_out_from_alu_and_access_pipeline, 
    out_1_out=>out_1_out_from_alu_and_access_pipeline
    );

  my_write_back_pipelined_alone: write_back_pipelined_alone port map(
    clk=>clk,
    rst=>rst,
    enable_in=>write_enable_in_registers_from_access,
    loaded_data_dec_in=>loaded_data_from_access(31 downto 0) ,
    result_in=>result_out_from_alu_and_access_pipeline,
    result_out_to_write_back=>result_out_to_enter_Write_back ,
    register_address_in=>register_address_out_from_alu_and_access_pipeline,
    write_back_register_address_out=> write_back_register_address_out_from_write_back,
    data_out=>data_out_from_write_back,
    loaded_data_to_enter_Write_back=>loaded_data_to_enter_Write_back,
    enable_out_to_write_back=>enable_out_to_write_back ,
    enable_out=>enable_out_from_write_back
    );


  instruction_output_for_control_unit<=instruction_output_from_instruction_fetch;

  convert_to_128_bits_for_forward_in_memory<= x"000000000000000000000000"&loaded_data_to_enter_Write_back when enable_out_to_write_back = "01"  else
                                              x"000000000000000000000000"&result_out_to_enter_Write_back when enable_out_to_write_back = "11" ; 

  convert_to_128_bits_for_store_in_memory<= x"000000000000000000000000"&out_1_out_from_alu_and_access_pipeline;

  convert_to_32_bits_for_pc_in_decode<=x"000000"&program_counter_out_from_fetch_and_decode_pipeline;

end Behavioral;
