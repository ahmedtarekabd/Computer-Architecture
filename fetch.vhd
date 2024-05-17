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
    -- SIGNAL pc_instruction_plus_one_Address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); --use the same one as the pc_mux1
    SIGNAL mux1_output : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mux2_output : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    --instruction cache
    SIGNAL instruction_out_from_instr_cache : STD_LOGIC_VECTOR(15 DOWNTO 0);
    -- SIGNAL FD_output : STD_LOGIC_VECTOR(80 DOWNTO 0); --the extra bit is the propagated immediate stall

    --internal signal for immediate register
    SIGNAL FD_imm_enable : STD_LOGIC;
    --internal signal for pc_reset muc
    SIGNAL pc_reset_output : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    --internal signals for pc mux_1
    SIGNAL pc_normal : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pc_plus_one : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sel_lower_mux1 : STD_LOGIC;
    SIGNAL sel_higher_mux1 : STD_LOGIC;
    --internal signals for pc mux_2
    SIGNAL sel_lower_mux2 : STD_LOGIC;
    SIGNAL sel_higher_mux2 : STD_LOGIC;
    --internal signals for pc
    SIGNAL pc_enable : STD_LOGIC;
    SIGNAL pc_reset : STD_LOGIC;

    --for the three regs
    SIGNAL FD_flush_internal : STD_LOGIC;

    --internal signals Fetch Decode reg only_instruction
    SIGNAL FD_enable_internal : STD_LOGIC;
    SIGNAL FD_output : STD_LOGIC_VECTOR(15 DOWNTO 0);

    --internal signals Fetch Decode reg except instruction
    SIGNAL FD_enable_internal_except_instruction : STD_LOGIC;
    SIGNAL FD_d_internal_except_instruction : STD_LOGIC_VECTOR(64 DOWNTO 0);
    SIGNAL FD_output_except_instruction : STD_LOGIC_VECTOR(64 DOWNTO 0);

    --internal signals for immediate register
    SIGNAL FD_enable_imm_internal : STD_LOGIC;

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
        inputB => x"00003333", --exception handling for overflow 
        inputC => x"0000cccc", --exception handling for memory 
        inputD => (OTHERS => '0'), -- unused
        Sel_lower => sel_lower_mux2,
        Sel_higher => sel_higher_mux2,
        output => mux2_output
    );

    --enabled when the pc enable coming from hazard detection unit is 1 and no interrupt signal (0)
    pc_enable <= pc_enable_hazard_detection AND NOT interrupt_signal;
    pc_reset <= reset OR FD_flush OR FD_flush_exception_unit or RST_signal;

    program_counter : my_nDFF GENERIC MAP(
        32) PORT MAP(
        clk => clk,
        reset => pc_reset,
        enable => pc_enable,
        d => mux2_output,
        q => pc_instruction_address
    );

    propagated_pc <= pc_instruction_address;
    propagated_pc_plus_one <= STD_LOGIC_VECTOR(unsigned(pc_instruction_address) + 1);

    inst_cache : instruction_cache PORT MAP(
        address_in => mux2_output,
        data_out => instruction_out_from_instr_cache
    );

    --for the three regs
    FD_flush_internal <= reset OR FD_flush OR FD_flush_exception_unit or RST_signal;

    FD_enable_internal <= immediate_reg_enable AND FD_enable AND FD_enable_loaduse;
    FD_reg : my_nDFF GENERIC MAP(16)
    PORT MAP(
        clk => clk,
        reset => FD_flush_internal,
        enable => FD_enable_internal,
        d => instruction_out_from_instr_cache,
        q => FD_output
    );
    opcode <= FD_output(15 DOWNTO 10);
    Rsrc1 <= FD_output(9 DOWNTO 7);
    Rsrc2 <= FD_output(6 DOWNTO 4);
    Rdest <= FD_output(3 DOWNTO 1);
    imm_flag <= FD_output(0);

    -- --the difference between this and the fetch_decode_only_instruction is that the immediate enable doesn't enable this one
    -- FD_enable_internal_except_instruction <= FD_enable AND FD_enable_loaduse;
    -- FD_d_internal_except_instruction <= pc_instruction_address & STD_LOGIC_VECTOR(unsigned(pc_instruction_address) + 1) & immediate_reg_enable;
    -- fetch_decode_except_instruction : my_nDFF GENERIC MAP(65)
    -- PORT MAP(
    --     clk => clk,
    --     reset => FD_flush_internal,
    --     enable => FD_enable_internal_except_instruction,
    --     d => FD_d_internal_except_instruction,
    --     q => FD_output_except_instruction
    -- );

    -- propagated_imm_stall <= FD_output_except_instruction(0);

    FD_imm_enable <= NOT immediate_reg_enable;
    FD_enable_imm_internal <= FD_enable AND FD_imm_enable AND FD_enable_loaduse;
    fetch_decode_imm : my_nDFF GENERIC MAP(16)
    PORT MAP(
        clk => clk,
        reset => FD_flush_internal,
        enable => FD_enable_imm_internal,
        d => instruction_out_from_instr_cache,
        q => selected_immediate_out
    );
END ARCHITECTURE arch_fetch;