LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SignExtend IS
    GENERIC (
        INPUT_WIDTH : NATURAL := 16; -- Width of the input signal
        OUTPUT_WIDTH : NATURAL := 32 -- Width of the output signal
    );
    PORT (
        input : IN STD_LOGIC_VECTOR(INPUT_WIDTH - 1 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR(OUTPUT_WIDTH - 1 DOWNTO 0)
    );
END ENTITY SignExtend;

ARCHITECTURE Behavioral OF SignExtend IS
BEGIN
    PROCESS (input)
    BEGIN
        output <= (OUTPUT_WIDTH - INPUT_WIDTH - 1 DOWNTO 0 => input(INPUT_WIDTH - 1)) & input; -- Sign extension
    END PROCESS;
END ARCHITECTURE Behavioral;