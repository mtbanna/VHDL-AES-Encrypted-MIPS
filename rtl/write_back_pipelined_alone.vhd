
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity write_back_pipelined_alone is
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
end write_back_pipelined_alone;

architecture Behavioral of write_back_pipelined_alone is

    component write_back_stage is
    Port ( 
     rst : in std_logic;
     enable_in : in STD_LOGIC_Vector(1 downto 0);
           loaded_data : in STD_LOGIC_VECTOR (31 downto 0);                  --after decryption
           result: in STD_LOGIC_VECTOR (31 downto 0);                        --from alu 
           
           data_out : out STD_LOGIC_VECTOR (31 downto 0);
           enable_out: out std_logic
           );
end component;

component memory_access_and_write_back_pipeline is
Port ( 
    clk,rst : in STD_LOGIC;  
    enable_in : in STD_LOGIC_Vector(1 downto 0);
    loaded_data_dec_in, result_in : in STD_LOGIC_VECTOR (31 downto 0);
    register_address_in :in STD_LOGIC_VECTOR(4 downto 0);
    
              register_address_out :out STD_LOGIC_VECTOR(4 downto 0); --to decode
              loaded_data_dec_out,result_out : out STD_LOGIC_VECTOR (31 downto 0);
              enable_out : out STD_LOGIC_Vector(1 downto 0)
              );
end component;

signal  enable_out1 : STD_LOGIC_Vector (1 downto 0);
signal loaded_data_dec_out, result_out : STD_LOGIC_VECTOR (31 downto 0);


begin

    my_memory_access_and_write_back_pipeline: memory_access_and_write_back_pipeline port map(
       clk=>clk,
       rst=>rst,
       enable_in=>enable_in,
       loaded_data_dec_in=>loaded_data_dec_in ,
       result_in=>result_in,
       register_address_in=>register_address_in,
       register_address_out=> write_back_register_address_out,
       loaded_data_dec_out=>loaded_data_dec_out ,
       result_out=>result_out,
       enable_out=>enable_out1
       ); 

    my_write_back_stage: write_back_stage port map ( 
      rst=>rst,
      enable_in=>enable_out1,
      loaded_data=>loaded_data_dec_out,
      result=>result_out,
      data_out=>data_out,
      enable_out=>enable_out
      );

    loaded_data_to_enter_Write_back<=loaded_data_dec_out;
    result_out_to_write_back<=result_out;
    enable_out_to_write_back<=enable_out1;

end Behavioral;
