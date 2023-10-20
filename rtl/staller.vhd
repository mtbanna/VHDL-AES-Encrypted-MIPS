--Intended behavior:
--------------------------
-- Cases for stalling once:
-- 1) load register then read same register in the following instruction => forward from memory to ALU
-- 2) load register followed by independent instruction followed by BEQZ or JR that read register
-- 3) any branch or jump
--------------------------
-- Cases for stalling twice:
-- 1) load register followed immediately by BEQZ or JR that reads register 

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity staller is
    port (
        clk : in std_logic;
        rst : in std_logic;
        branch_taken : in std_logic;
        head, mid, tail : in std_logic_vector(31 downto 0);
        stall : out std_logic
    );
end staller;

architecture rtl of staller is

-- head b4 memory access stage, mid b4 execute stage, tail b4 decode stage
signal tail_opcode, mid_opcode, head_opcode : std_logic_vector(3 downto 0);
--signal reset_stall_counter : unsigned(1 downto 0) := "00"; 
--signal stall_temp : std_logic := '0'; 

begin
    tail_opcode <= tail(19 downto 16);
    mid_opcode <= mid(19 downto 16);
    head_opcode <= head(19 downto 16);

process(clk)
begin
    if rst = '1' then
        stall <= '0';
    elsif rising_edge(clk) then
        stall <= '0';
        -- load into register followed by a read of the same register 
        if mid_opcode = "0100" and (((tail_opcode(2 downto 1) = "00" and tail_opcode /= "0000") and  --load b4 execute stage
        ((mid(14 downto 10) = tail(9 downto 5)) or (mid(14 downto 10) = tail(4 downto 0) and tail(15) = '0'))) -- ADD, SUB
        or (tail_opcode(2 downto 1) = "01" and 
        (mid(14 downto 10) = tail(9 downto 5) or mid(14 downto 10) = tail(4 downto 0))) -- AND, OR
        or (tail_opcode(2 downto 1) = "10" and mid(14 downto 10) = tail(4 downto 0)) -- LW, SW
        or (tail_opcode = "0101" and mid(14 downto 10) = tail(14 downto 10))) then -- SW
            stall <= '1';
        --    reset_stall_counter <= "01";
        -- write into register followed by JR or BEQZ using value from the same register
        elsif ((mid_opcode(2) = '0' and mid_opcode /= "0000") or mid_opcode = "0100") and ((tail_opcode(2 downto 1) = "11" and mid(14 downto 10) = tail(14 downto 10)) -- JR, BEQZ
        or (tail_opcode = "0111" and mid(14 downto 10) = tail(4 downto 0))) then -- BEQZ
            stall <= '1';
        --    reset_stall_counter <= "10";
        -- write into register followed by independent instruction followed by BEQZ or JR using value from same register => load is in memory access stage
        elsif ((head_opcode(2) = '0' and head_opcode /= "0000") or head_opcode = "0100") and ((tail_opcode(2 downto 1) = "11" and head(14 downto 10) = tail(14 downto 10)) -- JR, BEQZ
        or (tail_opcode = "0111" and head(14 downto 10) = tail(4 downto 0))) then --BEQZ
            stall <= '1';
        --    reset_stall_counter <= "01";
        -- stall on branch or jump
        elsif (mid_opcode(2 downto 0) = "111" and branch_taken = '1') -- BEQZ
        or (mid_opcode(2 downto 0) = "110") then --JR
            stall <= '1';
        --    reset_stall_counter <= "01";
        end if; 
    end if;
end process;

end architecture;