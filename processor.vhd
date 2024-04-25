LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY processor IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC

        -- add in port / out port
    );
END ENTITY processor;

ARCHITECTURE arch_processor OF processor IS

    COMPONENT fetch IS
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            selected_instruction_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            selected_immediate_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT fetch;

    COMPONENT decode IS
        PORT (
            clk : IN STD_LOGIC;
            instruction_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            immediate_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

            -- WB
            write_enable1 : IN STD_LOGIC;
            write_enable2 : IN STD_LOGIC;
            write_address1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_address2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_data1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            write_data2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            -- Propagated signals
            pc_plus_1 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);

            decode_execute_out : OUT STD_LOGIC_VECTOR(140 - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT execute IS
        PORT (
            -------------------------inputs-------------------------
            clk : IN STD_LOGIC;
            -- immediate value from decode stage
            immediate_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            -- propagated from decode stage
            address_read1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            address_read2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            destination_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- propagated from decode stage
            data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            control_signals_in : IN STD_LOGIC_VECTOR(22 DOWNTO 0);

            -------------------------outputs-------------------------

            -- alu output
            alu_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            outputed_control_signals : OUT STD_LOGIC_VECTOR(22 DOWNTO 0);
            -- addresses
            address_read1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            address_read2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            -- data
            data1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            data2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            -- destination address
            destination_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT execute;

    COMPONENT memory_stage IS
        PORT (

            -----------------------------------------inputs-----------------------------------------
            clk : IN STD_LOGIC;
            -- reset : in std_logic;

            -- Propagated stuff innit
            read_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_address1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_address2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            destination_address_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- propagated from decode stage 1 bit for memread, memwrite (1 bit each), protect & free 1 bit each, 1 regwrite, 1 regRead(i believe no regreads), 2 selectors for (WB, src1, src2), 1 of them is given to the 3rd MUX to know which mode it is in
            -- bit 0 -> memread, bit 1 -> memwrite, bit 2 -> protect, bit 3 -> free, bit 4 -> regwrite, bit 5 -> regread (i believe no regreads), bit 6 & 7 -> selectors for WB, src1, src2
            mem_wb_control_signals_in : IN STD_LOGIC_VECTOR(6 DOWNTO 0);

            -- PC + 1
            pc_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

            mem_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            -- depends on the control signal same as ALU out
            mem_read_or_write_addr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            -----------------------------------------outputs-----------------------------------------
            mem_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_address1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_address2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            destination_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            wb_control_signals_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)

            -- for forwarding make another output for the write data
        );
    END COMPONENT memory_stage;

    COMPONENT write_back IS
        PORT (
            clk : IN STD_LOGIC;

            ------------input signals------------------
            -- Propagated stuff
            read_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_address1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_address2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            destination_address_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            mem_read_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            --bit 0 -> regwrite, bit 3 -> regread (i believe no regreads), bit 1 & 2 -> selectors for WB, src1, src2
            wb_control_signals_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            ------------output signals------------------
            selected_data_out1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            selected_data_out2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            -- selects between read address 1 and destination address
            selected_address_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_address2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            -- from controller
            regWrite_out_control_signal : OUT STD_LOGIC
        );
    END COMPONENT write_back;

    --decode
    SIGNAL instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL immediate : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL write_enable1 : STD_LOGIC;
    SIGNAL write_enable2 : STD_LOGIC;
    SIGNAL write_address1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL write_address2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL write_data1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL write_data2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_plus_1 : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL decode_execute_out : STD_LOGIC_VECTOR(140 - 1 DOWNTO 0);

    -- execute
    SIGNAL alu_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL outputed_control_signals : STD_LOGIC_VECTOR(22 DOWNTO 0);
    SIGNAL address_read1_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL address_read2_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL data1_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL data2_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL destination_address_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN

    ----------Fetch---------- 

    fetch_inst : fetch PORT MAP(
        clk => clk,
        reset => reset,
        selected_instruction_out => instruction,
        selected_immediate_out => immediate
    );

    ----------Decode----------

    decode_inst : decode PORT MAP(
        clk => clk,
        instruction_in => instruction,
        immediate_in => immediate,
        write_enable1 => write_enable1,
        write_enable2 => write_enable2,
        write_address1 => write_address1,
        write_address2 => write_address2,
        write_data1 => write_data1,
        write_data2 => write_data2,
        pc_plus_1 => pc_plus_1,
        decode_execute_out => decode_execute_out
    );

    ----------Execute----------

    execute_inst : execute PORT MAP(
        clk => clk,
        -- immediate_in => decode_execute_out(140 - 1 - 23 - 32 - 32 - 3 - 3 - 3 DOWNTO 140 - 1 - 23 - 32 - 32 - 3 - 3 - 3 - 31),
        immediate_in => decode_execute_out(43 DOWNTO 12),
        address_read1_in => decode_execute_out(140 - 1 - 23 - 32 - 32 DOWNTO 140 - 1 - 23 - 32 - 32 - 2),
        address_read2_in => decode_execute_out(140 - 1 - 23 - 32 - 32 - 3 DOWNTO 140 - 1 - 23 - 32 - 32 - 3 - 2),
        destination_address => decode_execute_out(140 - 1 - 23 - 32 - 32 - 3 - 3 DOWNTO 140 - 1 - 23 - 32 - 32 - 3 - 3 - 2),
        data1_in => decode_execute_out(140 - 1 - 23 DOWNTO 140 - 1 - 23 - 31),
        data2_in => decode_execute_out(140 - 1 - 23 - 32 DOWNTO 140 - 1 - 23 - 32 - 31),
        control_signals_in => decode_execute_out(140 - 1 DOWNTO 140 - 1 - 22),
        alu_out => alu_out,
        outputed_control_signals => outputed_control_signals,
        address_read1_out => address_read1_out,
        address_read2_out => address_read2_out,
        data1_out => data1_out,
        data2_out => data2_out,
        destination_address_out => destination_address_out
    );

END ARCHITECTURE arch_processor;