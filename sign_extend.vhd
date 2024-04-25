LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY sign_extend IS
    GENERIC (
        INPUT_WIDTH : NATURAL := 16; -- Width of the input signal
        OUTPUT_WIDTH : NATURAL := 32 -- Width of the output signal
    );
    PORT (
        enable : IN STD_LOGIC;
        input : IN STD_LOGIC_VECTOR(INPUT_WIDTH - 1 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR(OUTPUT_WIDTH - 1 DOWNTO 0)
    );
END ENTITY sign_extend;

ARCHITECTURE Behavioral OF sign_extend IS
BEGIN
    PROCESS (input)
    BEGIN
        IF enable = '0' THEN
            output <= (OUTPUT_WIDTH - INPUT_WIDTH - 1 DOWNTO 0 => '0') & input; -- LDM only
        ELSE
            output <= (OUTPUT_WIDTH - INPUT_WIDTH - 1 DOWNTO 0 => input(INPUT_WIDTH - 1)) & input; -- Sign extension
        END IF;
    END PROCESS;
END ARCHITECTURE Behavioral;