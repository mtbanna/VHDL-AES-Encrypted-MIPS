----------------------------------------------------------------------------------
-- Company: 
-- Engineer:
-- 
-- Create Date: 12.12.2021 01:54:34
-- Design Name: 
-- Module Name: register_file - Datapath
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
--
-- Description: 
-- Contains registers R0 to R31. R0 is hardwired to zero. 
-- Registers are read and written as soon as input is available.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_file is
    Port ( read_reg1 : in STD_LOGIC_VECTOR (4 downto 0);
     read_reg2 : in STD_LOGIC_VECTOR (4 downto 0);
     write_reg : in STD_LOGIC_VECTOR (4 downto 0);
     write_data : in STD_LOGIC_VECTOR (31 downto 0);
     write_enable: in STD_LOGIC;
     read_data1 : out STD_LOGIC_VECTOR (31 downto 0);
     read_data2 : out STD_LOGIC_VECTOR (31 downto 0));
end register_file;

architecture Datapath of register_file is
    type registerFile is array(0 to 30) of std_logic_vector(31 downto 0);
    signal registers: registerFile:= (others=>x"00000000");
    signal register_31: std_logic_vector(31 downto 0):=x"000000DD";  --R31 is always 221 (decimal) to be able to access the memory from the end 
    begin
        read_data1 <= registers(to_integer(unsigned(read_reg1))) when (to_integer(unsigned(read_reg1)) /= 31) else
        register_31;
        read_data2 <= registers(to_integer(unsigned(read_reg2)))  when (to_integer(unsigned(read_reg2)) /= 31) else
        register_31;

        registers(to_integer(unsigned(write_reg))) <= write_data when ((write_enable = '1') and (to_integer(unsigned(write_reg)) /= 0) and (to_integer(unsigned(write_reg)) /= 31));

    end Datapath;
