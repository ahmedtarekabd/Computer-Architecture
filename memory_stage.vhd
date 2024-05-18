LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--  Might need to adjust memory width
ENTITY memory_stage IS
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
            free_signal : IN STD_LOGIC;

            protected_address_access : OUT STD_LOGIC

        );
    END COMPONENT memory;

    COMPONENT my_nDFF IS
        GENERIC (n : INTEGER := 16);
        PORT (
            Clk, reset, enable : IN STD_LOGIC;
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT my_nDFF;

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

    COMPONENT SP_ndff IS
        GENERIC (n : INTEGER := 16);
        PORT (
            Clk, reset, enable : IN STD_LOGIC;
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT SP_ndff;

    SIGNAL mem_read_data_internal : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL d_internal : STD_LOGIC_VECTOR(142 DOWNTO 0);
    SIGNAL q_output : STD_LOGIC_VECTOR(142 DOWNTO 0);

    SIGNAL SP_mux_out : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL MW_data_mux_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_address_mux_out : STD_LOGIC_VECTOR(11 DOWNTO 0);

    SIGNAL read_enable : STD_LOGIC;

    SIGNAL SP_in_temp : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL SP_out_temp : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL SP_mux_inputB : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL SP_mux_inputC : STD_LOGIC_VECTOR(11 DOWNTO 0);

    SIGNAL mem_address_mux_selectors : STD_LOGIC_VECTOR(1 DOWNTO 0);

    SIGNAL CCR_as_32_bit : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    -- SP register
    SP_in_temp <= SP_mux_out(11 DOWNTO 0);
    SP_ndffister : SP_ndff
    GENERIC MAP(n => 12)
    PORT MAP(
        Clk => clk,
        reset => RST,
        enable => '1',
        d => SP_in_temp,
        q => SP_out_temp
    );

    -- SP mux
    SP_mux_inputB <= STD_LOGIC_VECTOR(UNSIGNED(SP_out_temp) - TO_UNSIGNED(2, SP_out_temp'LENGTH));
    SP_mux_inputC <= STD_LOGIC_VECTOR(UNSIGNED(SP_out_temp) + TO_UNSIGNED(2, SP_out_temp'LENGTH));
    SP_mux : mux4x1
    GENERIC MAP(n => 12)
    PORT MAP(
        inputA => SP_out_temp,
        inputB => SP_mux_inputB,
        inputC => SP_mux_inputC,
        inputD => SP_out_temp, -- don't care
        Sel_lower => mem_control_signals_in(6),
        Sel_higher => mem_control_signals_in(7),
        output => SP_mux_out
    );

    -- mem address mux
    PROCESS (RST, mem_control_signals_in)
    BEGIN
        IF (RST = '0') THEN
            mem_address_mux_selectors <= mem_control_signals_in(5 DOWNTO 4);
        ELSE
            mem_address_mux_selectors <= "10";
        END IF;
    END PROCESS;

    mem_address_mux : mux4x1
    GENERIC MAP(n => 12)
    PORT MAP(
        inputA => ALU_result_in(11 DOWNTO 0),
        inputB => SP_mux_out,
        inputC => "000000000000", --M[0], M[1]
        inputD => "000000000010", --M[2], M[3]
        Sel_lower => mem_address_mux_selectors(0),
        Sel_higher => mem_address_mux_selectors(1),
        output => mem_address_mux_out
    );

    -- MW data mux
    CCR_as_32_bit <= "0000000000000000000000000000" & CCR_in;
    MW_data_mux : mux4x1
    GENERIC MAP(n => 32)
    PORT MAP(
        inputA => read_data2_in,
        inputB => PC_plus_one_in,
        inputC => PC_in,
        inputD => CCR_as_32_bit,
        Sel_lower => mem_control_signals_in(2),
        Sel_higher => mem_control_signals_in(3),
        output => MW_data_mux_out
    );

    -- Output 
    d_internal <= wb_control_signals_in & destination_address_in & write_address1_in & write_address2_in & read_data1_in & read_data2_in & ALU_result_in & mem_read_data_internal;
    mem_wb_reg : my_nDFF
    GENERIC MAP(n => 143)
    PORT MAP(
        Clk => clk,
        reset => '0',
        enable => '1',
        d => d_internal,
        q => q_output
    );

    -- Memory
    read_enable <= mem_control_signals_in(8) OR RST;
    mem : memory
    PORT MAP(
        clk => clk,
        -- addressing the memory using the 12 bits only
        address => mem_address_mux_out(11 DOWNTO 0),
        write_enable => mem_control_signals_in(9),
        write_data => MW_data_mux_out,
        read_enable => read_enable,
        read_data => mem_read_data_internal,
        protect_signal => mem_control_signals_in(1),
        free_signal => mem_control_signals_in(0),
        protected_address_access => protected_address_access_to_exception
    );

    wb_control_signals_out <= q_output(142 DOWNTO 137);
    destination_address_out <= q_output(136 DOWNTO 134);
    write_address1_out <= q_output(133 DOWNTO 131);
    write_address2_out <= q_output(130 DOWNTO 128);
    read_data1_out <= q_output(127 DOWNTO 96);
    read_data2_out <= q_output(95 DOWNTO 64);
    ALU_result_out <= q_output(63 DOWNTO 32);
    mem_read_data <= q_output(31 DOWNTO 0);
    PC_out_to_exception <= PC_in;

END memory_stage_arch;