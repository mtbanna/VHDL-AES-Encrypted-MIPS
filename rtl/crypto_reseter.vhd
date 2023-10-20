
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--enable
entity crypto_reseter is
    Port ( rst,done,clk: in STD_LOGIC;
           rst_crypto : out STD_LOGIC);
end crypto_reseter;

architecture Behavioral of crypto_reseter is

begin

process(clk,done,rst) 
begin

if(rst='1') then
rst_crypto<='0';
elsif(rising_edge(clk) ) then
rst_crypto<='1' after 3ns;
elsif(done='1') then
rst_crypto<='0';
end if;


end process; 

end Behavioral;
