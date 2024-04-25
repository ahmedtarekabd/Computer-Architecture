LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- no forwarding yet
-- may need to add zero flags to the output ot send to the controller
ENTITY execute IS
    PORT (
        -------------------------inputs-------------------------
        clk : IN STD_LOGIC;
        -- pc + 1 propagated
        pc_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- opcode from controller
        operation : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- propagated from decode stage
        address_read1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        address_read2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        destination_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- propagated from decode stage
        data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- from controller
        -- propagated from decode stage 1 bit for memread, memwrite (1 bit each), protect & free 1 bit each, 1 regwrite, 1 regRead(i believe no regreads), 2 selectors for (WB, src1, src2), 1 of them is given to the 3rd MUX to know which mode it is in
        -- bit 0 -> memread, bit 1 -> memwrite, bit 2 -> protect, bit 3 -> free, bit 4 -> regwrite, bit 5 -> regread (i believe no regreads), bit 6 & 7 -> selectors for WB, src1, src2
        mem_wb_control_signals_in : IN STD_LOGIC_VECTOR(6 DOWNTO 0);

        -- -- flags in
        -- old_negative_flag : in std_logic;
        -- old_zero_flag : in std_logic;
        -- old_overflow_flag : in std_logic;
        -- old_carry_flag : in std_logic;

        -- commented out for now
        -- forwarded stuff
        -- -- alu to alu forwarding
        -- alu_result_forward : in std_logic_vector(31 downto 0);
        -- -- memory to alu forwarding
        -- memory_result_forward : in std_logic_vector(31 downto 0);

        -- -- control signals in that order, 2 for alu, 2 for mem and 2 for wb
        -- alu_mem_wb_control_signals : in std_logic_vector(5 downto 0);

        -- -- forwarding unit signals
        -- forwarding_unit_signals : in std_logic_vector(1 downto 0);

        -------------------------outputs-------------------------

        -- alu output
        alu_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- mem and wb control signals
        mem_wb_control_signals_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        -- addresses
        address_read1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        address_read2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- data
        data1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        data2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- destination address
        destination_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- pc + 1
        pc_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)

    );
END execute;

ARCHITECTURE arch_execute OF execute IS
    COMPONENT ALU IS
        GENERIC (n : INTEGER := 32);
        PORT (
            A, B : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- A-> src1 , B -> src2
            -- 3 bits opcode
            opcode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            F : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            zero_flag : OUT STD_LOGIC;

            overflow_flag : OUT STD_LOGIC; -- Overflow flag
            carry_flag : OUT STD_LOGIC; -- Carry flag
            negative_flag : OUT STD_LOGIC; -- Negative flag

            --old flags
            old_negative_flag : IN STD_LOGIC; -- Old negative flag
            old_zero_flag : IN STD_LOGIC; -- Old zero flag
            old_overflow_flag : IN STD_LOGIC; -- Old overflow flag
            old_carry_flag : IN STD_LOGIC -- Old carry flag
        );
    END COMPONENT ALU;

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

    -- 4 bit D flip flop for the flags
    COMPONENT my_nDFF IS
        GENERIC (n : INTEGER := 16);
        PORT (
            Clk, reset : IN STD_LOGIC;
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL flags_temp_in : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL flags_temp_out : STD_LOGIC_VECTOR(3 DOWNTO 0);

    SIGNAL d_internal : STD_LOGIC_VECTOR(127 DOWNTO 0);
    SIGNAL q_output : STD_LOGIC_VECTOR(127 DOWNTO 0);
    SIGNAL alu_out_temp : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    -- flags_temp_out <= old_negative_flag_temp & old_zero_flag_temp & old_overflow_flag_temp & old_carry_flag_temp;

    alu_component : ALU
    PORT MAP(
        A => data1_in,
        B => data2_in,
        opcode => operation,
        F => alu_out_temp,
        -- NOTE: negative flag is rightmost in testbench waveform
        negative_flag => flags_temp_in(0),
        zero_flag => flags_temp_in(1),
        overflow_flag => flags_temp_in(2),
        carry_flag => flags_temp_in(3),
        old_negative_flag => flags_temp_out(0),
        old_zero_flag => flags_temp_out(1),
        old_overflow_flag => flags_temp_out(2),
        old_carry_flag => flags_temp_out(3)
    );

    -- DFF for the flags
    flags_dff : my_nDFF GENERIC MAP(4)
    PORT MAP(
        clk, '0', flags_temp_in, flags_temp_out
    );

    -- -- output signals + alu out
    -- pc_out <= pc_in;
    -- mem_wb_control_signals_out <= mem_wb_control_signals_in;
    -- address_read1_out <= address_read1_in;
    -- address_read2_out <= address_read2_in;
    -- data1_out <= data1_in;
    -- data2_out <= data2_in;
    -- destination_address_out <= destination_address;

    d_internal <= alu_out_temp & pc_in & mem_wb_control_signals_in & address_read1_in & address_read2_in & data1_in & data2_in & destination_address;

    execute_mem_reg : my_nDFF GENERIC MAP(128)
    PORT MAP(
        clk, '0', d_internal, q_output
    );

    alu_out <= q_output(127 DOWNTO 96);
    pc_out <= q_output(95 DOWNTO 80);
    mem_wb_control_signals_out <= q_output(79 DOWNTO 73);
    address_read1_out <= q_output(72 DOWNTO 70);
    address_read2_out <= q_output(69 DOWNTO 67);
    data1_out <= q_output(66 DOWNTO 35);
    data2_out <= q_output(34 DOWNTO 3);
    destination_address_out <= q_output(2 DOWNTO 0);

END arch_execute;
-- forwarding_unit : forwarding_unit
-- port map(
--     forwarding_unit_signals => forwarding_unit_signals,
--     address_read1_in => address_read1_in,
--     address_read2_in => address_read2_in,
--     data1_in => data1_in,
--     data2_in => data2_in,
--     alu_result_forward => alu_result_forward,
--     memory_result_forward => memory_result_forward,
--     alu_mem_wb_control_signals => alu_mem_wb_control_signals,
--     address_read1_out => address_read1_out,
--     address_read2_out => address_read2_out,
--     data1_out => data1_out,
--     data2_out => data2_out,
--     destination_address_out => destination_address_out,
--     mem_wb_control_signals => mem_wb_control_signals
-- );