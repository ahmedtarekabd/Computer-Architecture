LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY SP_reg IS
    PORT (
        d, clk, reset, enable : IN STD_LOGIC;
        q : OUT STD_LOGIC);
END SP_reg;

ARCHITECTURE a_SP_reg OF SP_reg IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            q <= '1';
        ELSIF clk'event AND clk = '1' AND enable = '1' THEN
            q <= d;
        END IF;
    END PROCESS;
END a_SP_reg;