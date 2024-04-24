LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY memory IS
    -- GENERIC (n : INTEGER := 32);
    PORT (
        clk : IN STD_LOGIC;
        address : IN STD_LOGIC_VECTOR(11 DOWNTO 0);

        write_enable : IN STD_LOGIC;
        write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        read_enable : IN STD_LOGIC;
        read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        protect_signal : IN STD_LOGIC;
        free_signal : IN STD_LOGIC

    );
END ENTITY memory;

ARCHITECTURE memory_arch OF memory IS

    TYPE register_array_type IS ARRAY(0 TO 4096) OF STD_LOGIC_VECTOR(16 DOWNTO 0);
    SIGNAL memory_array : register_array_type := (OTHERS => (OTHERS => '0'));

    -- memory is 4k (4096 bits) and each one is 17 bits

    -- if proteceted signal is '1' then take the address and put the last bit on the left with 1 (bit - 16)
    -- if free signal is '1' then take the address and put the last bit on the left with 0 (bit - 16) and reset its content
    -- if both signals are '0' check on write-enable and read-enable ->
    -- if write-enable is '1'
    -- check if the last bit is 1 (protected) then don't write on it
    -- if the last bit is 0 then write the data form write_data in the address and put the last bit on the left with 0
    -- if read-enable is '1' then read the data from the address and output it in read_data

BEGIN

PROCESS (clk) IS

    --variable if it is ored with any address it will have the last bit on the left with 1
    variable or_to_add_protected_bit : STD_LOGIC_VECTOR(16 DOWNTO 0);
    --variable if the free signal is 1 then the address will be reset and have the last bit on the left with 0
    variable reset_address_content : STD_LOGIC_VECTOR(16 DOWNTO 0);

    BEGIN

    or_to_add_protected_bit := "10000000000000000";
    reset_address_content := "00000000000000000";

        IF rising_edge(clk) THEN
            --check on protect_signal and free_signal
            IF protect_signal = '1' THEN
                memory_array(to_integer(unsigned(address))) <= (or_to_add_protected_bit or memory_array(to_integer(unsigned(address))));
                memory_array(to_integer(unsigned(address)+1)) <= (or_to_add_protected_bit or memory_array(to_integer(unsigned(address)+1)));

            ELSIF free_signal = '1' THEN
                memory_array(to_integer(unsigned(address))) <= reset_address_content;
                memory_array(to_integer(unsigned(address)+1)) <= reset_address_content;

            --both free_signal and protect_signal are '0'
            --check on write_enable and read_enable
            ELSE
                IF write_enable = '1' THEN
                    --check if the last bit is 1 (protected)
                    --if it is 1 then don't write on it

                    if memory_array(to_integer(unsigned(address)))(16) = '0' THEN
                    --default is that the last bit is 0 (free)
                    memory_array(to_integer(unsigned(address))) <= '0' & write_data(31 DOWNTO 16);
                    memory_array(to_integer(unsigned(address)+1)) <= '0' & write_data (15 DOWNTO 0);
                    -- ELSE
                    --what should i output if the protected bit is 1?
                    end if;

                END IF;
                
                --read the the 16 bits only don't read the last bit
                IF read_enable = '1' THEN
                    read_data <= memory_array(to_integer(unsigned(address)))(15 DOWNTO 0) & memory_array(to_integer(unsigned(address)+1))(15 DOWNTO 0);

                END IF;
            end if; 
            
        END IF;
    END PROCESS;
END memory_arch;

--not important
--------questions--------

--should the read data be indebendent of the write data?
--so can both of them be active at the same time?
--the current code handles them but to change that put the read enable and write enable in the same if statement

--also what is tries to write in a protected address?
--do nothing or output something?
--this code does nothing