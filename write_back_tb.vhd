LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY write_back_tb IS
END write_back_tb;

ARCHITECTURE write_back_tb_tb OF write_back_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT write_back
        PORT (
            clk : IN STD_LOGIC;
            read_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_address1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_address2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            destination_address_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            mem_read_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            wb_control_signals_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            selected_data_out1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            selected_data_out2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            selected_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_address2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            regWrite_out_control_signal : OUT STD_LOGIC
        );
    END COMPONENT;

    --Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL read_data1_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_data2_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_address1_in : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_address2_in : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL destination_address_in : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_read_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pc_in : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wb_control_signals_in : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');

    --Outputs
    SIGNAL selected_data_out1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL selected_data_out2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL selected_address_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL read_address2_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL regWrite_out_control_signal : STD_LOGIC;

    -- Clock period definitions
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : write_back PORT MAP(
        clk => clk,
        read_data1_in => read_data1_in,
        read_data2_in => read_data2_in,
        read_address1_in => read_address1_in,
        read_address2_in => read_address2_in,
        destination_address_in => destination_address_in,
        mem_read_data => mem_read_data,
        pc_in => pc_in,
        control_signals_in => control_signals_in,
        selected_data_out1 => selected_data_out1,
        selected_data_out2 => selected_data_out2,
        selected_address_out => selected_address_out,
        read_address2_out => read_address2_out,
        regWrite_out_control_signal => regWrite_out_control_signal
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

        -- Test case 1: wb_control_signals_in = "00"
        wb_control_signals_in <= "100";
        read_data1_in <= "00000000000000000000000000000001";
        read_data2_in <= "00000000000000000000000000000010";
        mem_read_data <= "00000000000000000000000000000011";
        read_address1_in <= "001";
        read_address2_in <= "010";
        destination_address_in <= "100";
        pc_in <= "0000000000000000";
        WAIT FOR clk_period;

        -- Test case 2: wb_control_signals_in = "01"
        wb_control_signals_in <= "001";
        read_data1_in <= "00000000000000000000000000000100";
        read_data2_in <= "00000000000000000000000000000101";
        mem_read_data <= "00000000000000000000000000000110";
        read_address1_in <= "100";
        read_address2_in <= "101";
        destination_address_in <= "010";
        pc_in <= "0000000000000000";
        WAIT FOR clk_period;

        -- Test case 3: wb_control_signals_in = "10"
        wb_control_signals_in <= "010";
        read_data1_in <= "00000000000000000000000000000111";
        read_data2_in <= "00000000000000000000000000001000";
        mem_read_data <= "00000000000000000000000000001001";
        read_address1_in <= "111";
        read_address2_in <= "000";
        destination_address_in <= "100";
        pc_in <= "0000000000000001";
        WAIT FOR clk_period;

        -- Test case 4: wb_control_signals_in = "11"
        wb_control_signals_in <= "111";
        read_data1_in <= "00000000000000000000000000001010";
        read_data2_in <= "00000000000000000000000000001011";
        mem_read_data <= "00000000000000000000000000001100";
        read_address1_in <= "010";
        read_address2_in <= "011";
        destination_address_in <= "101";
        pc_in <= "0000000000000000";
        WAIT FOR clk_period;

        WAIT;
    END PROCESS;

END write_back_tb_tb;