
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity write_back_stage is
    Port ( rst: std_logic;
        enable_in : in STD_LOGIC_Vector(1 downto 0);
        loaded_data : in STD_LOGIC_VECTOR (31 downto 0);                  --after decryption
        result: in STD_LOGIC_VECTOR (31 downto 0);                        --from alu

        data_out : out STD_LOGIC_VECTOR (31 downto 0);
        enable_out: out std_logic
        );
end write_back_stage;

architecture Behavioral of write_back_stage is

    begin

        data_out<=loaded_data when ((enable_in="01") and (rst='0')) else
        result when ((enable_in="11")and (rst='0')) else
        (others=>'0');
        enable_out<=enable_in(0) when (rst='0') else
        '0';

    end Behavioral;
