LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY decode IS
    PORT (
        clk : IN STD_LOGIC;
        instruction_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        immediate_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- WB
        write_enable1 : IN STD_LOGIC;

        -- lesaaa
        decode_execute_out : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
    );
END ENTITY decode;

ARCHITECTURE rtl OF decode IS

    COMPONENT controller
        PORT (
            clk : IN STD_LOGIC;

            -- 6-bit opcode
            opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);

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
        GENERIC (n : INTEGER := 8);
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
        GENERIC (
            n : INTEGER
        );
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT my_nDFF;

    -- take 3 bits: opcode, output 4 bits: opcode, write_enable
    SIGNAL opcode : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL write_enable1 : STD_LOGIC;
    SIGNAL write_enable2 : STD_LOGIC;
    SIGNAL write_address1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL write_address2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL write_data1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL write_data2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL read_enable : STD_LOGIC;
    SIGNAL read_address1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL read_address2 : STD_LOGIC_VECTOR(2 DOWNTO 0);

    --Outputs
    SIGNAL read_data1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_data2 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    -- 4 bits: controller
    -- 16 bits: 2 registers values
    -- 3 bits: address write back (destination)
    SIGNAL decode_execute_in : STD_LOGIC_VECTOR(22 DOWNTO 0);

BEGIN

    opcode <= instruction_in(15 DOWNTO 10);
    read_address1 <= instruction_in(9 DOWNTO 7);
    read_address2 <= instruction_in(6 DOWNTO 4);


    ctrl : controller PORT MAP(
        clk => clk,
        opcode => operation,
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

    register_file : register_file GENERIC MAP(
        8) PORT MAP(
        clk => clk,
        write_enable1 => write_enable1,
        write_enable2 => write_enable2,
        write_address1 => write_address1,
        write_address2 => write_address2,
        write_data1 => write_data1,
        write_data2 => write_data2,
        read_enable => read_enable,
        read_address1 => read_address1,
        read_address2 => read_address2,
        read_data1 => read_data1,
        read_data2 => read_data2
    );

    -- sign extend
    sign_extend : sign_extend PORT MAP(
        enable => decode_sign_extend,
        input => instruction_immediate_in,
        output => write_data2 -- TODO: Wady 3l decode_execute_in
    );

    -- 23 bits: 4 bits controller, 16 bits 2 registers values, 3 bits address write back (destination)
    decode_execute_in <= write_enable & opcode & register_file_out1 & register_file_out2 & instruction_in(6 DOWNTO 4);
    decode_execute : my_nDFF
    GENERIC MAP(23)
    PORT MAP(
        clk,
        '0', -- reset signal
        decode_execute_in,
        decode_execute_out
    );

END ARCHITECTURE rtl;