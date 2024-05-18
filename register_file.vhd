LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY register_file IS
    GENERIC (n : INTEGER := 16);
    PORT (
        clk : IN STD_LOGIC;
        write_enable1 : IN STD_LOGIC;
        write_enable2 : IN STD_LOGIC;
        write_address1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_address2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_data1 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        write_data2 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);

        read_enable : IN STD_LOGIC;
        read_address1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_address2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        read_data1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        read_data2 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
    );
END ENTITY register_file;

ARCHITECTURE register_file_arch OF register_file IS

    TYPE register_array_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL registers_array : register_array_type := (OTHERS => (OTHERS => '0'));

BEGIN
    PROCESS (clk) IS
    BEGIN
        IF rising_edge(clk) THEN
            IF write_enable1 = '1' THEN
                registers_array(to_integer(unsigned(write_address1))) <= write_data1;
            END IF;
            IF write_enable2 = '1' THEN
                registers_array(to_integer(unsigned(write_address2))) <= write_data2;
            END IF;
        END IF;
        IF falling_edge(clk) THEN
            IF read_enable = '1' THEN
                read_data1 <= registers_array(to_integer(unsigned(read_address1)));
                read_data2 <= registers_array(to_integer(unsigned(read_address2)));
            ELSE
                read_data1 <= (OTHERS => '0');
                read_data2 <= (OTHERS => '0');
            END IF;
        END IF;
    END PROCESS;
END register_file_arch;