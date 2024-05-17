LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY decode IS
    PORT (
        clk : IN STD_LOGIC;
        instruction_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        immediate_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- Signals
        interrupt_signal : IN STD_LOGIC; -- From Processor file

        -- Falgs
        zero_flag : IN STD_LOGIC; -- From Processor file

        -- WB
        write_enable1 : IN STD_LOGIC;
        write_enable2 : IN STD_LOGIC;
        write_address1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_address2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_data1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        write_data2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Propagated signals
        pc_plus_1 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);

        -- Outputs
        -- Immediate Enable
        immediate_reg_enable : OUT STD_LOGIC;

        -- TODO: add fetch in a separate signal (shilo men el register)
        decode_execute_out : OUT STD_LOGIC_VECTOR(140 - 1 DOWNTO 0)
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

            -- Immediate Enable
            immediate_reg_enable : OUT STD_LOGIC;

            -- fetch signals
            fetch_pc_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- decode signals
            decode_reg_read : OUT STD_LOGIC;
            decode_branch : OUT STD_LOGIC; -- later
            decode_sign_extend : OUT STD_LOGIC;

            -- execute signals
            alu_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            alu_src2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            alu_register_write : OUT STD_LOGIC;

            -- memory signals
            memory_write : OUT STD_LOGIC;
            memory_read : OUT STD_LOGIC;
            memory_stack_pointer : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            memory_address : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- alu | sp | 0 (reset) | 2 (interrupt)
            memory_write_data : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

            -- write back signals
            write_back_register_write1 : OUT STD_LOGIC;
            write_back_register_write2 : OUT STD_LOGIC;
            write_back_register_write_data_1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            write_back_register_write_address_1 : OUT STD_LOGIC -- Rdst | Rsrc1
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

    -- Instruction
    SIGNAL opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL read_enable : STD_LOGIC;
    SIGNAL read_address1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL read_address2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL destination : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL isImmediate : STD_LOGIC;

    -- fetch signals
    SIGNAL immediate_enable_internal : STD_LOGIC;
    SIGNAL fetch_pc_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- execute signals
    SIGNAL alu_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL alu_src2 : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL alu_register_write : STD_LOGIC;

    -- memory signals
    SIGNAL memory_write : STD_LOGIC;
    SIGNAL memory_read : STD_LOGIC;
    SIGNAL memory_stack_pointer : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL memory_address : STD_LOGIC_VECTOR(1 DOWNTO 0); -- alu | sp | 0 (reset) | 2 (interrupt)
    SIGNAL memory_write_data : STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- write back signals
    SIGNAL write_back_register_write1 : STD_LOGIC;
    SIGNAL write_back_register_write2 : STD_LOGIC;
    SIGNAL write_back_register_write_data_1 : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL write_back_register_write_address_1 : STD_LOGIC; -- Rdst | Rsrc1

    -- decode: not propagated
    SIGNAL decode_reg_read : STD_LOGIC;
    SIGNAL decode_branch : STD_LOGIC; -- later
    SIGNAL decode_sign_extend : STD_LOGIC;

    SIGNAL control_signals : STD_LOGIC_VECTOR(22 DOWNTO 0);

    --Outputs
    SIGNAL read_data1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_data2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL immediate_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL decode_execute_in : STD_LOGIC_VECTOR(140 - 1 DOWNTO 0);

BEGIN

    opcode <= instruction_in(15 DOWNTO 10);
    read_address1 <= instruction_in(9 DOWNTO 7);
    read_address2 <= instruction_in(6 DOWNTO 4);
    destination <= instruction_in(3 DOWNTO 1);
    isImmediate <= instruction_in(0);

    ctrl : controller PORT MAP(
        -- Inputs
        clk => clk,
        opcode => opcode, -- 
        isImmediate => isImmediate, --
        interrupt_signal => interrupt_signal,
        zero_flag => zero_flag,
        -- Outputs
        immediate_reg_enable => immediate_enable_internal,
        fetch_pc_sel => fetch_pc_sel,
        decode_reg_read => decode_reg_read,
        decode_branch => decode_branch,
        decode_sign_extend => decode_sign_extend,
        alu_sel => alu_sel,
        alu_src2 => alu_src2,
        alu_register_write => alu_register_write,
        memory_write => memory_write,
        memory_read => memory_read,
        memory_stack_pointer => memory_stack_pointer,
        memory_address => memory_address,
        memory_write_data => memory_write_data,
        write_back_register_write1 => write_back_register_write1,
        write_back_register_write2 => write_back_register_write2,
        write_back_register_write_data_1 => write_back_register_write_data_1,
        write_back_register_write_address_1 => write_back_register_write_address_1
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
        read_address1 => read_address1, --
        read_address2 => read_address2, --
        -- Outputs
        read_data1 => read_data1, --
        read_data2 => read_data2 --
    );

    -- sign extend
    sign_extend_instance : sign_extend PORT MAP(
        enable => decode_sign_extend,
        input => immediate_in,
        output => immediate_out
    );

    control_signals <= immediate_enable_internal
        & fetch_pc_sel
        & alu_sel
        & alu_src2
        & alu_register_write
        & memory_write
        & memory_read
        & memory_stack_pointer
        & memory_address
        & memory_write_data
        & write_back_register_write1
        & write_back_register_write2
        & write_back_register_write_data_1
        & write_back_register_write_address_1;

    -- 140 bits: 23 control signals + 32 read_data1 + 32 read_data2 + 3 read_address1 + 3 read_address2 + 3 destination + 32 immediate_out + 12 pc_plus_1
    decode_execute_in <= control_signals & read_data1 & read_data2 & read_address1 & read_address2 & destination
        & immediate_out & pc_plus_1;

    decode_execute : my_nDFF
    GENERIC MAP(140)
    PORT MAP(
        clk,
        '0', -- reset signal
        enable => immediate_enable_internal,
        d => decode_execute_in,
        q => decode_execute_out
    );

    immediate_reg_enable <= immediate_enable_internal;

END ARCHITECTURE rtl;