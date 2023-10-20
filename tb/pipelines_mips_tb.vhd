library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipelines_mips_tb is

	end pipelines_mips_tb;

architecture simulation of pipelines_mips_tb is

	component pipelined_mips is
		Port(
			clk, clk2, rst, enable_reading_instructions, stall, take_forwarded_data_for_memory: in std_logic;
			take_forwarded_data_for_alu  : in STD_LOGIC_VECTOR (1 downto 0);
			compiler_store_address : in STD_LOGIC_VECTOR (7 downto 0);
			compiler_input : in STD_LOGIC_VECTOR (127 downto 0);

			instruction_output_for_control_unit: out STD_LOGIC_VECTOR (127 downto 0)
		);
end component;

signal clk, clk2, rst, enable_reading_instructions, stall, take_forwarded_data_for_memory: std_logic;
signal take_forwarded_data_for_alu: std_logic_vector(1 downto 0);
signal compiler_store_address : STD_LOGIC_VECTOR (7 downto 0);
signal compiler_input, instruction_output_for_control_unit: STD_LOGIC_VECTOR (127 downto 0);
constant clk_period : time := 60 ns;
signal stop_the_clock : boolean := false;

begin

	uut: pipelined_mips port map (
		clk=>clk,
		stall=>stall,
		clk2=>clk2,
		rst=>rst,
		take_forwarded_data_for_memory=>take_forwarded_data_for_memory,
		take_forwarded_data_for_alu=>take_forwarded_data_for_alu,
		enable_reading_instructions=>enable_reading_instructions,
		compiler_store_address=>compiler_store_address,
		compiler_input=>compiler_input,
		instruction_output_for_control_unit=>instruction_output_for_control_unit
	);

	clk_stimulus: process
		begin
			if (not stop_the_clock) then
				clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		end if;
end process;

clk2_stimulus: process
	begin
		if (not stop_the_clock) then
			clk2 <= '0';
		wait for clk_period/40;
		clk2 <= '1';
		wait for clk_period/40;
	end if;
end process;

logic_stimulation: process
	begin
		--data:
			rst<='1'; enable_reading_instructions<='0';
		compiler_input<=x"00000000000000000000000000000005";       -- 5 stored at FC
			compiler_store_address<=x"FC";
		stall<='0';
		take_forwarded_data_for_memory<='0';
		take_forwarded_data_for_alu<="00";
		wait for clk_period/2;
		rst<='0';

		wait for clk_period;
		compiler_store_address <= x"F8";
		compiler_input<=x"00000000000000000000000000000003";

		wait for clk_period;
		compiler_store_address <= x"F4";
		compiler_input<=x"0000000000000000000000000000000C";

		--instructions:
			wait for clk_period;
		compiler_store_address <= x"00";
		compiler_input<=x"000000000000000000000000000407FF";      -- R1 = Mem(252) (load)

			wait for clk_period;
		compiler_store_address <= x"04";
		compiler_input<=x"00000000000000000000000000040B7F";       -- R2= Mem(248) (load)

			wait for clk_period;
		compiler_store_address <= x"08";
		compiler_input<=x"00000000000000000000000000088443";     --  R1= R2+3       (addi)

			wait for clk_period;
		compiler_store_address <= x"0C";
		compiler_input<=x"0000000000000000000000000003085F";      -- R2= R2 or R31(221)     (or)

			wait for clk_period;
		compiler_store_address <= x"10";
		compiler_input<=x"00000000000000000000000000060380";     --  PC=28       (jump)

			wait for clk_period;
		compiler_store_address <= x"14";
		compiler_input<=x"00000000000000000000000000089402";     --  R5=R0+2       (addi)

			wait for clk_period;
		compiler_store_address <= x"1C";
		compiler_input<=x"00000000000000000000000000040EFF";     --  R3= Mem(244)   (load)

			wait for clk_period;
		compiler_store_address <= x"20";
		compiler_input<=x"00000000000000000000000000011041";     --  R4=R2-R1       (sub)

			wait for clk_period;
		compiler_store_address <= x"24";
		compiler_input<=x"00000000000000000000000000021882";     --  R6=R4 and R2   (and)

			wait for clk_period;
		compiler_store_address <= x"28";
		compiler_input<=x"00000000000000000000000000051BFF";     --  Mem(252)= R2   (store)

			wait for clk_period;
		compiler_store_address <= x"2C";
		compiler_input<=x"000000000000000000000000000407FF";     --  R1= Mem(252)   (load)

			wait for clk_period;  --You must wait before reading instructions for the aes to finish
			enable_reading_instructions <= '1';
		wait for clk_period*4;
		stall<='1';
		wait for clk_period*1;
		stall<='0';
		wait for clk_period*1;
		take_forwarded_data_for_alu<="10";
		wait for clk_period*1;
		take_forwarded_data_for_alu<="00";
		wait for clk_period*1;
		stall<='1';
		wait for clk_period*1;
		stall<='0';
		wait for clk_period*3;
		take_forwarded_data_for_alu<="01";
		wait for clk_period*1;
		take_forwarded_data_for_alu<="00";
		wait for clk_period*1;
		take_forwarded_data_for_memory<='1';
		wait for clk_period*1;
		take_forwarded_data_for_memory<='0';
		wait for clk_period*4;
		enable_reading_instructions <= '0';
		wait;
	end process;

end simulation;
--compiler_input <= x"000000000000000000000000000 08405" change the last 5 bits

	--data:
		--			rst<='1'; enable_reading_instructions<='0';
--		compiler_input<=x"00000000000000000000000000000005";       -- 5 stored at FC
	--			compiler_store_address<=x"1C";
--		stall<='0';
--		take_forwarded_data_for_memory<='0';
--		take_forwarded_data_for_alu<="00";
--		wait for clk_period/2;
--		rst<='0';

--		--instructios:
	--			wait for clk_period;
--		compiler_store_address <= x"00";
--		compiler_input<=x"00000000000000000000000000040780";      -- R1 = Mem(1C) (load)

	--			wait for clk_period;
--		compiler_store_address <= x"04";
--		--compiler_input<=x"00000000000000000000000000060000";        -- jump to 0
	--			compiler_input<=x"00000000000000000000000000018C22";       -- R3=R1-2     (sub)

	--           wait for clk_period;
--		compiler_store_address <= x"08";
--		compiler_input<=x"0000000000000000000000000001107F";     --  R4=R3-R0       (sub)

	--			wait for clk_period;
--		compiler_store_address <= x"0C";
--		compiler_input<=x"00000000000000000000000000088BE0";      -- R2=R31(221)+0     (add)


	--		wait for clk_period;  --You must wait before reading instructions for the aes to finish
	--			enable_reading_instructions <= '1';
--		wait for clk_period*(3);
--		stall<='1';
--		wait for clk_period*1;
--		stall<='0';
--		wait for clk_period*1;
--		take_forwarded_data_for_alu<="10";
--		wait for clk_period;
--		take_forwarded_data_for_alu<="01";
--		wait for clk_period;
--		take_forwarded_data_for_alu<="00";
--		wait for 10*clk_period;
--		enable_reading_instructions <= '0';
--		wait;
--	end process;