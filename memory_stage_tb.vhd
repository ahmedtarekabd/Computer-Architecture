LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memory_stage_tb IS
END memory_stage_tb;

ARCHITECTURE behavior OF memory_stage_tb IS

    COMPONENT memory_stage
        PORT (
            clk : IN STD_LOGIC;
            mem_control_signals_in : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            wb_control_signals_in : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
            RST : IN STD_LOGIC;
            MW_enable : IN STD_LOGIC;
            MW_flush_from_exception : IN STD_LOGIC;
            PC_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            PC_plus_one_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            imm_enable_in : IN STD_LOGIC;
            destination_address_in : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            write_address1_in : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            write_address2_in : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            read_data1_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            read_data2_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            ALU_result_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            CCR_in : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            wb_control_signals_out : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
            destination_address_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            write_address1_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            write_address2_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            read_data1_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            read_data2_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            ALU_result_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            mem_read_data : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            PC_out_to_exception : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            protected_address_access_to_exception : OUT STD_LOGIC
        );
    END COMPONENT;

    --Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL mem_control_signals_in : STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wb_control_signals_in : STD_LOGIC_VECTOR (5 DOWNTO 0) := (OTHERS => '0');
    SIGNAL RST : STD_LOGIC := '0';
    SIGNAL MW_enable : STD_LOGIC := '0';
    SIGNAL MW_flush_from_exception : STD_LOGIC := '0';
    SIGNAL PC_in : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_plus_one_in : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL imm_enable_in : STD_LOGIC := '0';
    SIGNAL destination_address_in : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_address1_in : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_address2_in : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_data1_in : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_data2_in : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ALU_result_in : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL CCR_in : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');

    --Outputs
    SIGNAL wb_control_signals_out : STD_LOGIC_VECTOR (5 DOWNTO 0);
    SIGNAL destination_address_out : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL write_address1_out : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL write_address2_out : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL read_data1_out : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL read_data2_out : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL ALU_result_out : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL mem_read_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL PC_out_to_exception : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL protected_address_access_to_exception : STD_LOGIC;

    -- Clock period definitions
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : memory_stage PORT MAP(
        clk => clk,
        mem_control_signals_in => mem_control_signals_in,
        wb_control_signals_in => wb_control_signals_in,
        RST => RST,
        MW_enable => MW_enable,
        MW_flush_from_exception => MW_flush_from_exception,
        PC_in => PC_in,
        PC_plus_one_in => PC_plus_one_in,
        imm_enable_in => imm_enable_in,
        destination_address_in => destination_address_in,
        write_address1_in => write_address1_in,
        write_address2_in => write_address2_in,
        read_data1_in => read_data1_in,
        read_data2_in => read_data2_in,
        ALU_result_in => ALU_result_in,
        CCR_in => CCR_in,
        wb_control_signals_out => wb_control_signals_out,
        destination_address_out => destination_address_out,
        write_address1_out => write_address1_out,
        write_address2_out => write_address2_out,
        read_data1_out => read_data1_out,
        read_data2_out => read_data2_out,
        ALU_result_out => ALU_result_out,
        mem_read_data => mem_read_data,
        PC_out_to_exception => PC_out_to_exception,
        protected_address_access_to_exception => protected_address_access_to_exception
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
        WAIT FOR 100 ns;

        -- insert stimulus here 

        -- test case 1
        clk <= '0';
        mem_control_signals_in <= "0000000000";
        wb_control_signals_in <= "000000";
        RST <= '1';
        MW_enable <= '0';
        MW_flush_from_exception <= '0';
        PC_in <= "00000000000000000000000000000000";
        PC_plus_one_in <= "00000000000000000000000000000000";
        imm_enable_in <= '0';
        destination_address_in <= "000";
        write_address1_in <= "000";
        write_address2_in <= "000";
        read_data1_in <= "00000000000000000000000000000000";
        read_data2_in <= "00000000000000000000000000000000";
        ALU_result_in <= "00000000000000000000000000000000";
        CCR_in <= "0000";
        WAIT FOR clk_period;

        -- test case 2
        clk <= '0';
        mem_control_signals_in <= "1000000000";
        wb_control_signals_in <= "010010";
        RST <= '0';
        MW_enable <= '0';
        MW_flush_from_exception <= '0';
        PC_in <= "00000000000000000000000000000000";
        PC_plus_one_in <= "00000000000000000000000000000000";
        imm_enable_in <= '0';
        destination_address_in <= "000";
        write_address1_in <= "000";
        write_address2_in <= "000";
        read_data1_in <= "00000000000000000000000000000000";
        read_data2_in <= "00000000000000000000000000000000";
        ALU_result_in <= "00000000000000000001001001001001";
        CCR_in <= "0000";
        WAIT FOR clk_period;

        WAIT;
    END PROCESS;

END;