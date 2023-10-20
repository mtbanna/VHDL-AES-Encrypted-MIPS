
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity instruction_fetch_and_memory_access_and_crypto is
  Port (
    clk, clk2, rst, enable_reading_instructions, take_forwarded_data :in std_logic;
    op_code : in std_logic_vector (3 downto 0);
    store_or_read_address, program_counter :in STD_LOGIC_VECTOR(7 downto 0); 
    compiler_input, instruction_or_data_to_be_written, forwarded_data:STD_LOGIC_VECTOR (127 downto 0) ;
    compiler_store_address:STD_LOGIC_VECTOR (7 downto 0);
    
    write_enable_in_registers: out std_logic_vector(1 downto 0);
    instruction_output, loaded_data : out STD_LOGIC_VECTOR (127 downto 0);
    next_program_counter: out STD_LOGIC_VECTOR (7 downto 0)   
    );
end instruction_fetch_and_memory_access_and_crypto;

architecture Behavioral of instruction_fetch_and_memory_access_and_crypto is

    component instruction_fetch_and_memory_access is
    Port ( 
           rst, enable_reading_instructions, take_forwarded_data : in std_logic; 
           program_counter : in STD_LOGIC_VECTOR (7 downto 0); 
           op_code : in STD_LOGIC_Vector(3 downto 0);                       
           store_or_read_address, compiler_store_address :in STD_LOGIC_VECTOR(7 downto 0);
           instruction_or_data_to_be_written, compiler_input, forwarded_data : in STD_LOGIC_VECTOR (127 downto 0);

           write_enable_in_registers : out STD_LOGIC_Vector(1 downto 0);
           loaded_data: out STD_LOGIC_VECTOR(127 downto 0);
           instruction_output : out STD_LOGIC_VECTOR (127 downto 0);
           next_program_counter: out STD_LOGIC_VECTOR (7 downto 0));
end component;

component aes_enc is 
port (
  clk : in std_logic;
  rst : in std_logic;
  key : in std_logic_vector(127 downto 0);
  plaintext : in std_logic_vector(127 downto 0);
  ciphertext : out std_logic_vector(127 downto 0);
  done : out std_logic		
  );
end component;

component crypto_reseter is
Port ( rst,done,clk : in STD_LOGIC;
 rst_crypto : out STD_LOGIC);
end component;

component aes_dec is
port (
  clk : in std_logic;
  rst : in std_logic;
  dec_key : in std_logic_vector(127 downto 0);
  ciphertext : in std_logic_vector(127 downto 0);
  plaintext : out std_logic_vector(127 downto 0);
  done : out std_logic
  );
end component;

signal instruction_to_be_dec1, enc1_cipher_text_output, loaded_data_to_be_dec2,
compiler_input_after_decryption,instruction_output_at_done,
enc1_cipher_text_output_at_done, loaded_data_at_done,
compiler_input_after_decryption_at_done, forwarded_data_after_encryption,
forwarded_data_after_encryption_at_done : STD_LOGIC_VECTOR (127 downto 0);
signal enc_key: STD_LOGIC_VECTOR (127 downto 0):=x"00000000000000000000000000000000";
signal dec_key: STD_LOGIC_VECTOR (127 downto 0):=x"8e188f6fcf51e92311e2923ecb5befb4";
signal rst_crypto_1, done_1, rst_crypto_2, done_2, rst_crypto_3, done_3, rst_crypto_4, done_4, rst_crypto_5, done_5: std_logic;

begin

    my_instruction_fetch_and_memory_access: instruction_fetch_and_memory_access port map (
       rst=>rst,
       take_forwarded_data=>take_forwarded_data,
       enable_reading_instructions=>enable_reading_instructions,
       program_counter=> program_counter,
       op_code=>op_code,
       store_or_read_address=>store_or_read_address,
       forwarded_data=>forwarded_data_after_encryption,
       instruction_or_data_to_be_written=>enc1_cipher_text_output,
       compiler_input=>compiler_input_after_decryption,
       compiler_store_address=>compiler_store_address,
       write_enable_in_registers=>write_enable_in_registers,
       loaded_data=>loaded_data_to_be_dec2,
       instruction_output=> instruction_to_be_dec1,
       next_program_counter=> next_program_counter
       );

    first_decryptor: aes_dec port map ( 
       clk=>clk2,
       rst=>rst_crypto_1,
       dec_key=>dec_key,
       ciphertext=>instruction_to_be_dec1,
       plaintext=>instruction_output_at_done,
       done=>done_1
       );

    instruction_output<= (others=>'0') when ( (enable_reading_instructions='0') or (rst='1')) else
    instruction_output_at_done  when ((done_1='1')and (rst='0'));
    

    first_decryptor_resetter:  crypto_reseter port map( 
       clk=>clk,
       rst=>rst,
       done=>done_1,
       rst_crypto=>rst_crypto_1
       );  

    first_encryptor: aes_enc port map(
        clk=>clk2,
        rst=>rst_crypto_2,
        key=>enc_key,
        plaintext=>instruction_or_data_to_be_written,
        ciphertext=>enc1_cipher_text_output_at_done,
        done=>done_2
        );

    enc1_cipher_text_output<=enc1_cipher_text_output_at_done when ((done_2='1')and (rst='0')) else
    (others=>'0') when rst='1';

    first_encryptor_resetter:  crypto_reseter port map( 
       clk=>clk,
       rst=>rst,
       done=>done_2,
       rst_crypto=>rst_crypto_2
       );  

    second_decryptor: aes_dec port map ( 
       clk=>clk2,
       rst=>rst_crypto_3,
       dec_key=>dec_key,
       ciphertext=>loaded_data_to_be_dec2,
       plaintext=>loaded_data_at_done,
       done=>done_3
       );

    loaded_data<=   (others=>'0') when ( (enable_reading_instructions='0') or (rst='1') or op_code/="0100") else
    loaded_data_at_done when((done_3='1')and (rst='0'));

    second_decryptor_resetter:  crypto_reseter port map( 
       clk=>clk,
       rst=>rst,
       done=>done_3,
       rst_crypto=>rst_crypto_3
       );  

    second_encryptor: aes_enc port map(
        clk=>clk2,
        rst=>rst_crypto_4,
        key=>enc_key,
        plaintext=>compiler_input,
        ciphertext=>compiler_input_after_decryption_at_done,
        done=>done_4
        );

    compiler_input_after_decryption<=compiler_input_after_decryption_at_done when((done_4='1')and (rst='0')) else
    (others=>'0') when rst='1';

    second_encryptor_resetter:  crypto_reseter port map( 
       clk=>clk,
       rst=>rst,
       done=>done_4,
       rst_crypto=>rst_crypto_4
       );  

third_encryptor: aes_enc port map(
        clk=>clk2,
        rst=>rst_crypto_5,
        key=>enc_key,
        plaintext=>forwarded_data,
        ciphertext=>forwarded_data_after_encryption_at_done,
        done=>done_5
        );

  forwarded_data_after_encryption<=forwarded_data_after_encryption_at_done when((done_5='1')and (rst='0')) else
    (others=>'0') when rst='1';

    third_encryptor_resetter:  crypto_reseter port map( 
       clk=>clk,
       rst=>rst,
       done=>done_5,
       rst_crypto=>rst_crypto_5
       );  

end Behavioral;
