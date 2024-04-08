LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY controller IS
	PORT(
		clk : in std_logic;
		opcode : in std_logic_vector(2 DOWNTO 0);
		
		operation : out std_logic_vector(2 DOWNTO 0);
        write_enable : out std_logic
		);
END ENTITY controller;

ARCHITECTURE arch_controller OF controller IS
	
BEGIN
	PROCESS(clk) IS
		BEGIN
            IF falling_edge(clk) THEN
                operation <= opcode;
            END IF;
	END PROCESS;

    write_enable <= '0' WHEN opcode = "000" ELSE '1';

END arch_controller;
