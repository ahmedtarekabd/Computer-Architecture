-- FILEPATH: /e:/College/3- Senior 1/Semester 2/Computer Architecture/Project/Code/SignExtend_tb.vhd
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SignExtend_tb IS
END SignExtend_tb;

ARCHITECTURE behavior OF SignExtend_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT SignExtend
        GENERIC (
            INPUT_WIDTH : NATURAL := 16; -- Width of the input signal
            OUTPUT_WIDTH : NATURAL := 32 -- Width of the output signal
        );
        PORT (
            input : IN STD_LOGIC_VECTOR(INPUT_WIDTH - 1 DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR(OUTPUT_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    --Inputs
    SIGNAL input : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    --Outputs
    SIGNAL output : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL done : STD_LOGIC := '0';

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : SignExtend PORT MAP(
        input => input,
        output => output
    );

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- hold reset state for 100 ns.
        WAIT FOR 100 ns;

        input <= "0000000000000001"; -- Test 1: Extend 1
        WAIT FOR 100 ns;
        ASSERT output = "00000000000000000000000000000001" REPORT "Test 1 failed" SEVERITY error;

        input <= "1000000000000000"; -- Test 2: Extend negative number
        WAIT FOR 100 ns;
        ASSERT output = "11111111111111111000000000000000" REPORT "Test 2 failed" SEVERITY error;

        input <= "0111111111111111"; -- Test 3: Extend large positive number
        WAIT FOR 100 ns;
        ASSERT output = "00000000000000000111111111111111" REPORT "Test 3 failed" SEVERITY error;
        -- done <= '1';

        -- done
        WAIT;
    END PROCESS;

    -- -- Output process
    -- output_proc : PROCESS
    -- BEGIN
    --     WAIT UNTIL rising_edge(done);
    --     REPORT "Output: " & to_string(output);
    -- END PROCESS;

END;