LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity instruction_cache1 is
    port (
        -- reset : in std_logic;
        -- clk : in std_logic;
        address_in : in std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(15 downto 0)
    );
end entity instruction_cache1;

architecture ic_behavioral OF instruction_cache1 IS

    type instruction_type IS ARRAY(0 TO 4096) OF std_logic_vector(15 DOWNTO 0);
    signal instruction : instruction_type := (OTHERS => (OTHERS => '0'));

begin

    data_out <= instruction(to_integer(unsigned(address_in))) when to_integer(unsigned(address_in)) < 1024
        else (others => 'Z');

end architecture ic_behavioral;
