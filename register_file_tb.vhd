LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY register_file_tb IS
END register_file_tb;

ARCHITECTURE behavior OF register_file_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT register_file
        GENERIC (n : INTEGER := 8);
        PORT (
            clk : IN STD_LOGIC;
            write_enable1 : IN STD_LOGIC;
            write_enable2 : IN STD_LOGIC;
            write_address1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_address2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_data1 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            write_data2 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            read_enable : IN STD_LOGIC;
            read_address1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_address2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_data1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            read_data2 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT;

    --Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL write_enable1 : STD_LOGIC := '0';
    SIGNAL write_enable2 : STD_LOGIC := '0';
    SIGNAL write_address1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_address2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_data1 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_data2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_enable : STD_LOGIC := '0';
    SIGNAL read_address1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_address2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');

    --Outputs
    SIGNAL read_data1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_data2 : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Clock period definitions
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : register_file PORT MAP(
        clk => clk,
        write_enable1 => write_enable1,
        write_enable2 => write_enable2,
        write_address1 => write_address1,
        write_address2 => write_address2,
        write_data1 => write_data1,
        write_data2 => write_data2,
        read_enable => read_enable,
        read_address1 => read_address1,
        read_address2 => read_address2,
        read_data1 => read_data1,
        read_data2 => read_data2
    );

    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR clk_period/2;
        clk <= '0';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- hold reset state for 100 ns.
        WAIT FOR 100 ns;

        write_enable1 <= '1';
        write_address1 <= "001";
        write_data1 <= x"00000001";
        WAIT FOR clk_period;

        write_enable1 <= '0';
        write_enable2 <= '1';
        write_address2 <= "010";
        write_data2 <= x"00000002";
        WAIT FOR clk_period;

        write_enable1 <= '0';
        write_enable2 <= '0';
        read_enable <= '1';
        read_address1 <= "001";
        read_address2 <= "010";
        WAIT FOR clk_period;

        read_enable <= '0';
        write_enable1 <= '1';
        write_address1 <= "011";
        write_data1 <= x"00000003";
        write_enable2 <= '1';
        write_address2 <= "100";
        write_data2 <= x"00000004";
        WAIT FOR clk_period;
        ASSERT (read_data1 = x"00000001") AND (read_data2 = x"00000001") REPORT "Read test 1 failed" SEVERITY error;

        write_enable1 <= '0';
        write_enable2 <= '0';
        read_enable <= '1';
        read_address1 <= "011";
        read_address2 <= "100";
        WAIT FOR clk_period;
        ASSERT (read_data1 = x"00000003") AND (read_data2 = x"00000004") REPORT "Read test 2 failed" SEVERITY error;

        -- Insert more test cases here
        -- Wait forever, so the simulation does not end.
        WAIT;
    END PROCESS;

END;