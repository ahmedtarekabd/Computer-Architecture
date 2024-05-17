LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY exception_handling_tb IS
END exception_handling_tb;

ARCHITECTURE behavior OF exception_handling_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT exception_handling_unit
        PORT (
            clk : IN STD_LOGIC;
            pc_from_EM : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            pc_from_DE : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            overflow_flag_from_alu : IN STD_LOGIC;
            protected_bit_exeception_from_memory : IN STD_LOGIC;
            exception_out_port : OUT STD_LOGIC;
            second_pc_mux_out : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
            FD_flush : OUT STD_LOGIC;
            DE_flush : OUT STD_LOGIC;
            EM_flush : OUT STD_LOGIC;
            MW_flush : OUT STD_LOGIC;
            EPC_output : OUT STD_LOGIC_VECTOR (32 DOWNTO 0)
        );
    END COMPONENT;

    --Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL pc_from_EM : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pc_from_DE : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL overflow_flag_from_alu : STD_LOGIC := '0';
    SIGNAL protected_bit_exeception_from_memory : STD_LOGIC := '0';

    --Outputs
    SIGNAL exception_out_port : STD_LOGIC;
    SIGNAL second_pc_mux_out : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL FD_flush : STD_LOGIC;
    SIGNAL DE_flush : STD_LOGIC;
    SIGNAL EM_flush : STD_LOGIC;
    SIGNAL MW_flush : STD_LOGIC;
    SIGNAL EPC_output : STD_LOGIC_VECTOR (32 DOWNTO 0);

    -- Clock period definitions
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : exception_handling_unit PORT MAP(
        clk => clk,
        pc_from_EM => pc_from_EM,
        pc_from_DE => pc_from_DE,
        overflow_flag_from_alu => overflow_flag_from_alu,
        protected_bit_exeception_from_memory => protected_bit_exeception_from_memory,
        exception_out_port => exception_out_port,
        second_pc_mux_out => second_pc_mux_out,
        FD_flush => FD_flush,
        DE_flush => DE_flush,
        EM_flush => EM_flush,
        MW_flush => MW_flush,
        EPC_output => EPC_output
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
        -- Test case: No exception
        WAIT FOR clk_period;
        ASSERT (exception_out_port = '0') AND (second_pc_mux_out = "00") AND (FD_flush = '0') AND (DE_flush = '0') AND (EM_flush = '0') AND (MW_flush = '0') REPORT "No exception test failed" SEVERITY error;

        -- -- Test case: Overflow exception
        -- overflow_flag_from_alu <= '1';
        -- pc_from_EM <= "10000000000000000000000000000000"; -- Set a specific value to check EPC_output
        -- WAIT FOR clk_period;
        -- ASSERT (exception_out_port = '1') REPORT "Overflow exception: exception_out_port test failed" SEVERITY error;
        -- ASSERT (second_pc_mux_out = "01") REPORT "Overflow exception: second_pc_mux_out test failed" SEVERITY error;
        -- ASSERT (FD_flush = '1') REPORT "Overflow exception: FD_flush test failed" SEVERITY error;
        -- ASSERT (DE_flush = '1') REPORT "Overflow exception: DE_flush test failed" SEVERITY error;
        -- ASSERT (EM_flush = '1') REPORT "Overflow exception: EM_flush test failed" SEVERITY error;
        -- ASSERT (MW_flush = '0') REPORT "Overflow exception: MW_flush test failed" SEVERITY error;
        -- ASSERT (EPC_output = "100000000000000000000000000000001") REPORT "Overflow exception: EPC_output test failed" SEVERITY error;
        
        
        -- Test case: Memory protection exception
        overflow_flag_from_alu <= '0';
        protected_bit_exeception_from_memory <= '1';
        pc_from_DE <= "01000000000000000000000000000000"; -- Set a specific value to check EPC_output
        WAIT FOR clk_period;
        ASSERT (exception_out_port = '1') REPORT "Memory protection exception: exception_out_port test failed" SEVERITY error;
        ASSERT (second_pc_mux_out = "10") REPORT "Memory protection exception: second_pc_mux_out test failed" SEVERITY error;
        ASSERT (FD_flush = '1') REPORT "Memory protection exception: FD_flush test failed" SEVERITY error;
        ASSERT (DE_flush = '1') REPORT "Memory protection exception: DE_flush test failed" SEVERITY error;
        ASSERT (EM_flush = '1') REPORT "Memory protection exception: EM_flush test failed" SEVERITY error;
        ASSERT (MW_flush = '1') REPORT "Memory protection exception: MW_flush test failed" SEVERITY error;
        ASSERT (EPC_output = "010000000000000000000000000000000") REPORT "Memory protection exception: EPC_output test failed" SEVERITY error;
        WAIT;
    END PROCESS;

END;