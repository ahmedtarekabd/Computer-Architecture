LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY processor2 IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC
    );
END ENTITY processor2;

ARCHITECTURE arch_processor2 OF processor2 IS

    -- PC
    COMPONENT pc IS
        PORT (
            reset : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            pc_out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT;

    -- Instruction Cache
    COMPONENT instruction_cache IS
        PORT (
            -- clk : in std_logic;
            address_in : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    -- Controller
    COMPONENT controller IS
        PORT (
            clk : IN STD_LOGIC;
            opcode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            operation : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_enable : OUT STD_LOGIC
        );
    END COMPONENT;

    -- nDFF (register file)
    COMPONENT my_nDFF IS
        GENERIC (n : INTEGER := 16);
        PORT (
            Clk, reset : IN STD_LOGIC;
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- Registers array
    COMPONENT registers_array IS
        GENERIC (n : INTEGER := 8);
        PORT (
            clk, reset, enable : IN STD_LOGIC;
            address_read1, address_read2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            address_write : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            input : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            output1, output2 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- ALU
    COMPONENT ALU IS
        GENERIC (n : INTEGER := 8);
        PORT (
            A, B : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            Sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            F : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            Cin : IN STD_LOGIC;
            Cout : OUT STD_LOGIC
        );
    END COMPONENT;
    SIGNAL d, q : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL instruction_address : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL instruction_in : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL instruction_out : STD_LOGIC_VECTOR(15 DOWNTO 0);

    SIGNAL operation : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL write_enable : STD_LOGIC;

    SIGNAL register_file_out1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL register_file_out2 : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL decode_execute_in : STD_LOGIC_VECTOR(22 DOWNTO 0);
    SIGNAL decode_execute_out : STD_LOGIC_VECTOR(22 DOWNTO 0);

    SIGNAL write_back_in : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL write_back_out : STD_LOGIC_VECTOR(11 DOWNTO 0);

    SIGNAL alu_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL alu_cout : STD_LOGIC; -- not used

BEGIN

    program_counter : pc PORT MAP(
        reset,
        clk,
        instruction_address
    );

    inst_cache : instruction_cache PORT MAP(
        -- clk, 
        address_in => instruction_address,
        data_out => instruction_in
    );

    -- 3 bits: opcode
    -- 3 bits: register_src 1
    -- 3 bits: register_src 2
    -- 3 bits: register_dst
    -- rest: not used
    fetch_decode : my_nDFF
    GENERIC MAP(16)
    PORT MAP(
        clk,
        reset,
        d => instruction_in,
        q => instruction_out
    );

    -- decode
    alu0 : ALU GENERIC MAP(
        8) PORT MAP (
        A => decode_execute_out(18 DOWNTO 11),
        B => decode_execute_out(10 DOWNTO 3),
        Sel => decode_execute_out(21 DOWNTO 19),
        F => alu_out,
        Cin => '0',
        Cout => alu_cout -- not used
    );

    -- 1 bit: write enable
    -- 8 bits: alu output
    -- 3 bits: address write back (destination)
    write_back_in <= decode_execute_out(22) & alu_out & decode_execute_out(2 DOWNTO 0);
    write_back : my_nDFF
    GENERIC MAP(12)
    PORT MAP(
        clk,
        reset,
        d => write_back_in,
        q => write_back_out
    );

END ARCHITECTURE arch_processor2;