LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY memory_stage_tb IS
END ENTITY memory_stage_tb;

ARCHITECTURE behavior OF memory_stage_tb IS 

    COMPONENT memory_stage
    PORT(
        clk : IN std_logic;
        read_data1_in : IN std_logic_vector(31 downto 0);
        read_data2_in : IN std_logic_vector(31 downto 0);
        read_address1_in : IN std_logic_vector(2 downto 0);
        read_address2_in : IN std_logic_vector(2 downto 0);
        destination_address_in : IN std_logic_vector(2 downto 0);
        mem_wb_control_signals_in : IN std_logic_vector(6 downto 0);
        pc_in : IN std_logic_vector(15 downto 0);
        mem_write_data : IN std_logic_vector(31 downto 0);
        mem_read_or_write_addr : IN std_logic_vector(12 downto 0);
        mem_read_data : OUT std_logic_vector(31 downto 0);
        read_data1_out : OUT std_logic_vector(31 downto 0);
        read_data2_out : OUT std_logic_vector(31 downto 0);
        read_address1_out : OUT std_logic_vector(2 downto 0);
        read_address2_out : OUT std_logic_vector(2 downto 0);
        destination_address_out : OUT std_logic_vector(2 downto 0);
        pc_out : OUT std_logic_vector(15 downto 0);
        wb_control_signals_out : OUT std_logic_vector(2 downto 0)
    );
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
   signal read_data1_in : std_logic_vector(31 downto 0) := (others => '0');
   signal read_data2_in : std_logic_vector(31 downto 0) := (others => '0');
   signal read_address1_in : std_logic_vector(2 downto 0) := (others => '0');
   signal read_address2_in : std_logic_vector(2 downto 0) := (others => '0');
   signal destination_address_in : std_logic_vector(2 downto 0) := (others => '0');
   signal mem_wb_control_signals_in : std_logic_vector(6 downto 0) := (others => '0');
   signal pc_in : std_logic_vector(15 downto 0) := (others => '0');
   signal mem_write_data : std_logic_vector(31 downto 0) := (others => '0');
   signal mem_read_or_write_addr : std_logic_vector(12 downto 0) := (others => '0');

    --Outputs
   signal mem_read_data : std_logic_vector(31 downto 0);
   signal read_data1_out : std_logic_vector(31 downto 0);
   signal read_data2_out : std_logic_vector(31 downto 0);
   signal read_address1_out : std_logic_vector(2 downto 0);
   signal read_address2_out : std_logic_vector(2 downto 0);
   signal destination_address_out : std_logic_vector(2 downto 0);
   signal pc_out : std_logic_vector(15 downto 0);
   signal wb_control_signals_out : std_logic_vector(2 downto 0);

  -- Clock period definitions
  constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: memory_stage PORT MAP (
        clk => clk,
        read_data1_in => read_data1_in,
        read_data2_in => read_data2_in,
        read_address1_in => read_address1_in,
        read_address2_in => read_address2_in,
        destination_address_in => destination_address_in,
        mem_wb_control_signals_in => mem_wb_control_signals_in,
        pc_in => pc_in,
        mem_write_data => mem_write_data,
        mem_read_or_write_addr => mem_read_or_write_addr,
        mem_read_data => mem_read_data,
        read_data1_out => read_data1_out,
        read_data2_out => read_data2_out,
        read_address1_out => read_address1_out,
        read_address2_out => read_address2_out,
        destination_address_out => destination_address_out,
        pc_out => pc_out,
        wb_control_signals_out => wb_control_signals_out
       );

   -- Clock process definitions
   clk_process :process
   begin
       clk <= '0';
       wait for clk_period/2;
       clk <= '1';
       wait for clk_period/2;
   end process;

    -- -- the ones that matter:
    -- mem_wb_control_signals_in : in std_logic_vector(6 downto 0);

    -- mem_write_data : in std_logic_vector(31 downto 0);
    -- -- depends on the control signal same as ALU out
    -- mem_read_or_write_addr : in std_logic_vector(12 downto 0);

   -- Stimulus process
   stim_proc: process
   begin      
    -- hold reset state for 100 ns.
    wait for 100 ns;
    -- dummies for propagation  
    read_data1_in <= "00000000000000000000000000000001";
    read_data2_in <= "00000000000000000000000000000010";
    read_address1_in <= "001";
    read_address2_in <= "010";
    destination_address_in <= "011";
    pc_in <= "0000000000000001";
  
   
    mem_wb_control_signals_in <= "0000000";
    --write in address 0 the value 1010101010101010
    mem_read_or_write_addr <= "0000000000000";
    mem_wb_control_signals_in(1) <= '1'; -- memWrite
    mem_write_data <= "00000000000000001010101010101010";
    wait for clk_period;

    --output the value in address 0 which is 1010101010101010
    mem_wb_control_signals_in(0) <= '1'; -- memRead
    mem_wb_control_signals_in(1) <= '0';
    wait for clk_period;

    --protect this memory location 
    mem_wb_control_signals_in(2) <= '1'; -- protect_signal
    mem_read_or_write_addr <= "0000000000001";
    wait for clk_period;

    --try to write in the protected memory location
    mem_wb_control_signals_in(2) <= '0'; -- protect_signal
    mem_read_or_write_addr <= "0000000000010";
    mem_wb_control_signals_in(1) <= '1'; -- memWrite
    mem_write_data <= "00000000000000000101010101010101";
    wait for clk_period;

    --try to read from the protected memory location the expected -> 1010101010101010
    mem_wb_control_signals_in(0) <= '1'; -- memRead
    wait for clk_period;

    --free the memory location
    mem_wb_control_signals_in(2) <= '0'; -- protect_signal
    mem_wb_control_signals_in(3) <= '1'; -- free_signal
    wait for clk_period;

    --try to write in the freed memory location
    mem_wb_control_signals_in(3) <= '0'; -- free_signal
    mem_wb_control_signals_in(1) <= '1'; -- memWrite
    mem_write_data <= "00000000000000001111000011110000";
    wait for clk_period;

    --try to read from the freed memory location the expected -> 0000000000000000
    mem_wb_control_signals_in(0) <= '1'; -- memRead
    wait for clk_period;

    wait;
   end process;

END;