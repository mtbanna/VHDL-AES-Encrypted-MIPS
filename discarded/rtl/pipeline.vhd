-- All modules are instantiated here
-- Start with a reset signal and enable_reading_instructions = '0'
-- The processor accepts 128 bit AES-encrypted instructions or data
-- To start adding instructions and data to memory, set r_w
-- Instructions or data will be asynchronously written to the address in store_or_read address with the value inside instruction_or_data_to_be_written (max 64 instructions)
-- Start instructions at address 0, and increment by 4 each time. The program counter will automatically start from there.
-- Write data after instructions
-- The Pipeline depth is 8, and runs on a clock whose frequency is 1/10 that of clk. Clk is used to run the encryption/decryption.
-- The stages are Fetch, Decrypt, Decode, Execute, Encrypt, Memory, Decrypt, Write back
-- After the code is done executing, you can view the data in memory by setting r_w and enable_reading_instructions to 0
-- Then change the value of store_or_read_address to view different data

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline is
    port (
        clk : in std_logic;
        rst : in std_logic;
        store_or_read_address :in std_logic_vector(7 downto 0); --address where data/instructions is stored or loaded
        instruction_or_data_to_be_written : in std_logic_vector (127 downto 0);
        enable_reading_instructions : in std_logic; -- enable processor
        r_w: in std_logic; -- '0' => read memory, '1' => write memory
        data_out : out std_logic_vector(127 downto 0) -- to read out data after program execution
    );
end pipeline;

architecture behavioral of pipeline is
    -- Program counter
    signal pc : std_logic_vector(7 downto 0) := x"00";
    -- Clock division
    constant clk_divider : std_logic_vector(3 downto 0) := x"A"; -- AES is 10 rounds
    signal clk_pipe : std_logic := '0'; -- Pipeline clock
    -- Fetch
    signal opcode : std_logic_vector(2 downto 0);
    signal write_enable_in_registers : std_logic;
    signal instruction_output : std_logic_vector (127 downto 0);
    signal next_pc : std_logic_vector(7 downto 0);
    -- Decrypt instruction
    signal instr_ciphertext : std_logic_vector(127 downto 0);
    signal instr_plaintext : std_logic_vector(127 downto 0);
    constant key : std_logic_vector(127 downto 0) := x"8e188f6fcf51e92311e2923ecb5befb4";
    signal temp_pc, temp_pc2 : std_logic_vector(7 downto 0);
    -- Decode instruction
    signal temp_instr : std_logic_vector(31 downto 0);
    signal i_instr : std_logic_vector(31 downto 0);
    signal i_pc : std_logic_vector(31 downto 0);
    signal write_data : std_logic_vector(31 downto 0);
    signal write_enable : std_logic;
    signal write_reg : std_logic_vector(4 downto 0);
    signal reg_out1 : std_logic_vector(31 downto 0);
    signal reg_out2 : std_logic_vector(31 downto 0);
    signal sign_extended : std_logic_vector(31 downto 0);
    signal nxt_pc : std_logic_vector(31 downto 0);
    signal branch_taken : std_logic;
    -- ALU
    signal alu_opcode : std_logic_vector(2 downto 0);
    signal in1 : std_logic_vector(31 downto 0);
    signal in2 : std_logic_vector(31 downto 0);
    signal sign_xtd : std_logic_vector(31 downto 0);
    signal irflag : std_logic;
    signal result : std_logic_vector(31 downto 0);
    -- Data Encryption
    signal data_plaintext : std_logic_vector(127 downto 0);
    signal data_ciphertext : std_logic_vector(127 downto 0);
    signal temp_opcode, temp_opcode2 : std_logic_vector(2 downto 0);
    signal temp_result, temp_result2, temp_result3 : std_logic_vector(31 downto 0);
    -- Data memory access
    signal data_address : std_logic_vector(7 downto 0);
    signal data_input : std_logic_vector(127 downto 0);
    signal data_output : std_logic_vector(127 downto 0);
    -- Data Decryption
    signal loaded_plaintext : std_logic_vector(127 downto 0);
    signal loaded_ciphertext : std_logic_vector(127 downto 0);
    signal temp_write_enable : std_logic;
    signal temp_write_reg, temp_write_reg2, temp_write_reg3, temp_write_reg4 : std_logic_vector(4 downto 0);
begin
    clk_division: entity work.clk_divide
        port map(
            clk => clk,
            rst => rst,
            clk_divider => clk_divider,
            clk_div => clk_pipe
        ); 
    data_out <= data_output;

    memory : entity work.instruction_fetch_and_memory_access
        port map(
            rst => rst,
            enable_reading_instructions => enable_reading_instructions,
            program_counter => pc,
            op_code => opcode,
            store_or_read_address => data_address,
            instruction_or_data_to_be_written => data_input,
            write_enable_in_registers => write_enable_in_registers,
            loaded_data => data_output,
            instruction_output => instruction_output,
            next_program_counter => next_pc
        );
    instruction_decrypt : entity work.aes_dec
        port map(
            clk => clk,
            rst => rst,
            dec_key => key,
            ciphertext => instr_ciphertext,
            plaintext => instr_plaintext,
            done => open
        );
    instruction_decode : entity work.decode
        port map(
            instruction => i_instr,
            pc => i_pc,
            write_data => write_data,
            write_enable => write_enable,
            write_reg => write_reg,
            out1 => reg_out1,
            out2 => reg_out2,
            sign_extended => sign_extended,
            next_pc => nxt_pc,
            branch_taken => branch_taken
        );
    alu : entity work.alu
        port map(
            opcode => alu_opcode,
            in1 => in1,
            in2 => in2,
            sign_xtd => sign_xtd,
            irflag => irflag,
            result => result
        );
    data_encryption : entity work.aes_enc 
        port map(
            clk => clk,
            rst => rst,
            key => key,
            plaintext => data_plaintext,
            ciphertext => data_ciphertext,
            done => open
        );
    data_decryption : entity work.aes_dec
        port map(
            clk => clk,
            rst => rst,
            dec_key => key,
            ciphertext => loaded_ciphertext,
            plaintext => loaded_plaintext,
            done => open
        );

    pipeline : process(clk,clk_pipe)
    begin
        if(rst = '1') then
            pc <= (others => '0');
            opcode <= (others => '0');
            data_address <= (others => '0');
            data_input <= (others => '0');
            instr_ciphertext <= (others => '0');
            i_instr <= (others => '0');
            i_pc <= (others => '0');
            write_data <= (others => '0');
            write_enable <= '0';
            write_reg <= (others => '0');
            alu_opcode <= (others => '0');
            in1 <= (others => '0');
            in2 <= (others => '0');
            sign_xtd <= (others => '0');
            irflag <= '0';
            data_plaintext <= (others => '0');
            loaded_ciphertext <= (others => '0');
        elsif(enable_reading_instructions = '0') then
            if r_w = '0' then
                opcode <= "100";
            else
                opcode <= "101";
            end if;
            data_address <= store_or_read_address;
            data_input <= instruction_or_data_to_be_written;
        elsif(rising_edge(clk_pipe)) then
            -- Fetch timing handled in Testbench since direct input
            -- Decrypt
            instr_ciphertext <= instruction_output; -- Instruction decrypt input
            temp_pc <= next_pc;
            --Decode
            temp_pc2 <= temp_pc; -- passing pc to decode stage
            temp_instr <= instr_plaintext(31 downto 0); -- passing instr to decode stage
            -- ALU
            alu_opcode <= i_instr(18 downto 16);
            in1 <= reg_out1; -- Register values
            in2 <= reg_out2;
            sign_xtd <= sign_extended;
            irflag <= i_instr(15);
            temp_write_reg <= i_instr(14 downto 10); -- passing register address to write back in case of load
            pc <= nxt_pc(7 downto 0); --update program counter on jump or branch
            -- replace this line with: hazard_detector_input <= branch taken

            -- In the following parts, data are passed through crypto in all cases. Opcode selects LW or SW or nothing.
            -- Data Encryption in case of SW
            data_plaintext <= x"000000000000000000000000" & in1;
            temp_opcode <= alu_opcode;
            temp_result <= result; -- alu result
            temp_write_reg2 <= temp_write_reg;
            -- Data Memory access
            opcode <= temp_opcode;
            data_address <= temp_result(7 downto 0);
            data_input <= data_ciphertext; --store input
            temp_write_reg3 <= temp_write_reg2;
            temp_result2 <= temp_result;
            -- Data Decryption in case of LW
            loaded_ciphertext <= data_output;
            temp_write_enable <= write_enable_in_registers;
            temp_write_reg4 <= temp_write_reg3;
            temp_opcode2 <= opcode;
            temp_result3 <= temp_result2;
            -- Write back
            write_reg <= temp_write_reg4;
            if (temp_opcode2 = "101" or temp_opcode2 = "110" or temp_opcode2 = "111") then
                write_enable <= '1';
                write_data <= temp_result3;
            else
                write_enable <= temp_write_enable;
                write_data <= loaded_plaintext(31 downto 0);
            end if;
        elsif(falling_edge(clk_pipe)) then -- read registers on falling edge
        -- Decode
        i_instr <= temp_instr; -- Instruction decode input
        i_pc <= x"000000" & temp_pc2; -- pc input to decode stage
        end if;
    end process;
end architecture;