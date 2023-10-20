library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity alu_tb is
end;

architecture bench of alu_tb is

  component alu
  Port (
    opcode : in STD_LOGIC_VECTOR (2 downto 0);
    in1 : in STD_LOGIC_VECTOR (31 downto 0);
    in2 : in STD_LOGIC_VECTOR (31 downto 0);
    sign_xtd : in STD_LOGIC_VECTOR (31 downto 0);
    irflag : in STD_LOGIC;
    result : out STD_LOGIC_VECTOR (31 downto 0)
    );
end component;

signal opcode: STD_LOGIC_VECTOR (2 downto 0);
signal in1: STD_LOGIC_VECTOR (31 downto 0);
signal in2: STD_LOGIC_VECTOR (31 downto 0);
signal sign_xtd: STD_LOGIC_VECTOR (31 downto 0);
signal irflag: STD_LOGIC;
signal result: STD_LOGIC_VECTOR (31 downto 0) ;

begin

  uut: alu port map ( opcode   => opcode,
    in1      => in1,
    in2      => in2,
    sign_xtd => sign_xtd,
    irflag   => irflag,
    result   => result );

  stimulus: process
  begin
    
    -- add 9+15, expected 24
    opcode <= "000";  --ADD
    in1 <= x"00000005"; --5
    in2 <= x"00000013"; --19
    sign_xtd <= x"00001111";
    irflag <= '0';
    wait for 10 ns;

    -- add immediate 23+18, expected 24
    opcode <= "000";  --ADD
    in1 <= x"00000017"; --23
    in2 <= x"00001111"; --19
    sign_xtd <= x"00000012";
    irflag <= '1'; -- immediate

    wait;

  end process;


end;