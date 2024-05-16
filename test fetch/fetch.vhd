LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fetch IS
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
        immediate_stall : IN STD_LOGIC;
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
END ENTITY fetch;

ARCHITECTURE arch_fetch OF fetch IS

    --Multiplexers
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

    -- PC
    COMPONENT pc IS
        PORT (
            reset : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            enable : IN STD_LOGIC;
            pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    -- Instruction Cache
    COMPONENT instruction_cache IS
        PORT (
            address_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;
    -- Declare the my_nDFF component
    COMPONENT my_nDFF IS
        GENERIC (n : INTEGER := 16);
        PORT (
            Clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            enable : IN STD_LOGIC;
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT my_nDFF;

    --pc
    SIGNAL pc_instruction_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); --from pc to instruction cache
    SIGNAL mux1_output : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mux2_output : STD_LOGIC_VECTOR(31 DOWNTO 0);

    --instruction cache
    SIGNAL instruction_out_from_instr_cache : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL instruction_out_from_F_D_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);

    --internal signal for immediate register
    SIGNAL FD_imm_enable : STD_LOGIC;
    --internal signals for pc mux_1
    SIGNAL pc_plus_one : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL sel_lower_mux1 : STD_LOGIC;
    SIGNAL sel_higher_mux1 : STD_LOGIC;
    --internal signals for pc mux_2
    SIGNAL sel_lower_mux2 : STD_LOGIC;
    SIGNAL sel_higher_mux2 : STD_LOGIC;
    --internal signals for pc
    SIGNAL pc_enable : STD_LOGIC;
    --internal signals Fetch Decode reg
    SIGNAL FD_flush_internal : STD_LOGIC;
    SIGNAL FD_enable_internal : STD_LOGIC;
    --internal signals for immediate register
    SIGNAL FD_enable_imm_internal : STD_LOGIC;

    --signal to reset pc_counter for the first time only to start for pc = 0
    SIGNAL reset_pc : STD_LOGIC := '1';
    --internal signal for this
    SIGNAL pc_reset_internal : STD_LOGIC;

BEGIN

    pc_plus_one <= STD_LOGIC_VECTOR(unsigned(pc_instruction_address) + 1);
    sel_lower_mux1 <= pc_mux1_selector(0) OR RST_signal;
    sel_higher_mux1 <= pc_mux1_selector(1) OR RST_signal;

    pc_mux1 : mux4x1 GENERIC MAP(32)
    PORT MAP(
        inputA => pc_plus_one,
        inputB => branch_address,
        inputC => (OTHERS => '0'), -- unused
        inputD => read_data_from_memory,
        Sel_lower => sel_lower_mux1,
        Sel_higher => sel_higher_mux1,
        output => mux1_output
    );

    sel_lower_mux2 <= pc_mux2_selector(0) OR interrupt_signal;
    sel_higher_mux2 <= pc_mux2_selector(1) OR interrupt_signal;

    pc_mux2 : mux4x1 GENERIC MAP(32)
    PORT MAP(
        inputA => mux1_output, --mux1 ouptut (normal)
        inputB => x"33333333", --exception handling for overflow 
        inputC => x"cccccccc", --exception handling for memory 
        inputD => (OTHERS => '0'), -- unused
        Sel_lower => sel_lower_mux2,
        Sel_higher => sel_higher_mux2,
        output => mux2_output
    );

    --enabled when the pc enable coming from hazard detection unit is 1 and no interrupt signal (0)
    pc_enable <= pc_enable_hazard_detection AND NOT interrupt_signal;

    pc_reset_internal <= reset OR reset_pc;

    program_counter : my_nDFF GENERIC MAP(
        32) PORT MAP(
        clk => clk,
        reset => pc_reset_internal,
        enable => pc_enable,
        d => mux2_output,
        q => pc_instruction_address
    );
    --return it to normal to enable the pc to work normally   
    reset_pc <= '0';

    inst_cache : instruction_cache PORT MAP(
        address_in => pc_instruction_address,
        --el selk el 3ryan (imm)
        data_out => instruction_out_from_instr_cache
    );

    FD_flush_internal <= reset OR FD_flush OR FD_flush_exception_unit;
    FD_enable_internal <= immediate_stall AND FD_enable AND FD_enable_loaduse;

    fetch_decode : my_nDFF GENERIC MAP(16)
    PORT MAP(
        clk => clk,
        reset => FD_flush_internal,
        enable => FD_enable_internal,
        d => instruction_out_from_instr_cache,
        q => instruction_out_from_F_D_reg
    );

    --outputs
    opcode <= instruction_out_from_F_D_reg(15 DOWNTO 10);
    Rsrc1 <= instruction_out_from_F_D_reg(9 DOWNTO 7);
    Rsrc2 <= instruction_out_from_F_D_reg(6 DOWNTO 4);
    Rdest <= instruction_out_from_F_D_reg(3 DOWNTO 1);
    imm_flag <= instruction_out_from_F_D_reg(0);

    FD_imm_enable <= NOT immediate_stall;

    FD_enable_imm_internal <= FD_enable AND FD_imm_enable;

    fetch_decode_imm : my_nDFF GENERIC MAP(16)
    PORT MAP(
        clk => clk,
        reset => FD_flush_internal,
        enable => FD_enable_imm_internal,
        d => instruction_out_from_instr_cache,
        q => selected_immediate_out
    );

    propagated_pc <= pc_instruction_address;
    propagated_pc_plus_one <= STD_LOGIC_VECTOR(unsigned(pc_instruction_address) + 1);

END ARCHITECTURE arch_fetch;

--TODO: should the enable for the immediate flag be sent as 1 when the immediate flag is detected -> ezbotha fe el tb

--     --pc
--     SIGNAL pc_instruction_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); --from pc to instruction cache
--     SIGNAL mux1_output : STD_LOGIC_VECTOR(31 DOWNTO 0);
--     SIGNAL mux2_output : STD_LOGIC_VECTOR(31 DOWNTO 0);

--     --instruction cache
--     SIGNAL instruction_out_from_instr_cache : STD_LOGIC_VECTOR(15 DOWNTO 0);
--     SIGNAL instruction_out_from_F_D_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);

--     --internal signal for immediate register
--     SIGNAL FD_imm_enable : STD_LOGIC;
--     --internal signals for pc mux_1
--     SIGNAL pc_plus_one : STD_LOGIC_VECTOR(31 DOWNTO 0);
--     SIGNAL sel_lower_mux1 : STD_LOGIC;
--     SIGNAL sel_higher_mux1 : STD_LOGIC;
--     --internal signals for pc mux_2
--     SIGNAL sel_lower_mux2 : STD_LOGIC;
--     SIGNAL sel_higher_mux2 : STD_LOGIC;
--     --internal signals for pc
--     SIGNAL pc_enable : STD_LOGIC;
--     --internal signals Fetch Decode reg
--     SIGNAL FD_flush_internal : STD_LOGIC;
--     SIGNAL FD_enable_internal : STD_LOGIC;
--     --internal signals for immediate register
--     SIGNAL FD_enable_imm_internal : STD_LOGIC;

--     --signal to reset pc_counter for the first time only to start for pc = 0
--     SIGNAL reset_pc : STD_LOGIC := '1';
--     --internal signal for this
--     signal pc_reset_internal : STD_LOGIC;
--     -- Add these signals to hold the inputs to the flip-flops
--     SIGNAL fetch_decode_d : STD_LOGIC_VECTOR(15 DOWNTO 0);
--     SIGNAL fetch_decode_imm_d : STD_LOGIC_VECTOR(15 DOWNTO 0);
--     --signal to hold the old instruction
--     SIGNAL old_instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
-- BEGIN

--     pc_plus_one <= STD_LOGIC_VECTOR(unsigned(pc_instruction_address) + 1);
--     sel_lower_mux1 <= pc_mux1_selector(0) OR RST_signal;
--     sel_higher_mux1 <= pc_mux1_selector(1) OR RST_signal;

--     pc_mux1 : mux4x1 GENERIC MAP(32)
--     PORT MAP(
--         inputA => pc_plus_one,
--         inputB => branch_address,
--         inputC => (OTHERS => '0'), -- unused
--         inputD => read_data_from_memory,
--         Sel_lower => sel_lower_mux1,
--         Sel_higher => sel_higher_mux1,
--         output => mux1_output
--     );

--     sel_lower_mux2 <= pc_mux2_selector(0) OR interrupt_signal;
--     sel_higher_mux2 <= pc_mux2_selector(1) OR interrupt_signal;

--     pc_mux2 : mux4x1 GENERIC MAP(32)
--     PORT MAP(
--         inputA => mux1_output, --mux1 ouptut (normal)
--         inputB => x"33333333", --exception handling for overflow 
--         inputC => x"cccccccc", --exception handling for memory 
--         inputD => (OTHERS => '0'), -- unused
--         Sel_lower => sel_lower_mux2,
--         Sel_higher => sel_higher_mux2,
--         output => mux2_output
--     );

--     --enabled when the pc enable coming from hazard detection unit is 1 and no interrupt signal (0)
--     pc_enable <= pc_enable_hazard_detection and not interrupt_signal;

--     pc_reset_internal <= reset or reset_pc;

--     program_counter : my_nDFF GENERIC MAP(32) PORT MAP(
--         clk => clk,
--         reset => pc_reset_internal,
--         enable => pc_enable,
--         d => mux2_output,
--         q => pc_instruction_address
--     );
--     --return it to normal to enable the pc to work normally   
--     reset_pc <= '0';

--     inst_cache : instruction_cache PORT MAP(
--         address_in => pc_instruction_address,
--         --el selk el 3ryan (imm)
--         data_out => instruction_out_from_instr_cache
--     );

--     FD_flush_internal <= reset OR FD_flush OR FD_flush_exception_unit;
--     FD_enable_internal <= immediate_stall AND FD_enable AND FD_enable_loaduse;
--     -- Add this process to conditionally assign the inputs to the flip-flops
--     process(clk)
--     begin
--         if rising_edge(clk) then
--             if instruction_out_from_instr_cache(0) = '1' then --immediate flag is 1
--                 fetch_decode_d <= old_instruction;
--                 fetch_decode_imm_d <= instruction_out_from_instr_cache; 
--             else
--                 fetch_decode_d <= instruction_out_from_instr_cache;
--                 fetch_decode_imm_d <= instruction_out_from_instr_cache; --don't care
--             end if;
--         end if;
--     end process;

--     old_instruction <= instruction_out_from_instr_cache;

--     fetch_decode : my_nDFF GENERIC MAP(16)
--     PORT MAP(
--         clk => clk,
--         reset => FD_flush_internal,
--         enable => FD_enable_internal,
--         d => fetch_decode_d,
--         q => instruction_out_from_F_D_reg
--     );

--     --outputs
--     opcode <= instruction_out_from_F_D_reg(15 DOWNTO 10);
--     Rsrc1 <= instruction_out_from_F_D_reg(9 DOWNTO 7);
--     Rsrc2 <= instruction_out_from_F_D_reg(6 DOWNTO 4);
--     Rdest <= instruction_out_from_F_D_reg(3 DOWNTO 1);
--     imm_flag <= instruction_out_from_F_D_reg(0);

--     FD_imm_enable <= NOT immediate_stall;

--     FD_enable_imm_internal <= FD_enable AND FD_imm_enable;

--     fetch_decode_imm : my_nDFF GENERIC MAP(16)
--     PORT MAP(
--         clk => clk,
--         reset => FD_flush_internal,
--         enable => FD_enable_imm_internal,
--         d => fetch_decode_imm_d,
--         q => selected_immediate_out
--     );

--     propagated_pc <= pc_instruction_address;
--     propagated_pc_plus_one <= STD_LOGIC_VECTOR(unsigned(pc_instruction_address) + 1);