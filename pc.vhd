LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity pc is
    port (
        reset : in std_logic;
        enable : in std_logic;
        clk : in std_logic;
        pc_out : out std_logic_vector(31 downto 0)
    );
end entity pc;

architecture pc_behavioral of pc is
    signal counter : unsigned(31 downto 0) := (others => '0');
begin
    process(clk,reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
        --only increment counter if enable is high
        elsif rising_edge(clk) and enable ='1' then
            if counter = "11111111111111111111111111111111" then 
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
        end if;

    end process;    

    pc_out <= std_logic_vector(counter);

end architecture pc_behavioral;