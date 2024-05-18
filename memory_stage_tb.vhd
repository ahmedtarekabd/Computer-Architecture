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
            MW_flush_from_controller : IN STD_LOGIC;
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
            in_port_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            wb_control_signals_out : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
            destination_address_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            write_address1_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            write_address2_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            read_data1_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            read_data2_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            ALU_result_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            mem_read_data : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            PC_out_to_exception : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            protected_address_access_to_exception : OUT STD_LOGIC;
            in_port_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    --Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL mem_control_signals_in : STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wb_control_signals_in : STD_LOGIC_VECTOR (5 DOWNTO 0) := (OTHERS => '0');
    SIGNAL RST : STD_LOGIC := '0';
    SIGNAL MW_enable : STD_LOGIC := '0';
    SIGNAL MW_flush_from_exception : STD_LOGIC := '0';
    SIGNAL MW_flush_from_controller : STD_LOGIC := '0';
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
    SIGNAL in_port_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

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
    SIGNAL in_port_out : STD_LOGIC_VECTOR(31 DOWNTO 0);

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
        MW_flush_from_controller => MW_flush_from_controller,
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
        in_port_in => in_port_in,
        wb_control_signals_out => wb_control_signals_out,
        destination_address_out => destination_address_out,
        write_address1_out => write_address1_out,
        write_address2_out => write_address2_out,
        read_data1_out => read_data1_out,
        read_data2_out => read_data2_out,
        ALU_result_out => ALU_result_out,
        mem_read_data => mem_read_data,
        PC_out_to_exception => PC_out_to_exception,
        protected_address_access_to_exception => protected_address_access_to_exception,
        in_port_out => in_port_out
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

        -- test case 1
        RST <= '1';
        mem_control_signals_in <= "1100000000";
        wb_control_signals_in <= "000000";
        MW_enable <= '1';
        MW_flush_from_exception <= '0';
        MW_flush_from_controller <= '0';
        PC_in <= (OTHERS => '0');
        PC_plus_one_in <= (OTHERS => '0');
        imm_enable_in <= '0';
        destination_address_in <= (OTHERS => '0');
        write_address1_in <= (OTHERS => '0');
        write_address2_in <= (OTHERS => '0');
        read_data1_in <= (OTHERS => '0');
        read_data2_in <= "11111111111111000011111111111111";
        ALU_result_in <= (OTHERS => '0');
        CCR_in <= (OTHERS => '0');
        in_port_in <= (OTHERS => '0');
        WAIT FOR clk_period;

        -- test case 2
        RST <= '0';
        mem_control_signals_in <= "1100000000";
        wb_control_signals_in <= "000000";
        MW_enable <= '0';
        MW_flush_from_exception <= '0';
        MW_flush_from_controller <= '1';
        PC_in <= (OTHERS => '0');
        PC_plus_one_in <= (OTHERS => '0');
        imm_enable_in <= '0';
        destination_address_in <= (OTHERS => '0');
        write_address1_in <= (OTHERS => '0');
        write_address2_in <= (OTHERS => '0');
        read_data1_in <= (OTHERS => '0');
        read_data2_in <= "11111111111111100001111111111111";
        ALU_result_in <= (OTHERS => '0');
        CCR_in <= (OTHERS => '0');
        in_port_in <= (OTHERS => '0');
        WAIT FOR clk_period;

        -- test case 3
        RST <= '0';
        mem_control_signals_in <= "1100000000";
        wb_control_signals_in <= "111111";
        MW_enable <= '0';
        MW_flush_from_exception <= '0';
        MW_flush_from_controller <= '0';
        PC_in <= "00000000000000000000000000000001";
        PC_plus_one_in <= "00000000000000000000000000000010";
        imm_enable_in <= '0';
        destination_address_in <= "001";
        write_address1_in <= "010";
        write_address2_in <= "011";
        read_data1_in <= "10101010101010101010101010101010";
        read_data2_in <= "01010101010101010101010101010101";
        ALU_result_in <= (OTHERS => '0');
        CCR_in <= "0010";
        in_port_in <= (OTHERS => '0');
        WAIT FOR clk_period;

        -- test case 4
        RST <= '0';
        mem_control_signals_in <= "1101010000";
        wb_control_signals_in <= "000001";
        MW_enable <= '1';
        MW_flush_from_exception <= '1';
        MW_flush_from_controller <= '0';
        PC_in <= "00000000000000000000000000000010";
        PC_plus_one_in <= "00000000000000000000000000000011";
        imm_enable_in <= '1';
        destination_address_in <= "010";
        write_address1_in <= "011";
        write_address2_in <= "100";
        read_data1_in <= (OTHERS => '1');
        read_data2_in <= "11110000111100001111000011110000";
        ALU_result_in <= (OTHERS => '0');
        CCR_in <= "0100";
        in_port_in <= (OTHERS => '0');
        WAIT FOR clk_period;

        -- test case 5
        RST <= '0';
        mem_control_signals_in <= "1001001001";
        wb_control_signals_in <= "000111";
        MW_enable <= '0';
        MW_flush_from_exception <= '1';
        MW_flush_from_controller <= '0';
        PC_in <= "00000000000000000000000000000011";
        PC_plus_one_in <= "00000000000000000000000000000100";
        imm_enable_in <= '1';
        destination_address_in <= "011";
        write_address1_in <= "100";
        write_address2_in <= "101";
        read_data1_in <= (OTHERS => '1');
        read_data2_in <= "00001111000011110000111100001111";
        ALU_result_in <= (OTHERS => '0');
        CCR_in <= "0110";
        in_port_in <= (OTHERS => '0');
        WAIT FOR clk_period;

        -- test case 6
        RST <= '1';
        mem_control_signals_in <= "1100110011";
        wb_control_signals_in <= "111000";
        MW_enable <= '1';
        MW_flush_from_exception <= '0';
        MW_flush_from_controller <= '0';
        PC_in <= "00000000000000000000000000000001";
        PC_plus_one_in <= "00000000000000000000000000000010";
        imm_enable_in <= '0';
        destination_address_in <= "100";
        write_address1_in <= "101";
        write_address2_in <= "110";
        read_data1_in <= (OTHERS => '1');
        read_data2_in <= "00110011001100110011001100110011";
        ALU_result_in <= (OTHERS => '0');
        CCR_in <= "1000";
        in_port_in <= (OTHERS => '0');
        WAIT FOR clk_period;

        -- test case 7
        RST <= '0';
        mem_control_signals_in <= "1111000011";
        wb_control_signals_in <= "000011";
        MW_enable <= '0';
        MW_flush_from_exception <= '1';
        MW_flush_from_controller <= '0';
        PC_in <= "00000000000000000000000000000010";
        PC_plus_one_in <= "00000000000000000000000000000011";
        imm_enable_in <= '1';
        destination_address_in <= "101";
        write_address1_in <= "110";
        write_address2_in <= "111";
        read_data1_in <= (OTHERS => '1');
        read_data2_in <= "11001100110011001100110011001100";
        ALU_result_in <= "11001100110011001100110011001100";
        CCR_in <= "1010";
        in_port_in <= (OTHERS => '0');
        WAIT FOR clk_period;

        -- test case 8
        RST <= '1';
        mem_control_signals_in <= "1111110000";
        wb_control_signals_in <= "000000";
        MW_enable <= '1';
        MW_flush_from_exception <= '0';
        MW_flush_from_controller <= '0';
        PC_in <= "00000000000000000000000000000011";
        PC_plus_one_in <= "00000000000000000000000000000100";
        imm_enable_in <= '0';
        destination_address_in <= "110";
        write_address1_in <= "111";
        write_address2_in <= "000";
        read_data1_in <= (OTHERS => '1');
        read_data2_in <= "11111111000000001111111100000000";
        ALU_result_in <= "11111111000000001111111100000000";
        CCR_in <= "1100";
        in_port_in <= (OTHERS => '0');
        WAIT FOR clk_period;

        -- test case 9
        RST <= '0';
        mem_control_signals_in <= "0000111111";
        wb_control_signals_in <= "000001";
        MW_enable <= '0';
        MW_flush_from_exception <= '1';
        MW_flush_from_controller <= '0';
        PC_in <= "00000000000000000000000000000001";
        PC_plus_one_in <= "00000000000000000000000000000010";
        imm_enable_in <= '1';
        destination_address_in <= "111";
        write_address1_in <= "000";
        write_address2_in <= "001";
        read_data1_in <= (OTHERS => '1');
        read_data2_in <= "00000000111111110000000011111111";
        ALU_result_in <= "00000000111111110000000011111111";
        CCR_in <= "1110";
        in_port_in <= (OTHERS => '0');
        WAIT FOR clk_period;

        -- test case 10
        RST <= '1';
        mem_control_signals_in <= "0000001111";
        wb_control_signals_in <= "000010";
        MW_enable <= '1';
        MW_flush_from_exception <= '0';
        MW_flush_from_controller <= '0';
        PC_in <= "00000000000000000000000000000010";
        PC_plus_one_in <= "00000000000000000000000000000011";
        imm_enable_in <= '0';
        destination_address_in <= "000";
        write_address1_in <= "001";
        write_address2_in <= "010";
        read_data1_in <= (OTHERS => '1');
        read_data2_in <= "11111111000000001111111100000000";
        ALU_result_in <= "11111111000000001111111100000000";
        CCR_in <= "0001";
        in_port_in <= (OTHERS => '0');
        WAIT FOR clk_period;

        -- test case 11
        RST <= '0';
        mem_control_signals_in <= "0000111100";
        wb_control_signals_in <= "000011";
        MW_enable <= '0';
        MW_flush_from_exception <= '1';
        MW_flush_from_controller <= '0';
        PC_in <= "00000000000000000000000000000011";
        PC_plus_one_in <= "00000000000000000000000000000100";
        imm_enable_in <= '1';
        destination_address_in <= "001";
        write_address1_in <= "010";
        write_address2_in <= "011";
        read_data1_in <= (OTHERS => '1');
        read_data2_in <= "00000000111111110000000011111111";
        ALU_result_in <= "00000000111111110000000011111111";
        CCR_in <= "0011";
        in_port_in <= (OTHERS => '0');
        WAIT FOR clk_period;

        -- test case 12
        RST <= '1';
        mem_control_signals_in <= "0000001111";
        wb_control_signals_in <= "000100";
        MW_enable <= '1';
        MW_flush_from_exception <= '0';
        MW_flush_from_controller <= '0';
        PC_in <= "00000000000000000000000000000001";
        PC_plus_one_in <= "00000000000000000000000000000010";
        imm_enable_in <= '0';
        destination_address_in <= "010";
        write_address1_in <= "011";
        write_address2_in <= "100";
        read_data1_in <= (OTHERS => '1');
        read_data2_in <= "11111111000000001111111100000000";
        ALU_result_in <= "11111111000000001111111100000000";
        CCR_in <= "0101";
        in_port_in <= (OTHERS => '0');
        WAIT FOR clk_period;
        WAIT;
    END PROCESS;

END;