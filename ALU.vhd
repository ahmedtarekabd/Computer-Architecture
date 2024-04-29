LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU IS
    GENERIC (n : INTEGER := 32);
    PORT (
        A, B : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- A-> src1 , B -> src2
        -- 3 bits opcode
        opcode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        F : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        zero_flag : OUT STD_LOGIC;

        overflow_flag : OUT STD_LOGIC; -- Overflow flag
        carry_flag : OUT STD_LOGIC; -- Carry flag
        negative_flag : OUT STD_LOGIC; -- Negative flag

        --old flags
        old_negative_flag : IN STD_LOGIC; -- Old negative flag
        old_zero_flag : IN STD_LOGIC; -- Old zero flag
        old_overflow_flag : IN STD_LOGIC; -- Old overflow flag
        old_carry_flag : IN STD_LOGIC -- Old carry flag

    );
END ALU;
--TODO: check if carry and overflow falgs are updated correctly
-- 000 -> negate (changes zero and negative flags only)
-- 001 -> add (changes all flags)
-- 010 -> sub (changes all flags) --TODO: problem here that if cmp instruction is used, only zero-negative flags should be updated
-- 011 -> mov (changes nothing) (returns B -> src2)
-- 100 -> and (changes zero and negative flags only)
-- 101 -> or (changes zero and negative flags only)
-- 110 -> xor (changes zero and negative flags only)
-- 111 -> not (changes zero and negative flags only)

ARCHITECTURE ALU_Behavior OF ALU IS
    -- signal F_internal : std_logic_vector(n-1 downto 0);
    SIGNAL zero_neg_flags : STD_LOGIC;
    SIGNAL A_integer, B_integer : unsigned(n - 1 DOWNTO 0);
    SIGNAL A_extended, B_extended : unsigned(n DOWNTO 0);
    SIGNAL sum, difference : unsigned(n DOWNTO 0);
    SIGNAL F_internal : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);

BEGIN

    A_integer <= unsigned(A);
    B_integer <= unsigned(B);
    A_extended <= unsigned('0' & A);
    B_extended <= unsigned('0' & B);

    sum <= A_extended + B_extended;
    difference <= A_extended - B_extended;

    F_internal <= STD_LOGIC_VECTOR((NOT A_integer) + 1) WHEN opcode = "000" ELSE --negate
        STD_LOGIC_VECTOR(sum(n - 1 DOWNTO 0)) WHEN opcode = "001" ELSE --add
        STD_LOGIC_VECTOR(difference(n - 1 DOWNTO 0)) WHEN opcode = "010" ELSE --sub
        B WHEN opcode = "011" ELSE --mov
        STD_LOGIC_VECTOR(A_integer AND B_integer) WHEN opcode = "100" ELSE --and
        STD_LOGIC_VECTOR(A_integer OR B_integer) WHEN opcode = "101" ELSE --or
        STD_LOGIC_VECTOR(A_integer XOR B_integer) WHEN opcode = "110" ELSE --xor
        STD_LOGIC_VECTOR(NOT A_integer) WHEN opcode = "111" ELSE --not
        (OTHERS => '0');

    --carry flag
    carry_flag <= '1' WHEN opcode = "001" AND sum(n) = '1' ELSE
        '1' WHEN opcode = "010" AND A_integer < B_integer ELSE
        '0' WHEN opcode = "010" OR opcode = "001" ELSE
        old_carry_flag;

    --overflow flag
    overflow_flag <= '1' WHEN opcode = "001" AND A_integer(n - 1) = B_integer(n - 1) AND A_integer(n - 1) /= sum(n - 1) ELSE
        '1' WHEN opcode = "010" AND A_integer(n - 1) /= B_integer(n - 1) AND A_integer(n - 1) /= difference(n - 1) ELSE
        '0' WHEN opcode = "001" OR opcode = "010" ELSE
        old_overflow_flag;

    --zero and negative flags -> check if its supposed to upadate these flags or no
    zero_neg_flags <= '1' WHEN opcode = "000" OR opcode = "001" OR opcode = "010" OR opcode = "100" OR opcode = "101" OR opcode = "110" OR opcode = "111" ELSE
        '0';

    --zero flag
    zero_flag <= '1' WHEN zero_neg_flags = '1' AND unsigned(F_internal) = 0 ELSE
        '0' WHEN zero_neg_flags = '1' ELSE
        old_zero_flag;

    --negative flag
    negative_flag <= '1' WHEN zero_neg_flags = '1' AND F_internal(n - 1) = '1' ELSE
        '0' WHEN zero_neg_flags = '1' ELSE
        old_negative_flag;

    F <= F_internal; -- Assign the internal signal to the output

END ARCHITECTURE ALU_Behavior;