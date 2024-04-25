-- Testbench for fetch.vhd

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY processor_tb IS
END ENTITY processor_tb;

ARCHITECTURE tb_arch OF processor_tb IS
    -- Component declaration
    COMPONENT processor
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC
        );
    END COMPONENT processor;

    -- Signal declarations
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';
    -- Declare other signals here as needed

BEGIN
    -- Instantiate the processor module
    processor1 : processor PORT MAP(
        clk,
        reset
    );

    -- Clock process
    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR 5 ns;
        clk <= '0';
        WAIT FOR 5 ns;
    END PROCESS clk_process;

    -- Add stimulus processes here to drive inputs and monitor outputs
    stimulus_process : PROCESS
    BEGIN

        reset <= '1';
        WAIT FOR 10 ns;

        -- Cycle 1
        reset <= '0';
        WAIT FOR 10 ns;


        -- Cycle 2
        WAIT FOR 10 ns;

        WAIT;

    END PROCESS stimulus_process;

END ARCHITECTURE tb_arch;