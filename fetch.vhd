library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
    port (
        clk : in std_logic; 
        reset : in std_logic
    );
end entity fetch;

architecture arch_fetch of fetch is

    -- PC
    component pc is
        port (
            reset : in std_logic;
            clk : in std_logic;
            pc_out : out std_logic_vector(9 downto 0)
        );
    end component;

    -- Instruction Cache
    component instruction_cache is
        port (
            clk : in std_logic;
            address_in : in std_logic_vector(9 downto 0);
            data_out : out std_logic_vector(15 downto 0)
        );
    end component;

    -- nDFF (register file)
    component my_nDFF IS
        GENERIC ( n : integer := 16);
        PORT(
            Clk, reset : IN std_logic;
            d : IN std_logic_vector(n-1 DOWNTO 0);
            q : OUT std_logic_vector(n-1 DOWNTO 0)
            );
    end component;


    signal d, q : std_logic_vector(15 downto 0);
    signal instruction_address : std_logic_vector(9 downto 0);
    signal instruction_in : std_logic_vector(15 downto 0);
    signal instruction_out : std_logic_vector(15 downto 0);


begin

    program_counter: pc PORT MAP (
        reset,
        clk,
        instruction_address
    );

    inst_cache: instruction_cache PORT MAP (
        clk, 
        address_in => instruction_address, 
        data_out => instruction_in
    );

    -- 3 bits: opcode
    -- 3 bits: register_src 1
    -- 3 bits: register_src 2
    -- 3 bits: register_dst
    -- rest: not used
    fetch_decode: my_nDFF
        GENERIC MAP (16)
        PORT MAP (
            clk,
            reset,
            d => instruction_in,
            q => instruction_out
        );

end architecture arch_fetch;