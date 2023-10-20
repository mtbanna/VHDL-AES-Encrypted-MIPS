-- Intended operation
------------------------------------
-- 1) Forward from ALU to ALU in RAW cases
--    => special case: writing into register then immediately storing it => forward from alu to memory (implemented here as from memory to memory)
-- 2) Forward from memory to ALU in case of LW in register then reading the same register 
-- 3) Forward from memory to memory in case of LW then SW the same register

library IEEE;
use IEEE.std_logic_1164.ALL;

entity forwarder is
    port (
        clk : in std_logic;
        rst : in std_logic;
        head, mid, tail : in std_logic_vector(31 downto 0);
        forwarding_flags : out std_logic_vector(2 downto 0) -- "000" => no forwarding, "001" => mem to mem, "010" => mem to alu, "100" => alu to alu
    );
end forwarder;

architecture rtl of forwarder is

-- head after memory access stage, mid after execute stage, tail after decode stage
signal tail_opcode, mid_opcode, head_opcode : std_logic_vector(3 downto 0); 
--signal flag : std_logic;
--signal forwarding_flags_temp : std_logic_vector(2 downto 0) := "000";

begin
    tail_opcode <= tail(19 downto 16);
    mid_opcode <= mid(19 downto 16);
    head_opcode <= head(19 downto 16);

    process(clk, head, mid, tail)
    begin
        if rst = '1' then
            forwarding_flags <= "000";
            --flag <= '0';
        elsif rising_edge(clk) then
            forwarding_flags <= "000";
            -- load into register followed by a read of the same register 
            if head_opcode = "0100" then  -- load exited memory access stage
                if ((tail_opcode(2 downto 1) = "00" and tail_opcode /= "0000") and 
                ((head(14 downto 10) = tail(9 downto 5)) or (head(14 downto 10) = tail(4 downto 0) and tail(15) = '0'))) -- ADD, SUB
                or (tail_opcode(2 downto 1) = "01" and 
                (head(14 downto 10) = tail(9 downto 5) or head(14 downto 10) = tail(4 downto 0))) -- AND, OR
                or (tail_opcode(2 downto 1) = "10" and head(14 downto 10) = tail(4 downto 0)) then -- LW, SW
                    forwarding_flags <= "010"; -- fw from memory to alu
                    --flag <= '1';
                elsif (mid_opcode = "0101" and head(14 downto 10) = mid(14 downto 10)) then -- case of loading then storing same register
                    forwarding_flags <= "001"; -- fw from memory to memory
                    --flag <= '1';
                else
                    forwarding_flags <= "000";
                    --flag <= '0';
                end if;
            -- write then store register
            elsif (head_opcode(2) = '0' and head_opcode /= "0000") and (mid_opcode = "0101" and head(14 downto 10) = mid(14 downto 10)) then -- case of writing in register then storing it
                forwarding_flags <= "001"; --fw from memory to memory
                --flag <= '1';
            --write then read register
            elsif (mid_opcode(2) = '0' and mid_opcode /= "0000") and 
            (((tail_opcode(2 downto 1) = "00" and tail_opcode /= "0000") and 
            ((mid(14 downto 10) = tail(9 downto 5)) or (mid(14 downto 10) = tail(4 downto 0) and tail(15) = '0'))) -- ADD, SUB
            or (tail_opcode(2 downto 1) = "01" and 
            (mid(14 downto 10) = tail(9 downto 5) or mid(14 downto 10) = tail(4 downto 0))) -- AND, OR
            or (tail_opcode(2 downto 1) = "10" and mid(14 downto 10) = tail(4 downto 0)) -- LW, SW
            or (tail_opcode(2 downto 1) = "11" and mid(14 downto 10) = tail(14 downto 10)) -- JR, BEQZ
            or (tail_opcode = "0111" and mid(14 downto 10) = tail(4 downto 0))) then -- BEQZ 
                forwarding_flags <= "100"; -- fw from alu to alu
                --flag <= '1';
            end if;
        end if;
    end process;

end architecture;