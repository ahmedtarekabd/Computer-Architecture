LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fetch_tb IS
END ENTITY fetch_tb;

ARCHITECTURE behavior OF fetch_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT fetch
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
            immediate_enable : IN STD_LOGIC;
            FD_enable : IN STD_LOGIC;
            FD_enable_loaduse : IN STD_LOGIC;
            FD_flush : IN STD_LOGIC;
            FD_flush_exception_unit : IN STD_LOGIC;
            selected_immediate_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            opcode : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            Rsrc1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdest : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
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
    SIGNAL immediate_enable : STD_LOGIC := '0';
    SIGNAL FD_enable : STD_LOGIC := '0';
    SIGNAL FD_enable_loaduse : STD_LOGIC := '0';
    SIGNAL FD_flush : STD_LOGIC := '0';
    SIGNAL FD_flush_exception_unit : STD_LOGIC := '0';

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
    uut : fetch PORT MAP(
        clk => clk,
        reset => reset,
        pc_mux1_selector => pc_mux1_selector,
        RST_signal => RST_signal,
        pc_enable_hazard_detection => pc_enable_hazard_detection,
        read_data_from_memory => read_data_from_memory,
        branch_address => branch_address,
        pc_mux2_selector => pc_mux2_selector,
        interrupt_signal => interrupt_signal,
        immediate_enable => immediate_enable,
        FD_enable => FD_enable,
        FD_enable_loaduse => FD_enable_loaduse,
        FD_flush => FD_flush,
        FD_flush_exception_unit => FD_flush_exception_unit,
        selected_immediate_out => selected_immediate_out,
        opcode => opcode,
        Rsrc1 => Rsrc1,
        Rsrc2 => Rsrc2,
        Rdest => Rdest,
        imm_flag => imm_flag,
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
        -- immediate_enable : IN STD_LOGIC;
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
        RST_signal <= '0';
        read_data_from_memory <= (OTHERS => '0');
        branch_address <= (OTHERS => '0');
        interrupt_signal <= '0';
        FD_enable <= '1';
        FD_enable_loaduse <= '1';
        FD_flush <= '0';
        FD_flush_exception_unit <= '0';

        pc_enable_hazard_detection <= '1';
        immediate_enable <= '1';
        --first testcase - > fetch first instruction
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "First instruction opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "First instruction Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "First instruction Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "000") REPORT "First instruction Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '0') REPORT "First instruction imm_flag is wrong" SEVERITY error;
        -- assert (selected_immediate_out = "0000000000000000") report "First instruction selected_immediate_out is wrong" severity error;
        ASSERT (propagated_pc = "00000000000000000000000000000000") REPORT "First instruction propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000001") REPORT "First instruction propagated_pc_plus_one is wrong" SEVERITY error;

        --second testcase - > second instruction with immediate
        pc_mux1_selector <= "00";   
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "First instruction opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "First instruction Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "First instruction Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "000") REPORT "First instruction Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '0') REPORT "First instruction imm_flag is wrong" SEVERITY error;
        -- assert (selected_immediate_out = "0000000000000000") report "First instruction selected_immediate_out is wrong" severity error;
        ASSERT (propagated_pc = "00000000000000000000000000000001") REPORT "First instruction propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000010") REPORT "First instruction propagated_pc_plus_one is wrong" SEVERITY error;

        --third testcase - > 
        immediate_enable <= '0'; --checkkkkk
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "First instruction opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "First instruction Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "First instruction Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "000") REPORT "First instruction Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '1') REPORT "First instruction imm_flag is wrong" SEVERITY error;
        -- ASSERT (selected_immediate_out = "0000000000000010") REPORT "First instruction selected_immediate_out is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000000000000000000000000010") REPORT "First instruction propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000011") REPORT "First instruction propagated_pc_plus_one is wrong" SEVERITY error;

        --fourth testcase - >
        immediate_enable <= '1'; --checkkkkk
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "First instruction opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "First instruction Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "First instruction Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "000") REPORT "First instruction Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '1') REPORT "First instruction imm_flag is wrong" SEVERITY error;
        ASSERT (selected_immediate_out = "0000000000000010") REPORT "First instruction selected_immediate_out is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000000000000000000000000011") REPORT "First instruction propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000100") REPORT "First instruction propagated_pc_plus_one is wrong" SEVERITY error;


        --fifth testcase - >
        immediate_enable <= '0'; --checkkkkk
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "First instruction opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "First instruction Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "First instruction Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "001") REPORT "First instruction Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '1') REPORT "First instruction imm_flag is wrong" SEVERITY error;
        -- ASSERT (selected_immediate_out = "0000000000000010") REPORT "First instruction selected_immediate_out is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000000000000000000000000100") REPORT "First instruction propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000101") REPORT "First instruction propagated_pc_plus_one is wrong" SEVERITY error;

        --sixth testcase - >
        immediate_enable <= '1'; --checkkkkk
        pc_mux1_selector <= "00";
        pc_mux2_selector <= "00";
        WAIT FOR clk_period;
        ASSERT (opcode = "000000") REPORT "First instruction opcode is wrong" SEVERITY error;
        ASSERT (Rsrc1 = "000") REPORT "First instruction Rsrc1 is wrong" SEVERITY error;
        ASSERT (Rsrc2 = "000") REPORT "First instruction Rsrc2 is wrong" SEVERITY error;
        ASSERT (Rdest = "001") REPORT "First instruction Rdest is wrong" SEVERITY error;
        ASSERT (imm_flag = '1') REPORT "First instruction imm_flag is wrong" SEVERITY error;
        ASSERT (selected_immediate_out = "0000000000000100") REPORT "First instruction selected_immediate_out is wrong" SEVERITY error;
        ASSERT (propagated_pc = "00000000000000000000000000000101") REPORT "First instruction propagated_pc is wrong" SEVERITY error;
        ASSERT (propagated_pc_plus_one = "00000000000000000000000000000110") REPORT "First instruction propagated_pc_plus_one is wrong" SEVERITY error;

        WAIT;
    END PROCESS;

END;