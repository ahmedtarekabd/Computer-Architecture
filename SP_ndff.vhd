LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SP_ndff IS
    GENERIC (n : INTEGER := 16);
    PORT (
        Clk, reset, enable : IN STD_LOGIC;
        d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
    );
END SP_ndff;

ARCHITECTURE b_SP_ndff OF SP_ndff IS
    COMPONENT SP_dff IS
        PORT (
            d, Clk, reset, enable : IN STD_LOGIC;
            q : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN

    loop1 : FOR i IN 0 TO n - 1 GENERATE
        fx : SP_dff PORT MAP(d(i), Clk, reset, enable, q(i));
    END GENERATE;

END b_SP_ndff;