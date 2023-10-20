-- VHDL implementation of AES
-- Copyright (C) 2019  Hosein Hadipour

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;

entity test_dec is 
end test_dec;

architecture behavior of test_dec is
	component aes_dec
	port(
		clk        : in  std_logic;
		rst        : in  std_logic;
		dec_key    : in  std_logic_vector(127 downto 0);
		ciphertext : in  std_logic_vector(127 downto 0);
		plaintext  : out std_logic_vector(127 downto 0);
		done       : out std_logic
		);	
end component aes_dec;


	-- Input signals
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal ciphertext : std_logic_vector(127 downto 0);
	signal dec_key : std_logic_vector(127 downto 0);
	
	-- Output signals
	signal done : std_logic;
	signal plaintext : std_logic_vector(127 downto 0);	
	
	-- Clock period definition
	constant clk_period : time := 5 ns;
	
	begin
		dec_inst : component aes_dec
		port map(
			clk        => clk,
			rst        => rst,
			dec_key    => dec_key,
			ciphertext => ciphertext,
			plaintext  => plaintext,
			done       => done
			);
		
	-- clock process definitions
	clk_process : process is
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process clk_process;
	
	-- Simulation process
	sim_proc : process is
	begin
		ciphertext <= x"d15b975b3003492a87889f046d9327e5";
		dec_key <= x"8e188f6fcf51e92311e2923ecb5befb4"; 
		rst <= '0';
		wait for clk_period;
		rst<='1';
		wait until done = '1';
		
		rst <= '0';  
		ciphertext <= x"2e2b34ca59fa4c883b2c8aefd44be966";              
		wait for clk_period;
		rst <= '1';
		wait until done = '1';
		
		rst <= '0';  
		ciphertext <= x"1f75e21568ae7d06980b7104edc7a3ff";              
		wait for clk_period;
		rst <= '1';
		wait until done = '1';
		
		rst<='0';
		
		wait;
	end process sim_proc;
	
end architecture behavior;
