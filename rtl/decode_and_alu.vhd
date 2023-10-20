
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decode_and_alu is
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
end decode_and_alu;

architecture Behavioral of decode_and_alu is

    component decode is
    Port ( instruction : in std_logic_vector (31 downto 0); -- opcode(18 downto 16), I/R indicator 15
           pc : in std_logic_vector (31 downto 0);           --r0(14 downto 10), I/R1(9 downto 5), I/R2(4 downto 0) 
           write_data : in std_logic_vector (31 downto 0);
           write_enable : in std_logic;
           write_reg : in std_logic_vector (4 downto 0);        
           out1 : out std_logic_vector (31 downto 0); --Ignore on load
           out2 : out std_logic_vector (31 downto 0); --Ignore on jump
           sign_extended : out std_logic_vector(31 downto 0);
           next_pc : out std_logic_vector (31 downto 0)   --return to instruction decode
           );
end component;

component alu is
Port (
        opcode : in STD_LOGIC_VECTOR (3 downto 0);
        in1, forwarded_data_from_alu, forwarded_data_from_memory : in STD_LOGIC_VECTOR (31 downto 0);
        in2 : in STD_LOGIC_VECTOR (31 downto 0);
        sign_xtd : in STD_LOGIC_VECTOR (31 downto 0);
        irflag : in STD_LOGIC;
        take_forwarded_data: in STD_LOGIC_VECTOR (1 downto 0);        -- "10">> take from memory___"01">> take from alu

        result : out STD_LOGIC_VECTOR (31 downto 0)
    );
end component;

component decode_and_alu_pipeline is
Port (
   clk :in STD_LOGIC;
   rst :in STD_LOGIC;
   out1_in :in std_logic_vector (31 downto 0);
   out2_in :in std_logic_vector (31 downto 0);
   sign_extended_in : in std_logic_vector(31 downto 0);
   op_code_and_ir_flag_in : in  STD_LOGIC_VECTOR (4 downto 0);
   load_register_in : in STD_LOGIC_VECTOR(4 downto 0);
   load_register_out :out STD_LOGIC_VECTOR(4 downto 0);
   op_code_and_ir_flag_out : out  STD_LOGIC_VECTOR (4 downto 0);
   sign_extended_out : out std_logic_vector(31 downto 0);
   out2_out :out std_logic_vector (31 downto 0);
   out1_out: out std_logic_vector (31 downto 0)
   );
end component;

signal out1_in, out2_in, sign_extended_in, sign_extended_out, out1_out, out2_out: std_logic_vector (31 downto 0);
signal op_code_and_ir_flag_out :  STD_LOGIC_VECTOR (4 downto 0);

begin

    my_decode: decode port map ( instruction   => instruction,
       pc            => pc,
       write_data    => write_data,
       write_enable  => write_enable,
       write_reg     => write_reg,
       out1          => out1_in,
       out2          => out2_in,
       sign_extended => sign_extended_in,
       next_pc       => next_pc
       );
    
    my_decode_and_alu_pipeline: decode_and_alu_pipeline port map ( clk=>clk,
     rst=>rst,                                                    
     out1_in=>out1_in,
     out2_in=>out2_in,
     sign_extended_in=>sign_extended_in,
     op_code_and_ir_flag_in=>instruction(19 downto 15),
     load_register_in=>instruction(14 downto 10),
     load_register_out=>load_register_out,
     op_code_and_ir_flag_out=>op_code_and_ir_flag_out, 
     sign_extended_out=> sign_extended_out,
     out2_out=> out2_out,
     out1_out=> out1_out);
    
    my_alu: alu port map ( opcode   => op_code_and_ir_flag_out( 4 downto 1),
     in1      => out1_out,
     in2      => out2_out,
     forwarded_data_from_alu=>forwarded_data_from_alu,
     forwarded_data_from_memory=>forwarded_data_from_memory,
     take_forwarded_data=>take_forwarded_data,
     sign_xtd => sign_extended_out,
     irflag   => op_code_and_ir_flag_out(0),
     result   => result 
     
     );   

    op_code_out<=op_code_and_ir_flag_out(4 downto 1); 
    out_1_out<= out1_out;                                                                                                                                                
end Behavioral;
