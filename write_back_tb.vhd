library ieee;
use ieee.std_logic_1164.all;

entity write_back_tb is
end write_back_tb;

architecture write_back_tb_tb of write_back_tb is 

    -- Component Declaration for the Unit Under Test (UUT)
    component write_back
    port(
        clk : in std_logic;
        read_data1_in : in std_logic_vector(31 downto 0);
        read_data2_in : in std_logic_vector(31 downto 0);
        read_address1_in : in std_logic_vector(2 downto 0);
        read_address2_in : in std_logic_vector(2 downto 0);
        destination_address_in : in std_logic_vector(2 downto 0);
        mem_read_data : in std_logic_vector(31 downto 0);
        pc_in : in std_logic_vector(15 downto 0);
        wb_control_signals_in : in std_logic_vector(2 downto 0);
        selected_data_out1 : out std_logic_vector(31 downto 0);
        selected_data_out2 : out std_logic_vector(31 downto 0);
        selected_address_out : out std_logic_vector(2 downto 0);
        read_address2_out : out std_logic_vector(2 downto 0);
        regWrite_out_control_signal : out std_logic
    );
    end component;

    --Inputs
    signal clk : std_logic := '0';
    signal read_data1_in : std_logic_vector(31 downto 0) := (others => '0');
    signal read_data2_in : std_logic_vector(31 downto 0) := (others => '0');
    signal read_address1_in : std_logic_vector(2 downto 0) := (others => '0');
    signal read_address2_in : std_logic_vector(2 downto 0) := (others => '0');
    signal destination_address_in : std_logic_vector(2 downto 0) := (others => '0');
    signal mem_read_data : std_logic_vector(31 downto 0) := (others => '0');
    signal pc_in : std_logic_vector(15 downto 0) := (others => '0');
    signal wb_control_signals_in : std_logic_vector(2 downto 0) := (others => '0');

    --Outputs
    signal selected_data_out1 : std_logic_vector(31 downto 0);
    signal selected_data_out2 : std_logic_vector(31 downto 0);
    signal selected_address_out : std_logic_vector(2 downto 0);
    signal read_address2_out : std_logic_vector(2 downto 0);
    signal regWrite_out_control_signal : std_logic;

    -- Clock period definitions
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: write_back PORT MAP (
        clk => clk,
        read_data1_in => read_data1_in,
        read_data2_in => read_data2_in,
        read_address1_in => read_address1_in,
        read_address2_in => read_address2_in,
        destination_address_in => destination_address_in,
        mem_read_data => mem_read_data,
        pc_in => pc_in,
        wb_control_signals_in => wb_control_signals_in,
        selected_data_out1 => selected_data_out1,
        selected_data_out2 => selected_data_out2,
        selected_address_out => selected_address_out,
        read_address2_out => read_address2_out,
        regWrite_out_control_signal => regWrite_out_control_signal
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 100 ns.
        wait for 100 ns;
    
        -- Test case 1: wb_control_signals_in = "00"
        wb_control_signals_in <= "100";
        read_data1_in <= "00000000000000000000000000000001";
        read_data2_in <= "00000000000000000000000000000010";
        mem_read_data <= "00000000000000000000000000000011";
        read_address1_in <= "001";
        read_address2_in <= "010";
        destination_address_in <= "100";
        pc_in <= "0000000000000000";
        wait for clk_period;
    
        -- Test case 2: wb_control_signals_in = "01"
        wb_control_signals_in <= "001";
        read_data1_in <= "00000000000000000000000000000100";
        read_data2_in <= "00000000000000000000000000000101";
        mem_read_data <= "00000000000000000000000000000110";
        read_address1_in <= "100";
        read_address2_in <= "101";
        destination_address_in <= "010";
        pc_in <= "0000000000000000";
        wait for clk_period;
    
        -- Test case 3: wb_control_signals_in = "10"
        wb_control_signals_in <= "010";
        read_data1_in <= "00000000000000000000000000000111";
        read_data2_in <= "00000000000000000000000000001000";
        mem_read_data <= "00000000000000000000000000001001";
        read_address1_in <= "111";
        read_address2_in <= "000";
        destination_address_in <= "100";
        pc_in <= "0000000000000001";
        wait for clk_period;
    
        -- Test case 4: wb_control_signals_in = "11"
        wb_control_signals_in <= "111";
        read_data1_in <= "00000000000000000000000000001010";
        read_data2_in <= "00000000000000000000000000001011";
        mem_read_data <= "00000000000000000000000000001100";
        read_address1_in <= "010";
        read_address2_in <= "011";
        destination_address_in <= "101";
        pc_in <= "0000000000000000";
        wait for clk_period;
    
        wait;
    end process;

end write_back_tb_tb;