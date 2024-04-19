library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_tb is
end ALU_tb;

architecture behavior of ALU_tb is 
    constant n: integer := 32;
    signal A, B: std_logic_vector(n-1 downto 0);
    signal opcode: std_logic_vector(2 downto 0);
    signal F: std_logic_vector(n-1 downto 0);
    signal zero_flag, overflow_flag, carry_flag, negative_flag: std_logic;
    signal old_negative_flag, old_zero_flag, old_overflow_flag, old_carry_flag: std_logic;

    component ALU is
        generic (n: integer := 32);
        port (
            A, B: in std_logic_vector(n-1 downto 0);
            opcode: in std_logic_vector(2 downto 0);
            F: out std_logic_vector(n-1 downto 0);
            zero_flag: out std_logic;
            overflow_flag: out std_logic;
            carry_flag: out std_logic;
            negative_flag: out std_logic;
            old_negative_flag: in std_logic;
            old_zero_flag: in std_logic;
            old_overflow_flag: in std_logic;
            old_carry_flag: in std_logic
        );
    end component;

begin 
    uut: ALU generic map (n => 32)
         port map (
            A => A,
            B => B,
            opcode => opcode,
            F => F,
            zero_flag => zero_flag,
            overflow_flag => overflow_flag,
            carry_flag => carry_flag,
            negative_flag => negative_flag,
            old_negative_flag => old_negative_flag,
            old_zero_flag => old_zero_flag,
            old_overflow_flag => old_overflow_flag,
            old_carry_flag => old_carry_flag
         );

    tb : process
    begin

        -- -- Initialize old flags
        -- old_negative_flag <= '0';
        -- old_zero_flag <= '0';
        -- old_overflow_flag <= '0';
        -- old_carry_flag <= '0';

        -- Test case 1: ADD operation
        A <= "00000000000000000000000000000001"; B <= "00000000000000000000000000000001"; opcode <= "001";
        wait for 10 ns;

        -- Update old flags
        old_negative_flag <= negative_flag;
        old_zero_flag <= zero_flag;
        old_overflow_flag <= overflow_flag;
        old_carry_flag <= carry_flag;

        -- -- Test case 1: ADD operation
        -- A <= "00000000000000000000000000000001"; B <= "00000000000000000000000000000001"; opcode <= "001";
        -- wait for 10 ns;

        -- -- Test case 2: SUB operation
        -- A <= "00000000000000000000000000000010"; B <= "00000000000000000000000000000001"; opcode <= "010";
        -- wait for 10 ns;
        
        -- -- Test case 4: AND operation
        -- A <= "00000000000000000000000000001111"; B <= "00000000000000000000000000001111"; opcode <= "100";
        -- wait for 10 ns;

        -- -- Test case 5: OR operation
        -- A <= "00000000000000000000000000001111"; B <= "00000000000000000000000000010000"; opcode <= "101";
        -- wait for 10 ns;

        -- -- Test case 6: XOR operation
        -- A <= "00000000000000000000000000001111"; B <= "00000000000000000000000000001111"; opcode <= "110";
        -- wait for 10 ns;

        --test case 7 : move operation
        A <= "00000000000000000000000000001111"; opcode <= "011";
        wait for 10 ns;

        -- Update old flags
        old_negative_flag <= negative_flag;
        old_zero_flag <= zero_flag;
        old_overflow_flag <= overflow_flag;
        old_carry_flag <= carry_flag;

        -- -- Test case 8: ADD operation that triggers overflow
        -- A <= "01111111111111111111111111111111"; B <= "00000000000000000000000000000001"; opcode <= "001";
        -- wait for 10 ns;

        -- -- Test case 9: SUB operation that triggers overflow
        -- A <= "00000000000000000000000000000001"; B <= "01111111111111111111111111111111"; opcode <= "010";
        -- wait for 10 ns;

        -- -- Test case 10: NOT operation
        -- A <= "00000000000000000000000000001111"; opcode <= "111";
        -- wait for 10 ns;
        -- wait;

        -- -- Test case 11: SUB that triggers carry
        A <= "00000000000000000000000000000000"; B <= "00000000000000000000000000000001"; opcode <= "010";
        wait for 10 ns;
        -- Update old flags
        old_negative_flag <= negative_flag;
        old_zero_flag <= zero_flag;
        old_overflow_flag <= overflow_flag;
        old_carry_flag <= carry_flag;

        A <= "00000000000000000000000000000001"; B <= "00000000000000000000000000000010"; opcode <= "010";
        wait for 10 ns;
        -- Update old flags
        old_negative_flag <= negative_flag;
        old_zero_flag <= zero_flag;
        old_overflow_flag <= overflow_flag;
        old_carry_flag <= carry_flag;

        --test case 12 : ADD that triggers overflow
        A <= "10000000000000000000000000000000"; -- A = -2147483648 (32-bit signed integer)
        B <= "01111111111111111111111111111111"; -- B = 2147483647 (32-bit signed integer)
        opcode <= "010"; -- SUB operation
        wait for 10 ns;
        -- Update old flags
        old_negative_flag <= negative_flag;
        old_zero_flag <= zero_flag;
        old_overflow_flag <= overflow_flag;
        old_carry_flag <= carry_flag;

        --test case 7 : move operation
        A <= "00000000000000000000000000001111"; opcode <= "011";
        -- Update old flags
        old_negative_flag <= negative_flag;
        old_zero_flag <= zero_flag;
        old_overflow_flag <= overflow_flag;
        old_carry_flag <= carry_flag;
        wait;


    end process;
end;