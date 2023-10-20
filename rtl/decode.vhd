----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2021 01:54:34
-- Design Name: 
-- Module Name: decode - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- 
-- Description: 
-- This module decodes instructions, outputs the register contents, sign extends any immediate value,
-- calculates branch and jump addresses, and outputs a flag that indicates whether the branch is taken,
-- and the new value of the program counter. It takes a register address to be written as input, and
-- writes the register as soon as write_enable bit is set.
--
-- Documentation:
-- Outputs 3 values to the ALU: two registers from register file, and a sign extended immediate
-- Any registers to be read are output on out1 and out2 by their order of appearance in the instruction
-- In the case of Jump, out2 is to be ignored. In the case of Load, out1 is to be ignored
-- Any immediate value in the instruction is output to sign_extended, else don't care
-- Branch and Jump addresses are calculated and output on next_pc, else don't care
-- branch_taken indicates whether branch is taken or not
-- Registers are written using write_reg for address of register and write_data for data to be written
-- Data is written as soon as write_enable is set, except for R0 as it is hardwired to zero.
--
-- Dependencies: 
-- register_file.vhd
-- sign_extend.vhd
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decode is
    Port ( instruction : in std_logic_vector (31 downto 0); -- opcode(19 downto 16), I/R indicator 15
                                                            --r0(14 downto 10), I/R1(9 downto 5), I/R2(4 downto 0) 
           pc : in std_logic_vector (31 downto 0);
           write_data : in std_logic_vector (31 downto 0);
           write_enable : in std_logic;
           write_reg : in std_logic_vector (4 downto 0);        
           out1 : out std_logic_vector (31 downto 0); --Ignore on load
           out2 : out std_logic_vector (31 downto 0); --Ignore on jump
           sign_extended : out std_logic_vector(31 downto 0);
           next_pc : out std_logic_vector (31 downto 0)   --return to instruction decode
           );                  
end decode;

architecture Behavioral of decode is
    component register_file is
    Port ( read_reg1 : in std_logic_vector (4 downto 0);
           read_reg2 : in std_logic_vector (4 downto 0);
           write_reg : in std_logic_vector (4 downto 0);
           write_data : in std_logic_vector (31 downto 0);
           write_enable: in std_logic;
           read_data1 : out std_logic_vector (31 downto 0);
           read_data2 : out std_logic_vector (31 downto 0));
    end component;
    
    component sign_extend is
    Port ( immediate : in std_logic_vector (4 downto 0);
           sign_extended : out std_logic_vector (31 downto 0));
    end component;
    
    signal opcode : std_logic_vector(3 downto 0);
    signal indicator: std_logic;
    signal i_r1: std_logic_vector(4 downto 0); -- Immediate / 1st operand
    signal i_r2: std_logic_vector(4 downto 0); -- Immediate / 2nd operand
    signal reg_data1: std_logic_vector(31 downto 0);
    signal reg_data2: std_logic_vector(31 downto 0);
    signal immediate: std_logic_vector(4 downto 0):=(others=>'0');
    signal sign_xtd : std_logic_vector(31 downto 0);
    
begin
    opcode <= instruction(19 downto 16);
    indicator <= instruction(15);
    -- In case of branch or jump, fetch register in (14 downto 10) instead
    i_r1 <= instruction(14 downto 10) when (opcode = "0111") or (opcode = "0110") or (opcode = "0101") else 
            instruction(9 downto 5);
    i_r2 <= instruction(4 downto 0);
    
    regFile: register_file port map(
        read_reg1 => i_r1,
        read_reg2 => i_r2,
        write_reg => write_reg,
        write_data => write_data,
        write_enable => write_enable,
        read_data1 => reg_data1,
        read_data2 => reg_data2
    );
    
    signExtend: sign_extend port map(
        immediate => immediate,
        sign_extended => sign_xtd
    );
    
    sign_extended <= sign_xtd;
    out1 <= reg_data1;
    out2 <= reg_data2;
    -- Decide on which input to sign extend if any
    immediate <= i_r2 when (indicator = '1' and ((opcode = "1000") or (opcode = "0001"))) else
                 instruction(9 downto 5) when ((opcode = "0100") or (opcode = "0101") or (opcode = "0110") or (opcode = "0111"));
    -- Calculate new program counter in case of jump or branch
    next_pc <= std_logic_vector(unsigned(sign_xtd) + unsigned(reg_data2)) when opcode = "0111" else
               std_logic_vector(unsigned(sign_xtd) + unsigned(reg_data1)) when opcode = "0110" else
               pc;
   
end Behavioral;
