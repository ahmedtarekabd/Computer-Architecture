-- FILEPATH: /e:/College/3- Senior 1/Semester 2/Computer Architecture/Project/Code/controller_tb.vhd
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controller_tb IS
END controller_tb;

ARCHITECTURE behavior OF controller_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT controller
        PORT (
            clk : IN STD_LOGIC;

            -- 6-bit opcode
            opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            isImmediate : IN STD_LOGIC;

            -- Immediate Enable
            immediate_enable : OUT STD_LOGIC;

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

    --Inputs
    SIGNAL operation : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');

    --Outputs
    -- Add your controller's output signals here
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL fetch_pc_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL decode_reg_read : STD_LOGIC;
    SIGNAL decode_branch : STD_LOGIC;
    SIGNAL decode_sign_extend : STD_LOGIC;
    SIGNAL alu_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL alu_src2 : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL alu_register_write : STD_LOGIC;
    SIGNAL memory_write : STD_LOGIC;
    SIGNAL memory_read : STD_LOGIC;
    SIGNAL memory_stack_pointer : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL memory_address : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL memory_write_data : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL write_back_register_write1 : STD_LOGIC;
    SIGNAL write_back_register_write2 : STD_LOGIC;
    SIGNAL write_back_register_write_data_1 : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL write_back_register_write_address_1 : STD_LOGIC;
    SIGNAL isImmediate : STD_LOGIC := '0';
    SIGNAL immediate_enable : STD_LOGIC;

    -- Testbench
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : controller PORT MAP(
        clk => clk,
        opcode => operation,
        isImmediate => isImmediate,
        immediate_enable => immediate_enable,
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

    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR 5 ns;
        clk <= '0';
        WAIT FOR 5 ns;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- hold reset state for 100 ns.
        WAIT FOR 100 ns;

        operation <= "000001"; -- not
        WAIT FOR 100 ns;
        ASSERT fetch_pc_sel = "000" REPORT "not: fetch_pc_sel is not the expected value" SEVERITY ERROR;
        ASSERT decode_reg_read = '1' REPORT "not: decode_reg_read is not the expected value" SEVERITY ERROR;
        ASSERT decode_branch = '0' REPORT "not: decode_branch is not the expected value" SEVERITY ERROR;
        ASSERT decode_sign_extend = 'X' REPORT "not: decode_sign_extend is not the expected value" SEVERITY ERROR;
        ASSERT alu_sel = "111" REPORT "not: alu_sel is not the expected value" SEVERITY ERROR;
        ASSERT alu_src2 = "XX" REPORT "not: alu_src2 is not the expected value" SEVERITY ERROR;
        ASSERT alu_register_write = '1' REPORT "not: alu_register_write is not the expected value" SEVERITY ERROR;
        ASSERT memory_write = '0' REPORT "not: memory_write is not the expected value" SEVERITY ERROR;
        ASSERT memory_read = '0' REPORT "not: memory_read is not the expected value" SEVERITY ERROR;
        ASSERT memory_stack_pointer = "00" REPORT "not: memory_stack_pointer is not the expected value" SEVERITY ERROR;
        ASSERT memory_address = "XX" REPORT "not: memory_address is not the expected value" SEVERITY ERROR;
        ASSERT memory_write_data = "XX" REPORT "not: memory_write_data is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write_data_1 = "00" REPORT "not: write_back_register_write_data_1 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write1 = '1' REPORT "not: write_back_register_write1 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write2 = '0' REPORT "not: write_back_register_write2 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write_address_1 = '0' REPORT "not: write_back_register_write_address_1 is not the expected value" SEVERITY ERROR;
        ASSERT immediate_enable = '1' REPORT "not: immediate_enable is not the expected value" SEVERITY ERROR;

        operation <= "000100"; -- dec
        WAIT FOR 100 ns;
        ASSERT fetch_pc_sel = "000" REPORT "dec: fetch_pc_sel is not the expected value" SEVERITY ERROR;
        ASSERT decode_reg_read = '1' REPORT "dec: decode_reg_read is not the expected value" SEVERITY ERROR;
        ASSERT decode_branch = '0' REPORT "dec: decode_branch is not the expected value" SEVERITY ERROR;
        ASSERT decode_sign_extend = 'X' REPORT "dec: decode_sign_extend is not the expected value" SEVERITY ERROR;
        ASSERT alu_sel = "010" REPORT "dec: alu_sel is not the expected value" SEVERITY ERROR;
        ASSERT alu_src2 = "10" REPORT "dec: alu_src2 is not the expected value" SEVERITY ERROR;
        ASSERT alu_register_write = '1' REPORT "dec: alu_register_write is not the expected value" SEVERITY ERROR;
        ASSERT memory_write = '0' REPORT "dec: memory_write is not the expected value" SEVERITY ERROR;
        ASSERT memory_read = '0' REPORT "dec: memory_read is not the expected value" SEVERITY ERROR;
        ASSERT memory_stack_pointer = "00" REPORT "dec: memory_stack_pointer is not the expected value" SEVERITY ERROR;
        ASSERT memory_address = "XX" REPORT "dec: memory_address is not the expected value" SEVERITY ERROR;
        ASSERT memory_write_data = "XX" REPORT "dec: memory_write_data is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write_data_1 = "00" REPORT "dec: write_back_register_write_data_1 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write1 = '1' REPORT "dec: write_back_register_write1 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write2 = '0' REPORT "dec: write_back_register_write2 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write_address_1 = '0' REPORT "dec: write_back_register_write_address_1 is not the expected value" SEVERITY ERROR;
        ASSERT immediate_enable = '1' REPORT "dec: immediate_enable is not the expected value" SEVERITY ERROR;

        operation <= "010000"; -- mov
        WAIT FOR 100 ns;
        ASSERT fetch_pc_sel = "000" REPORT "mov: fetch_pc_sel is not the expected value" SEVERITY ERROR;
        ASSERT decode_reg_read = '1' REPORT "mov: decode_reg_read is not the expected value" SEVERITY ERROR;
        ASSERT decode_branch = '0' REPORT "mov: decode_branch is not the expected value" SEVERITY ERROR;
        ASSERT decode_sign_extend = 'X' REPORT "mov: decode_sign_extend is not the expected value" SEVERITY ERROR;
        ASSERT alu_sel = "011" REPORT "mov: alu_sel is not the expected value" SEVERITY ERROR;
        ASSERT alu_src2 = "00" REPORT "mov: alu_src2 is not the expected value" SEVERITY ERROR;
        ASSERT alu_register_write = '1' REPORT "mov: alu_register_write is not the expected value" SEVERITY ERROR;
        ASSERT memory_write = '0' REPORT "mov: memory_write is not the expected value" SEVERITY ERROR;
        ASSERT memory_read = '0' REPORT "mov: memory_read is not the expected value" SEVERITY ERROR;
        ASSERT memory_stack_pointer = "00" REPORT "mov: memory_stack_pointer is not the expected value" SEVERITY ERROR;
        ASSERT memory_address = "XX" REPORT "mov: memory_address is not the expected value" SEVERITY ERROR;
        ASSERT memory_write_data = "XX" REPORT "mov: memory_write_data is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write_data_1 = "00" REPORT "mov: write_back_register_write_data_1 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write1 = '1' REPORT "mov: write_back_register_write1 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write2 = '0' REPORT "mov: write_back_register_write2 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write_address_1 = '0' REPORT "mov: write_back_register_write_address_1 is not the expected value" SEVERITY ERROR;
        ASSERT immediate_enable = '1' REPORT "mov: immediate_enable is not the expected value" SEVERITY ERROR;

        isImmediate <= '1';
        operation <= "100100"; -- ldm
        WAIT FOR 100 ns;
        ASSERT fetch_pc_sel = "000" REPORT "ldm: fetch_pc_sel is not the expected value" SEVERITY ERROR;
        ASSERT decode_reg_read = '1' REPORT "ldm: decode_reg_read is not the expected value" SEVERITY ERROR;
        ASSERT decode_branch = '0' REPORT "ldm: decode_branch is not the expected value" SEVERITY ERROR;
        ASSERT decode_sign_extend = '1' REPORT "ldm: decode_sign_extend is not the expected value" SEVERITY ERROR;
        ASSERT alu_sel = "011" REPORT "ldm: alu_sel is not the expected value" SEVERITY ERROR;
        ASSERT alu_src2 = "01" REPORT "ldm: alu_src2 is not the expected value" SEVERITY ERROR;
        ASSERT alu_register_write = '1' REPORT "ldm: alu_register_write is not the expected value" SEVERITY ERROR;
        ASSERT memory_write = '0' REPORT "ldm: memory_write is not the expected value" SEVERITY ERROR;
        ASSERT memory_read = '0' REPORT "ldm: memory_read is not the expected value" SEVERITY ERROR;
        ASSERT memory_stack_pointer = "00" REPORT "ldm: memory_stack_pointer is not the expected value" SEVERITY ERROR;
        ASSERT memory_address = "XX" REPORT "ldm: memory_address is not the expected value" SEVERITY ERROR;
        ASSERT memory_write_data = "XX" REPORT "ldm: memory_write_data is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write_data_1 = "00" REPORT "ldm: write_back_register_write_data_1 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write1 = '1' REPORT "ldm: write_back_register_write1 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write2 = '0' REPORT "ldm: write_back_register_write2 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write_address_1 = '0' REPORT "ldm: write_back_register_write_address_1 is not the expected value" SEVERITY ERROR;
        ASSERT immediate_enable = '0' REPORT "ldm: immediate_enable is not the expected value" SEVERITY ERROR;

        isImmediate <= '0';
        operation <= "010101"; -- or
        WAIT FOR 100 ns;
        ASSERT fetch_pc_sel = "000" REPORT "or: fetch_pc_sel is not the expected value" SEVERITY ERROR;
        ASSERT decode_reg_read = '1' REPORT "or: decode_reg_read is not the expected value" SEVERITY ERROR;
        ASSERT decode_branch = '0' REPORT "or: decode_branch is not the expected value" SEVERITY ERROR;
        ASSERT decode_sign_extend = 'X' REPORT "or: decode_sign_extend is not the expected value" SEVERITY ERROR;
        ASSERT alu_sel = "101" REPORT "or: alu_sel is not the expected value" SEVERITY ERROR;
        ASSERT alu_src2 = "00" REPORT "or: alu_src2 is not the expected value" SEVERITY ERROR;
        ASSERT alu_register_write = '1' REPORT "or: alu_register_write is not the expected value" SEVERITY ERROR;
        ASSERT memory_write = '0' REPORT "or: memory_write is not the expected value" SEVERITY ERROR;
        ASSERT memory_read = '0' REPORT "or: memory_read is not the expected value" SEVERITY ERROR;
        ASSERT memory_stack_pointer = "00" REPORT "or: memory_stack_pointer is not the expected value" SEVERITY ERROR;
        ASSERT memory_address = "XX" REPORT "or: memory_address is not the expected value" SEVERITY ERROR;
        ASSERT memory_write_data = "XX" REPORT "or: memory_write_data is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write_data_1 = "00" REPORT "or: write_back_register_write_data_1 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write1 = '1' REPORT "or: write_back_register_write1 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write2 = '0' REPORT "or: write_back_register_write2 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write_address_1 = '0' REPORT "or: write_back_register_write_address_1 is not the expected value" SEVERITY ERROR;
        ASSERT immediate_enable = '1' REPORT "or: immediate_enable is not the expected value" SEVERITY ERROR;

        operation <= "010111"; -- cmp
        WAIT FOR 100 ns;
        ASSERT fetch_pc_sel = "000" REPORT "cmp: fetch_pc_sel is not the expected value" SEVERITY ERROR;
        ASSERT decode_reg_read = '1' REPORT "cmp: decode_reg_read is not the expected value" SEVERITY ERROR;
        ASSERT decode_branch = '0' REPORT "cmp: decode_branch is not the expected value" SEVERITY ERROR;
        ASSERT decode_sign_extend = 'X' REPORT "cmp: decode_sign_extend is not the expected value" SEVERITY ERROR;
        ASSERT alu_sel = "010" REPORT "cmp: alu_sel is not the expected value" SEVERITY ERROR;
        ASSERT alu_src2 = "00" REPORT "cmp: alu_src2 is not the expected value" SEVERITY ERROR;
        ASSERT alu_register_write = '0' REPORT "cmp: alu_register_write is not the expected value" SEVERITY ERROR;
        ASSERT memory_write = '0' REPORT "cmp: memory_write is not the expected value" SEVERITY ERROR;
        ASSERT memory_read = '0' REPORT "cmp: memory_read is not the expected value" SEVERITY ERROR;
        ASSERT memory_stack_pointer = "00" REPORT "cmp: memory_stack_pointer is not the expected value" SEVERITY ERROR;
        ASSERT memory_address = "XX" REPORT "cmp: memory_address is not the expected value" SEVERITY ERROR;
        ASSERT memory_write_data = "XX" REPORT "cmp: memory_write_data is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write_data_1 = "XX" REPORT "cmp: write_back_register_write_data_1 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write1 = '0' REPORT "cmp: write_back_register_write1 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write2 = '0' REPORT "cmp: write_back_register_write2 is not the expected value" SEVERITY ERROR;
        ASSERT write_back_register_write_address_1 = '0' REPORT "cmp: write_back_register_write_address_1 is not the expected value" SEVERITY ERROR;
        ASSERT immediate_enable = '1' REPORT "cmp: immediate_enable is not the expected value" SEVERITY ERROR;

        -- Add more operations and wait states as needed

        -- Finish the test
        WAIT;
    END PROCESS;

END;