-- Testbench for fetch.vhd

library ieee;
use ieee.std_logic_1164.all;

entity processor_tb is
end entity processor_tb;

architecture tb_arch of processor_tb is
    -- Component declaration
    component processor
        port (
            clk : in std_logic; 
            reset : in std_logic
        );
    end component processor;

    -- Signal declarations
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    -- Declare other signals here as needed

begin
    -- Instantiate the processor module
    processor1: processor port map (
            clk,
            reset
        );

    -- Clock process
    clk_process: process
    begin
        while now < 1000 ns loop
            clk <= '1';
            wait for 5 ns;
            clk <= '0';
            wait for 5 ns;
        end loop;
        wait;
    end process clk_process;

    -- Add stimulus processes here to drive inputs and monitor outputs
    stimulus_process : process
    begin

        reset <= '1';
        wait for 10 ns;
        
        reset <= '0';
        wait;
    
    end process stimulus_process;

end architecture tb_arch;