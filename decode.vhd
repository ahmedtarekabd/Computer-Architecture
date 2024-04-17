library ieee;
use ieee.std_logic_1164.all;

entity decode is
    port (
        clk : in std_logic;
        instruction_out : in std_logic_vector(15 downto 0);
        write_back_out : in std_logic_vector(11 downto 0);
        decode_execute_out : out std_logic_vector(23 downto 0)
    );
end entity decode;

architecture rtl of decode is

    component controller is
        port (
            clk : in std_logic;
            opcode : in std_logic_vector(2 downto 0);
            opcode : out std_logic_vector(3 downto 0);
            write_enable : out std_logic
        );
    end component controller;

    component registers_array is
        generic (
            n : integer
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            address_read1 : in std_logic_vector(2 downto 0);
            address_read2 : in std_logic_vector(2 downto 0);
            address_write : in std_logic_vector(2 downto 0);
            input : in std_logic_vector(7 downto 0);
            output1 : out std_logic_vector(7 downto 0);
            output2 : out std_logic_vector(7 downto 0)
        );
    end component registers_array;

    component my_nDFF is
        generic (
            n : integer
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            d : in std_logic_vector(n-1 downto 0);
            q : out std_logic_vector(n-1 downto 0)
        );
    end component my_nDFF;

    -- take 3 bits: opcode, output 4 bits: opcode, write_enable
    signal opcode : std_logic_vector(3 downto 0);
    signal write_enable : std_logic;

    -- 3 bits: source1, source2
    signal register_file_out1 : std_logic_vector(7 downto 0);
    signal register_file_out2 : std_logic_vector(7 downto 0);

    -- 4 bits: controller
    -- 16 bits: 2 registers values
    -- 3 bits: address write back (destination)
    signal decode_execute_in : std_logic_vector(22 downto 0);

begin

    ctrl: controller PORT MAP (
        clk,
        instruction_out(15 downto 13),
        opcode,
        write_enable
    );

    register_file: registers_array GENERIC MAP (8) PORT MAP (
        clk,
        '0', -- reset signal
        write_enable,
        instruction_out(12 downto 10), -- source1
        instruction_out(9 downto 7), -- source2
        write_back_out(2 downto 0), -- destination
        write_back_out(10 downto 3),
        register_file_out1,
        register_file_out2
    );

    decode_execute_in <= write_enable & opcode & register_file_out1 & register_file_out2 & instruction_out(6 downto 4);

    decode_execute: my_nDFF 
        GENERIC MAP (23)
        PORT MAP (
            clk,
            '0', -- reset signal
            decode_execute_in,
            decode_execute_out
        );

end architecture rtl;