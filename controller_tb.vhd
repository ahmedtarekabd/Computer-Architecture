LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY controller_tb IS
END ENTITY controller_tb;

ARCHITECTURE tb_arch OF controller_tb IS

    COMPONENT controller
        PORT (
            clk : IN STD_LOGIC;

            opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            isImmediate : IN STD_LOGIC;
            interrupt_signal : IN STD_LOGIC;
            zero_flag : IN STD_LOGIC;

            fetch_pc_mux1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            immediate_stall : OUT STD_LOGIC;
            fetch_decode_flush : OUT STD_LOGIC;

            decode_reg_read : OUT STD_LOGIC;
            decode_sign_extend : OUT STD_LOGIC;
            decode_execute_flush : OUT STD_LOGIC;

            execute_alu_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            execute_alu_src2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            decode_branch : OUT STD_LOGIC;
            conditional_jump : OUT STD_LOGIC;

            memory_write : OUT STD_LOGIC;
            memory_read : OUT STD_LOGIC;
            memory_stack_pointer : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            memory_address : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            memory_write_data : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            memory_protected : OUT STD_LOGIC;
            memory_free : OUT STD_LOGIC;
            execute_memory_flush : OUT STD_LOGIC;

            write_back_register_write1 : OUT STD_LOGIC;
            write_back_register_write2 : OUT STD_LOGIC;
            write_back_register_write_data_1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            write_back_register_write_address_1 : OUT STD_LOGIC;
            outport_enable : OUT STD_LOGIC
        );
    END COMPONENT controller;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL isImmediate : STD_LOGIC;
    SIGNAL interrupt_signal : STD_LOGIC;
    SIGNAL zero_flag : STD_LOGIC;

    SIGNAL fetch_pc_mux1 : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL immediate_stall : STD_LOGIC;
    SIGNAL fetch_decode_flush : STD_LOGIC;

    SIGNAL decode_reg_read : STD_LOGIC;
    SIGNAL decode_sign_extend : STD_LOGIC;
    SIGNAL decode_execute_flush : STD_LOGIC;

    SIGNAL execute_alu_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL execute_alu_src2 : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL decode_branch : STD_LOGIC;
    SIGNAL conditional_jump : STD_LOGIC;

    SIGNAL memory_write : STD_LOGIC;
    SIGNAL memory_read : STD_LOGIC;
    SIGNAL memory_stack_pointer : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL memory_address : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL memory_write_data : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL memory_protected : STD_LOGIC;
    SIGNAL memory_free : STD_LOGIC;
    SIGNAL execute_memory_flush : STD_LOGIC;

    SIGNAL write_back_register_write1 : STD_LOGIC;
    SIGNAL write_back_register_write2 : STD_LOGIC;
    SIGNAL write_back_register_write_data_1 : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL write_back_register_write_address_1 : STD_LOGIC;
    SIGNAL outport_enable : STD_LOGIC;

BEGIN

    uut : controller
    PORT MAP(
        clk => clk,

        opcode => opcode,
        isImmediate => isImmediate,
        interrupt_signal => interrupt_signal,
        zero_flag => zero_flag,

        fetch_pc_mux1 => fetch_pc_mux1,
        immediate_stall => immediate_stall,
        fetch_decode_flush => fetch_decode_flush,

        decode_reg_read => decode_reg_read,
        decode_sign_extend => decode_sign_extend,
        decode_execute_flush => decode_execute_flush,

        execute_alu_sel => execute_alu_sel,
        execute_alu_src2 => execute_alu_src2,
        decode_branch => decode_branch,
        conditional_jump => conditional_jump,

        memory_write => memory_write,
        memory_read => memory_read,
        memory_stack_pointer => memory_stack_pointer,
        memory_address => memory_address,
        memory_write_data => memory_write_data,
        memory_protected => memory_protected,
        memory_free => memory_free,
        execute_memory_flush => execute_memory_flush,

        write_back_register_write1 => write_back_register_write1,
        write_back_register_write2 => write_back_register_write2,
        write_back_register_write_data_1 => write_back_register_write_data_1,
        write_back_register_write_address_1 => write_back_register_write_address_1,
        outport_enable => outport_enable
    );

    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR 10 ns;
        clk <= '0';
        WAIT FOR 10 ns;
    END PROCESS clk_process;

    -- asserts before waiting because they are asynchronous
    stimulus_process : PROCESS
    BEGIN
        -- Test NOP_INST
        opcode <= "000000";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        ASSERT fetch_pc_mux1 = "00" AND immediate_stall = '1' AND fetch_decode_flush = '0' AND
        decode_reg_read = '0' AND decode_sign_extend = '0' AND decode_execute_flush = '0' AND
        execute_alu_sel = "000" AND execute_alu_src2 = "00" AND decode_branch = '0' AND
        conditional_jump = '0' AND memory_write = '0' AND memory_read = '0' AND
        memory_stack_pointer = "00" AND memory_address = "00" AND memory_write_data = "00" AND
        memory_protected = '0' AND memory_free = '0' AND execute_memory_flush = '0' AND
        write_back_register_write1 = '0' AND write_back_register_write2 = '0' AND
        write_back_register_write_data_1 = "00" AND write_back_register_write_address_1 = '0' AND
        outport_enable = '0' REPORT "Test NOP_INST failed" SEVERITY ERROR;
        WAIT FOR 20 ns;

        -- Test NOT_INST
        opcode <= "000001";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        ASSERT fetch_pc_mux1 = "00" AND immediate_stall = '1' AND fetch_decode_flush = '0' AND
        decode_reg_read = '0' AND decode_sign_extend = '0' AND decode_execute_flush = '0' AND
        execute_alu_sel = "001" AND execute_alu_src2 = "00" AND decode_branch = '0' AND
        conditional_jump = '0' AND memory_write = '0' AND memory_read = '0' AND
        memory_stack_pointer = "00" AND memory_address = "00" AND memory_write_data = "00" AND
        memory_protected = '0' AND memory_free = '0' AND execute_memory_flush = '0' AND
        write_back_register_write1 = '0' AND write_back_register_write2 = '0' AND
        write_back_register_write_data_1 = "00" AND write_back_register_write_address_1 = '0' AND
        outport_enable = '0' REPORT "Test NOT_INST failed" SEVERITY ERROR;
        WAIT FOR 20 ns;

        -- Test NEG_INST
        opcode <= "000010";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        ASSERT fetch_pc_mux1 = "00" AND immediate_stall = '1' AND fetch_decode_flush = '0' AND
        decode_reg_read = '0' AND decode_sign_extend = '0' AND decode_execute_flush = '0' AND
        execute_alu_sel = "010" AND execute_alu_src2 = "00" AND decode_branch = '0' AND
        conditional_jump = '0' AND memory_write = '0' AND memory_read = '0' AND
        memory_stack_pointer = "00" AND memory_address = "00" AND memory_write_data = "00" AND
        memory_protected = '0' AND memory_free = '0' AND execute_memory_flush = '0' AND
        write_back_register_write1 = '0' AND write_back_register_write2 = '0' AND
        write_back_register_write_data_1 = "00" AND write_back_register_write_address_1 = '0' AND
        outport_enable = '0' REPORT "Test NEG_INST failed" SEVERITY ERROR;
        WAIT FOR 20 ns;

        -- Test INC_INST
        opcode <= "000011";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        ASSERT fetch_pc_mux1 = "00" AND immediate_stall = '1' AND fetch_decode_flush = '0' AND
        decode_reg_read = '0' AND decode_sign_extend = '0' AND decode_execute_flush = '0' AND
        execute_alu_sel = "011" AND execute_alu_src2 = "00" AND decode_branch = '0' AND
        conditional_jump = '0' AND memory_write = '0' AND memory_read = '0' AND
        memory_stack_pointer = "00" AND memory_address = "00" AND memory_write_data = "00" AND
        memory_protected = '0' AND memory_free = '0' AND execute_memory_flush = '0' AND
        write_back_register_write1 = '0' AND write_back_register_write2 = '0' AND
        write_back_register_write_data_1 = "00" AND write_back_register_write_address_1 = '0' AND
        outport_enable = '0' REPORT "Test INC_INST failed" SEVERITY ERROR;
        WAIT FOR 20 ns;

        -- Test DEC_INST
        opcode <= "000100";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        ASSERT fetch_pc_mux1 = "00" AND immediate_stall = '1' AND fetch_decode_flush = '0' AND
        decode_reg_read = '0' AND decode_sign_extend = '0' AND decode_execute_flush = '0' AND
        execute_alu_sel = "100" AND execute_alu_src2 = "00" AND decode_branch = '0' AND
        conditional_jump = '0' AND memory_write = '0' AND memory_read = '0' AND
        memory_stack_pointer = "00" AND memory_address = "00" AND memory_write_data = "00" AND
        memory_protected = '0' AND memory_free = '0' AND execute_memory_flush = '0' AND
        write_back_register_write1 = '0' AND write_back_register_write2 = '0' AND
        write_back_register_write_data_1 = "00" AND write_back_register_write_address_1 = '0' AND
        outport_enable = '0' REPORT "Test DEC_INST failed" SEVERITY ERROR;
        WAIT FOR 20 ns;

        -- Test OUT_INST
        opcode <= "000101";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        ASSERT fetch_pc_mux1 = "00" AND immediate_stall = '1' AND fetch_decode_flush = '0' AND
        decode_reg_read = '0' AND decode_sign_extend = '0' AND decode_execute_flush = '0' AND
        execute_alu_sel = "101" AND execute_alu_src2 = "00" AND decode_branch = '0' AND
        conditional_jump = '0' AND memory_write = '0' AND memory_read = '0' AND
        memory_stack_pointer = "00" AND memory_address = "00" AND memory_write_data = "00" AND
        memory_protected = '0' AND memory_free = '0' AND execute_memory_flush = '0' AND
        write_back_register_write1 = '0' AND write_back_register_write2 = '0' AND
        write_back_register_write_data_1 = "00" AND write_back_register_write_address_1 = '0' AND
        outport_enable = '1' REPORT "Test OUT_INST failed" SEVERITY ERROR;
        WAIT FOR 20 ns;

        -- Test IN_INST
        opcode <= "000110";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        ASSERT fetch_pc_mux1 = "00" AND immediate_stall = '1' AND fetch_decode_flush = '0' AND
        decode_reg_read = '0' AND decode_sign_extend = '0' AND decode_execute_flush = '0' AND
        execute_alu_sel = "110" AND execute_alu_src2 = "00" AND decode_branch = '0' AND
        conditional_jump = '0' AND memory_write = '0' AND memory_read = '0' AND
        memory_stack_pointer = "00" AND memory_address = "00" AND memory_write_data = "00" AND
        memory_protected = '0' AND memory_free = '0' AND execute_memory_flush = '0' AND
        write_back_register_write1 = '0' AND write_back_register_write2 = '0' AND
        write_back_register_write_data_1 = "00" AND write_back_register_write_address_1 = '0' AND
        outport_enable = '0' REPORT "Test IN_INST failed" SEVERITY ERROR;
        WAIT FOR 20 ns;

        -- Test MOV_INST
        opcode <= "010000";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test SWAP_INST
        opcode <= "010001";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test ADD_INST
        opcode <= "010010";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test SUB_INST
        opcode <= "010011";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test AND_INST
        opcode <= "010100";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test OR_INST
        opcode <= "010101";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test XOR_INST
        opcode <= "010110";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test CMP_INST
        opcode <= "010111";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test ADDI_INST
        opcode <= "011000";
        isImmediate <= '1';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test SUBI_INST
        opcode <= "011001";
        isImmediate <= '1';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test PUSH_INST
        opcode <= "100000";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test POP_INST
        opcode <= "100001";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test PROTECT_INST
        opcode <= "100010";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test FREE_INST
        opcode <= "100011";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test LDM_INST
        opcode <= "100100";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test LDD_INST
        opcode <= "100101";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test STD_INST
        opcode <= "100110";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test JZ_INST
        opcode <= "110000";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test JMP_INST
        opcode <= "110001";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test CALL_INST
        opcode <= "110010";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test RET_INST
        opcode <= "110011";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test RTI_INST
        opcode <= "110100";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- Test interrupt signal in the middle
        opcode <= "000000";
        isImmediate <= '0';
        interrupt_signal <= '1';
        zero_flag <= '0';
        WAIT FOR 20 ns;
        -- WAIT FOR 20 ns;
        -- WAIT FOR 20 ns;

        -- Test interrupt signal at the end
        opcode <= "000001";
        isImmediate <= '0';
        interrupt_signal <= '0';
        zero_flag <= '0';
        WAIT FOR 20 ns;

        -- End of simulation
        WAIT;
    END PROCESS stimulus_process;

END tb_arch;