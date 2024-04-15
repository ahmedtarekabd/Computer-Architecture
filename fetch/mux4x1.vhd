-- 4x1 Multiplexer
library ieee;
use ieee.std_logic_1164.all;

entity mux4x1 is
    generic (n: integer := 16);
    port (
        inputA : in std_logic_vector(n-1 downto 0);
        inputB : in std_logic_vector(n-1 downto 0);
        inputC : in std_logic_vector(n-1 downto 0);
        inputD : in std_logic_vector(n-1 downto 0);
        Sel_lower : in std_logic; 
        Sel_higher : in std_logic; 
        output : out std_logic_vector(n-1 downto 0)
    );
end entity mux4x1;

architecture behavioral of mux4x1 is
    signal sel : std_logic_vector(1 downto 0); -- Intermediate signal
begin
    sel <= Sel_higher & Sel_lower; -- Assign concatenated select inputs to sel

    process(inputA, inputB, inputC, inputD, sel) -- Use sel in the sensitivity list
    begin
        case sel is -- Use sel in the case statement
            when "00" =>
                output <= inputA;
            when "01" =>
                output <= inputB;
            when "10" =>
                output <= inputC;
            when "11" =>
                output <= inputD;
            when others =>
                output <= (others => 'U');                
        end case;
    end process;
end architecture behavioral;