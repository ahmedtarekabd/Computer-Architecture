LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY decode_tb IS
END ENTITY decode_tb;

ARCHITECTURE tb_arch OF decode_tb IS

    -- Component declaration
    COMPONENT decode
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdest : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            imm_flag : IN STD_LOGIC;
            immediate_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            propagated_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            propagated_pc_plus_one_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            in_port_in : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            interrupt_signal : IN STD_LOGIC;
            zero_flag : IN STD_LOGIC;
            write_enable1 : IN STD_LOGIC;
            write_enable2 : IN STD_LOGIC;
            write_address1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_address2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_data1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            write_data2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            fetch_control_signals : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            in_port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            immediate_stall : OUT STD_LOGIC;
            propagated_control_signals : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
            propagated_read_data1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            propagated_read_data2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            propagated_Rsrc1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            propagated_Rsrc2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            propagated_Rdest : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            immediate_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            propagated_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            propagated_pc_plus_one : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';
    SIGNAL opcode : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rsrc1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rsrc2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rdest : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL imm_flag : STD_LOGIC := '0';
    SIGNAL immediate_in : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL propagated_pc_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL propagated_pc_plus_one_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in_port_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL interrupt_signal : STD_LOGIC := '0';
    SIGNAL zero_flag : STD_LOGIC := '0';
    SIGNAL write_enable1 : STD_LOGIC := '0';
    SIGNAL write_enable2 : STD_LOGIC := '0';
    SIGNAL write_address1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_address2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_data1 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_data2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fetch_control_signals : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL in_port : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL immediate_stall : STD_LOGIC;
    SIGNAL propagated_control_signals : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL propagated_read_data1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL propagated_read_data2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL propagated_Rsrc1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL propagated_Rsrc2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL propagated_Rdest : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL immediate_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL propagated_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL propagated_pc_plus_one : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    -- Instantiate the decode module
    uut : decode
    PORT MAP(
        clk => clk,
        reset => reset,
        opcode => opcode,
        Rsrc1 => Rsrc1,
        Rsrc2 => Rsrc2,
        Rdest => Rdest,
        imm_flag => imm_flag,
        immediate_in => immediate_in,
        propagated_pc_in => propagated_pc_in,
        propagated_pc_plus_one_in => propagated_pc_plus_one_in,
        in_port_in => in_port_in,
        interrupt_signal => interrupt_signal,
        zero_flag => zero_flag,
        write_enable1 => write_enable1,
        write_enable2 => write_enable2,
        write_address1 => write_address1,
        write_address2 => write_address2,
        write_data1 => write_data1,
        write_data2 => write_data2,
        fetch_control_signals => fetch_control_signals,
        in_port => in_port,
        immediate_stall => immediate_stall,
        propagated_control_signals => propagated_control_signals,
        propagated_read_data1 => propagated_read_data1,
        propagated_read_data2 => propagated_read_data2,
        propagated_Rsrc1 => propagated_Rsrc1,
        propagated_Rsrc2 => propagated_Rsrc2,
        propagated_Rdest => propagated_Rdest,
        immediate_out => immediate_out,
        propagated_pc => propagated_pc,
        propagated_pc_plus_one => propagated_pc_plus_one
    );

    -- Clock process
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR 5 NS;
        clk <= '1';
        WAIT FOR 5 NS;
    END PROCESS clk_process;

    -- Stimulus process
    stimulus_process : PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= "000000";
        Rsrc1 <= "000";
        Rsrc2 <= "000";
        Rdest <= "000";
        imm_flag <= '0';
        immediate_in <= (OTHERS => '0');
        propagated_pc_in <= (OTHERS => '0');
        propagated_pc_plus_one_in <= (OTHERS => '0');
        interrupt_signal <= '0';
        zero_flag <= '0';
        write_enable1 <= '0';
        write_enable2 <= '0';
        write_address1 <= (OTHERS => '0');
        write_address2 <= (OTHERS => '0');
        write_data1 <= (OTHERS => '0');
        write_data2 <= (OTHERS => '0');

        -- Wait for reset to complete
        WAIT FOR 10 NS;
        reset <= '0';

    END PROCESS;

    -- Test cases for NOP instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= NOP_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for NOT instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= NOT_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for NEG instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= NEG_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for INC instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= INC_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for DEC instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= DEC_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for OUT instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= OUT_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for IN instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= IN_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for MOV instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= MOV_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for SWAP instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= SWAP_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for ADD instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= ADD_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for SUB instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= SUB_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for AND instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= AND_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for OR instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= OR_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for XOR instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= XOR_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for CMP instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= CMP_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for ADDI instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= ADDI_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for SUBI instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= SUBI_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for PUSH instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= PUSH_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for POP instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= POP_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for PROTECT instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= PROTECT_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for FREE instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= FREE_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for LDM instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= LDM_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for LDD instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= LDD_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for STD instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= STD_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for JZ instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= JZ_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for JMP instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= JMP_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for CALL instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= CALL_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for RET instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= RET_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

    -- Test cases for RTI instruction
    PROCESS
    BEGIN
        -- Initialize inputs
        reset <= '1';
        opcode <= RTI_INST;
        -- TODO: Set other input values here

        -- Wait for reset to complete
        WAIT FOR 10 ns;
        reset <= '0';

        -- Wait for a few clock cycles
        WAIT FOR 20 ns;

        -- Check the outputs
        -- TODO: Add assertions here

        -- End the simulation
        WAIT;
    END PROCESS;

END ARCHITECTURE tb_arch;