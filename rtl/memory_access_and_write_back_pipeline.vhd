
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory_access_and_write_back_pipeline is
    Port ( 
       clk,rst : in STD_LOGIC;  
       enable_in : in STD_LOGIC_Vector(1 downto 0);
       loaded_data_dec_in, result_in : in STD_LOGIC_VECTOR (31 downto 0);
       register_address_in :in STD_LOGIC_VECTOR(4 downto 0);
       
           register_address_out :out STD_LOGIC_VECTOR(4 downto 0); --to decode
           loaded_data_dec_out,result_out : out STD_LOGIC_VECTOR (31 downto 0);
           enable_out : out STD_LOGIC_Vector(1 downto 0)
           );
end memory_access_and_write_back_pipeline;

architecture Behavioral of memory_access_and_write_back_pipeline is

    signal enable_save_register : STD_LOGIC_Vector(1 downto 0);
    signal loaded_data_dec_save_register, result_save_register : std_logic_vector(31 downto 0);
    signal register_address_save_register : STD_LOGIC_VECTOR(4 downto 0);

    begin

        process(clk,rst,loaded_data_dec_in)  -- add other signals if there is a bug
        begin
            if(rst='1') then
                enable_save_register<=(others=>'0');
                loaded_data_dec_save_register<=(others=>'0');
                register_address_save_register<=(others=>'0');
                result_save_register<=(others=>'0');
                register_address_out <=(others=>'0');
                enable_out<=(others=>'0');
                loaded_data_dec_out<=(others=>'0');
                result_out<=(others=>'0');

                    elsif(rising_edge(clk)) then
                        register_address_out<=register_address_save_register;
                        enable_out<=enable_save_register;
                        loaded_data_dec_out<=loaded_data_dec_save_register;
                        result_out<=result_save_register;
                        else
                        enable_save_register<=enable_in;
                        loaded_data_dec_save_register<=loaded_data_dec_in;
                        register_address_save_register<=register_address_in;
                        result_save_register<=result_in;
                    end if;
                end process;

            end Behavioral;
--elsif(falling_edge(clk)) then
--                    enable_save_register<=enable_in;
--                    loaded_data_dec_save_register<=loaded_data_dec_in;
--                    register_address_save_register<=register_address_in;
--                    result_save_register<=result_in;