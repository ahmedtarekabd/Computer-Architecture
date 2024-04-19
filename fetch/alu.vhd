library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    generic (n: integer := 32);
    port (
        A, B: in std_logic_vector(n-1 downto 0); -- A-> src1 , B -> src2
        -- 3 bits opcode
        opcode: in std_logic_vector(2 downto 0); 
        F: out std_logic_vector(n-1 downto 0);
        zero_flag: out std_logic;

        overflow_flag: out std_logic; -- Overflow flag
        carry_flag: out std_logic; -- Carry flag
        negative_flag: out std_logic; -- Negative flag

        --old flags
        old_negative_flag: in std_logic := '0'; -- Old negative flag
        old_zero_flag: in std_logic := '0'; -- Old zero flag
        old_overflow_flag: in std_logic := '0'; -- Old overflow flag
        old_carry_flag: in std_logic := '0' -- Old carry flag

    );
end ALU;

-- 000 -> nop (changes nothing)
-- 001 -> add (changes all flags)
-- 010 -> sub (changes all flags)
-- 011 -> mov (changes nothing)
-- 100 -> and (changes zero and negative flags only)
-- 101 -> or (changes zero and negative flags only)
-- 110 -> xor (changes zero and negative flags only)
-- 111 -> not (changes zero and negative flags only)

architecture ALU_Behavior of ALU is
    -- signal F_internal : std_logic_vector(n-1 downto 0);
    signal zero_neg_flags : std_logic; 
    signal A_integer, B_integer: unsigned(n-1 downto 0);
    signal A_extended, B_extended: unsigned(n downto 0);
    signal sum, difference: unsigned(n downto 0);
    signal F_internal: std_logic_vector(n-1 downto 0);

begin

    A_integer <= unsigned(A);
    B_integer <= unsigned(B);
    A_extended <= unsigned('0' & A);
    B_extended <= unsigned('0' & B);

    sum <= A_extended + B_extended;
    difference <= A_extended - B_extended;

    F_internal <= (others => '0') when opcode = "000" else
        std_logic_vector(sum(n-1 downto 0)) when opcode = "001" else
        std_logic_vector(difference(n-1 downto 0)) when opcode = "010" else
        A when opcode = "011" else
        std_logic_vector(A_integer and B_integer) when opcode = "100" else
        std_logic_vector(A_integer or B_integer) when opcode = "101" else
        std_logic_vector(A_integer xor B_integer) when opcode = "110" else
        std_logic_vector(not A_integer) when opcode = "111" else
        (others => '0');

    --carry flag
    carry_flag <= '1' when opcode = "001" and sum(n) = '1' else
        '1' when opcode = "010" and A_integer < B_integer else
        '0' when opcode = "010" or opcode = "001" else
        old_carry_flag;

    --overflow flag
    overflow_flag <= '1' when opcode = "001" and A_integer(n-1) = B_integer(n-1) and A_integer(n-1) /= sum(n-1) else
        '1' when opcode = "010" and A_integer(n-1) /= B_integer(n-1) and A_integer(n-1) /= difference(n-1) else
        '0' when opcode = "001" or opcode = "010" else
        old_overflow_flag;
    
    --zero and negative flags -> check if its supposed to upadate these flags or no
    zero_neg_flags <= '1' when opcode = "001" or opcode = "010" or opcode = "100" or opcode = "101" or opcode = "110" or opcode = "111" else
        '0';
    
    --zero flag
    zero_flag <= '1' when zero_neg_flags = '1' and unsigned(F_internal) = 0 else 
        '0' when zero_neg_flags = '1' else
        old_zero_flag;

    --negative flag
    negative_flag <= '1' when zero_neg_flags = '1' and F_internal(n-1) = '1' else
        '0' when zero_neg_flags = '1' else
        old_negative_flag;


    F <= F_internal; -- Assign the internal signal to the output

end architecture ALU_Behavior;