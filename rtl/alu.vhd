----------------------------------------------------------------------------------
    -- Description: Takes as input the opcode, 2 register inputs,
        --              immediate sign extended input, i/r indicator flag,
            --              and outputs the needed result or address.
                --
                    -- Author: Youssef Abouelazm
                        ----------------------------------------------------------------------------------


                            library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
    -- any Xilinx leaf cells in this code.
        --library UNISIM;
--use UNISIM.VComponents.all;


entity alu is
    Port (
        opcode : in STD_LOGIC_VECTOR (3 downto 0);
        in1, forwarded_data_from_alu, forwarded_data_from_memory : in STD_LOGIC_VECTOR (31 downto 0);
        in2 : in STD_LOGIC_VECTOR (31 downto 0);
        sign_xtd : in STD_LOGIC_VECTOR (31 downto 0);
        irflag : in STD_LOGIC;
        take_forwarded_data: in STD_LOGIC_VECTOR (1 downto 0);        -- "10">> take from memory___"01">> take from alu

        result : out STD_LOGIC_VECTOR (31 downto 0)
    );
end alu;


architecture Behavioral of alu is

    signal operand1 : STD_LOGIC_VECTOR (31 downto 0);
signal operand2 : STD_LOGIC_VECTOR (31 downto 0);

begin
    --handling when to use immediate values instead of register
        operand1 <= sign_xtd WHEN opcode(2) = '1'  ELSE
            forwarded_data_from_alu when take_forwarded_data="01" else
                forwarded_data_from_memory when take_forwarded_data="10" else
                    in1;
    operand2 <= sign_xtd WHEN ((opcode(2) = '0') AND irflag = '1') ELSE
        forwarded_data_from_alu when take_forwarded_data="01" and (opcode="0101" or opcode="0100")  else
        forwarded_data_from_memory when take_forwarded_data="10" and (opcode="0101" or opcode="0100") else
        in2;

    --MUX
        WITH opcode SELECT
            result <=   STD_LOGIC_VECTOR(UNSIGNED(operand1) + UNSIGNED(operand2))   WHEN "1000", --ADD
                STD_LOGIC_VECTOR(UNSIGNED(operand1) - UNSIGNED(operand2))   WHEN "0001", --SUB
                    operand1 AND operand2                                       WHEN "0010", --AND
                        operand1 OR operand2                                        WHEN "0011", --OR
                            STD_LOGIC_VECTOR(UNSIGNED(operand1) + UNSIGNED(operand2))      WHEN "0100", --LW
                                STD_LOGIC_VECTOR(UNSIGNED(operand1) + UNSIGNED(operand2))       WHEN "0101", --SW
                                    x"00000000"                                                 WHEN OTHERS; --JR,BEQZ (dontcare)

    end Behavioral;


    -- ("0000000000000000000000" & operand2 & operand1)                        