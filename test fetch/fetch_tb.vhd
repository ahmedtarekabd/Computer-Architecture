LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fetch_tb IS
END ENTITY fetch_tb;

ARCHITECTURE behavior OF fetch_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT fetch1
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            pc_mux1_selector : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            RST_signal : IN STD_LOGIC;
            pc_enable_hazard_detection : IN STD_LOGIC;
            read_data_from_memory : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            branch_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_mux2_selector : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            interrupt_signal : IN STD_LOGIC;
            immediate_reg_enable : IN STD_LOGIC;
            FD_enable : IN STD_LOGIC;
            FD_enable_loaduse : IN STD_LOGIC;
            FD_flush : IN STD_LOGIC;
            FD_flush_exception_unit : IN STD_LOGIC;
            selected_immediate_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            opcode : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            Rsrc1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdest : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            in_port_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            in_port_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            imm_flag : OUT STD_LOGIC;
            propagated_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            propagated_pc_plus_one : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    --Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';
    SIGNAL pc_mux1_selector : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL RST_signal : STD_LOGIC := '0';
    SIGNAL read_data_from_memory : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL branch_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pc_mux2_selector : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL interrupt_signal : STD_LOGIC := '0';
    SIGNAL pc_enable_hazard_detection : STD_LOGIC := '0';
    SIGNAL immediate_reg_enable : STD_LOGIC := '0';
    SIGNAL FD_enable : STD_LOGIC := '0';
    SIGNAL FD_enable_loaduse : STD_LOGIC := '0';
    SIGNAL FD_flush : STD_LOGIC := '0';
    SIGNAL FD_flush_exception_unit : STD_LOGIC := '0';
    signal in_port_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    signal in_port_out : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    --Outputs
    SIGNAL selected_immediate_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL Rsrc1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL Rsrc2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL Rdest : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL imm_flag : STD_LOGIC;
    SIGNAL propagated_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL propagated_pc_plus_one : STD_LOGIC_VECTOR(31 DOWNTO 0);


    -- Clock period definitions
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : fetch1 PORT MAP(
        clk => clk,
        reset => reset,
        pc_mux1_selector => pc_mux1_selector,
        RST_signal => RST_signal,
        pc_enable_hazard_detection => pc_enable_hazard_detection,
        read_data_from_memory => read_data_from_memory,
        branch_address => branch_address,
        pc_mux2_selector => pc_mux2_selector,
        interrupt_signal => interrupt_signal,
        immediate_reg_enable => immediate_reg_enable,
        FD_enable => FD_enable,
        FD_enable_loaduse => FD_enable_loaduse,
        FD_flush => FD_flush,
        FD_flush_exception_unit => FD_flush_exception_unit,
        in_port_in => in_port_in,
        selected_immediate_out => selected_immediate_out,
        opcode => opcode,
        Rsrc1 => Rsrc1,
        Rsrc2 => Rsrc2,
        Rdest => Rdest,
        imm_flag => imm_flag,
        in_port_out => in_port_out,
        propagated_pc => propagated_pc,
        propagated_pc_plus_one => propagated_pc_plus_one
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
        reset <= '1';
        -- hold reset state for 100 ns.
        WAIT FOR 100 ns;

        reset <= '0';
        -- insert stimulus here 

        -- ----------pc----------
        -- --first mux
        -- pc_mux1_selector : IN STD_Logic_vector(1 DOWNTO 0); --from controller
        -- RST_signal : IN STD_LOGIC;
        -- read_data_from_memory : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- branch_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- -- pc_plus_one : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -> from me

        -- --second mux
        -- pc_mux2_selector : IN STD_Logic_vector(1 DOWNTO 0); --from exception handling

        -- --pc nafso
        -- interrupt_signal : IN STD_LOGIC;
        -- pc_enable : IN STD_LOGIC;

        -- ----------F/D reg----------
        -- --enables
        -- immediate_reg_enable : IN STD_LOGIC;
        -- FD_enable : IN STD_LOGIC;
        -- FD_enable_loaduse : IN STD_LOGIC;

        -- --reset
        -- -- RST_signal : IN STD_LOGIC; -> already defined in the mux
        -- FD_flush : IN STD_LOGIC;
        -- FD_flush_exception_unit : IN STD_LOGIC;
        --  ----------outputs----------
        --  selected_immediate_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        --  -- instruction 
        --  opcode : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        --  Rsrc1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        --  Rsrc2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        --  Rdest : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        --  imm_flag : OUT STD_LOGIC;

        --  propagated_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        --  propagated_pc_plus_one : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        in_port_in <= "00000000000000000000000000000000";
        RST_signal <= '0';
        read_data_from_memory <= "00000000000000000000000000000100";
        -- branch_address <="0000000000000000000000000000010";
        branch_address <="00000000011111111110000000000010";
        interrupt_signal <= '0';
        FD_enable <= '1';
        FD_enable_loaduse <= '1';
        FD_flush <= '0';
        FD_flush_exception_unit <= '0';

        pc_enable_hazard_detection <= '1';
        immediate_reg_enable <= '1';
        --first testcase - > fetch first instruction (00000000000000000000000000000000)
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "Testcase 2 opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "Testcase 2 Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "Testcase 2 Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "000") REPORT "Testcase 2 Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '0') REPORT "Testcase 2 imm_flag is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000000000000000000000000000") REPORT "Testcase 2 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000001") REPORT "Testcase 2 propagated_pc_plus_one is wrong" SEVERITY error;
        assert (in_port_out = "00000000000000000000000000000000") report "Testcase 2 in_port_out is wrong" severity error;
        
        --second testcase - > second instruction with immediate (00000000000000000000000000000001)
        immediate_reg_enable <= '0'; --checkkkkk
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "Testcase 3 opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "Testcase 3 Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "Testcase 3 Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "000") REPORT "Testcase 3 Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '1') REPORT "Testcase 3 imm_flag is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000000000000000000000000001") REPORT "Testcase 3 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000010") REPORT "Testcase 3 propagated_pc_plus_one is wrong" SEVERITY error;        
        --third testcase - > (00000000000000000000000000000010) (stalled cycle)
        immediate_reg_enable <= '1'; --checkkkkk
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "Testcase 4 opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "Testcase 4 Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "Testcase 4 Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "000") REPORT "Testcase 4 Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '1') REPORT "Testcase 4 imm_flag is wrong" SEVERITY error;
        assert (selected_immediate_out = "0000000000000010") report "Testcase 4 selected_immediate_out is wrong" severity error;
        ASSERT (propagated_pc = "00000000000000000000000000000010") REPORT "Testcase 4 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000011") REPORT "Testcase 4 propagated_pc_plus_one is wrong" SEVERITY error;
        --fourth testcase - > (00000000000000000000000000000011)
        immediate_reg_enable <= '0'; --checkkkkk
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "Testcase 5 opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "Testcase 5 Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "Testcase 5 Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "001") REPORT "Testcase 5 Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '1') REPORT "Testcase 5 imm_flag is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000000000000000000000000011") REPORT "Testcase 5 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000100") REPORT "Testcase 5 propagated_pc_plus_one is wrong" SEVERITY error;
        --fifth testcase - > (00000000000000000000000000000100) (stalled cycle)
        immediate_reg_enable <= '1'; --checkkkkk
        pc_mux1_selector <= "01";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "Testcase 6 opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "Testcase 6 Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "Testcase 6 Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "001") REPORT "Testcase 6 Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '1') REPORT "Testcase 6 imm_flag is wrong" SEVERITY error;
        -- ASSERT (selected_immediate_out = "0000000000000100") REPORT "Testcase 6 selected_immediate_out is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000000000000000000000000100") REPORT "Testcase 6 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000101") REPORT "Testcase 6 propagated_pc_plus_one is wrong" SEVERITY error;
        -- --sixth testcase - > branch address (11111001111100111110000000000000)
        -- pc_mux1_selector <= "01";
        -- pc_mux2_selector <= "00";
        -- WAIT FOR clk_period;
        -- ASSERT (opcode = "000000") REPORT "Testcase 7 opcode is wrong" SEVERITY error;
        -- ASSERT (Rsrc1 = "000") REPORT "Testcase 7 Rsrc1 is wrong" SEVERITY error;
        -- ASSERT (Rsrc2 = "000") REPORT "Testcase 7 Rsrc2 is wrong" SEVERITY error;
        -- ASSERT (Rdest = "010") REPORT "Testcase 7 Rdest is wrong" SEVERITY error;
        -- ASSERT (imm_flag = '1') REPORT "Testcase 7 imm_flag is wrong" SEVERITY error;
        -- ASSERT (selected_immediate_out = "0000000000000011") REPORT "Testcase 7 selected_immediate_out is wrong" SEVERITY error;
        -- ASSERT (propagated_pc = "00000000000000000000000000000100") REPORT "Testcase 7 propagated_pc is wrong" SEVERITY error;
        -- ASSERT (propagated_pc_plus_one = "00000000000000000000000000000101") REPORT "Testcase 7 propagated_pc_plus_one is wrong" SEVERITY error;
        -- assert (propagated_imm_stall = '1') report "Testcase 7 propaged_imm_stall is wrong" severity error;

        --seventh testcase - > branch address (00000000000000000000000000000010) -> 00000000000000000000000000000010
        pc_mux1_selector <= "11";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
    --    ASSERT (opcode = "000000") REPORT "Testcase 8 opcode is wrong" SEVERITY error;
    --     ASSERT (Rsrc1 = "000") REPORT "Testcase 8 Rsrc1 is wrong" SEVERITY error;
    --     ASSERT (Rsrc2 = "000") REPORT "Testcase 8 Rsrc2 is wrong" SEVERITY error;
    --     ASSERT (Rdest = "010") REPORT "Testcase 8 Rdest is wrong" SEVERITY error;
    --     ASSERT (imm_flag = '1') REPORT "Testcase 8 imm_flag is wrong" SEVERITY error;
    --     ASSERT (selected_immediate_out = "0000000000000100") REPORT "Testcase 8 selected_immediate_out is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000011111111110000000000010") REPORT "Testcase 8 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000011111111110000000000011") REPORT "Testcase 8 propagated_pc_plus_one is wrong" SEVERITY error;
        --eight testcase - > read data from memory address (00000000000000000000000000000100) -> 00000000000000000000000000000100 
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "Testcase 9 opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "Testcase 9 Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "Testcase 9 Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "010") REPORT "Testcase 9 Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '0') REPORT "Testcase 9 imm_flag is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000000000000000000000000100") REPORT "Testcase 9 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000101") REPORT "Testcase 9 propagated_pc_plus_one is wrong" SEVERITY error;

        --nine testcase -> immediate (stalled cycle)
        immediate_reg_enable <= '0'; --checkkkkk
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "Testcase 10 opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "Testcase 10 Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "Testcase 10 Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "010") REPORT "Testcase 10 Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '1') REPORT "Testcase 10 imm_flag is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000000000000000000000000101") REPORT "Testcase 10 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000110") REPORT "Testcase 10 propagated_pc_plus_one is wrong" SEVERITY error;

        immediate_reg_enable <= '1'; --checkkkkk
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "01";
        wait for clk_period;
        ASSERT (opcode = "000000") REPORT "Testcase 11 opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "Testcase 11 Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "Testcase 11 Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "010") REPORT "Testcase 11 Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '1') REPORT "Testcase 11 imm_flag is wrong" SEVERITY error;
        ASSERT (selected_immediate_out = "0000000000000110") REPORT "Testcase 11 selected_immediate_out is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000000000000000000000000110") REPORT "Testcase 11 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000111") REPORT "Testcase 11 propagated_pc_plus_one is wrong" SEVERITY error;

        pc_mux1_selector <= "00";
        pc_mux2_selector <= "10";
        wait for clk_period;
        ASSERT (propagated_pc = "00000000000000000011001100110011") REPORT "Testcase 12 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000011001100110100") REPORT "Testcase 12 propagated_pc_plus_one is wrong" SEVERITY error;

        wait for clk_period;
        ASSERT (propagated_pc = "00000000000000001100110011001100") REPORT "Testcase 13 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000001100110011001101") REPORT "Testcase 13 propagated_pc_plus_one is wrong" SEVERITY error;
        
        RST_signal <= '1'; -- resets every thing in the pipeline so it doesn't need to wait one cycle to see its effect
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "00";
        wait for clk_period;
        ASSERT (propagated_pc = "00000000000000000000000000000000") REPORT "Testcase 14 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000001") REPORT "Testcase 14 propagated_pc_plus_one is wrong" SEVERITY error;

        RST_signal <= '0';
        wait for clk_period;
        ASSERT (opcode = "000000") REPORT "Testcase 15 opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "Testcase 15 Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "Testcase 15 Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "000") REPORT "Testcase 15 Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '0') REPORT "Testcase 15 imm_flag is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000000000000000000000000000") REPORT "Testcase 15 propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000001") REPORT "Testcase 15 propagated_pc_plus_one is wrong" SEVERITY error;


        WAIT;
    END PROCESS;

END;