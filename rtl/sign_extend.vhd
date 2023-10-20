----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2021 01:54:34
-- Design Name: 
-- Module Name: sign_extend - Datapath
-- Project Name: 
-- Target Devices: 
-- Tool Versions:
-- 
-- Description: 
-- Does what it says on the box
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

entity sign_extend is
    Port ( immediate : in STD_LOGIC_VECTOR (4 downto 0);
     sign_extended : out STD_LOGIC_VECTOR (31 downto 0));
end sign_extend;



architecture Datapath of sign_extend is
    signal sign_extend_output : STD_LOGIC_VECTOR (31 downto 0):=(others=>'0');
    begin

        sign_extend_output <= std_logic_vector(resize(unsigned(immediate), sign_extended'length));
        sign_extended<=sign_extend_output;

    end Datapath;
