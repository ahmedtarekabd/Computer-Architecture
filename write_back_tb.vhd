LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY write_back_tb IS
END write_back_tb;

ARCHITECTURE write_back_tb_tb OF write_back_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT write_back
        PORT (
            clk : IN STD_LOGIC;
            -- Input signals
            read_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_address1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_address2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            destination_address_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            mem_read_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            in_port : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            reg_write_enable1_in : IN STD_LOGIC;
            reg_write_enable2_in : IN STD_LOGIC;
            Rsrc1_selector_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            reg_write_address1_in_select : IN STD_LOGIC;
            -- Output signals
            WB_selected_data_out1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            WB_selected_data_out2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            WB_selected_address_out1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            WB_selected_address_out2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            mem_read_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            reg_write_enable1_out : OUT STD_LOGIC;
            reg_write_enable2_out : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL read_data1_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_data2_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_address1_in : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_address2_in : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL destination_address_in : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_read_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ALU_result : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in_port : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL reg_write_enable1_in : STD_LOGIC := '0';
    SIGNAL reg_write_enable2_in : STD_LOGIC := '0';
    SIGNAL Rsrc1_selector_in : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL reg_write_address1_in_select : STD_LOGIC := '0';

    -- Outputs
    SIGNAL WB_selected_data_out1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL WB_selected_data_out2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL WB_selected_address_out1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL WB_selected_address_out2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL mem_read_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg_write_enable1_out : STD_LOGIC;
    SIGNAL reg_write_enable2_out : STD_LOGIC;

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
        ALU_result => ALU_result,
        in_port => in_port,
        reg_write_enable1_in => reg_write_enable1_in,
        reg_write_enable2_in => reg_write_enable2_in,
        Rsrc1_selector_in => Rsrc1_selector_in,
        reg_write_address1_in_select => reg_write_address1_in_select,
        WB_selected_data_out1 => WB_selected_data_out1,
        WB_selected_data_out2 => WB_selected_data_out2,
        WB_selected_address_out1 => WB_selected_address_out1,
        WB_selected_address_out2 => WB_selected_address_out2,
        mem_read_data_out => mem_read_data_out,
        reg_write_enable1_out => reg_write_enable1_out,
        reg_write_enable2_out => reg_write_enable2_out
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

        -- initialise all inputs to 0
        read_data1_in <= (OTHERS => '0');
        read_data2_in <= (OTHERS => '0');
        read_address1_in <= (OTHERS => '0');
        read_address2_in <= (OTHERS => '0');
        destination_address_in <= (OTHERS => '0');
        mem_read_data <= (OTHERS => '0');
        ALU_result <= (OTHERS => '0');
        in_port <= (OTHERS => '0');
        reg_write_enable1_in <= '0';
        reg_write_enable2_in <= '0';
        Rsrc1_selector_in <= (OTHERS => '0');
        reg_write_address1_in_select <= '0';
        
        -- hold reset state for 100 ns.
        WAIT FOR 100 ns;

        -- Test case 1: Rsrc1_selector_in = "00"
        -- AND reg_write_address1_in_select = '0'
        -- Expected 
        -- ALU_result <= "00000000000000000000000000000100";
        -- destination_address_in <= "100";
        Rsrc1_selector_in <= "00";
        read_data1_in <= "00000000000000000000000000000001";
        read_data2_in <= "00000000000000000000000000000010";
        mem_read_data <= "00000000000000000000000000000011";
        ALU_result <= "00000000000000000000000000000100";
        in_port <= "00000000000000000000000000000101";
        read_address1_in <= "001";
        read_address2_in <= "010";
        destination_address_in <= "100";
        reg_write_enable1_in <= '1';
        reg_write_enable2_in <= '0';
        reg_write_address1_in_select <= '0';
        WAIT FOR clk_period;

        -- Test case 2: Rsrc1_selector_in = "01"
        -- AND reg_write_address1_in_select = '1'
        Rsrc1_selector_in <= "01";
        read_data1_in <= "00000000000000000000000000000110";
        read_data2_in <= "00000000000000000000000000000111";
        mem_read_data <= "00000000000000000000000000001000";
        ALU_result <= "00000000000000000000000000001001";
        in_port <= "00000000000000000000000000001010";
        read_address1_in <= "011";
        read_address2_in <= "100";
        destination_address_in <= "101";
        reg_write_enable1_in <= '1';
        reg_write_enable2_in <= '1';
        reg_write_address1_in_select <= '1';
        WAIT FOR clk_period;

        -- Test case 3: Rsrc1_selector_in = "10"
        -- AND reg_write_address1_in_select = '0'
        Rsrc1_selector_in <= "10";
        read_data1_in <= "00000000000000000000000000001011";
        read_data2_in <= "00000000000000000000000000001100";
        mem_read_data <= "00000000000000000000000000001101";
        ALU_result <= "00000000000000000000000000001110";
        in_port <= "00000000000000000000000000001111";
        read_address1_in <= "101";
        read_address2_in <= "110";
        destination_address_in <= "111";
        reg_write_enable1_in <= '0';
        reg_write_enable2_in <= '1';
        reg_write_address1_in_select <= '0';
        WAIT FOR clk_period;

        -- Test case 4: Rsrc1_selector_in = "11"
        -- AND reg_write_address1_in_select = '1'
        Rsrc1_selector_in <= "11";
        read_data1_in <= "00000000000000000000000000010000";
        read_data2_in <= "00000000000000000000000000010001";
        mem_read_data <= "00000000000000000000000000010010";
        ALU_result <= "00000000000000000000000000010011";
        in_port <= "00000000000000000000000000010100";
        read_address1_in <= "111";
        read_address2_in <= "000";
        destination_address_in <= "001";
        reg_write_enable1_in <= '1';
        reg_write_enable2_in <= '1';
        reg_write_address1_in_select <= '1';
        WAIT FOR clk_period;

        WAIT;
    END PROCESS;

END write_back_tb_tb;
