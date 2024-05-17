LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY exception_handling_unit IS
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
END ENTITY exception_handling_unit;

--when exeption is detected (either flag(overflow_flag_from_alu or protected_bit_exeception_from_memory) is set to 1), the exception_handling_unit will set the exception_out_port to 1
--also set the pc mux to 01 (if its overflow) or 10 (if its memory protection) and 00 if no execption happened
--it will also put the pc depending on the exception type in the EPC_output and its type
--if the exception is detected is overflow it will flush fetch,decode,execute stages
--if the exception is detected is memory protection it will fetch,decode,execute,memory stages
--it will hold this flushing state to halt the processor until the processor is restarted
ARCHITECTURE exception_behavioral OF exception_handling_unit IS

BEGIN
    PROCESS (clk)
        VARIABLE halt_the_processor : STD_LOGIC := '0';
    BEGIN
        IF halt_the_processor = '0' THEN

            IF rising_edge(clk) THEN

                -- Check for overflow exception
                IF overflow_flag_from_alu = '1' THEN
                    exception_out_port <= '1';
                    second_pc_mux_out <= "01";
                    FD_flush <= '1';
                    DE_flush <= '1';
                    EM_flush <= '1';
                    EPC_output(32 DOWNTO 1) <= pc_from_EM;
                    EPC_output(0) <= '1'; -- '1' indicates overflow exception
                    halt_the_processor := '1';
                    -- Check for memory protection exception
                ELSIF protected_bit_exeception_from_memory = '1' THEN
                    exception_out_port <= '1';
                    second_pc_mux_out <= "10";
                    FD_flush <= '1';
                    DE_flush <= '1';
                    EM_flush <= '1';
                    MW_flush <= '1';
                    EPC_output(32 DOWNTO 1) <= pc_from_DE;
                    EPC_output(0) <= '0'; -- '0' indicates memory protection exception
                    halt_the_processor := '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE exception_behavioral;