LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY decode IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        branch_prediction_flush : IN STD_LOGIC;
        exception_handling_flush : IN STD_LOGIC;
        hazard_detection_flush : IN STD_LOGIC;

        --* Inputs
        -- instruction 
        opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rdest : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        imm_flag : IN STD_LOGIC;
        immediate_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        propagated_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        propagated_pc_plus_one_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        in_port_in : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Signals
        interrupt_signal : IN STD_LOGIC; -- From Processor file

        -- Falgs
        zero_flag : IN STD_LOGIC; -- From ALU

        -- WB
        write_enable1 : IN STD_LOGIC;
        write_enable2 : IN STD_LOGIC;
        write_address1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_address2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_data1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        write_data2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Forwarding
        forwarded_alu_execute : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        forwarded_data1_mw : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        forwarded_data2_mw : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        forwarded_data1_em : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        forwarded_data2_em : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branching_op_mux_selector : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        branching_or_normal_mux_selector : IN STD_LOGIC;
        --* Outputs
        -- fetch signals
        fetch_pc_mux1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        immediate_stall : OUT STD_LOGIC;
        fetch_decode_flush : OUT STD_LOGIC;
        in_port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- Propagated signals
        execute_control_signals : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        memory_control_signals : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
        wb_control_signals : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        propagated_read_data1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        propagated_read_data2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        propagated_Rsrc1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        propagated_Rsrc2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        propagated_Rdest : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        immediate_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_pc_address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        propagated_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        propagated_pc_plus_one : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY decode;

ARCHITECTURE rtl OF decode IS

    COMPONENT controller
        PORT (
            clk : IN STD_LOGIC;

            -- 6-bit opcode
            opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            isImmediate : IN STD_LOGIC;
            interrupt_signal : IN STD_LOGIC;
            zero_flag : IN STD_LOGIC;

            -- fetch signals
            fetch_pc_mux1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
            immediate_stall : OUT STD_LOGIC := '1';
            fetch_decode_flush : OUT STD_LOGIC := '0';

            -- decode signals
            decode_reg_read : OUT STD_LOGIC := '0';
            decode_sign_extend : OUT STD_LOGIC := '0';
            decode_execute_flush : OUT STD_LOGIC := '0';

            -- execute signals
            execute_alu_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
            execute_alu_src2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
            decode_branch : OUT STD_LOGIC := '0';
            conditional_jump : OUT STD_LOGIC := '0';

            -- memory signals
            memory_write : OUT STD_LOGIC := '0';
            memory_read : OUT STD_LOGIC := '0';
            memory_stack_pointer : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
            memory_address : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
            memory_write_data : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
            memory_protected : OUT STD_LOGIC := '0';
            memory_free : OUT STD_LOGIC := '0';
            execute_memory_flush : OUT STD_LOGIC := '0';

            -- write back signals
            write_back_register_write1 : OUT STD_LOGIC := '0';
            write_back_register_write2 : OUT STD_LOGIC := '0';
            write_back_register_write_data_1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
            write_back_register_write_address_1 : OUT STD_LOGIC := '0';
            outport_enable : OUT STD_LOGIC := '0'
        );

    END COMPONENT;

    COMPONENT register_file IS
        GENERIC (n : INTEGER := 32);
        PORT (
            clk : IN STD_LOGIC;
            write_enable1 : IN STD_LOGIC;
            write_enable2 : IN STD_LOGIC;
            write_address1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_address2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_data1 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            write_data2 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            read_enable : IN STD_LOGIC;
            read_address1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_address2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_data1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            read_data2 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT sign_extend IS
        GENERIC (
            INPUT_WIDTH : NATURAL := 16; -- Width of the input signal
            OUTPUT_WIDTH : NATURAL := 32 -- Width of the output signal
        );
        PORT (
            enable : IN STD_LOGIC;
            input : IN STD_LOGIC_VECTOR(INPUT_WIDTH - 1 DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR(OUTPUT_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT my_nDFF IS
        GENERIC (n : INTEGER := 16);
        PORT (
            Clk, reset, enable : IN STD_LOGIC;
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT mux4x1 IS
        GENERIC (n : INTEGER := 16);
        PORT (
            inputA : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            inputB : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            inputC : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            inputD : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            Sel_lower : IN STD_LOGIC;
            Sel_higher : IN STD_LOGIC;
            output : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT mux4x1;

    SIGNAL isImmediate : STD_LOGIC := '0';

    -- decode signals
    SIGNAL decode_reg_read : STD_LOGIC := '0';
    SIGNAL decode_sign_extend : STD_LOGIC := '0';
    SIGNAL decode_execute_flush : STD_LOGIC := '0';

    -- execute signals
    SIGNAL execute_alu_sel : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL execute_alu_src2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL decode_branch : STD_LOGIC := '0';
    SIGNAL conditional_jump : STD_LOGIC := '0';

    -- memory signals
    SIGNAL memory_write : STD_LOGIC := '0';
    SIGNAL memory_read : STD_LOGIC := '0';
    SIGNAL memory_stack_pointer : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL memory_address : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"; -- alu | sp | 0 (reset) | 2 (interrupt)
    SIGNAL memory_write_data : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL memory_protected : STD_LOGIC := '0';
    SIGNAL memory_free : STD_LOGIC := '0';
    SIGNAL execute_memory_flush : STD_LOGIC := '0';

    -- write back signals
    SIGNAL write_back_register_write1 : STD_LOGIC := '0';
    SIGNAL write_back_register_write2 : STD_LOGIC := '0';
    SIGNAL write_back_register_write_data_1 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL write_back_register_write_address_1 : STD_LOGIC := '0'; -- Rdst | Rsrc1
    SIGNAL outport_enable : STD_LOGIC := '0';

    -- Outputs holder
    SIGNAL control_signals_in : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL execute_control_signals_in : STD_LOGIC_VECTOR(6 DOWNTO 0); --*Changed thiss
    SIGNAL memory_control_signals_in : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL wb_control_signals_in : STD_LOGIC_VECTOR(5 DOWNTO 0); --because it have the out port with it
    SIGNAL read_data1_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_data2_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Rdest_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL decode_execute_in : STD_LOGIC_VECTOR(193 - 1 DOWNTO 0);
    SIGNAL decode_execute_out : STD_LOGIC_VECTOR(193 - 1 DOWNTO 0);
    SIGNAL forward_mux : STD_LOGIC_VECTOR(31 DOWNTO 0);

    --
    SIGNAL reg_reset : STD_LOGIC := '0';
BEGIN

    isImmediate <= imm_flag;

    ctrl : controller PORT MAP(
        clk,

        opcode,
        isImmediate,
        interrupt_signal,
        zero_flag,

        -- fetch signals - 4 bits
        fetch_pc_mux1,
        immediate_stall,
        fetch_decode_flush,

        -- decode signals - 3 bits
        decode_reg_read,
        decode_sign_extend,
        decode_execute_flush,

        -- execute signals - 7 bits
        execute_alu_sel,
        execute_alu_src2,
        decode_branch,
        conditional_jump,

        -- memory signals - 11 bits
        memory_write,
        memory_read,
        memory_stack_pointer,
        memory_address,
        memory_write_data,
        memory_protected,
        memory_free,
        execute_memory_flush,

        -- write back signals - 6 bits
        write_back_register_write1,
        write_back_register_write2,
        write_back_register_write_data_1,
        write_back_register_write_address_1,
        outport_enable
    );

    register_file_instance : register_file GENERIC MAP(
        32) PORT MAP(
        -- Inputs
        clk => clk,
        write_enable1 => write_enable1, -- WB
        write_enable2 => write_enable2, -- WB
        write_address1 => write_address1, -- WB
        write_address2 => write_address2,
        write_data1 => write_data1, -- WB
        write_data2 => write_data2, -- WB
        read_enable => decode_reg_read, --
        read_address1 => Rsrc1, --
        read_address2 => Rsrc2, --
        -- Outputs
        read_data1 => read_data1_in, --
        read_data2 => read_data2_in --
    );

    -- sign extend
    sign_extend_instance : sign_extend PORT MAP(
        enable => decode_sign_extend,
        input => immediate_in,
        output => immediate_out
    );

    -- Forwarding
    WITH branching_op_mux_selector SELECT
        forward_mux <= read_data1_in WHEN "000",
        forwarded_alu_execute WHEN "001",
        forwarded_data1_mw WHEN "010",
        forwarded_data2_mw WHEN "011",
        forwarded_data1_em WHEN "100",
        forwarded_data2_em WHEN "101",
        propagated_read_data1 WHEN "110",
        propagated_read_data2 WHEN "111",
        (OTHERS => '0') WHEN OTHERS;

    branch_pc_address <= (OTHERS => '0') WHEN branching_or_normal_mux_selector = '0' ELSE
        forward_mux;

    -- execute signals - 7 bits
    execute_control_signals_in <= execute_alu_sel
        & execute_alu_src2
        & execute_memory_flush
        & conditional_jump;
    -- memory signals - 11 bits
    memory_control_signals_in <= memory_write
        & memory_read
        & memory_stack_pointer
        & memory_address
        & memory_write_data
        & memory_protected
        & memory_free
        & '0';
    -- write back signals - 6 bits
    wb_control_signals_in <= write_back_register_write_data_1
        & write_back_register_write1
        & write_back_register_write2
        & write_back_register_write_address_1
        & outport_enable;

    -- output
    control_signals_in <=
        -- execute signals - 7 bits
        execute_control_signals_in
        -- memory signals - 11 bits
        & memory_control_signals_in
        -- write back signals - 6 bits
        & wb_control_signals_in;

    -- 193 bits: 24 control signals(propagated) + 32 read_data1_in + 32 read_data2_in + 3 read_address1 + 3 read_address2 + 3 destination + 32 immediate_out + 32 pc_plus_1 + 32 pc
    decode_execute_in <= control_signals_in & read_data1_in & read_data2_in & Rsrc1 & Rsrc2 & Rdest
        & immediate_out & propagated_pc_plus_one_in & propagated_pc_in;

    reg_reset <= reset OR decode_execute_flush OR exception_handling_flush OR hazard_detection_flush OR immediate_stall;

    decode_execute : my_nDFF
    GENERIC MAP(193)
    PORT MAP(
        clk => clk,
        reset => reg_reset,
        enable => '1',
        d => decode_execute_in,
        q => decode_execute_out
    );

    immediate_stall <= isImmediate;
    in_port <= in_port_in;
    out_port <= read_data1_in;

    -- length = start - end + 1
    -- end = start - length + 1
    execute_control_signals <= decode_execute_out(193 - 1 DOWNTO 193 - 7);
    memory_control_signals <= decode_execute_out(193 - 7 - 1 DOWNTO 193 - 7 - 11);
    wb_control_signals <= decode_execute_out(193 - 7 - 11 - 1 DOWNTO 193 - 24);
    propagated_read_data1 <= decode_execute_out(193 - 23 - 1 DOWNTO 193 - 23 - 32);
    propagated_read_data2 <= decode_execute_out(193 - 23 - 32 - 1 DOWNTO 193 - 23 - 32 - 32);
    propagated_Rsrc1 <= decode_execute_out(193 - 23 - 32 - 32 - 1 DOWNTO 193 - 23 - 32 - 32 - 3);
    propagated_Rsrc2 <= decode_execute_out(193 - 23 - 32 - 32 - 3 - 1 DOWNTO 193 - 23 - 32 - 32 - 3 - 3);
    propagated_Rdest <= decode_execute_out(193 - 23 - 32 - 32 - 3 - 3 - 1 DOWNTO 193 - 23 - 32 - 32 - 3 - 3 - 3);
    immediate_out <= decode_execute_out(193 - 23 - 32 - 32 - 3 - 3 - 3 - 1 DOWNTO 193 - 23 - 32 - 32 - 3 - 3 - 3 - 32);
    propagated_pc <= decode_execute_out(193 - 23 - 32 - 32 - 3 - 3 - 3 - 32 - 1 DOWNTO 193 - 23 - 32 - 32 - 3 - 3 - 3 - 32 - 32);
    propagated_pc_plus_one <= decode_execute_out(193 - 23 - 32 - 32 - 3 - 3 - 3 - 32 - 32 - 1 DOWNTO 193 - 23 - 32 - 32 - 3 - 3 - 3 - 32 - 32 - 32);

END ARCHITECTURE rtl;