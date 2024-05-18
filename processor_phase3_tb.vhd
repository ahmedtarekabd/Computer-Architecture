LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY processor_phase3_tb IS
END ENTITY processor_phase3_tb;

ARCHITECTURE tb_arch OF processor_phase3_tb IS

    -- Component declaration
    COMPONENT processor_phase3
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            RST_signal : IN STD_LOGIC;
            interrupt_signal : IN STD_LOGIC;
            in_port_from_processor : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            out_port_to_processor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            EPC_out_to_processor : OUT STD_LOGIC_VECTOR(32 DOWNTO 0)
        );
    END COMPONENT processor_phase3;

    -- Signal declaration
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';
    SIGNAL RST_signal : STD_LOGIC := '0';
    SIGNAL interrupt_signal : STD_LOGIC := '0';
    SIGNAL in_port_from_processor : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL out_port_to_processor : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL EPC_out_to_processor : STD_LOGIC_VECTOR(32 DOWNTO 0);

    CONSTANT clk_period : TIME := 10 ns;
BEGIN

    -- Instantiate the DUT
    dut : processor_phase3
    PORT MAP(
        clk => clk,
        reset => reset,
        RST_signal => RST_signal,
        interrupt_signal => interrupt_signal,
        in_port_from_processor => in_port_from_processor,
        out_port_to_processor => out_port_to_processor,
        EPC_out_to_processor => EPC_out_to_processor
    );

    -- Clock process
    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR clk_period/2;
        clk <= '0';
        WAIT FOR clk_period/2;
    END PROCESS clk_process;

    -- Stimulus process
    stimulus_process : PROCESS
    BEGIN

        -- Add reset here
        reset <= '1';
        RST_signal <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        RST_signal <= '0';
        WAIT FOR clk_period;

        -- Add stimulus here
        -- Example:
        -- in_port_from_processor <= "00000000000000000000000000000001";
        -- WAIT FOR clk_period;
        -- in_port_from_processor <= "00000000000000000000000000000010";
        -- WAIT FOR clk_period;
        -- in_port_from_processor <= "00000000000000000000000000000011";
        -- WAIT FOR clk_period;
        -- ...

        -- Add test cases here

        WAIT;
    END PROCESS stimulus_process;

END ARCHITECTURE tb_arch;