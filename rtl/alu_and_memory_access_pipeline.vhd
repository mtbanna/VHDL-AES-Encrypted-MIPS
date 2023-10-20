--load: Data inside Memory(result) >>register_address
-- write Data inside register_address >> Memory(result)
-- write back result >> write_back_register
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_and_memory_access_pipeline is
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
end alu_and_memory_access_pipeline;

architecture Behavioral of alu_and_memory_access_pipeline is

    signal opcode_save_register : STD_LOGIC_Vector(3 downto 0);
    signal result_save_register : STD_LOGIC_Vector(31 downto 0);
    signal register_address_save_register: STD_LOGIC_Vector(4 downto 0);
    signal out_1_save_register : std_logic_vector (31 downto 0);

    begin

        process(clk,rst)
        begin
            if(rst='1') then
                opcode_save_register<=(others=>'0');
                result_save_register<=(others=>'0');
                register_address_save_register<=(others=>'0');
                out_1_save_register<=(others=>'0');
                register_address_out<=(others=>'0');
                opcode_out<=(others=>'0');
                result_out<=(others=>'0');
                out_1_out<=(others=>'0');

                elsif(falling_edge(clk)) then
                    opcode_save_register<=opcode_in;
                    result_save_register<=result_in;
                    register_address_save_register<=register_address_in;
                    out_1_save_register<=out_1_in;
                    elsif(rising_edge(clk)) then
                        register_address_out<=register_address_save_register;
                        opcode_out<=opcode_save_register;
                        result_out<=result_save_register;
                        out_1_out<=out_1_save_register;
                    end if;
                end process;

            end Behavioral;
