LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY execute_tb IS
END execute_tb;

ARCHITECTURE execute_tb_tb OF execute_tb IS

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL pc_in : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL operation : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL address_read1_in, address_read2_in, destination_address : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data1_in, data2_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_wb_control_signals_in : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');

    SIGNAL alu_out, data1_out, data2_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_wb_control_signals_out : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL address_read1_out, address_read2_out, destination_address_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL pc_out : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
    -- Instantiate the unit under test (UUT)
    uut : ENTITY work.execute
        PORT MAP(
            clk => clk,
            pc_in => pc_in,
            operation => operation,
            address_read1_in => address_read1_in,
            address_read2_in => address_read2_in,
            destination_address => destination_address,
            data1_in => data1_in,
            data2_in => data2_in,
            mem_wb_control_signals_in => mem_wb_control_signals_in,
            alu_out => alu_out,
            mem_wb_control_signals_out => mem_wb_control_signals_out,
            address_read1_out => address_read1_out,
            address_read2_out => address_read2_out,
            data1_out => data1_out,
            data2_out => data2_out,
            destination_address_out => destination_address_out,
            pc_out => pc_out
        );

    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR 10 ns;
        clk <= '0';
        WAIT FOR 10 ns;
    END PROCESS;

    -- 000 -> negate (changes zero and negative flags only)
    -- 001 -> add (changes all flags)
    -- 010 -> sub (changes all flags)
    -- 011 -> mov (changes nothing) (returns B -> src2)
    -- 100 -> and (changes zero and negative flags only)
    -- 101 -> or (changes zero and negative flags only)
    -- 110 -> xor (changes zero and negative flags only)
    -- 111 -> not (changes zero and negative flags only)

    --flags: temp[3] = carry, temp[2] = overflow, temp[1] = zero, temp[0] = negative

    -- Stimulus process

    stim_proc : PROCESS
    BEGIN
        -- Test case 1: ADD operation
        data1_in <= "10000000000000000000000000000001";
        data2_in <= "00000000000000000000000000000001";
        operation <= "001";
        WAIT FOR 20 ns;
        --expected output: 10000000000000000000000000000010 / flags 0 0 0 1

        -- Test case 2: SUB operation
        data1_in <= "00000000000000000000000000000010";
        data2_in <= "00000000000000000000000000000001";
        operation <= "010";
        WAIT FOR 20 ns;
        --expected output: 00000000000000000000000000000001 / flags: 0 0 0 0

        -- Test case 3: AND operation
        data1_in <= "00000000000000000000000000001111";
        data2_in <= "00000000000000000000000000001111";
        operation <= "100";
        WAIT FOR 20 ns;
        --expected output: 00000000000000000000000000001111 / flags: 0 0 0 0

        -- Test case 4: OR operation
        data1_in <= "00000000000000000000000000001111";
        data2_in <= "00000000000000000000000000010000";
        operation <= "101";
        WAIT FOR 20 ns;
        --expected output: 00000000000000000000000000011111 / flags: 0 0 0 0

        -- Test case 5: XOR operation
        data1_in <= "00000000000000000000000000001111";
        data2_in <= "00000000000000000000000000001111";
        operation <= "110";
        WAIT FOR 20 ns;

        -- Test case 6: Move operation
        data1_in <= "00000000000000000000000000001111";
        operation <= "011";
        WAIT FOR 20 ns;

        -- Test case 7: SUB operation that triggers carry
        data1_in <= "00000000000000000000000000000000";
        data2_in <= "00000000000000000000000000000001";
        operation <= "010";
        WAIT FOR 20 ns;

        -- Test case 8: ADD operation that triggers overflow
        data1_in <= "10000000000000000000000000000000";
        data2_in <= "01111111111111111111111111111111";
        operation <= "001";
        WAIT FOR 20 ns;

        -- Test case 9: NOT operation
        data1_in <= "00000000000000000000000000001111";
        operation <= "111";
        WAIT FOR 20 ns;

        WAIT;
    END PROCESS;

END execute_tb_tb;