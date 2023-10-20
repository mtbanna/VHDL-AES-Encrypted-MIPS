
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decode_and_alu_pipeline is
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
end decode_and_alu_pipeline;


architecture Behavioral of decode_and_alu_pipeline is

    signal out1_save_register,out2_save_register,sign_extended_save_register :std_logic_vector (31 downto 0);
    signal op_code_and_ir_flag_save_register: std_logic_vector(4 downto 0);
    signal load_register_save_register:std_logic_vector(4 downto 0);

    begin
        process(clk,rst)
        begin
            if(rst='1') then
                out1_save_register<=(others=>'0');
                out2_save_register<=(others=>'0');
                sign_extended_save_register<=(others=>'0');
                op_code_and_ir_flag_save_register<=(others=>'0');
                load_register_save_register<=(others=>'0');

                out1_out<=(others=>'0');
                out2_out<=(others=>'0');
                sign_extended_out<=(others=>'0');
                op_code_and_ir_flag_out<=(others=>'0');
                load_register_out<=(others=>'0');

                elsif(falling_edge(clk)) then
                    out1_save_register<=out1_in;
                    out2_save_register<=out2_in;
                    sign_extended_save_register<=sign_extended_in;
                    op_code_and_ir_flag_save_register<=op_code_and_ir_flag_in;
                    load_register_save_register<=load_register_in;
               elsif(rising_edge(clk)) then
                    out1_out<=out1_save_register;
                    out2_out<=out2_save_register;
                    sign_extended_out<=sign_extended_save_register;
                    op_code_and_ir_flag_out<=op_code_and_ir_flag_save_register;
                    load_register_out<=load_register_save_register;

                end if;
            end process;


        end Behavioral;
