LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY memory_tb IS
END ENTITY memory_tb;

ARCHITECTURE behavior OF memory_tb IS

    COMPONENT memory
        PORT (
            clk : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            write_enable : IN STD_LOGIC;
            write_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            read_enable : IN STD_LOGIC;
            read_data : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            protect_signal : IN STD_LOGIC;
            free_signal : IN STD_LOGIC;
            protected_address_access : OUT STD_LOGIC
        );
    END COMPONENT;

    --Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL address : STD_LOGIC_VECTOR (11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_enable : STD_LOGIC := '0';
    SIGNAL write_data : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_enable : STD_LOGIC := '0';
    SIGNAL protect_signal : STD_LOGIC := '0';
    SIGNAL free_signal : STD_LOGIC := '0';

    --Outputs
    SIGNAL read_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL protected_address_access : STD_LOGIC;

    -- Clock period definitions
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : memory PORT MAP(
        clk => clk,
        address => address,
        write_enable => write_enable,
        write_data => write_data,
        read_enable => read_enable,
        read_data => read_data,
        protect_signal => protect_signal,
        free_signal => free_signal,
        protected_address_access => protected_address_access
    );

    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- hold reset state for 100 ns.
        WAIT FOR 105 ns;
        protect_signal <= '0';
        free_signal <= '0';
        read_enable <= '0';

        --write in address 0 the value 1010101010101010
        address <= "000000000000";
        write_enable <= '1';
        write_data <= "10101010101010101010111111111110";
        WAIT FOR clk_period;

        --output the value in address 0 which is 1010101010101010
        read_enable <= '1';
        WAIT FOR clk_period;

        --protect this memory location 
        protect_signal <= '1';
        address <= "000000000000";
        WAIT FOR clk_period;

        --try to write in the protected memory location
        protect_signal <= '0';
        address <= "000000000000";
        write_enable <= '1';
        write_data <= "01010101010101010101011111111111";
        WAIT FOR clk_period;

        --try to read from the protected memory location the expected -> 1010101010101010
        read_enable <= '1';
        WAIT FOR clk_period;

        --free the memory location
        protect_signal <= '0';
        free_signal <= '1';
        WAIT FOR clk_period;

        --try to write in the freed memory location
        free_signal <= '0';
        write_enable <= '1';
        write_data <= "11110000111100001111000011110000";
        WAIT FOR clk_period;

        --try to read from the freed memory location the expected -> 0000000000000000
        read_enable <= '1';
        WAIT FOR clk_period;

        WAIT;
    END PROCESS;

END;