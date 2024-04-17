library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
    port (
        clk : in std_logic; 
        reset : in std_logic
    );
end entity processor;

architecture arch_processor of processor is

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
            -- clk : in std_logic;
            address_in : in std_logic_vector(9 downto 0);
            data_out : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Controller
    component controller is
        PORT(
            clk : in std_logic;
            opcode : in std_logic_vector(2 DOWNTO 0);
            
            operation : out std_logic_vector(2 DOWNTO 0);
            write_enable : out std_logic
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

    -- Registers array
    component registers_array IS
        GENERIC ( n : integer := 8 );
        PORT(
            clk, reset, enable : IN std_logic;
            address_read1, address_read2 : IN std_logic_vector(2 DOWNTO 0);
            address_write : IN std_logic_vector(2 DOWNTO 0);
            
            input : IN std_logic_vector(n-1 DOWNTO 0);
            output1, output2 : OUT std_logic_vector(n-1 DOWNTO 0)
            );
    end component;

    -- ALU
    component ALU is
        generic (n: integer := 8);
        port (
            A, B: in std_logic_vector(n-1 downto 0);
            Sel: in std_logic_vector(2 downto 0);
            F: out std_logic_vector(n-1 downto 0);
            Cin: in std_logic;
            Cout: out std_logic
        );
    end component;
    

    signal d, q : std_logic_vector(15 downto 0);
    signal instruction_address : std_logic_vector(9 downto 0);
    signal instruction_in : std_logic_vector(15 downto 0);
    signal instruction_out : std_logic_vector(15 downto 0);

    signal operation : std_logic_vector(2 downto 0);
    signal write_enable : std_logic;

    signal register_file_out1 : std_logic_vector(7 downto 0);
    signal register_file_out2 : std_logic_vector(7 downto 0);

    signal decode_execute_in : std_logic_vector(22 downto 0);
    signal decode_execute_out : std_logic_vector(22 downto 0);

    signal write_back_in : std_logic_vector(11 downto 0);
    signal write_back_out : std_logic_vector(11 downto 0);

    signal alu_out : std_logic_vector(7 downto 0);
    signal alu_cout : std_logic; -- not used

begin

    program_counter: pc PORT MAP (
        reset,
        clk,
        instruction_address
    );

    inst_cache: instruction_cache PORT MAP (
        -- clk, 
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

    -- take 3 bits: opcode, output 4 bits: opcode, write_enable
    ctrl: controller PORT MAP (
        clk,
        instruction_out(15 downto 13),
        operation,
        write_enable
    );

    -- 3 bits: source1
    -- 3 bits: source2
    register_file: registers_array GENERIC MAP (8) PORT MAP (
        clk,
        reset,
        enable => write_back_out(11), -- last bit of the instruction
        address_read1 => instruction_out(12 downto 10), -- source1
        address_read2 => instruction_out(9 downto 7), -- source2
        address_write => write_back_out(2 downto 0), -- destination
        input => write_back_out(10 downto 3),
        output1 => register_file_out1,
        output2 => register_file_out2
    );

    -- 4 bits: controller
    -- 16 bits: 2 registers values
    -- 3 bits: address write back (destination)
    decode_execute_in <= write_enable & operation & register_file_out1 & register_file_out2 & instruction_out(6 downto 4);
    decode_execute: my_nDFF 
        GENERIC MAP (23)
        PORT MAP (
            clk,
            reset,
            d => decode_execute_in,
            q => decode_execute_out
        );


    alu0: ALU generic map (8) port map (
        A => decode_execute_out(18 downto 11),
        B => decode_execute_out(10 downto 3),
        Sel => decode_execute_out(21 downto 19),
        F => alu_out,
        Cin => '0',
        Cout => alu_cout -- not used
    );

    -- 1 bit: write enable
    -- 8 bits: alu output
    -- 3 bits: address write back (destination)
    write_back_in <= decode_execute_out(22) & alu_out & decode_execute_out(2 downto 0);
    write_back: my_nDFF 
        GENERIC MAP (12)
        PORT MAP (
            clk,
            reset,
            d => write_back_in,
            q => write_back_out
        );

end architecture arch_processor;