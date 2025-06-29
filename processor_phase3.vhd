LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY processor_phase3 IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        RST_signal : IN STD_LOGIC;
        interrupt_signal : IN STD_LOGIC;
        in_port_from_processor : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        --outputs
        out_port_to_processor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        --first 32 bits are the pc that caused the exception, last bit is the exception type 0 -> mem protection, 1 -> overflow
        EPC_out_to_processor : OUT STD_LOGIC_VECTOR(32 DOWNTO 0)
    );
END ENTITY processor_phase3;
ARCHITECTURE arch_processor OF processor_phase3 IS

    --**********************************************************COMPONENTS*************************************************--
    COMPONENT forwarding_unit
        PORT (
            -- Addresses
            -- From Decode/Execute
            src_address1_de : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            src_address2_de : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            dst_address_de : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- From Execute/Memory
            dst_address_em : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            src_address1_em : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            src_address2_em : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- From Memory/Writeback
            -- address1 is address1 is register file and is either src1 or rdst
            address1_mw : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            -- address2 is address 2 in register file always src2
            address2_mw : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- Rdst from the Fetch/Decode stage which is Source 1 address in diagram
            dst_address_fd : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- Control Signals
            memory_read_em : IN STD_LOGIC;
            -- FROM Decode/Execute
            memory_read_de : IN STD_LOGIC;

            -- Output signals
            opp1_ALU_MUX_SEL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            opp2_ALU_MUX_SEL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

            opp_branching_mux_selector : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            opp_branch_or_normal_mux_selector : OUT STD_LOGIC;

            load_use_hazard : OUT STD_LOGIC;

            -- From Execute/Memory
            -- write_back_em : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            write_back_em_enable1 : IN STD_LOGIC;
            write_back_em_enable2 : IN STD_LOGIC;

            -- From Memory/Writeback
            -- write_back_mw : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            write_back_mw_enable1 : IN STD_LOGIC;
            write_back_mw_enable2 : IN STD_LOGIC;

            -- From Decode/Execute
            -- write_back_de : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            write_back_de_enable1 : IN STD_LOGIC;
            write_back_de_enable2 : IN STD_LOGIC;

            --inputs for forwading in port case
            -- FOR IN instruction I need reg_write_address1_in_select if it is 11 and src1 in execute is same as address 1 from WB then forwarding happens
            reg_write_address1_in_select_em : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            reg_write_address1_in_select_mw : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            -- add additional check for presence of out port opcode
            -- if true and adresses match then we need to forward
            out_port_enable : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT hazard_detection_unit
        PORT (
            src_address1_fd : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            src_address2_fd : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            dst_address_de : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_back_1_de : IN STD_LOGIC;
            memory_read_de : IN STD_LOGIC;
            reg_read_controller : IN STD_LOGIC;
            PC_enable : OUT STD_LOGIC;
            enable_fd : OUT STD_LOGIC;
            reset_de : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT exception_handling_unit IS
        PORT (
            clk : IN STD_LOGIC;
            pc_from_EM : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_from_DE : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            overflow_flag_from_alu : IN STD_LOGIC;
            protected_bit_exeception_from_memory : IN STD_LOGIC;

            --outputs
            exception_out_port : OUT STD_LOGIC := '0';
            second_pc_mux_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
            FD_flush : OUT STD_LOGIC := '0';
            DE_flush : OUT STD_LOGIC := '0';
            EM_flush : OUT STD_LOGIC := '0';
            MW_flush : OUT STD_LOGIC := '0';

            --output to epc
            --first 32 bits are the pc, last bit is the exception type 0 -> mem protection, 1 -> overflow
            EPC_output : OUT STD_LOGIC_VECTOR(32 DOWNTO 0)

        );
    END COMPONENT exception_handling_unit;

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
            immediate_stall : IN STD_LOGIC; --1 in normal case, 0 when immediate flag is detected
            FD_enable : IN STD_LOGIC;
            FD_enable_loaduse : IN STD_LOGIC;
            pc_enable_hazard_detection : IN STD_LOGIC;

            --reset
            -- RST_signal : IN STD_LOGIC; -> already defined in the mux
            FD_flush : IN STD_LOGIC;
            FD_flush_exception_unit : IN STD_LOGIC;

            --in port
            in_port_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            ----------outputs----------
            in_port_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
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
    COMPONENT decode
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
            in_port_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

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
            forwarded_alu_out_em : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
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
    END COMPONENT decode;

    --TODO add decode component
    COMPONENT execute
        PORT (
            clk : IN STD_LOGIC;
            pc_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            pc_plus_1_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            destination_address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            address_read1_in : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            address_read2_in : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            immediate_enable_in : IN STD_LOGIC;
            data1_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            data2_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            immediate_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            forwarded_data1_em : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            forwarded_data2_em : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            forwarded_alu_out_em : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            forwarded_data1_mw : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            forwarded_data2_mw : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            forwarding_mux_selector_op2 : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            forwarding_mux_selector_op1 : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            control_signals_memory_in : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
            control_signals_write_back_in : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
            
            alu_selectors : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            alu_src2_selector : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
            execute_mem_register_enable : IN STD_LOGIC;
            RST_signal_input : IN STD_LOGIC;
            execute_mem_flush_controller : IN STD_LOGIC;
            EM_flush_exception_handling_in : IN STD_LOGIC;
            pc_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            pc_plus_1_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            destination_address_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            address_read1_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            address_read2_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            flag_register_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);         --zero / overflow flag /carry / negative flag
            alu_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            immediate_enable_out : OUT STD_LOGIC;
            data1_swapping_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            data2_swapping_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            zero_flag_out_controller : OUT STD_LOGIC; 
            overflow_flag_out_exception_handling : OUT STD_LOGIC;
            address1_out_forwarding_unit : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            address2_out_forwarding_unit : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            pc_out_exception_handling : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            
            in_port_input : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            in_port_output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            control_signals_memory_out : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            control_signals_write_back_out : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
            ALU_result_before_EM : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            --inputs godad
            in_port_forwarded_from_EM : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            in_port_forwarded_from_MW : IN STD_LOGIC_VECTOR(31 DOWNTO 0)

        );
    END COMPONENT;

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
            in_port_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
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
            in_port_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
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
    SIGNAL pc_mux1_selector_to_fetch : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL FD_enable_to_fetch : STD_LOGIC := '1';
    SIGNAL FD_flush_to_fetch : STD_LOGIC;
    -- signal immediate_stall_to_fetch : STD_LOGIC;

    --from hazard detection unit
    SIGNAL pc_enable_hazard_detection_to_fetch : STD_LOGIC;
    SIGNAL FD_enable_loaduse_to_fetch : STD_LOGIC;

    --from exception handling unit
    SIGNAL pc_mux2_selector_to_fetch : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL FD_flush_exception_unit_to_fetch : STD_LOGIC;

    --from memory
    SIGNAL read_data_from_memory_to_fetch : STD_LOGIC_VECTOR(31 DOWNTO 0);

    --from decode
    SIGNAL branch_address_to_fetch : STD_LOGIC_VECTOR(31 DOWNTO 0);

    --outputs
    SIGNAL in_port_from_fetch : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL propagated_pc_from_fetch : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL propagated_pc_plus_one_from_fetch : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL opcode_from_fetch : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL Rsrc1_from_fetch : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL Rsrc2_from_fetch : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL Rdest_from_fetch : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL imm_flag_from_fetch : STD_LOGIC;
    SIGNAL selected_immediate_out_from_fetch : STD_LOGIC_VECTOR(15 DOWNTO 0);

    --*--------Decode----------

    --from forwarding
    SIGNAL branching_opp_mux_sel_forwarding_to_decode : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL branching_or_normal_sel_forwarding_to_decode : STD_LOGIC;

    --from
    SIGNAL branch_prediction_flush_to_Decode : STD_LOGIC;
    SIGNAL exception_handling_flush_to_Decode : STD_LOGIC;
    SIGNAL hazard_detection_flush_to_Decode : STD_LOGIC;

    --output
    SIGNAL in_port_from_Decode : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL immediate_stall_to_fetch_and_decode : STD_LOGIC := '0';
    SIGNAL execute_control_signals_from_decode : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL memory_control_signals_from_decode : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL wb_control_signals_from_decode : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL write_back_1_forwarding_from_decode : STD_LOGIC;
    SIGNAL write_back_2_forwarding_from_decode : STD_LOGIC;
    SIGNAL memory_read_from_decode : STD_LOGIC;
    --*--------Execute----------
    --from decode
    SIGNAL pc_in_to_excute : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_plus_1_in_to_excute : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL destination_address_to_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL address_read1_in_to_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL address_read2_in_to_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL data1_in_to_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL data2_in_to_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL immediate_in_to_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --from execute
    SIGNAL alu_result_from_Execution_before_EM : STD_LOGIC_VECTOR(31 DOWNTO 0);

    --from controller
    SIGNAL EM_enable_in_to_execute : STD_LOGIC;
    SIGNAL EM_flush_in_to_execute : STD_LOGIC;
    SIGNAL Alu_src2_selector_to_execute : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL Alu_selectors_to_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL EM_flush_controller_to_execute : STD_LOGIC;

    --from exception handling
    SIGNAL EM_flush_exception_handling_to_excute : STD_LOGIC;

    --from forwarding unit
    SIGNAL forwarding_mux_selector_op2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL forwarding_mux_selector_op1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal write_back_rsrc1_data_from_execute : STD_LOGIC_VECTOR(1 DOWNTO 0);

    --ouputs
    SIGNAL pc_out_from_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_plus_1_out_from_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL destination_address_out_from_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL address_read1_out_from_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL address_read2_out_from_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL data1_swapping_out_from_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL data2_swapping_out_from_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL flag_register_out_from_execute : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL alu_out_from_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL in_port_from_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_out_to_exception_from_execute : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL memory_read_from_execute : STD_LOGIC;

    SIGNAL zero_flag_out_controller_from_execute : STD_LOGIC;
    SIGNAL overflow_flag_out_exception_handling_from_execute : STD_LOGIC;
    --propagation of control signals
    SIGNAL control_signals_memory_out_from_execute : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL control_signals_write_back_out_from_execute : STD_LOGIC_VECTOR(5 DOWNTO 0);

    --to forwarding unit
    SIGNAL address1_out_forwarding_unit_from_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL address2_out_forwarding_unit_from_execute : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL write_back_1_forwarding_from_excute : STD_LOGIC;
    SIGNAL write_back_2_forwarding_from_excute : STD_LOGIC;

    --*--------Memory----------
    --from controller
    SIGNAL MW_enable_to_memory : STD_LOGIC;
    SIGNAL MW_flush_to_memory : STD_LOGIC;

    --from exepction handling
    SIGNAL MW_flush_from_exception_to_memory : STD_LOGIC;

    --outputs
    SIGNAL wb_control_signals_out_from_memory : STD_LOGIC_VECTOR(5 DOWNTO 0); -- -> to wb
    SIGNAL write_address1_out_from_memory : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL write_address2_out_from_memory : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL write_address1_out_from_wb : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL write_address2_out_from_wb : STD_LOGIC_VECTOR(2 DOWNTO 0);

    SIGNAL read_data1_out_from_memory : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_data2_out_from_memory : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_data1_out_from_wb : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_data2_out_from_wb : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL ALU_result_out_from_memory : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_read_data_from_memory : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PC_out_to_exception_from_memory : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL protected_address_access_to_exception_from_memory : STD_LOGIC;
    SIGNAL Rdst_from_memory : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL in_port_from_memory : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --*--------Write Back----------
    --from controller
    SIGNAL reg_write_enable1_in_to_wb : STD_LOGIC;
    SIGNAL reg_write_enable2_in_to_wb : STD_LOGIC;
    SIGNAL reg_write_address1_mux_to_wb : STD_LOGIC;
    SIGNAL rscr1_data_to_wb : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL read_data1_in_to_wb : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- Outputs
    SIGNAL reg_write_enable1_from_wb : STD_LOGIC;
    SIGNAL reg_write_enable2_from_wb : STD_LOGIC;
    --**********************************************************INST*************************************************--

BEGIN

    ----------Fetch---------- 
    fetch_inst : fetch PORT MAP(
        clk => clk,
        reset => reset,
        pc_mux1_selector => pc_mux1_selector_to_fetch,
        RST_signal => RST_signal,
        pc_enable_hazard_detection => pc_enable_hazard_detection_to_fetch,
        read_data_from_memory => mem_read_data_from_memory,
        branch_address => branch_address_to_fetch,
        pc_mux2_selector => pc_mux2_selector_to_fetch,
        interrupt_signal => interrupt_signal,
        immediate_stall => immediate_stall_to_fetch_and_decode,
        FD_enable => FD_enable_to_fetch,
        FD_enable_loaduse => FD_enable_loaduse_to_fetch,
        FD_flush => FD_flush_to_fetch,
        FD_flush_exception_unit => FD_flush_exception_unit_to_fetch,
        selected_immediate_out => selected_immediate_out_from_fetch,
        in_port_in => in_port_from_processor,
        in_port_out => in_port_from_fetch,
        opcode => opcode_from_fetch,
        Rsrc1 => Rsrc1_from_fetch,
        Rsrc2 => Rsrc2_from_fetch,
        Rdest => Rdest_from_fetch,
        imm_flag => imm_flag_from_fetch,
        propagated_pc => propagated_pc_from_fetch,
        propagated_pc_plus_one => propagated_pc_plus_one_from_fetch
    );

    ----------Decode----------
    decode_inst : decode
    PORT MAP(
        clk => clk,
        reset => RST_signal,
        -- reset : IN STD_LOGIC;
        -- branch_prediction_flush : IN STD_LOGIC;
        -- exception_handling_flush : IN STD_LOGIC;
        -- hazard_detection_flush : IN STD_LOGIC;
        branch_prediction_flush => zero_flag_out_controller_from_execute,
        exception_handling_flush => exception_handling_flush_to_Decode,
        hazard_detection_flush => hazard_detection_flush_to_Decode,
        opcode => opcode_from_fetch,
        Rsrc1 => Rsrc1_from_fetch,
        Rsrc2 => Rsrc2_from_fetch,
        Rdest => Rdest_from_fetch,
        imm_flag => imm_flag_from_fetch,
        immediate_in => selected_immediate_out_from_fetch,
        propagated_pc_in => propagated_pc_from_fetch,
        propagated_pc_plus_one_in => propagated_pc_plus_one_from_fetch,
        in_port_in => in_port_from_fetch,
        interrupt_signal => interrupt_signal,
        zero_flag => zero_flag_out_controller_from_execute,
        -- WB
        write_enable1 => reg_write_enable1_from_wb,
        write_enable2 => reg_write_enable2_from_wb,
        write_address1 => write_address1_out_from_wb,
        write_address2 => write_address2_out_from_wb,
        write_data1 => read_data1_out_from_wb,
        write_data2 => read_data2_out_from_wb,
        fetch_pc_mux1 => pc_mux1_selector_to_fetch,
        fetch_decode_flush => FD_flush_to_fetch,
        in_port => in_port_from_Decode,
        immediate_stall => immediate_stall_to_fetch_and_decode,
        execute_control_signals => execute_control_signals_from_decode,
        memory_control_signals => memory_control_signals_from_decode,
        wb_control_signals => wb_control_signals_from_decode,
        propagated_read_data1 => data1_in_to_execute,
        propagated_read_data2 => data2_in_to_execute,
        propagated_Rsrc1 => address_read1_in_to_execute,
        propagated_Rsrc2 => address_read2_in_to_execute,
        propagated_Rdest => destination_address_to_execute,
        immediate_out => immediate_in_to_execute,
        branch_pc_address => branch_address_to_fetch,
        propagated_pc => pc_in_to_excute,
        propagated_pc_plus_one => pc_plus_1_in_to_excute,
        --
        forwarded_alu_execute => alu_result_from_Execution_before_EM,
        forwarded_alu_out_em => alu_out_from_execute,
        forwarded_data1_mw => read_data1_out_from_memory,
        forwarded_data2_mw => read_data2_out_from_memory,
        forwarded_data1_em => data1_swapping_out_from_execute,
        forwarded_data2_em => data2_swapping_out_from_execute,
        branching_op_mux_selector => branching_opp_mux_sel_forwarding_to_decode,
        branching_or_normal_mux_selector => branching_or_normal_sel_forwarding_to_decode
    );

    Alu_selectors_to_execute <= execute_control_signals_from_decode(6 DOWNTO 4);
    Alu_src2_selector_to_execute <= execute_control_signals_from_decode(3 DOWNTO 2);
    EM_flush_controller_to_execute <= execute_control_signals_from_decode(1);

    ----------Execute----------
    excute_inst : execute PORT MAP(
        clk => clk,
        pc_in => pc_in_to_excute,
        pc_plus_1_in => pc_plus_1_in_to_excute,
        destination_address => destination_address_to_execute,
        address_read1_in => address_read1_in_to_execute,
        address_read2_in => address_read2_in_to_execute,
        alu_result_before_EM => alu_result_from_Execution_before_EM,
        immediate_enable_in => EM_flush_controller_to_execute,
        data1_in => data1_in_to_execute,
        data2_in => data2_in_to_execute,
        immediate_in => immediate_in_to_execute,
        forwarded_data1_em => data1_swapping_out_from_execute, --from myself (execute) --TODO:check
        forwarded_data2_em => data2_swapping_out_from_execute,
        forwarded_alu_out_em => alu_out_from_execute,
        forwarded_data1_mw => read_data1_out_from_memory, --from memory 
        forwarded_data2_mw => read_data2_out_from_memory,
        forwarding_mux_selector_op2 => forwarding_mux_selector_op2, --from forwarding unit
        forwarding_mux_selector_op1 => forwarding_mux_selector_op1,
        control_signals_memory_in => memory_control_signals_from_decode, --from decode
        control_signals_write_back_in => wb_control_signals_from_decode,
        alu_selectors => Alu_selectors_to_execute,
        alu_src2_selector => Alu_src2_selector_to_execute,
        execute_mem_register_enable => EM_enable_in_to_execute,
        RST_signal_input => RST_signal,
        execute_mem_flush_controller => '0',
        EM_flush_exception_handling_in => EM_flush_exception_handling_to_excute,
        pc_out => pc_out_from_execute,
        pc_plus_1_out => pc_plus_1_out_from_execute,
        destination_address_out => destination_address_out_from_execute,
        in_port_forwarded_from_EM => in_port_from_execute, --forwaded units
        in_port_forwarded_from_MW => in_port_from_memory,

        address_read1_out => address_read1_out_from_execute,
        address_read2_out => address_read2_out_from_execute,
        flag_register_out => flag_register_out_from_execute,
        alu_out => alu_out_from_execute,
        immediate_enable_out => OPEN,
        data1_swapping_out => data1_swapping_out_from_execute,
        data2_swapping_out => data2_swapping_out_from_execute, --problem
        zero_flag_out_controller => zero_flag_out_controller_from_execute,
        overflow_flag_out_exception_handling => overflow_flag_out_exception_handling_from_execute,
        address1_out_forwarding_unit => address1_out_forwarding_unit_from_execute,
        address2_out_forwarding_unit => address2_out_forwarding_unit_from_execute,
        pc_out_exception_handling => pc_out_to_exception_from_execute,
        in_port_input => in_port_from_Decode, --should it be propagated or what?
        in_port_output => in_port_from_execute,
        control_signals_memory_out => control_signals_memory_out_from_execute,
        control_signals_write_back_out => control_signals_write_back_out_from_execute
    );
    write_back_rsrc1_data_from_execute <= control_signals_write_back_out_from_execute(5 DOWNTO 4);
    write_back_1_forwarding_from_excute <= control_signals_write_back_out_from_execute(3);
    write_back_2_forwarding_from_excute <= control_signals_write_back_out_from_execute(2);

    ----------Memory----------
    mem_inst : memory_stage PORT MAP(
        clk => clk,
        mem_control_signals_in => control_signals_memory_out_from_execute(10 DOWNTO 1),
        wb_control_signals_in => control_signals_write_back_out_from_execute,
        RST => RST_signal,
        MW_enable => MW_enable_to_memory,
        MW_flush_from_exception => MW_flush_from_exception_to_memory,
        PC_in => pc_out_from_execute,
        PC_plus_one_in => pc_plus_1_out_from_execute,
        imm_enable_in => '0',
        destination_address_in => destination_address_out_from_execute,
        write_address1_in => address_read1_out_from_execute,
        write_address2_in => address_read2_out_from_execute,
        read_data1_in => data1_swapping_out_from_execute,
        read_data2_in => data2_swapping_out_from_execute, --problem
        ALU_result_in => alu_out_from_execute,
        CCR_in => flag_register_out_from_execute,
        wb_control_signals_out => wb_control_signals_out_from_memory,
        destination_address_out => Rdst_from_memory,
        write_address1_out => write_address1_out_from_memory,
        write_address2_out => write_address2_out_from_memory,
        read_data1_out => read_data1_out_from_memory,
        read_data2_out => read_data2_out_from_memory,
        ALU_result_out => ALU_result_out_from_memory,
        mem_read_data => mem_read_data_from_memory,
        PC_out_to_exception => PC_out_to_exception_from_memory,
        protected_address_access_to_exception => protected_address_access_to_exception_from_memory,
        in_port_in => in_port_from_execute,
        in_port_out => in_port_from_memory
    );
    --* wb control signals
    -- rscr1_data -> bit(5->4)
    --reg_write_enable1 -> bit (3)
    --reg_write_enable2 -> bit(2)
    --regw1_address_mux -> bit(1)
    --out_port_enable -> bit(0)

    -- signal reg_write_enable1_in_to_wb : STD_LOGIC;
    -- signal reg_write_enable2_in_to_wb : STD_LOGIC;
    -- signal reg_write_address1_mux_to_wb : STD_LOGIC;
    -- signal rscr1_data_to_wb : STD_LOGIC_VECTOR(1 DOWNTO 0);

    rscr1_data_to_wb <= wb_control_signals_out_from_memory(5 DOWNTO 4);
    reg_write_enable1_in_to_wb <= wb_control_signals_out_from_memory(3);
    reg_write_enable2_in_to_wb <= wb_control_signals_out_from_memory(2);
    reg_write_address1_mux_to_wb <= wb_control_signals_out_from_memory(1);


    exception_handling_inst : exception_handling_unit PORT MAP(
        clk => clk,
        pc_from_EM => pc_out_to_exception_from_execute,
        pc_from_DE => pc_out_from_execute, --can be cahnged to be taken from the memory
        overflow_flag_from_alu => overflow_flag_out_exception_handling_from_execute,
        protected_bit_exeception_from_memory => protected_address_access_to_exception_from_memory,
        exception_out_port => OPEN, --1 if an exception is detected, 0 otherwise --TODO:do we need it?
        second_pc_mux_out => pc_mux2_selector_to_fetch,
        FD_flush => FD_flush_exception_unit_to_fetch,
        DE_flush => exception_handling_flush_to_Decode,
        EM_flush => EM_flush_exception_handling_to_excute,
        MW_flush => MW_flush_from_exception_to_memory,
        EPC_output => EPC_out_to_processor
    );

    write_back_1_forwarding_from_decode <= wb_control_signals_from_decode(3);
    write_back_2_forwarding_from_decode <= wb_control_signals_from_decode(2);

    hazard_detection_inst : hazard_detection_unit PORT MAP(
        src_address1_fd => Rsrc1_from_fetch, --from fetch
        src_address2_fd => Rsrc2_from_fetch,
        dst_address_de => destination_address_to_execute, --from decode
        write_back_1_de => write_back_1_forwarding_from_decode,
        memory_read_de => write_back_2_forwarding_from_decode,
        reg_read_controller => '0',
        PC_enable => pc_enable_hazard_detection_to_fetch,
        enable_fd => FD_enable_loaduse_to_fetch,
        reset_de => hazard_detection_flush_to_Decode --from decode
    );

    memory_read_from_decode <= memory_control_signals_from_decode(9);
    memory_read_from_execute <= control_signals_memory_out_from_execute(9);

    forwarding_unit_inst : forwarding_unit PORT MAP(
        src_address1_de => address_read1_in_to_execute, --from decode
        src_address2_de => address_read2_in_to_execute,
        dst_address_de => destination_address_to_execute,
        dst_address_em => destination_address_out_from_execute, --from execute
        src_address1_em => address_read1_out_from_execute,
        src_address2_em => address_read2_out_from_execute,
        address1_mw => write_address1_out_from_memory,
        address2_mw => write_address2_out_from_memory,
        dst_address_fd => Rdest_from_fetch,
  
        reg_write_address1_in_select_em => write_back_rsrc1_data_from_execute,   --to detect in port
        reg_write_address1_in_select_mw => rscr1_data_to_wb,
        out_port_enable => wb_control_signals_from_decode(0),

        write_back_de_enable1 => write_back_1_forwarding_from_decode, --from execute
        write_back_de_enable2 => write_back_2_forwarding_from_decode,
        --
        write_back_em_enable1 => write_back_1_forwarding_from_excute,
        write_back_em_enable2 => write_back_2_forwarding_from_excute,
        --
        write_back_mw_enable1 => reg_write_enable1_in_to_wb,
        write_back_mw_enable2 => reg_write_enable2_in_to_wb,

        memory_read_em => memory_read_from_execute, --from execute stage
        memory_read_de => memory_read_from_decode, --from decode stage
        opp1_ALU_MUX_SEL => forwarding_mux_selector_op1, --outputed to execute
        opp2_ALU_MUX_SEL => forwarding_mux_selector_op2,
        opp_branching_mux_selector => branching_opp_mux_sel_forwarding_to_decode, --to decode
        opp_branch_or_normal_mux_selector => branching_or_normal_sel_forwarding_to_decode,

        load_use_hazard => OPEN --not used
    );

    ----------Write Back----------
    write_back_inst : write_back PORT MAP(
        clk => clk,
        reg_write_enable1_in => reg_write_enable1_in_to_wb,
        reg_write_enable2_in => reg_write_enable2_in_to_wb,
        read_data1_in => read_data1_out_from_memory,
        read_data2_in => read_data2_out_from_memory, --problemmmm
        read_address1_in => write_address1_out_from_memory,
        read_address2_in => write_address2_out_from_memory,
        destination_address_in => Rdst_from_memory,
        mem_read_data => mem_read_data_from_memory,
        ALU_result => ALU_result_out_from_memory,
        in_port => in_port_from_memory,
        Rsrc1_selector_in => rscr1_data_to_wb,
        reg_write_address1_in_select => reg_write_address1_mux_to_wb,
        WB_selected_data_out1 => read_data1_out_from_wb,
        WB_selected_data_out2 => read_data2_out_from_wb,
        WB_selected_address_out1 => write_address1_out_from_wb,
        WB_selected_address_out2 => write_address2_out_from_wb,
        mem_read_data_out => OPEN,
        reg_write_enable1_out => reg_write_enable1_from_wb,
        reg_write_enable2_out => reg_write_enable2_from_wb
    );

    -- data1_in_to_execute
    -- data1_swapping_out_from_execute

    --* output port
    --check the control signal and depending on it it will ouput data 1 or no
    -- PROCESS (read_data2_out_from_wb,data1_in_to_execute,wb_control_signals_from_decode(0), wb_control_signals_out_from_memory(0))
    -- BEGIN
    --     IF wb_control_signals_from_decode(0) = '1' THEN
    --         out_port_to_processor <= data1_in_to_execute;
    --     ELSE
    --         out_port_to_processor <= (OTHERS => '-'); -- don't care
    --     END IF;
    -- END PROCESS;

    PROCESS (wb_control_signals_out_from_memory(0),read_data2_out_from_wb)
    BEGIN
        IF wb_control_signals_out_from_memory(0) = '1' THEN
            out_port_to_processor <= read_data2_out_from_wb;
        ELSE
            out_port_to_processor <= (OTHERS => '-'); -- don't care
        END IF;
    END PROCESS;
END ARCHITECTURE arch_processor;