library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_tb is
end ALU_tb;

architecture behavior of ALU_tb is 

    -- Component Declaration for the Unit Under Test (UUT)
    component ALU
    generic (n: integer := 32);
    port(
          A : in  std_logic_vector(31 downto 0);
          B : in  std_logic_vector(31 downto 0);
          opcode : in  std_logic_vector(2 downto 0);
          F : out  std_logic_vector(31 downto 0);
          zero_flag : out  std_logic;
          overflow_flag: out std_logic
    );
    end component;

    --Inputs
    signal A : std_logic_vector(31 downto 0) := (others => '0');
    signal B : std_logic_vector(31 downto 0) := (others => '0');
    signal opcode : std_logic_vector(2 downto 0) := (others => '0');

    --Outputs
    signal F : std_logic_vector(31 downto 0);
    signal zero_flag : std_logic;
    signal overflow_flag : std_logic;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: ALU generic map (32) 
          port map (
             A => A,
             B => B,
             opcode => opcode,
             F => F,
             zero_flag => zero_flag,
             overflow_flag => overflow_flag
          );

    -- Stimulus process
    stim_proc: process
    begin  
        -- NOP operation
        opcode <= "000";
        wait for 10 ns;
        
        -- ADD operation that triggers overflow
        A <= "11111111111111111111111111111111"; B <= "00000000000000000000000000000001"; opcode <= "001";
        wait for 10 ns;
        -- Expected output: F = "00000000000000000000000000000000", zero_flag = '1', overflow_flag = '1'
       
        -- ADD operation
        A <= "00000000000000000000000000000001"; B <= "00000000000000000000000000000001"; opcode <= "001";
        wait for 10 ns;
        -- Expected output: F = "00000000000000000000000000000010", zero_flag = '0', overflow_flag = '0'

        --error
        -- SUB operation
        A <= "00000000000000000000000000000010"; B <= "00000000000000000000000000000001"; opcode <= "010";
        wait for 10 ns;
        -- Expected output: F = "00000000000000000000000000000001", zero_flag = '0', overflow_flag = '0'

        -- MOVE operation
        A <= "00000000000000000000000000000001"; opcode <= "011";
        wait for 10 ns;
        -- Expected output: F = "00000000000000000000000000000001", zero_flag = '0', overflow_flag = '0'

        -- AND operation
        A <= "00000000000000000000000000000001"; B <= "00000000000000000000000000000001"; opcode <= "100";
        wait for 10 ns;
        -- Expected output: F = "00000000000000000000000000000001", zero_flag = '0', overflow_flag = '0'

        -- OR operation
        A <= "00000000000000000000000000000001"; B <= "00000000000000000000000000000001"; opcode <= "101";
        wait for 10 ns;
        -- Expected output: F = "00000000000000000000000000000001", zero_flag = '0', overflow_flag = '0'

        -- XOR operation
        A <= "00000000000000000000000000000001"; B <= "00000000000000000000000000000001"; opcode <= "110";
        wait for 10 ns;
        -- Expected output: F = "00000000000000000000000000000000", zero_flag = '1', overflow_flag = '0'

        -- NOT operation
        A <= "00000000000000000000000000000001"; opcode <= "111";
        wait for 10 ns;
        -- Expected output: F = "11111111111111111111111111111110", zero_flag = '0', overflow_flag = '0'
            
        wait;
    end process;

end;