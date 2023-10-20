
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rst_crypto_tb is

end rst_crypto_tb;

architecture Behavioral of rst_crypto_tb is

    component  crypto_reseter is 
    Port ( rst,done,clk : in STD_LOGIC;
        rst_crypto : out STD_LOGIC);
end component;

signal rst,done,clk,rst_crypto : std_logic;
constant clk_period : time := 60 ns;

begin

    uut: crypto_reseter port map ( rst=>rst, done=>done, clk=>clk, rst_crypto=>rst_crypto);

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
    
    wait for 50 ns;
    done<='1';
    wait for 5 ns;
    done<='0';
    wait;
    
end process;


end Behavioral;
