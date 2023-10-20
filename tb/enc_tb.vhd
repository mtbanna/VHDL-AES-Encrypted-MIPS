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

entity test_enc is 
end test_enc;

architecture behavior of test_enc is
	component aes_enc
	port(
		clk        : in  std_logic;
		rst        : in  std_logic;
		key        : in  std_logic_vector(127 downto 0);
		plaintext  : in  std_logic_vector(127 downto 0);
		ciphertext : out std_logic_vector(127 downto 0);
		done       : out std_logic
		);		
end component aes_enc;	
	-- Input signals
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal plaintext : std_logic_vector(127 downto 0);
	signal key : std_logic_vector(127 downto 0);	
	
	-- Output signals
	signal done : std_logic;
	signal ciphertext : std_logic_vector(127 downto 0);	
	
	-- Clock period definition
	constant clk_period : time := 5 ns;
	
	begin
		enc_inst : aes_enc
		port map(
			clk        => clk,
			rst        => rst,
			key        => key,
			plaintext  => plaintext,
			ciphertext => ciphertext,
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
		
		plaintext <= x"340737e0a29831318d305a88a8f64332";
		key <= x"00000000000000000000000000000000";
		rst <= '0';
		wait for clk_period;
		rst<='1';
		wait until done = '1';
		
		plaintext <= x"00000000000000000000000000000000";
		rst <= '0';       
		wait for clk_period;
		rst <= '1';
		wait until done = '1';
		
		plaintext <= x"11111111111111111111111111111111";
		rst <= '0';       
		wait for clk_period;
		rst <= '1';
		wait until done = '1';
		
		rst<='0';
		
		wait;
	end process sim_proc;
	
end architecture behavior;


