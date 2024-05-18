LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY execute IS
    PORT (
        -------------------------inputs-------------------------
        clk : IN STD_LOGIC;
        ---------------------------- Propagated from the previous stage------------------------
        -- pc + 1 propagated (32 bits)
        -- pc propagated
        pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_plus_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- destination address from decode stage
        destination_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- write address 1 and 2
        address_read1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        address_read2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- immediate flag 
        immediate_enable_in : IN STD_LOGIC;

        ---------------------------- Normal useful inputs ------------------------
        -- data 1 and 2 from the register file
        data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- immediate value from decode stage
        immediate_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        ---------------------------- Forwarded data ------------------------
        -- forwarded data 1 and 2 from Mem stage
        forwarded_data1_em : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        forwarded_data2_em : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        forwarded_alu_out_em : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- forwarded from the write back stage
        forwarded_data1_mw : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        forwarded_data2_mw : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        ---------------------------- Forwarding control signals ------------------------
        -- opp 2 mux selector 3 bits
        forwarding_mux_selector_op2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- opp 1 mux selector 3 bits
        forwarding_mux_selector_op1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -------------------------------- Control signals ------------------------

        -------------------------------- Propagated from the previous stage ------------------------
        -- 11 bits for memory control signals and 5 bits for write back control signals
        control_signals_memory_in : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        control_signals_write_back_in : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        -- output them

        -------------------------------- used in the execute stage ------------------------
        -- alu selectors 3 bits
        alu_selectors : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- mux selector for src2 and immediate 2 bits
        alu_src2_selector : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

        -- register enable 1 bit
        execute_mem_register_enable : IN STD_LOGIC;
        -- reset signal input
        RST_signal_input : IN STD_LOGIC;
        -- Load use reset
        execute_mem_flush_controller : IN STD_LOGIC;
        -- E/M flush from exception handling
        EM_flush_exception_handling_in : IN STD_LOGIC;
        -- EM_enable_exception_handling_in : IN STD_LOGIC;

        ------------------------- Outputs -------------------------
        ------------------------- Propagated outputs -------------------------
        -- pc + 1 propagated (32 bits)
        -- pc propagated also used for exception handling
        pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_plus_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- destination address from decode stage
        destination_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- write address 1 and 2 for forwarding and propagation
        address_read1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        address_read2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        ---------------------- Stage outputs ----------------------

        -- overflow exception output 1 bit
        -- zero flag to controller 1 bit
        -- flag register output 4 bits, 0 -> zero, 1 -> overflow, 2 -> carry, 3 -> negative
        flag_register_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

        -- ALU output 32 bits
        alu_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- immediate flag output
        immediate_enable_out : OUT STD_LOGIC;

        ----------------------- For swapping -----------------------
        -- data 1 and 2 for swapping 32 bits
        data1_swapping_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        data2_swapping_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ---------------------- Outputs not propagated ----------------------
        -- 1 bit zero flag
        -- 1 bit overflow flag
        -- 3 bits address 1
        -- 3 bits address 2
        -- 32 bits PC
        zero_flag_out_controller : OUT STD_LOGIC;
        overflow_flag_out_exception_handling : OUT STD_LOGIC;
        address1_out_forwarding_unit : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        address2_out_forwarding_unit : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        pc_out_exception_handling : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ------------------- In Port -----------------
        in_port_input : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        in_port_output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        control_signals_memory_out : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
        control_signals_write_back_out : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        ALU_result_before_EM : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)

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
            Clk, reset, enable : IN STD_LOGIC;
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT my_nDFF;

    -- internal signals
    SIGNAL op1_mux_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL op2_mux_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL op2_mux_in : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL flag_register_in_temp : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL flag_register_out_temp : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- for Execute/Mem register
    SIGNAL d_output : STD_LOGIC_VECTOR(222 DOWNTO 0);
    SIGNAL q_output : STD_LOGIC_VECTOR(222 DOWNTO 0);

    -- output signals
    SIGNAL alu_out_temp : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Pipeline registers
    SIGNAL execute_mem_reset : STD_LOGIC;
    SIGNAL execute_mem_enable : STD_LOGIC;

BEGIN
    -- data 2 and immediate mux
    -- MUX2: mux4x1 PORT MAP (
    --     inputA => data2_in,
    --     inputB => immediate_in,
    --     inputC => "00000000000000000000000000000001",
    --     inputD => (OTHERS => '0'),
    --     Sel_lower => alu_src2_selector(0),
    --     Sel_higher => alu_src2_selector(1),
    --     output => op2_mux_in
    -- );

    WITH alu_src2_selector SELECT
        op2_mux_in <= data2_in WHEN "00",
        immediate_in WHEN "01",
        "00000000000000000000000000000001" WHEN "10",
        (OTHERS => '0') WHEN OTHERS;
    -- forwarding mux 1 8x1
    -- 000 data_1in
    -- 001 forwarded_alu_out_em
    -- 010 forwarded_data1_mw
    -- 011 forwarded_data2_mw 
    -- 100 forwarded_data1_em
    -- 101 forwarded_data2_em
    -- for the rest of the cases, the data is zero
    WITH forwarding_mux_selector_op1 SELECT
        op1_mux_out <= data1_in WHEN "000",
        forwarded_alu_out_em WHEN "001",
        forwarded_data1_mw WHEN "010",
        forwarded_data2_mw WHEN "011",
        forwarded_data1_em WHEN "100",
        forwarded_data2_em WHEN "101",
        (OTHERS => '0') WHEN OTHERS;

    -- forwarding mux 2 8x1
    -- 000 data_2in
    -- 001 forwarded_alu_out_em
    -- 010 forwarded_data1_mw
    -- 011 forwarded_data2_mw
    -- 100 forwarded_data1_em
    -- 101 forwarded_data2_em
    -- for the rest of the cases, the data is zero
    WITH forwarding_mux_selector_op2 SELECT
        op2_mux_out <= op2_mux_in WHEN "000",
        forwarded_alu_out_em WHEN "001",
        forwarded_data1_mw WHEN "010",
        forwarded_data2_mw WHEN "011",
        forwarded_data1_em WHEN "100",
        forwarded_data2_em WHEN "101",
        (OTHERS => '0') WHEN OTHERS;
    -- ALU
    ALU1 : ALU PORT MAP(
        A => op1_mux_out,
        B => op2_mux_out,
        opcode => alu_selectors,
        F => alu_out_temp,
        zero_flag => flag_register_in_temp(0),
        overflow_flag => flag_register_in_temp(1),
        carry_flag => flag_register_in_temp(2),
        negative_flag => flag_register_in_temp(3),
        old_negative_flag => flag_register_out_temp(3),
        old_zero_flag => flag_register_out_temp(0),
        old_overflow_flag => flag_register_out_temp(1),
        old_carry_flag => flag_register_out_temp(2)
    );

    -- before flip flop
    ALU_result_before_EM <= alu_out_temp;

    -- flag register
    FLAG_REGISTER : my_nDFF
    GENERIC MAP(4)
    PORT MAP(
        Clk => clk,
        -- check the reset. i decided that it is the user's reset input signal
        reset => RST_signal_input,
        enable => '1',
        d => flag_register_in_temp,
        q => flag_register_out_temp
    );

    -- other outputs that are not sent to register are 
    -- 1 bit zero flag
    -- 1 bit overflow flag
    -- 3 bits address 1
    -- 3 bits address 2
    -- 32 bits PC 
    pc_out_exception_handling <= pc_in;
    overflow_flag_out_exception_handling <= flag_register_out_temp(1);
    zero_flag_out_controller <= flag_register_out_temp(0);
    -- address 1 and 2 forwarding unit
    address1_out_forwarding_unit <= address_read1_in;
    address2_out_forwarding_unit <= address_read2_in;

    d_output <=
        in_port_input &
        control_signals_memory_in &
        control_signals_write_back_in &
        destination_address &
        pc_in &
        pc_plus_1_in &
        address_read1_in &
        address_read2_in &
        data1_in & data2_in &
        alu_out_temp &
        flag_register_out_temp &
        immediate_enable_in;
    -- Execute/Mem register enable is the execute memory enable  OR propagated immediate flag
    -- execute_mem_enable <= execute_mem_register_enable OR immediate_enable_in;
    -- Execute/Mem register reset is the user input reset signal OR the load use stall signal OR the flush signal from exception handling
    execute_mem_reset <= RST_signal_input OR execute_mem_flush_controller OR EM_flush_exception_handling_in;

    -- Execute/Mem register
    execute_mem_reg : my_nDFF GENERIC MAP(223)
    PORT MAP(
        clk, execute_mem_reset, '1', d_output, q_output
    );

    -- internal signals to be sent to the next stage output register 188 bits
    -- 11 bits memory control signals
    -- 6 bits write back control signals
    -- 3 bits propagated rdst
    -- 32 bits propagated pc
    -- 32 bits propagated pc + 1
    -- 3 bits propagated write address 1
    -- 3 bits propagated write address 2
    -- 32 bits propagated data 1 for swapping
    -- 32 bits propagated data 2 for swapping
    -- 32 bits propagated alu out
    -- 4 bits propagated flags
    -- 1 bit immediate flag
    -- 191 bits in total.
    -- from left to right most significant to least significant
    in_port_output <= q_output(222 DOWNTO 191);
    control_signals_memory_out <= q_output(190 DOWNTO 180);
    control_signals_write_back_out <= q_output(179 DOWNTO 174);
    destination_address_out <= q_output(173 DOWNTO 171);
    pc_out <= q_output(170 DOWNTO 139);
    pc_plus_1_out <= q_output(138 DOWNTO 107);
    address_read1_out <= q_output(106 DOWNTO 104);
    address_read2_out <= q_output(103 DOWNTO 101);
    data1_swapping_out <= q_output(100 DOWNTO 69);
    data2_swapping_out <= q_output(68 DOWNTO 37);
    alu_out <= q_output(36 DOWNTO 5);
    flag_register_out <= q_output(4 DOWNTO 1);
    immediate_enable_out <= q_output(0);

END arch_execute;