library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity register_file_tb is
end;

architecture bench of register_file_tb is

  component register_file
  Port ( read_reg1 : in STD_LOGIC_VECTOR (4 downto 0);
   read_reg2 : in STD_LOGIC_VECTOR (4 downto 0);
   write_reg : in STD_LOGIC_VECTOR (4 downto 0);
   write_data : in STD_LOGIC_VECTOR (31 downto 0);
   write_enable: in STD_LOGIC;
   read_data1 : out STD_LOGIC_VECTOR (31 downto 0);
   read_data2 : out STD_LOGIC_VECTOR (31 downto 0));
end component;

signal read_reg1: STD_LOGIC_VECTOR (4 downto 0);
signal read_reg2: STD_LOGIC_VECTOR (4 downto 0);
signal write_reg: STD_LOGIC_VECTOR (4 downto 0);
signal write_data: STD_LOGIC_VECTOR (31 downto 0);
signal write_enable: STD_LOGIC;
signal read_data1: STD_LOGIC_VECTOR (31 downto 0);
signal read_data2: STD_LOGIC_VECTOR (31 downto 0);

begin

  uut: register_file port map ( read_reg1    => read_reg1,
    read_reg2    => read_reg2,
    write_reg    => write_reg,
    write_data   => write_data,
    write_enable => write_enable,
    read_data1   => read_data1,
    read_data2   => read_data2 );

  stimulus: process
  begin
    
    -- Put initialisation code here
    write_data <= x"00000001"; write_reg <= "00001"; write_enable <= '1'; wait for 10 ns; write_enable <= '0';
    write_data <= x"00000002"; write_reg <= "00010"; write_enable <= '1'; wait for 10 ns; write_enable <= '0';
    write_data <= x"00000003"; write_reg <= "00011"; write_enable <= '1'; wait for 10 ns; write_enable <= '0';
    -- Put test bench stimulus code here
    read_reg1 <= (others => '0'); read_reg2 <= (others => '0'); wait for 10 ns;
    read_reg1 <= "00001"; read_reg2 <= "00010"; wait for 10 ns;
    wait;
  end process;


end;