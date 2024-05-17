LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY ram IS
	GENERIC ( n : integer := 8 );
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
END ENTITY ram;

ARCHITECTURE syncrama OF ram IS

	TYPE ram_type IS ARRAY(0 TO 63) OF std_logic_vector(n-1 DOWNTO 0);
	SIGNAL registers_array : ram_type := (OTHERS => (OTHERS => '0'));
	
BEGIN
	PROCESS(clk, we, reset) IS
		BEGIN	
			IF reset = '1' THEN
				-- registers_array <= (OTHERS => (OTHERS => '0'));
			ELSE
				IF falling_edge(clk) THEN
					IF we = '1' THEN
						registers_array(to_integer(unsigned(address_write))) <= datain;
					END IF;
					dataout1 <= registers_array(to_integer(unsigned(address_read1)));
					dataout2 <= registers_array(to_integer(unsigned(address_read2)));
				END IF;
			END IF;
	END PROCESS;
	-- dataout1 <= registers_array(to_integer(unsigned(address_read1)));
	-- dataout2 <= registers_array(to_integer(unsigned(address_read2)));
END syncrama;
