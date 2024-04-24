library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute_tb is
end execute_tb;

architecture execute_tb_tb of execute_tb is 
    constant n: integer := 32;
    signal clk : std_logic := '0';
    signal pc_in : std_logic_vector(15 downto 0) := (others => '0');
    signal operation : std_logic_vector(2 downto 0) := (others => '0');
    signal address_read1_in, address_read2_in, destination_address : std_logic_vector(2 downto 0) := (others => '0');
    signal data1_in, data2_in : std_logic_vector(31 downto 0) := (others => '0');
    signal mem_wb_control_signals_in : std_logic_vector(6 downto 0) := (others => '0');

    signal alu_out, data1_out, data2_out : std_logic_vector(31 downto 0);
    signal mem_wb_control_signals_out : std_logic_vector(6 downto 0);
    signal address_read1_out, address_read2_out, destination_address_out : std_logic_vector(2 downto 0);
    signal pc_out : std_logic_vector(15 downto 0);

begin
    -- Instantiate the unit under test (UUT)
    uut: entity work.execute
    port map (
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
    clk_process :process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Test case 1: ADD operation
        data1_in <= "00000000000000000000000000000001"; 
        data2_in <= "00000000000000000000000000000001"; 
        operation <= "001";
        wait for 10 ns;

        -- Test case 2: SUB operation
        data1_in <= "00000000000000000000000000000010"; 
        data2_in <= "00000000000000000000000000000001"; 
        operation <= "010";
        wait for 10 ns;

        -- Test case 3: AND operation
        data1_in <= "00000000000000000000000000001111"; 
        data2_in <= "00000000000000000000000000001111"; 
        operation <= "100";
        wait for 10 ns;

        -- Test case 4: OR operation
        data1_in <= "00000000000000000000000000001111"; 
        data2_in <= "00000000000000000000000000010000"; 
        operation <= "101";
        wait for 10 ns;

        -- Test case 5: XOR operation
        data1_in <= "00000000000000000000000000001111"; 
        data2_in <= "00000000000000000000000000001111"; 
        operation <= "110";
        wait for 10 ns;

        -- Test case 6: Move operation
        data1_in <= "00000000000000000000000000001111"; 
        operation <= "011";
        wait for 10 ns;

        -- Test case 7: SUB operation that triggers carry
        data1_in <= "00000000000000000000000000000000"; 
        data2_in <= "00000000000000000000000000000001"; 
        operation <= "010";
        wait for 10 ns;

        -- Test case 8: ADD operation that triggers overflow
        data1_in <= "10000000000000000000000000000000"; 
        data2_in <= "01111111111111111111111111111111"; 
        operation <= "001";
        wait for 10 ns;

        -- Test case 9: NOT operation
        data1_in <= "00000000000000000000000000001111"; 
        operation <= "111";
        wait for 10 ns;

        wait;
    end process;

end execute_tb_tb;