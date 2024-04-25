LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fetch IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        selected_instruction_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        selected_immediate_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY fetch;

ARCHITECTURE arch_fetch OF fetch IS

    -- PC
    COMPONENT pc IS
        PORT (
            reset : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            pc_out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT;

    -- Instruction Cache
    COMPONENT instruction_cache IS
        PORT (
            address_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
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
    SIGNAL instruction_address : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL instruction_out_from_instr_cache : STD_LOGIC_VECTOR(15 DOWNTO 0);
    -- signal instruction_out_from_F_D_reg : std_logic_vector(15 downto 0);
    SIGNAL instruction_out_temp : STD_LOGIC_VECTOR(15 DOWNTO 0); -- New signal
    SIGNAL instruction_out_temp_imm : STD_LOGIC_VECTOR(15 DOWNTO 0); -- New signal

    SIGNAL check_signal : STD_LOGIC := '0'; -- Declare a new signal
    TYPE state_type IS (instruction, waitOnce, immediate);
    SIGNAL state : state_type := instruction;
    SIGNAL pipeline_enable : STD_LOGIC := '1';
    SIGNAL pipeline_enable_imm : STD_LOGIC := '0';

BEGIN

    program_counter : pc PORT MAP(
        reset,
        clk,
        instruction_address
    );

    inst_cache : instruction_cache PORT MAP(
        address_in => instruction_address,
        --el selk el 3ryan (imm)
        data_out => instruction_out_from_instr_cache
    );

    fetch_decode : my_nDFF GENERIC MAP(16)
    PORT MAP(
        clk => clk,
        reset => reset,
        enable => pipeline_enable,
        d => instruction_out_from_instr_cache,
        q => instruction_out_temp
    );

    pipeline_enable_imm <= NOT pipeline_enable;

    fetch_decode_imm : my_nDFF GENERIC MAP(16)
    PORT MAP(
        clk => clk,
        reset => reset,
        enable => pipeline_enable_imm,
        d => instruction_out_from_instr_cache,
        q => instruction_out_temp_imm
    );

    PROCESS (clk) IS
    BEGIN
        IF falling_edge(clk) THEN

            -- FSM
            CASE state IS
                WHEN instruction =>
                    IF instruction_out_temp(0) = '1' THEN
                        state <= waitOnce;
                        pipeline_enable <= '0';
                    ELSE
                        pipeline_enable <= '1';
                    END IF;
                WHEN waitOnce =>
                    state <= immediate;
                    pipeline_enable <= '1';
                WHEN immediate =>
                    -- check neroh le waitOnce wala la2
                    IF instruction_out_temp(0) = '1' THEN
                        state <= waitOnce;
                        pipeline_enable <= '0';
                    ELSE
                        state <= instruction;
                        pipeline_enable <= '1';
                    END IF;
            END CASE;
        END IF;
    END PROCESS;
    selected_instruction_out <= instruction_out_temp; -- Assign new signal to output port
    selected_immediate_out <= instruction_out_temp_imm; -- Assign new signal to output port

END ARCHITECTURE arch_fetch;