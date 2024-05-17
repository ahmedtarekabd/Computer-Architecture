LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY processor_phase3 IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        RST_signal : IN STD_LOGIC;
        interrupt_signal : IN STD_LOGIC

        -- add in port / out port
    );
END ENTITY processor_phase3;
ARCHITECTURE arch_processor OF processor_phase3 IS

    --**********************************************************COMPONENTS*************************************************--
    --TODO:add in port / out port propagation in fetch?

    COMPONENT fetch
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;

            ----------pc----------
            --first mux
            pc_mux1_selector : IN STD_LOGIC_VECTOR(1 DOWNTO 0); --from controller
            RST_signal : IN STD_LOGIC;
            read_data_from_memory : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            branch_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            -- pc_plus_one : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -> from me

            --second mux
            pc_mux2_selector : IN STD_LOGIC_VECTOR(1 DOWNTO 0); --from exception handling

            --pc nafso
            interrupt_signal : IN STD_LOGIC;

            ----------F/D reg----------
            --enables
            immediate_reg_enable : IN STD_LOGIC; --1 in normal case, 0 when immediate flag is detected
            FD_enable : IN STD_LOGIC;
            FD_enable_loaduse : IN STD_LOGIC;
            pc_enable_hazard_detection : IN STD_LOGIC;

            --reset
            -- RST_signal : IN STD_LOGIC; -> already defined in the mux
            FD_flush : IN STD_LOGIC;
            FD_flush_exception_unit : IN STD_LOGIC;

            ----------outputs----------
            selected_immediate_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- instruction 
            opcode : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            Rsrc1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdest : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            imm_flag : OUT STD_LOGIC;

            propagated_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            propagated_pc_plus_one : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT fetch;

    --TODO add decode component


    COMPONENT execute IS
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
            control_signals_memory_out : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
            control_signals_write_back_out : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);

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
            RST_signal_load_use_input : IN STD_LOGIC;
            -- E/M flush from exception handling
            EM_flush_exception_handling_in : IN STD_LOGIC;
            EM_enable_exception_handling_in : IN STD_LOGIC;

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
            in_port_output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)

        );
    END COMPONENT execute;

    COMPONENT memory_stage IS
        PORT (

            --inputs=======================================================================================================
            clk : IN STD_LOGIC;
            --control signals
            --TODO: confirm this size with tarek (order of bits as the report)
            mem_control_signals_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            wb_control_signals_in : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            RST : IN STD_LOGIC;
            MW_enable : IN STD_LOGIC; -- bat3et el register el kber msh el memory
            MW_flush_from_exception : IN STD_LOGIC;
            --PC
            PC_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            PC_plus_one_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            --prpagated data
            imm_enable_in : IN STD_LOGIC;
            destination_address_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_address1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_address2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_result_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            --flags
            CCR_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

            --outputs=======================================================================================================
            --control Signals
            wb_control_signals_out : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            --propagated data
            destination_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_address1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_address2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_data1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_result_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            --Memory
            mem_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            --Exception
            PC_out_to_exception : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            protected_address_access_to_exception : OUT STD_LOGIC
        );
    END COMPONENT memory_stage;

    COMPONENT write_back IS
        PORT (
            clk : IN STD_LOGIC;
            ------------input signals------------------
            -- Propagated stuff
            read_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- data1 -> R0 (00000000000000000000)
            read_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_address1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_address2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            destination_address_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            mem_read_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            in_port : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            -- pc_in : in std_logic_vector(15 downto 0);
            --bit 0 -> regwrite, bit 3 -> regread (i believe no regreads), bit 1 & 2 -> selectors for WB, src1, src2
            ---------------- control signals ----------------
            reg_write_enable1_in : IN STD_LOGIC;
            reg_write_enable2_in : IN STD_LOGIC;
            Rsrc1_selector_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            reg_write_address1_in_select : IN STD_LOGIC;
            ------------output signals------------------
            -- data
            WB_selected_data_out1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            WB_selected_data_out2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            -- adresses
            WB_selected_address_out1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            WB_selected_address_out2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- Read data from memory
            mem_read_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

            -- from controller (enable signals)
            reg_write_enable1_out : OUT STD_LOGIC;
            reg_write_enable2_out : OUT STD_LOGIC
        );
    END COMPONENT write_back;

    --**********************************************************SIGNALS*************************************************--
        --*--------Fetch---------- 
        --from controller
        signal pc_mux1_selector_to_fetch : STD_LOGIC_VECTOR(1 DOWNTO 0);
        signal FD_enable_to_fetch : STD_LOGIC;
        signal FD_flush_to_fetch : STD_LOGIC;
        -- signal immediate_stall_to_fetch : STD_LOGIC;
        
        --from hazard detection unit
        signal pc_enable_hazard_detection_to_fetch : STD_LOGIC;
        signal FD_enable_loaduse_to_fetch : STD_LOGIC;
        
        --from exception handling unit
        signal pc_mux2_selector_to_fetch : STD_LOGIC_VECTOR(1 DOWNTO 0);
        signal FD_flush_exception_unit_to_fetch : STD_LOGIC;
        
        --from memory
        signal read_data_from_memory_to_fetch : STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        --from decode
        signal branch_address_to_fetch : STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        --outputs
        signal propagated_pc_from_fetch : STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal propagated_pc_plus_one_from_fetch : STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal opcode_from_fetch : STD_LOGIC_VECTOR(5 DOWNTO 0);
        signal Rsrc1_from_fetch : STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal Rsrc2_from_fetch : STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal Rdest_from_fetch : STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal imm_flag_from_fetch : STD_LOGIC;
        signal selected_immediate_out_from_fetch : STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        --*--------Decode----------

        --output to all reg
        signal immediate_stall_to_all : STD_LOGIC;
        
        --*--------Execute----------
        --from decode
        signal pc_in_to_excute : STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal pc_plus_1_in_to_excute : STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal destination_address_to_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal address_read1_in_to_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal address_read2_in_to_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal data1_in_to_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal data2_in_to_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal immediate_in_to_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        --from controller
        -- signal immediate_stall_in_to_execute : STD_LOGIC;
        signal EM_enable_in_to_execute : STD_LOGIC;
        signal EM_flush_in_to_execute : STD_LOGIC;
        signal alu_src2_selector_to_execute : STD_LOGIC_VECTOR(1 DOWNTO 0);
        signal alu_selectors_to_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);

        --from exception handling
        signal EM_flush_exception_handling_to_excute : STD_LOGIC;

        --ouputs
        signal pc_out_from_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal pc_plus_1_out_from_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal destination_address_out_from_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal address_read1_out_from_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal address_read2_out_from_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal data1_swapping_out_from_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal data2_swapping_out_from_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal flag_register_out_from_execute : STD_LOGIC_VECTOR(3 DOWNTO 0);
        signal alu_out_from_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);

        signal zero_flag_out_controller_from_execute : STD_LOGIC;
        signal overflow_flag_out_exception_handling_from_execute : STD_LOGIC;
        --propagation of control signals
        signal control_signals_memory_out_from_execute : STD_LOGIC_VECTOR(10 DOWNTO 0);
        signal control_signals_write_back_out_from_execute : STD_LOGIC_VECTOR(5 DOWNTO 0);

        --to forwarding unit
        signal address1_out_forwarding_unit_from_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal address2_out_forwarding_unit_from_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);

        --*--------Memory----------


        --*--------Write Back----------


    --**********************************************************INST*************************************************--

    begin

        ----------Fetch---------- 
        fetch_inst: fetch PORT MAP(
            clk => clk,
            reset => reset,
            pc_mux1_selector => pc_mux1_selector_to_fetch,
            RST_signal => RST_signal,
            pc_enable_hazard_detection => pc_enable_hazard_detection_to_fetch,
            read_data_from_memory => read_data_from_memory_to_fetch,
            branch_address => branch_address_to_fetch,
            pc_mux2_selector => pc_mux2_selector_to_fetch,
            interrupt_signal => interrupt_signal,
            immediate_reg_enable => immediate_stall_to_all,
            FD_enable => FD_enable_to_fetch,
            FD_enable_loaduse => FD_enable_loaduse_to_fetch,
            FD_flush => FD_flush_to_fetch,
            FD_flush_exception_unit => FD_flush_exception_unit_to_fetch,
            selected_immediate_out => selected_immediate_out_from_fetch,
            opcode => opcode_from_fetch,
            Rsrc1 => Rsrc1_from_fetch,
            Rsrc2 => Rsrc2_from_fetch,
            Rdest => Rdest_from_fetch,
            imm_flag => imm_flag_from_fetch,
            propagated_pc => propagated_pc_from_fetch,
            propagated_pc_plus_one => propagated_pc_plus_one_from_fetch
        );

        ----------Decode---------- 



        ----------Execute----------
        excute_inst: execute PORT MAP (
        clk => clk,
        pc_in => pc_in_to_excute,
        pc_plus_1_in => pc_plus_1_in_to_excute,
        destination_address => destination_address_to_execute,
        address_read1_in => address_read1_in_to_execute,
        address_read2_in => address_read2_in_to_execute,
        immediate_enable_in => immediate_stall_to_all,
        data1_in => data1_in_to_execute,
        data2_in => data2_in_to_execute,
        immediate_in => immediate_in_to_execute,
        forwarded_data1_em => forwarded_data1_em, --need forwarding unit to complete
        forwarded_data2_em => forwarded_data2_em,
        forwarded_alu_out_em => forwarded_alu_out_em,
        forwarded_data1_mw => forwarded_data1_mw,
        forwarded_data2_mw => forwarded_data2_mw,
        forwarding_mux_selector_op2 => forwarding_mux_selector_op2,
        forwarding_mux_selector_op1 => forwarding_mux_selector_op1,
        control_signals_memory_in => control_signals_memory_out_from_execute,
        control_signals_write_back_in => control_signals_write_back_out_from_execute,
        alu_selectors => alu_selectors_to_execute,
        alu_src2_selector => alu_src2_selector_to_execute,
        execute_mem_register_enable => EM_enable_in_to_execute,
        RST_signal_input => RST_signal,
        RST_signal_load_use_input => RST_signal_load_use_input, --what is this?
        EM_flush_exception_handling_in => EM_flush_exception_handling_to_excute,
        EM_enable_exception_handling_in => EM_enable_exception_handling_in, --not found in the digram
        pc_out => pc_out_from_execute,
        pc_plus_1_out => pc_plus_1_out_from_execute,
        destination_address_out => destination_address_out_from_execute,
        address_read1_out => address_read1_out_from_execute,
        address_read2_out => address_read2_out_from_execute,
        flag_register_out => flag_register_out_from_execute,
        alu_out => alu_out_from_execute,
        immediate_enable_out => immediate_enable_out_from_execute, --it shouldn't be propagated
        data1_swapping_out => data1_swapping_out_from_execute,
        data2_swapping_out => data2_swapping_out_from_execute,
        zero_flag_out_controller => zero_flag_out_controller_from_execute,
        overflow_flag_out_exception_handling => overflow_flag_out_exception_handling_from_execute,
        address1_out_forwarding_unit => address1_out_forwarding_unit_from_execute,
        address2_out_forwarding_unit => address2_out_forwarding_unit_from_execute,
        pc_out_exception_handling => pc_out_exception_handling_from_execute, --is it the same as the ouputed pc?
        in_port_input => , --should it be propagated or what?
        in_port_output => in_port_output
   );


        ----------Memory----------


        ----------Write Back----------



    END ARCHITECTURE arch_processor;
