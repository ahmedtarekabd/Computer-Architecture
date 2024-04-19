LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY memory_tb IS
END ENTITY memory_tb;

ARCHITECTURE behavior OF memory_tb IS 

    COMPONENT memory
    GENERIC (n : INTEGER := 16);
    PORT(
        clk : IN  std_logic;
        address : IN  std_logic_vector (12 downto 0);
        write_enable : IN  std_logic;
        write_data : IN  std_logic_vector (15 downto 0);
        read_enable : IN  std_logic;
        read_data : OUT  std_logic_vector (15 downto 0);
        protect_signal : IN  std_logic;
        free_signal : IN  std_logic
       );
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
   signal address : std_logic_vector (12 downto 0) := (others => '0');
   signal write_enable : std_logic := '0';
   signal write_data : std_logic_vector (15 downto 0) := (others => '0');
   signal read_enable : std_logic := '0';
   signal protect_signal : std_logic := '0';
   signal free_signal : std_logic := '0';

    --Outputs
   signal read_data : std_logic_vector (15 downto 0);

  -- Clock period definitions
  constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: memory PORT MAP (
        clk => clk,
        address => address,
        write_enable => write_enable,
        write_data => write_data,
        read_enable => read_enable,
        read_data => read_data,
        protect_signal => protect_signal,
        free_signal => free_signal
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
    protect_signal <= '0';
    free_signal <= '0';
    read_enable <= '0';

    --write in address 0 the value 1010101010101010
    address <= "0000000000000";
    write_enable <= '1';
    write_data <= "1010101010101010";
    wait for clk_period;

    --output the value in address 0 which is 1010101010101010
    read_enable <= '1';
    wait for clk_period;

    --protect this memory location 
    protect_signal <= '1';
    address <= "0000000000000";
    wait for clk_period;

    --try to write in the protected memory location
    protect_signal <= '0';
    address <= "0000000000000";
    write_enable <= '1';
    write_data <= "0101010101010101";
    wait for clk_period;

    --try to read from the protected memory location the expected -> 1010101010101010
    read_enable <= '1';
    wait for clk_period;

    --free the memory location
    protect_signal <= '0';
    free_signal <= '1';
    wait for clk_period;

    --try to write in the freed memory location
    free_signal <= '0';
    write_enable <= '1';
    write_data <= "1111000011110000";
    wait for clk_period;

    --try to read from the freed memory location the expected -> 0000000000000000
    read_enable <= '1';
    wait for clk_period;

    wait;
end process;

END;