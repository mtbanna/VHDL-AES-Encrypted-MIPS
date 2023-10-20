library IEEE;
use IEEE.std_logic_1164.ALL;

entity mips_controller is
    port (
        clk : in std_logic;
        rst : in std_logic;
        branch_taken : in std_logic;
        instruction : in std_logic_vector(31 downto 0); -- instruction being currently decoded opcode(19 downto 16), I/R indicator 15
        -- r0(14 downto 10), I/R1(9 downto 5), I/R2(4 downto 0)
        stall : out std_logic;
        forwarding_flags : out std_logic_vector(2 downto 0) 
    );
end mips_controller;

architecture rtl of mips_controller is

    -- head after memory access, mid1 after ALU, mid2 after decode stage, tail before decode stage
    -- pass head, mid1, mid2 to forwarding unit. pass mid1, mid2, tail to stall unit
    signal head, mid1, mid2, tail : std_logic_vector(31 downto 0) := x"00000000"; -- instruction FIFO
    signal s_stall : std_logic;

    component staller is 
        port (
            clk : in std_logic;
            rst : in std_logic;
            branch_taken : in std_logic;
            head, mid, tail : in std_logic_vector(31 downto 0);
            stall : out std_logic
        );
    end component;

    component forwarder is 
        port (
            clk : in std_logic;
            rst : in std_logic;
            head, mid, tail : in std_logic_vector(31 downto 0);
            forwarding_flags : out std_logic_vector(2 downto 0) -- "000" => no forwarding, "001" => mem to mem, "010" => mem to alu, "100" => alu to alu
        );
    end component;
begin

    stall <= s_stall;

    my_staller : staller 
        port map(
            clk => clk,
            rst => rst,
            branch_taken => branch_taken,
            head => mid1,
            mid => mid2,
            tail => tail,
            stall => s_stall
        );

    my_forwarder : forwarder
        port map(
            clk => clk,
            rst => rst,
            head => head,
            mid => mid1,
            tail => mid2,
            forwarding_flags => forwarding_flags
        );

process(clk)
begin
    if rst = '1' then
        head <= x"00000000";
        mid1 <= x"00000000";
        mid2 <= x"00000000";
        tail <= x"00000000";
    elsif falling_edge(clk) then
        head <= mid1;
        mid1 <= mid2;
        if s_stall = '0' then
            mid2 <= tail;
            tail <= instruction;
        else 
            mid2 <= x"00000000";
            tail <= tail;
        end if;
    end if;
end process;


end architecture;