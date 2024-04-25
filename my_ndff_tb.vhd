LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_my_nDFF IS
END tb_my_nDFF;

ARCHITECTURE behavior OF tb_my_nDFF IS 

     -- Component Declaration for the Unit Under Test (UUT)
     COMPONENT my_nDFF
     PORT(
            Clk : IN  std_logic;
            reset : IN  std_logic;
            enable : IN  std_logic;
            d : IN  std_logic_vector(15 downto 0);
            q : OUT  std_logic_vector(15 downto 0)
          );
     END COMPONENT;

    --Inputs
    signal Clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal enable : std_logic := '0';
    signal d : std_logic_vector(15 downto 0) := (others => '0');

     --Outputs
    signal q : std_logic_vector(15 downto 0);

    -- Clock period definitions
    constant Clk_period : time := 10 ns;

BEGIN

     -- Instantiate the Unit Under Test (UUT)
    uut: my_nDFF PORT MAP (
            Clk => Clk,
            reset => reset,
            enable => enable,
            d => d,
            q => q
          );

     -- Clock process definitions
    Clk_process :process
    begin
          Clk <= '0';
          wait for Clk_period/2;
          Clk <= '1';
          wait for Clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
        -- hold reset state for 100 ns.
        wait for 100 ns;  
        
        reset <= '1';  -- assert reset
        wait for Clk_period;  -- wait for 1 clock cycle
        reset <= '0';  -- de-assert reset
        
        -- wait for reset to finish
        wait for 100 ns;

        -- insert stimulus here 
        enable <= '1';
        d <= "1010101010101010"; -- example input
        wait for Clk_period;
        d <= "0101010101010101"; -- example input
        wait for Clk_period;

        enable <= '0';
        d <= "1111111111111111"; -- example input
        wait for Clk_period;
        d <= "0000000000000000"; -- example input
        wait for Clk_period;
        
        wait;
    end process;

END;