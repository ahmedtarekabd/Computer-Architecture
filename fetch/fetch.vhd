library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
    port (
        clk : in std_logic; 
        reset : in std_logic;
        selected_instruction_out : out std_logic_vector(15 downto 0)
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

    -- Declare the mux4x1 component
    component mux4x1 is
        generic (n: integer := 8);
        port (
            inputA : in std_logic_vector(n downto 0);
            inputB : in std_logic_vector(n downto 0);
            inputC : in std_logic_vector(n downto 0);
            inputD : in std_logic_vector(n downto 0);
            Sel_lower : in std_logic; 
            Sel_higher : in std_logic; 
            output : out std_logic_vector(n downto 0)
        );
    end component mux4x1;

    -- Declare the my_nDFF component
    component my_nDFF is
        generic (n : integer := 16);
        port (
            Clk : in std_logic;
            reset : in std_logic;
            d : in std_logic_vector(n-1 downto 0);
            q : out std_logic_vector(n-1 downto 0)
        );
    end component my_nDFF;
    

    signal instruction_address : std_logic_vector(9 downto 0);
    signal instruction_out_from_instr_cache : std_logic_vector(15 downto 0);
    -- signal instruction_out_from_F_D_reg : std_logic_vector(15 downto 0);
    signal instruction_out_from_mux : std_logic_vector(15 downto 0);
    signal selected_instruction : std_logic_vector(15 downto 0); -- New signal

    signal check_signal : std_logic := '0'; -- Declare a new signal


begin

    program_counter: pc PORT MAP (
        reset,
        clk,
        instruction_address
    );

    inst_cache: instruction_cache PORT MAP (
        address_in => instruction_address, 
        --el selk el 3ryan (imm)
        data_out => instruction_out_from_instr_cache
    );

    --to avoid infinty loop
    -- this acts as a buffer -> 
    --      thats why we are using (instruction_out_from_instr_cache) not the one out of the f/d reg
    return_Sel_lower_to_zero: process(clk)
    begin
        if rising_edge(clk) then
            if instruction_out_from_instr_cache(0) = '1' then
                if check_signal = '1' then 
                    check_signal <= '0';
                else
                    check_signal <= '1';
                end if;
            else
                check_signal <= '0';
            end if;
        end if;
    end process return_Sel_lower_to_zero;
    
    --currently used as mux 2x1
    inst_mux: mux4x1 generic map (16) 
        port map (
            inputA => instruction_out_from_instr_cache(15 downto 0),
            inputB => selected_instruction(15 downto 0),

            --to be added later if needed
            inputC =>  instruction_out_from_instr_cache(15 downto 0),
            inputD =>  instruction_out_from_instr_cache(15 downto 0),

            Sel_lower => check_signal,
            Sel_higher => '0',
            -- Sel =>  '0' & instruction_out_from_instr_cache(15),
            output => instruction_out_from_mux
        );


    fetch_decode: my_nDFF GENERIC MAP (16)
        PORT MAP (
            clk,
            reset,
            d => instruction_out_from_mux,
            q => selected_instruction
        );

    selected_instruction_out <= selected_instruction; -- Assign new signal to output port


end architecture arch_fetch;