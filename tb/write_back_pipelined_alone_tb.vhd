
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity write_back_pipelined_alone_tb is
    
end write_back_pipelined_alone_tb;

architecture Behavioral of write_back_pipelined_alone_tb is

     component write_back_pipelined_alone is
     Port (
         clk, rst : in std_logic; 
         enable_in : in STD_LOGIC_Vector(1 downto 0);
         loaded_data_dec_in, result_in: in STD_LOGIC_VECTOR (31 downto 0);
         register_address_in :in STD_LOGIC_VECTOR(4 downto 0);
         
         write_back_register_address_out: out STD_LOGIC_VECTOR (4 downto 0);
         data_out : out STD_LOGIC_VECTOR (31 downto 0); 
         enable_out: out std_logic
         );
end component;

signal clk, rst, enable_out : STD_LOGIC;
signal enable_in : STD_LOGIC_Vector(1 downto 0);
signal register_address_in, write_back_register_address_out: STD_LOGIC_Vector(4 downto 0);
signal loaded_data_dec_in, result_in, data_out: STD_LOGIC_Vector(31 downto 0);
constant clk_period : time := 60 ns;

begin

     uut: write_back_pipelined_alone port map (
      clk=>clk,
      rst=>rst,
      enable_in=>enable_in,
      loaded_data_dec_in=>loaded_data_dec_in ,
      result_in=>result_in,
      register_address_in=>register_address_in,
      write_back_register_address_out=> write_back_register_address_out,
      data_out=>data_out,
      enable_out=>enable_out
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
          
          enable_in<="01";
          loaded_data_dec_in<=x"00000001";
          result_in<=x"11000000";
          register_address_in<="00001";
          wait for clk_period;
          
          enable_in<="11";
          loaded_data_dec_in<=x"00000001";
          result_in<=x"11000000";
          register_address_in<="00011";
          wait for clk_period;
          
          enable_in<="00";
          loaded_data_dec_in<=x"00000001";
          result_in<=x"11000000";
          register_address_in<="00111";
          wait;        
          
     end process;

end Behavioral;
