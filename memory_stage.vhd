LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--  Might need to adjust memory width
ENTITY memory_stage IS
    PORT (
        -----------------------------------------inputs-----------------------------------------
        clk : IN STD_LOGIC;
        -- reset : in std_logic;

        -- Propagated stuff innit
        read_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_address1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_address2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        destination_address_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- propagated from decode stage 1 bit for memread, memwrite (1 bit each), protect & free 1 bit each, 1 regwrite, 1 regRead(i believe no regreads), 2 selectors for (WB, src1, src2), 1 of them is given to the 3rd MUX to know which mode it is in
        -- bit 0 -> memread, bit 1 -> memwrite, bit 2 -> protect, bit 3 -> free, bit 4 -> regwrite, bit 5 -> regread (i believe no regreads), bit 6 & 7 -> selectors for WB, src1, src2
        mem_wb_control_signals_in : IN STD_LOGIC_VECTOR(6 DOWNTO 0);

        -- PC + 1
        pc_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        mem_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- depends on the control signal same as ALU out which is 32 bits
        mem_read_or_write_addr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        -----------------------------------------outputs-----------------------------------------
        mem_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_address1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_address2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        destination_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        pc_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        wb_control_signals_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)

        -- for forwarding make another output for the write data
    );
END memory_stage;

ARCHITECTURE memory_stage_arch OF memory_stage IS

    COMPONENT memory IS
        PORT (
            clk : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(11 DOWNTO 0);

            write_enable : IN STD_LOGIC;
            write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            read_enable : IN STD_LOGIC;
            read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

            protect_signal : IN STD_LOGIC;
            free_signal : IN STD_LOGIC

        );
    END COMPONENT memory;

    COMPONENT my_nDFF IS
        GENERIC (n : INTEGER := 16);
        PORT (
            Clk, reset, enable : IN STD_LOGIC;
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT
    SIGNAL mem_read_data_internal : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL d_internal : STD_LOGIC_VECTOR(123 DOWNTO 0);
    SIGNAL q_output : STD_LOGIC_VECTOR(123 DOWNTO 0);

BEGIN
    mem : memory
    PORT MAP(
        clk => clk,
        -- addressing the memory using the 12 bits only
        address => mem_read_or_write_addr(11 DOWNTO 0),
        write_enable => mem_wb_control_signals_in(1),
        write_data => mem_write_data,
        read_enable => mem_wb_control_signals_in(0),
        read_data => mem_read_data_internal, -- the 7th output
        protect_signal => mem_wb_control_signals_in(2),
        free_signal => mem_wb_control_signals_in(3)
    );

    -- mem_read_data <= mem_read_data_internal;
    -- read_data1_out <= read_data1_in;
    -- read_data2_out <= read_data2_in;
    -- read_address1_out <= read_address1_in;
    -- read_address2_out <= read_address2_in;
    -- destination_address_out <= destination_address_in;
    -- pc_out <= pc_in;
    -- wb_control_signals_out <= mem_wb_control_signals_in(6 downto 4);

    d_internal <= mem_read_data_internal & read_data1_in & read_data2_in & read_address1_in & read_address2_in & destination_address_in & pc_in & mem_wb_control_signals_in(6 DOWNTO 4);
    mem_wb_reg : my_nDFF
    GENERIC MAP(n => 124)
    PORT MAP(
        Clk => clk,
        reset => '0',
        enable => '1',
        d => d_internal,
        q => q_output
    );
    mem_read_data <= q_output(123 DOWNTO 92);
    read_data1_out <= q_output(91 DOWNTO 60);
    read_data2_out <= q_output(59 DOWNTO 28);
    read_address1_out <= q_output(27 DOWNTO 25);
    read_address2_out <= q_output(24 DOWNTO 22);
    destination_address_out <= q_output(21 DOWNTO 19);
    pc_out <= q_output(18 DOWNTO 3);
    wb_control_signals_out <= q_output(2 DOWNTO 0);
END memory_stage_arch;