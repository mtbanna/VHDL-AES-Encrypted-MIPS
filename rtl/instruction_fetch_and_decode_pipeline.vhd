
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_fetch_and_decode_pipeline is
   Port ( 
    clk :in STD_LOGIC;
    rst, stall :in STD_LOGIC;  
instruction_in : in STD_LOGIC_VECTOR (31 downto 0);      --after decryption
program_counter_in : in STD_LOGIC_VECTOR (7 downto 0);
instruction_out : out STD_LOGIC_VECTOR (31 downto 0);
program_counter_out : out STD_LOGIC_VECTOR (7 downto 0)
);

end instruction_fetch_and_decode_pipeline;

architecture Behavioral of instruction_fetch_and_decode_pipeline is

    signal instruction_save_register, previous_instruction : std_logic_vector(31 downto 0);
    signal program_counter_save_register : std_logic_vector(7 downto 0);

    begin

     process(clk,rst)
     begin
        if(rst='1') then
            instruction_save_register<=(others=>'0');
            program_counter_save_register<=(others=>'0');
            instruction_out<=(others=>'0');
            program_counter_out<=(others=>'0');
            previous_instruction<=(others=>'0');

            elsif(falling_edge(clk)) then
                if(stall='0') then
                instruction_save_register<=instruction_in;
                program_counter_save_register<=program_counter_in;
                elsif (stall='1'and (previous_instruction(19 downto 16)="0110" or previous_instruction(19 downto 16)="0111")) then
                instruction_save_register<=instruction_in;
                program_counter_save_register<=std_logic_vector(unsigned(program_counter_in)  );
            end if;

                elsif(rising_edge(clk) and stall='0') then
                    instruction_out<=instruction_save_register;
                    program_counter_out<=program_counter_save_register;
                    previous_instruction<=instruction_save_register;
                
                    elsif(rising_edge(clk) and stall='1') then
                        if(previous_instruction(19 downto 16)="0110" or previous_instruction(19 downto 16)="0111") then
                          instruction_out<=(others=>'0');
                          program_counter_out<=std_logic_vector(unsigned(program_counter_in) );
                            else
                        instruction_out<=(others=>'0');
                        program_counter_out<=std_logic_vector(unsigned(program_counter_save_register) -4 );
                    end if;
                    end if;
                end process;

            end Behavioral;