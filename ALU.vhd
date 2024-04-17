library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    generic (n: integer := 8);
    port (
        A, B: in std_logic_vector(n-1 downto 0);
        Sel: in std_logic_vector(2 downto 0);
        F: out std_logic_vector(n-1 downto 0);
        Cin: in std_logic;
        Cout: out std_logic
    );
end ALU;

architecture ALU_Behavior of ALU is
    signal output : std_logic_vector(n downto 0);
begin

    
    process(A, B, Sel)
        variable A_integer, B_integer : unsigned(n-1 downto 0);
    begin
        
        -- A_integer := to_integer(unsigned(A));
        -- B_integer := to_integer(unsigned(B));
        A_integer := unsigned(A);
        B_integer := unsigned(B);

        
        case Sel is
            when "000" => -- NOP
                
            when "010" => -- add
                -- F <= std_logic_vector(to_unsigned(A_integer + B_integer, F'length));
                F <= std_logic_vector(A_integer + B_integer);
                Cout <= '0';
            when "011" => -- decrement
                -- F <= std_logic_vector(to_unsigned(A_integer - 1, F'length));
                F <= std_logic_vector(A_integer - 1);
                Cout <= '0';
            when others =>
                Cout <= '1';
        end case;

        -- F <= output(n-1 downto 0);
        Cout <= output(n);

    end process;

end architecture ALU_Behavior;
