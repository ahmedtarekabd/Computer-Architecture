LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY memory_stage_tb IS
END ENTITY memory_stage_tb;

ARCHITECTURE behavior OF memory_stage_tb IS

    COMPONENT memory_stage
        PORT (
            clk : IN STD_LOGIC;
            read_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_address1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_address2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            destination_address_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            mem_wb_control_signals_in : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
            pc_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            mem_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            mem_read_or_write_addr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            mem_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_address1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_address2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            destination_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            wb_control_signals_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

    --Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL read_data1_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_data2_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_address1_in : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_address2_in : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL destination_address_in : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_wb_control_signals_in : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pc_in : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_write_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_read_or_write_addr : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');

    --Outputs
    SIGNAL mem_read_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_data1_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_data2_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_address1_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL read_address2_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL destination_address_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL pc_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL wb_control_signals_out : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- Clock period definitions
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : memory_stage PORT MAP(
        clk => clk,
        read_data1_in => read_data1_in,
        read_data2_in => read_data2_in,
        read_address1_in => read_address1_in,
        read_address2_in => read_address2_in,
        destination_address_in => destination_address_in,
        mem_wb_control_signals_in => mem_wb_control_signals_in,
        pc_in => pc_in,
        mem_write_data => mem_write_data,
        mem_read_or_write_addr => mem_read_or_write_addr,
        mem_read_data => mem_read_data,
        read_data1_out => read_data1_out,
        read_data2_out => read_data2_out,
        read_address1_out => read_address1_out,
        read_address2_out => read_address2_out,
        destination_address_out => destination_address_out,
        pc_out => pc_out,
        wb_control_signals_out => wb_control_signals_out
    );

    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- -- the ones that matter:
    -- mem_wb_control_signals_in : in std_logic_vector(6 downto 0);

    -- mem_write_data : in std_logic_vector(31 downto 0);
    -- -- depends on the control signal same as ALU out
    -- mem_read_or_write_addr : in std_logic_vector(12 downto 0);

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- hold reset state for 100 ns.
        WAIT FOR 105 ns;
        -- dummies for propagation  
        read_data1_in <= "00000000000000000000000000000001";
        read_data2_in <= "00000000000000000000000000000010";
        read_address1_in <= "001";
        read_address2_in <= "010";
        destination_address_in <= "011";
        pc_in <= "0000000000000001";
        ----
        mem_wb_control_signals_in <= "0000000";
        --write in address 0 the value 1010101010101010
        mem_read_or_write_addr <= "000000000000";
        mem_wb_control_signals_in(1) <= '1'; -- memWrite
        mem_wb_control_signals_in(0) <= '0'; -- memRead
        mem_write_data <= "00000000000000001010101010101010";
        WAIT FOR clk_period;

        --output the value in address 0 which is 1010101010101010
        mem_wb_control_signals_in(0) <= '1'; -- memRead
        mem_wb_control_signals_in(1) <= '0'; -- memWrite
        WAIT FOR clk_period;

        --protect this memory location 
        mem_wb_control_signals_in(2) <= '1'; -- protect_signal
        mem_read_or_write_addr <= "000000000000";
        WAIT FOR clk_period;

        --try to write in the protected memory location
        -- mem_wb_control_signals_in(2) <= '0'; -- protect_signal
        mem_read_or_write_addr <= "000000000010";

        mem_wb_control_signals_in(2) <= '0'; -- protect_signal
        mem_wb_control_signals_in(1) <= '1'; -- memWrite
        mem_wb_control_signals_in(0) <= '0'; -- memRead
        mem_write_data <= "00000000000000000101010101010101";
        WAIT FOR clk_period;

        --try to read from the protected memory location the expected -> 1010101010101010
        mem_wb_control_signals_in(0) <= '1'; -- memRead
        WAIT FOR clk_period;

        --free the memory location
        mem_wb_control_signals_in(2) <= '0'; -- protect_signal
        mem_wb_control_signals_in(3) <= '1'; -- free_signal
        WAIT FOR clk_period;

        --try to write in the freed memory location
        mem_wb_control_signals_in(3) <= '0'; -- free_signal
        mem_wb_control_signals_in(1) <= '1'; -- memWrite
        mem_write_data <= "00000000000000001111000011110000";
        WAIT FOR clk_period;

        --try to read from the freed memory location the expected -> 0000000000000000
        mem_wb_control_signals_in(0) <= '1'; -- memRead
        WAIT FOR clk_period;

        WAIT;
    END PROCESS;

END;