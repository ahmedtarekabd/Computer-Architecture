library ieee;
use ieee.std_logic_1164.all;

entity fetch_tb is
end fetch_tb;

architecture arch of fetch_tb is
    constant clk_period : time := 10 ns;
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';

    component fetch is
        port (
            clk : in std_logic; 
            reset : in std_logic
        );
    end component fetch;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: fetch port map (
        clk => clk,
        reset => reset
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
        reset <= '0'; 

        -- insert stimulus here 

        wait;
    end process;

end arch;