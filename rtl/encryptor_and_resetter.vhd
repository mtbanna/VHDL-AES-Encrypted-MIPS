
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity encryptor_and_resetter is
	port(
		clk, clk2, rst : in std_logic;
		plaintext : in std_logic_vector(127 downto 0);

		ciphertext_at_done : out std_logic_vector(127 downto 0)
		);
end encryptor_and_resetter;

architecture Behavioral of encryptor_and_resetter is

	component aes_enc is 
	port (
		clk : in std_logic;
		rst : in std_logic;
		key : in std_logic_vector(127 downto 0);
		plaintext : in std_logic_vector(127 downto 0);
		
		ciphertext : out std_logic_vector(127 downto 0);
		done : out std_logic		
		);
end component;

component crypto_reseter is
Port ( rst,done,clk : in STD_LOGIC;
	rst_crypto : out STD_LOGIC);
end component;

signal rst_crypto,done: std_logic;
signal key, ciphertext: STD_LOGIC_VECTOR (127 downto 0):=x"00000000000000000000000000000000";

begin

	enycrptor: aes_enc port map (
		clk=>clk2,
		rst=>rst_crypto,
		key=>key,
		plaintext=>plaintext,
		ciphertext=>ciphertext,
		done=>done
		);

	crypto_resetter: crypto_reseter port map (
		rst=>rst,
		done=>done,
		clk=>clk,
		rst_crypto=>rst_crypto
		);

	ciphertext_at_done<= ciphertext when ((done='1') and (rst='0')) else
	(others=>'0') when rst='1';

end Behavioral;
