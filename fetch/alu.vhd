library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    generic (n: integer := 32);
    port (
        A, B: in std_logic_vector(n-1 downto 0); -- A-> src1 , B -> src2
        -- 3 bits opcode
        opcode: in std_logic_vector(2 downto 0); 
        F: out std_logic_vector(n-1 downto 0);
        zero_flag: out std_logic;

        overflow_flag: out std_logic -- Overflow flag
    );
end ALU;

architecture ALU_Behavior of ALU is
    signal F_internal : std_logic_vector(n-1 downto 0);

begin
    
    process(A, B, opcode)
        variable A_integer, B_integer: unsigned(n downto 0);
        --used to store the result of the operation before assigning it to the output because A_integer and B_integer are 33bits and F_internal is 32bits
        variable temp : unsigned(n downto 0);

    begin
        
        A_integer := unsigned('0' & A);
        B_integer := unsigned('0' & B);

        overflow_flag <= '0'; -- it will be one if overflow occurs in add operation
        
        case opcode is
            when "000" => -- NOP
                F_internal <= (others => '0');
                
            when "001" => -- add (checks for overflow)
                temp := A_integer + B_integer;
                    F_internal <= std_logic_vector(temp(n-1 downto 0));
                -- Check for overflow
                if temp(n) = '1' then 
                    overflow_flag <= '1';
                end if;        

            when "010" => -- sub the value in src2 from src1 (checks for underflow)

                A_integer := unsigned(A(31) & A);
                B_integer := unsigned(B(31) & B);

                temp := B_integer - A_integer;
                F_internal <= std_logic_vector(temp(n-1 downto 0));

                --overflow flag -> if B is positive, A is negative and the result is negative then overflow occurs
                -- or if B is negative, A is positive and the result is positive then overflow occurs
                -- if ((B_integer > 0 and A_integer < 0 and temp < 0) or (B_integer < 0 and A_integer > 0 and temp > 0)) then
                --     overflow_flag <= '1';
                -- else
                --     overflow_flag <= '0';
                -- end if;
                if ((B_integer(n) = '1' and A_integer(n) = '0' and temp(n) = '1') or (B_integer(n) = '0' and A_integer(n) = '1' and temp(n) = '0')) then
                    overflow_flag <= '1';
                else
                    overflow_flag <= '0';
                end if;
        
            when "011" => -- move from src1 to destination so output is src1
                F_internal <= A;
                    
            when "100" => -- and
                temp := A_integer and B_integer;
                    F_internal <= std_logic_vector(temp(n-1 downto 0));                    
            when "101" => -- or
                temp := A_integer or B_integer;
                    F_internal <= std_logic_vector(temp(n-1 downto 0));    
            when "110" => -- xor
                temp := A_integer xor B_integer;
                    F_internal <= std_logic_vector(temp(n-1 downto 0));    
            when "111" => -- not
                temp := not A_integer;
                    F_internal <= std_logic_vector(temp(n-1 downto 0));                
            when others =>
                F_internal <= (others => 'X');
   
        end case;
            
    end process;

    --zero flag
    process(F_internal)
    begin
        if unsigned(F_internal) = 0 then
            zero_flag <= '1';
        else
            zero_flag <= '0';
        end if;
    end process;
    
    F <= F_internal; -- Assign the internal signal to the output

end architecture ALU_Behavior;