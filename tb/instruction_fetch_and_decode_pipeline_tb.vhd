
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity instruction_fetch_and_decode_pipeline_tb is

end instruction_fetch_and_decode_pipeline_tb;

architecture simulation of instruction_fetch_and_decode_pipeline_tb is

	component instruction_fetch_and_decode_pipeline is
	Port ( 
		clk :in STD_LOGIC;
		rst :in STD_LOGIC;  
instruction_in : in STD_LOGIC_VECTOR (31 downto 0);      --after decryption
program_counter_in : in STD_LOGIC_VECTOR (7 downto 0);
instruction_out : out STD_LOGIC_VECTOR (31 downto 0);
program_counter_out : out STD_LOGIC_VECTOR (7 downto 0));
end component;

signal clk ,rst : std_logic:='0';
signal instruction_in,instruction_out : std_logic_vector(31 downto 0):=x"00000000";
signal program_counter_in,program_counter_out : std_logic_vector(7 downto 0):=x"00";
constant clk_period : time := 60 ns;

begin

	instruction_fetch_and_decode_pipeline_unit: instruction_fetch_and_decode_pipeline port map(clk=>clk, rst=>rst,
		instruction_in=>instruction_in, instruction_out=>instruction_out, program_counter_in=>program_counter_in, program_counter_out=>program_counter_out);

	clk_stimulus: process 
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	logic_stimulation: process
	begin
		rst<='1';
		wait for clk_period;
		rst<='0';

		wait for clk_period;
		program_counter_in<=x"01";
		instruction_in<=x"00101000";
		wait;

	end process;
end simulation;
