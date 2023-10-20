
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decode_and_alu_tb is

end decode_and_alu_tb;

architecture Simulation of decode_and_alu_tb is

     component decode_and_alu is
     Port (
               clk, rst, write_enable : in std_logic;                           --normal inputs and from write back
               pc, instruction, write_data : in std_logic_vector (31 downto 0); --from fetch and write back
               write_reg : in std_logic_vector (4 downto 0);                  --from write back
               load_register_out : out std_logic_vector (4 downto 0);         --return to memory access
               result : out STD_LOGIC_VECTOR (31 downto 0);                  --return to memory access
               next_pc : out std_logic_vector (31 downto 0);                 --return to instruction decode
               branch_taken : out std_logic                                  --return to hazard detector
               );
end component;

signal clk, rst, write_enable, branch_taken: std_logic;
signal pc, instruction, write_data, next_pc, result : std_logic_vector (31 downto 0);
signal write_reg, load_register_out : std_logic_vector (4 downto 0);
constant clk_period : time := 75 ns;

begin

     uut: decode_and_alu port map ( clk=>clk,
          rst=>rst,
          write_enable=>write_enable,
          pc=>pc,
          instruction=>instruction,
          write_data=>write_data,
          write_reg=>write_reg,
          load_register_out=>load_register_out,
          result=>result,
          next_pc=>next_pc,
          branch_taken=>branch_taken
          );
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
          wait for clk_period/2;
          rst<='0';
          
          write_enable<='1';
          write_data<=x"00000001";
          write_reg<="11111";
          pc<=x"00000001";
          instruction<=x"00007BDF";
          wait for clk_period;
          
          write_enable<='0';
          write_data<=x"00000111";
          wait for clk_period;
          
          pc<=x"00000111";
          instruction<=x"00016BDF";
          wait;
          
     end process;
end Simulation;
