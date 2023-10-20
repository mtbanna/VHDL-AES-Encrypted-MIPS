

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity encryptor_and_resetter_tb is

end encryptor_and_resetter_tb;

architecture Behavioral of encryptor_and_resetter_tb is

	component encryptor_and_resetter is
	port(
		clk, clk2, rst : in std_logic;
		plaintext : in std_logic_vector(127 downto 0);

		ciphertext_at_done : out std_logic_vector(127 downto 0)
		);
end component;

signal clk, clk2, rst :std_logic;
signal plaintext, ciphertext_at_done: std_logic_vector( 127 downto 0);
constant clk_period : time := 60 ns; 

begin

	uut: encryptor_and_resetter port map(
		clk=>clk,
		clk2=>clk2,
		rst=>rst,
		plaintext=>plaintext,
		ciphertext_at_done=>ciphertext_at_done
		);

	clk_stimulus: process 
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
	
	clk2_stimulus: process 
	begin
		clk2 <= '0';
		wait for clk_period/100;
		clk2 <= '1';
		wait for clk_period/100;
	end process;

	logic_stim: process
	begin
		rst<='1';
		plaintext <= x"00000000000000000000000000000000";
		wait for clk_period/2;
		rst<='0';

		wait for clk_period;
		plaintext <= x"00000000000000000000000000000011";

		wait for clk_period;
		plaintext <= x"00000000000000000000000000000000";

		wait for clk_period;
		plaintext <= x"00000000000000000000000000000011";

		wait for clk_period;
		plaintext <= x"00000000000000000000000000000000";

		wait;


	end process;
end Behavioral;
