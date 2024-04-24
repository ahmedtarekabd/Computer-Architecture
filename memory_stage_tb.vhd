LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY memory_stage_tb IS
END ENTITY memory_stage_tb;

ARCHITECTURE behavior OF memory_stage_tb IS 

    COMPONENT memory_stage
    -- Copy the port definition of memory_stage from your active selection
    END COMPONENT;

   --Inputs
   -- Initialize your inputs here

    --Outputs
   -- Initialize your outputs here

  -- Clock period definitions
  constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: memory_stage PORT MAP (
        -- Map your signals here
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
    mem_wb_control_signals_in <= "00000000";
    read_enable <= '0';

    --write in address 0 the value 1010101010101010
    mem_read_or_write_addr <= "0000000000000";
    mem_wb_control_signals_in(1) <= '1'; -- write_enable
    mem_write_data <= "1010101010101010";
    wait for clk_period;

    --output the value in address 0 which is 1010101010101010
    mem_wb_control_signals_in(0) <= '1'; -- read_enable
    wait for clk_period;

    --protect this memory location 
    mem_wb_control_signals_in(2) <= '1'; -- protect_signal
    mem_read_or_write_addr <= "0000000000000";
    wait for clk_period;

    --try to write in the protected memory location
    mem_wb_control_signals_in(2) <= '0'; -- protect_signal
    mem_read_or_write_addr <= "0000000000000";
    mem_wb_control_signals_in(1) <= '1'; -- write_enable
    mem_write_data <= "0101010101010101";
    wait for clk_period;

    --try to read from the protected memory location the expected -> 1010101010101010
    mem_wb_control_signals_in(0) <= '1'; -- read_enable
    wait for clk_period;

    --free the memory location
    mem_wb_control_signals_in(2) <= '0'; -- protect_signal
    mem_wb_control_signals_in(3) <= '1'; -- free_signal
    wait for clk_period;

    --try to write in the freed memory location
    mem_wb_control_signals_in(3) <= '0'; -- free_signal
    mem_wb_control_signals_in(1) <= '1'; -- write_enable
    mem_write_data <= "1111000011110000";
    wait for clk_period;

    --try to read from the freed memory location the expected -> 0000000000000000
    mem_wb_control_signals_in(0) <= '1'; -- read_enable
    wait for clk_period;

    wait;
   end process;

END;