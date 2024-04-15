library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
    port (
        clk : in std_logic; 
        reset : in std_logic;
        instruction_out : out std_logic_vector(15 downto 0)
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
            address_in : in std_logic_vector(9 downto 0);
            data_out : out std_logic_vector(15 downto 0)
        );
    end component;

    signal instruction_address : std_logic_vector(9 downto 0);
    -- signal instruction_out : std_logic_vector(15 downto 0);

begin

    program_counter: pc PORT MAP (
        reset,
        clk,
        instruction_address
    );

    inst_cache: instruction_cache PORT MAP (
        clk, 
        address_in => instruction_address, 
        data_out => instruction_out
    );

end architecture arch_fetch;