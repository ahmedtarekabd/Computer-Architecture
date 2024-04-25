LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY execute_tb IS
END execute_tb;

ARCHITECTURE behavior OF execute_tb IS 

    COMPONENT execute
    PORT(
        clk : IN  std_logic;
        immediate_in : IN  std_logic_vector (15 downto 0);
        address_read1_in : IN  std_logic_vector (2 downto 0);
        address_read2_in : IN  std_logic_vector (2 downto 0);
        destination_address : IN  std_logic_vector (2 downto 0);
        data1_in : IN  std_logic_vector (31 downto 0);
        data2_in : IN  std_logic_vector (31 downto 0);
        control_signals_in : IN  std_logic_vector (22 downto 0);
        alu_out : OUT  std_logic_vector (31 downto 0);
        outputed_control_signals : OUT  std_logic_vector (22 downto 0);
        address_read1_out : OUT  std_logic_vector (2 downto 0);
        address_read2_out : OUT  std_logic_vector (2 downto 0);
        data1_out : OUT  std_logic_vector (31 downto 0);
        data2_out : OUT  std_logic_vector (31 downto 0);
        destination_address_out : OUT  std_logic_vector (2 downto 0)
        );
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
   signal immediate_in : std_logic_vector (15 downto 0) := (others => '0');
   signal address_read1_in : std_logic_vector (2 downto 0) := (others => '0');
   signal address_read2_in : std_logic_vector (2 downto 0) := (others => '0');
   signal destination_address : std_logic_vector (2 downto 0) := (others => '0');
   signal data1_in : std_logic_vector (31 downto 0) := (others => '0');
   signal data2_in : std_logic_vector (31 downto 0) := (others => '0');
   signal control_signals_in : std_logic_vector (22 downto 0) := (others => '0');

    --Outputs
   signal alu_out : std_logic_vector (31 downto 0);
   signal outputed_control_signals : std_logic_vector (22 downto 0);
   signal address_read1_out : std_logic_vector (2 downto 0);
   signal address_read2_out : std_logic_vector (2 downto 0);
   signal data1_out : std_logic_vector (31 downto 0);
   signal data2_out : std_logic_vector (31 downto 0);
   signal destination_address_out : std_logic_vector (2 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: execute PORT MAP (
          clk => clk,
          immediate_in => immediate_in,
          address_read1_in => address_read1_in,
          address_read2_in => address_read2_in,
          destination_address => destination_address,
          data1_in => data1_in,
          data2_in => data2_in,
          control_signals_in => control_signals_in,
          alu_out => alu_out,
          outputed_control_signals => outputed_control_signals,
          address_read1_out => address_read1_out,
          address_read2_out => address_read2_out,
          data1_out => data1_out,
          data2_out => data2_out,
          destination_address_out => destination_address_out
        );

   -- Clock process definitions
   clk_process :process
   begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      --set immediate in with 32'b00000000000000110000000000000011
      --data1_in with 32'b00000000000000000000000000000001
      --data2_in with 32'b00000000000000000000000000000010

        immediate_in <= "00000000000000110000000000000011";
        data1_in <= "00000000000000000000000000000001";
        data2_in <= "00000000000000000000000000000010";

    --control signals bit


      -- insert stimulus here 

      wait;
   end process;

END;