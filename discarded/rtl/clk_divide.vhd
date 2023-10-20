library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clk_divide is
    port (
        clk : in std_logic;
        rst : in std_logic;
        clk_divider: in std_logic_vector(3 downto 0);
        clk_div: out std_logic
    );
end clk_divide;

architecture behavioral of clk_divide is
    signal count : unsigned(3 downto 0);
    signal divider : unsigned(3 downto 0);
    signal divider_half : unsigned(3 downto 0);
begin
    divider <= unsigned(clk_divider);
    divider_half <= unsigned('0'&clk_divider(3 downto 1)); -- half
    p_clk_divider: process(clk)
    begin
        if(rising_edge(clk)) then
            if(rst='1') then
                count <= (others=>'0');
                clk_div <= '0';
            else
                count <= count + 1;
            end if;
            if(count = divider_half) then 
                clk_div <= '0';
            elsif(count = divider) then
                count <= x"1";
                clk_div <= '1';
            end if;
        end if;
    end process p_clk_divider;

end architecture;