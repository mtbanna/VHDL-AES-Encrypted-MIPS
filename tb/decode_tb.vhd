library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity decode_tb is
end;

architecture bench of decode_tb is

  component decode
  Port ( instruction : in std_logic_vector (31 downto 0);
   pc : in std_logic_vector (31 downto 0);
   write_data : in std_logic_vector (31 downto 0);
   write_enable : in std_logic;
   write_reg : in std_logic_vector (4 downto 0);
   out1 : out std_logic_vector (31 downto 0);
   out2 : out std_logic_vector (31 downto 0);
   sign_extended : out std_logic_vector(31 downto 0);
   next_pc : out std_logic_vector (31 downto 0);
   branch_taken : out std_logic );
end component;

signal instruction: std_logic_vector (31 downto 0);
signal pc: std_logic_vector (31 downto 0);
signal write_data: std_logic_vector (31 downto 0);
signal write_enable: std_logic;
signal write_reg: std_logic_vector (4 downto 0);
signal out1: std_logic_vector (31 downto 0);
signal out2: std_logic_vector (31 downto 0);
signal sign_extended: std_logic_vector(31 downto 0);
signal next_pc: std_logic_vector (31 downto 0);
signal branch_taken: std_logic;

begin

  uut: decode port map ( instruction   => instruction,
   pc            => pc,
   write_data    => write_data,
   write_enable  => write_enable,
   write_reg     => write_reg,
   out1          => out1,
   out2          => out2,
   sign_extended => sign_extended,
   next_pc       => next_pc,
   branch_taken  => branch_taken );

  stimulus: process
  begin
    
    -- Put initialisation code here
    pc <= x"00000000"; write_enable <= '0';
    write_data <= x"00000001"; write_reg <= "00001"; write_enable <= '1'; wait for 10 ns; write_enable <= '0';
    write_data <= x"00000002"; write_reg <= "00010"; write_enable <= '1'; wait for 10 ns; write_enable <= '0';
    write_data <= x"00000003"; write_reg <= "00011"; write_enable <= '1'; wait for 10 ns; write_enable <= '0';
    -- Put test bench stimulus code here
    instruction <= x"00008403"; wait for 10 ns; -- ADD R1, R0, 5
    instruction <= x"00000443"; wait for 10 ns; -- ADD R1, R2, R3
    instruction <= x"00010443"; wait for 10 ns; -- SUB R1, R2, R3
    instruction <= x"00018443"; wait for 10 ns; -- SUB R1, R2, 5
    instruction <= x"00020443"; wait for 10 ns; -- AND R1, R2, R3
    instruction <= x"00030443"; wait for 10 ns; -- OR R1, R2, R3
    instruction <= x"000404A2"; wait for 10 ns; -- LW R1, 5, R2
    instruction <= x"000504A2"; wait for 10 ns; -- SW R1, 5, R2
    instruction <= x"000604A2"; wait for 10 ns; -- JR R1, 5
    instruction <= x"000704A2"; wait for 10 ns; -- BEQZ R1, 5, R2
    wait;
  end process;


end;