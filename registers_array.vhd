LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY registers_array IS
	GENERIC ( n : integer := 8 );
	PORT(
		clk, reset, enable : IN std_logic;
		address_read1, address_read2 : IN std_logic_vector(2 DOWNTO 0);
		address_write : IN std_logic_vector(2 DOWNTO 0);
        
		input : IN std_logic_vector(n-1 DOWNTO 0);
		output1, output2 : OUT std_logic_vector(n-1 DOWNTO 0)
		);
END registers_array;

ARCHITECTURE arch_registers_array OF registers_array IS

    COMPONENT ram IS
    PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		reset : IN std_logic;
		address_read1 : IN std_logic_vector(2 DOWNTO 0);
		address_read2 : IN std_logic_vector(2 DOWNTO 0);
		address_write : IN std_logic_vector(2 DOWNTO 0);
		datain  : IN  std_logic_vector(n-1 DOWNTO 0);

		dataout1 : OUT std_logic_vector(n-1 DOWNTO 0);
		dataout2 : OUT std_logic_vector(n-1 DOWNTO 0)
		);
    END COMPONENT;

BEGIN

    ram0: ram GENERIC MAP(n) PORT MAP (
        clk => clk,
        we => enable,
        reset => reset,
        address_read1 => address_read1,
        address_read2 => address_read2,
        address_write => address_write,
        datain => input,
        dataout1 => output1,
        dataout2 => output2
    );  

END arch_registers_array;
