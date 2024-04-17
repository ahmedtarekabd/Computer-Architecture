LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity pc is
    port (
        reset : in std_logic;
        clk : in std_logic;
        pc_out : out std_logic_vector(9 downto 0)
    );
end entity pc;

architecture pc_behavioral of pc is
    signal counter : integer := 0;
begin
    process(clk,reset)
    begin
        if reset = '1' then
            counter <= 0;
        -- -- Prevent counter from incrementing on the same clock cycle as reset
        -- elsif falling_edge(reset) then
        --         counter <= 0;
        elsif rising_edge(clk) then
            if counter = 1024 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;

    end process;

    pc_out <= std_logic_vector(to_unsigned(counter, 10));

end architecture pc_behavioral;
