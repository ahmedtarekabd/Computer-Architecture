LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY execute_tb IS
END execute_tb;

ARCHITECTURE behavior OF execute_tb IS 

    COMPONENT execute
    PORT(
        clk : IN  std_logic;
        pc_in : IN std_logic_vector (31 downto 0);
        pc_plus_1_in : IN std_logic_vector (31 downto 0);
        destination_address : IN std_logic_vector (2 downto 0);
        address_read1_in : IN std_logic_vector (2 downto 0);
        address_read2_in : IN std_logic_vector (2 downto 0);
        immediate_enable_in : IN std_logic;
        data1_in : IN std_logic_vector (31 downto 0);
        data2_in : IN std_logic_vector (31 downto 0);
        immediate_in : IN std_logic_vector (31 downto 0);
        forwarded_data1_em : IN std_logic_vector (31 downto 0);
        forwarded_data2_em : IN std_logic_vector (31 downto 0);
        forwarded_alu_out_em : IN std_logic_vector (31 downto 0);
        forwarded_data1_mw : IN std_logic_vector (31 downto 0);
        forwarded_data2_mw : IN std_logic_vector (31 downto 0);
        forwarding_mux_selector_op2 : IN std_logic_vector (2 downto 0);
        forwarding_mux_selector_op1 : IN std_logic_vector (2 downto 0);
        control_signals_memory_in : IN std_logic_vector (10 downto 0);
        control_signals_write_back_in : IN std_logic_vector (5 downto 0);
        control_signals_memory_out : OUT std_logic_vector (10 downto 0);
        control_signals_write_back_out : OUT std_logic_vector (5 downto 0);
        alu_selectors : IN std_logic_vector (2 downto 0);
        alu_src2_selector : IN std_logic_vector (1 downto 0);
        execute_mem_register_enable : IN std_logic;
        RST_signal_input : IN std_logic;
        RST_signal_load_use_input : IN std_logic;
        EM_flush_exception_handling_in : IN std_logic;
        EM_enable_exception_handling_in : IN std_logic;
        -- memory_control_signals : IN std_logic_vector (7 downto 0);
        -- write_back_control_signals : IN std_logic_vector (4 downto 0);
        -- flush_exception_handling : IN std_logic;
        -- load_use_stall : IN std_logic;
        -- user_input_RST : IN std_logic;
        pc_out : OUT std_logic_vector (31 downto 0);
        pc_plus_1_out : OUT std_logic_vector (31 downto 0);
        destination_address_out : OUT std_logic_vector (2 downto 0);
        address_read1_out : OUT std_logic_vector (2 downto 0);
        address_read2_out : OUT std_logic_vector (2 downto 0);
        flag_register_out : OUT std_logic_vector (3 downto 0);
        alu_out : OUT std_logic_vector (31 downto 0);
        immediate_enable_out : OUT std_logic;
        data1_swapping_out : OUT std_logic_vector (31 downto 0);
        data2_swapping_out : OUT std_logic_vector (31 downto 0);
        zero_flag_out_controller : OUT std_logic;
        overflow_flag_out_exception_handling : OUT std_logic;
        address1_out_forwarding_unit : OUT std_logic_vector (2 downto 0);
        address2_out_forwarding_unit : OUT std_logic_vector (2 downto 0);
        pc_out_exception_handling : OUT std_logic_vector (31 downto 0)
    );
    END COMPONENT;

  -- Inputs
   signal clk : std_logic := '0';
   signal pc_in : std_logic_vector (31 downto 0) := (others => '0');
   signal pc_plus_1_in : std_logic_vector (31 downto 0) := (others => '0');
   signal destination_address : std_logic_vector (2 downto 0) := (others => '0');
   signal address_read1_in : std_logic_vector (2 downto 0) := (others => '0');
   signal address_read2_in : std_logic_vector (2 downto 0) := (others => '0');
   signal immediate_enable_in : std_logic := '0';
   signal data1_in : std_logic_vector (31 downto 0) := (others => '0');
   signal data2_in : std_logic_vector (31 downto 0) := (others => '0');
   signal immediate_in : std_logic_vector (31 downto 0) := (others => '0');
   signal forwarded_data1_em : std_logic_vector (31 downto 0) := (others => '0');
   signal forwarded_data2_em : std_logic_vector (31 downto 0) := (others => '0');
   signal forwarded_alu_out_em : std_logic_vector (31 downto 0) := (others => '0');
   signal forwarded_data1_mw : std_logic_vector (31 downto 0) := (others => '0');
   signal forwarded_data2_mw : std_logic_vector (31 downto 0) := (others => '0');
   signal forwarding_mux_selector_op2 : std_logic_vector (2 downto 0) := (others => '0');
   signal forwarding_mux_selector_op1 : std_logic_vector (2 downto 0) := (others => '0');
   signal control_signals_memory_in : std_logic_vector (10 downto 0) := (others => '0');
   signal control_signals_write_back_in : std_logic_vector (5 downto 0) := (others => '0');
   signal alu_selectors : std_logic_vector (2 downto 0) := (others => '0');
   signal alu_src2_selector : std_logic_vector (1 downto 0) := (others => '0');
   signal execute_mem_register_enable : std_logic := '0';
   signal RST_signal_input : std_logic := '0';
   signal RST_signal_load_use_input : std_logic := '0';
   signal EM_flush_exception_handling_in : std_logic := '0';
   signal EM_enable_exception_handling_in : std_logic := '0';
  --  signal memory_control_signals : std_logic_vector (7 downto 0) := (others => '0');
  --  signal write_back_control_signals : std_logic_vector (4 downto 0) := (others => '0');
  --  signal flush_exception_handling : std_logic := '0';
  --  signal load_use_stall : std_logic := '0';
  --  signal user_input_RST : std_logic := '0';

   -- Outputs
   signal pc_out : std_logic_vector (31 downto 0);
   signal pc_plus_1_out : std_logic_vector (31 downto 0);
   signal destination_address_out : std_logic_vector (2 downto 0);
   signal address_read1_out : std_logic_vector (2 downto 0);
   signal address_read2_out : std_logic_vector (2 downto 0);
   signal flag_register_out : std_logic_vector (3 downto 0);
   signal alu_out : std_logic_vector (31 downto 0);
   signal immediate_enable_out : std_logic;
   signal data1_swapping_out : std_logic_vector (31 downto 0);
   signal data2_swapping_out : std_logic_vector (31 downto 0);
   signal zero_flag_out_controller : std_logic;
   signal overflow_flag_out_exception_handling : std_logic;
   signal address1_out_forwarding_unit : std_logic_vector (2 downto 0);
   signal address2_out_forwarding_unit : std_logic_vector (2 downto 0);
   signal pc_out_exception_handling : std_logic_vector (31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: execute PORT MAP (
        clk => clk,
        pc_in => pc_in,
        pc_plus_1_in => pc_plus_1_in,
        destination_address => destination_address,
        address_read1_in => address_read1_in,
        address_read2_in => address_read2_in,
        immediate_enable_in => immediate_enable_in,
        data1_in => data1_in,
        data2_in => data2_in,
        immediate_in => immediate_in,
        forwarded_data1_em => forwarded_data1_em,
        forwarded_data2_em => forwarded_data2_em,
        forwarded_alu_out_em => forwarded_alu_out_em,
        forwarded_data1_mw => forwarded_data1_mw,
        forwarded_data2_mw => forwarded_data2_mw,
        forwarding_mux_selector_op2 => forwarding_mux_selector_op2,
        forwarding_mux_selector_op1 => forwarding_mux_selector_op1,
        control_signals_memory_in => control_signals_memory_in,
        control_signals_write_back_in => control_signals_write_back_in,
        alu_selectors => alu_selectors,
        alu_src2_selector => alu_src2_selector,
        execute_mem_register_enable => execute_mem_register_enable,
        RST_signal_input => RST_signal_input,
        RST_signal_load_use_input => RST_signal_load_use_input,
        EM_flush_exception_handling_in => EM_flush_exception_handling_in,
        EM_enable_exception_handling_in => EM_enable_exception_handling_in,
        -- -- memory_control_signals => memory_control_signals,
        -- -- write_back_control_signals => write_back_control_signals,
        -- flush_exception_handling => flush_exception_handling,
        -- load_use_stall => load_use_stall,
        -- user_input_RST => user_input_RST,
        pc_out => pc_out,
        pc_plus_1_out => pc_plus_1_out,
        destination_address_out => destination_address_out,
        address_read1_out => address_read1_out,
        address_read2_out => address_read2_out,
        flag_register_out => flag_register_out,
        alu_out => alu_out,
        immediate_enable_out => immediate_enable_out,
        data1_swapping_out => data1_swapping_out,
        data2_swapping_out => data2_swapping_out,
        zero_flag_out_controller => zero_flag_out_controller,
        overflow_flag_out_exception_handling => overflow_flag_out_exception_handling,
        address1_out_forwarding_unit => address1_out_forwarding_unit,
        address2_out_forwarding_unit => address2_out_forwarding_unit,
        pc_out_exception_handling => pc_out_exception_handling
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
        wait for 10 ns;  
    
      -- test the reset input signal
        RST_signal_input <= '1';
        wait for 10 ns;
        
      -- initialize all inputs to 0
        pc_in <= (others => '0');
        pc_plus_1_in <= (others => '0');
        destination_address <= (others => '0');
        address_read1_in <= (others => '0');
        address_read2_in <= (others => '0');
        immediate_enable_in <= '0';
        data1_in <= (others => '0');
        data2_in <= (others => '0');
        immediate_in <= (others => '0');
        forwarded_data1_em <= (others => '0');
        forwarded_data2_em <= (others => '0');
        forwarded_alu_out_em <= (others => '0');
        forwarded_data1_mw <= (others => '0');
        forwarded_data2_mw <= (others => '0');
        forwarding_mux_selector_op2 <= (others => '0');
        forwarding_mux_selector_op1 <= (others => '0');
        control_signals_memory_in <= (others => '0');
        control_signals_write_back_in <= (others => '0');
        alu_selectors <= (others => '0');
        alu_src2_selector <= (others => '0');
        execute_mem_register_enable <= '0';
        RST_signal_input <= '0';
        RST_signal_load_use_input <= '0';
        EM_flush_exception_handling_in <= '0';
        EM_enable_exception_handling_in <= '0';
        -- memory_control_signals <= (others => '0');
        -- write_back_control_signals <= (others => '0');
        -- flush_exception_handling <= '0';
        -- load_use_stall <= '0';
        -- user_input_RST <= '0';
        wait for 10 ns;

      -- Test case 1: select normal data not forwarded.
        -- give dummy values to the forwarded data
          execute_mem_register_enable <= '1';
          forwarded_data1_em <= "00000001111111110000000000000000";
          forwarded_data2_em <= "11111111000000000000000000000000";
          forwarded_alu_out_em <= "01010101010101010101010101010101";

          forwarded_data1_mw <= "11001100110011001100110011001100";
          forwarded_data2_mw <= "00110011001100110011001100110011";

          forwarding_mux_selector_op2 <= "000";
          forwarding_mux_selector_op1 <= "000";
          alu_src2_selector <= "00";
          data1_in <= "00000001111111110000000000000000";
          data2_in <= "11111111000000000000000000000000";
          immediate_in <= "11100011100011100011100011100011";
          wait for 10 ns;

      -- Test case 2: select data forwarded from E/M
          forwarding_mux_selector_op2 <= "100";
          forwarding_mux_selector_op1 <= "101";
          alu_src2_selector <= "00";
          wait for 10 ns;


      -- Test case 3: select data forwarded from M/W
          forwarding_mux_selector_op2 <= "010";
          forwarding_mux_selector_op1 <= "011";
          alu_src2_selector <= "00";
          wait for 10 ns;


      -- Test case 4: select data forwarded from E/M and M/W
          forwarding_mux_selector_op2 <= "010";
          forwarding_mux_selector_op1 <= "101";
          alu_src2_selector <= "00";
          wait for 10 ns;

      -- Test case 5: Use immediate value instead of data2
          -- immediate_enable_in <= '1';
          forwarding_mux_selector_op2 <= "000";
          forwarding_mux_selector_op1 <= "000";
          alu_src2_selector <= "01";
          wait for 10 ns;

      -- Test case 6: set immediate_enable_in to 1
          immediate_enable_in <= '1';
          forwarding_mux_selector_op2 <= "000";
          forwarding_mux_selector_op1 <= "000";
          alu_src2_selector <= "00";
          wait for 10 ns;

      -- Test case 7: set immediate_enable_in to 1 and flush exception handling
          EM_flush_exception_handling_in <= '1';
          forwarding_mux_selector_op2 <= "000";
          forwarding_mux_selector_op1 <= "000";
          alu_src2_selector <= "00";
          wait for 10 ns;

      -- Test case 8: change the propagated values
          EM_flush_exception_handling_in <= '0';
          pc_in <= "00100100100100100100100100100100";
          control_signals_memory_in <= "01111001100";
          wait for 10 ns;
      
      
      wait;
   end process;

END;
