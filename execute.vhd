library ieee;
use ieee.std_logic_1164.all;


-- no forwarding yet
entity execute is
    port(
-------------------------inputs-------------------------
        clk : in std_logic;
        -- pc + 1 propagated
        pc_in : in std_logic_vector(15 downto 0);
        -- opcode from controller
        operation : in std_logic_vector(2 downto 0);

        -- propagated from decode stage
        address_read1_in : in std_logic_vector(2 downto 0);
        address_read2_in : in std_logic_vector(2 downto 0);
        destination_address : in std_logic_vector(2 downto 0);

        -- propagated from decode stage
        data1_in : in std_logic_vector(31 downto 0);
        data2_in : in std_logic_vector(31 downto 0);

        -- from controller
        -- propagated from decode stage 1 bit for memread, memwrite (1 bit each), protect & free 1 bit each, 1 regwrite, 1 regRead, 2 selectors for (WB, src1, src2), 1 of them is given to the 3rd MUX to know which mode it is in
        -- bit 0 -> memread, bit 1 -> memwrite, bit 2 -> protect, bit 3 -> free, bit 4 -> regwrite, bit 5 -> regread, bit 6 & 7 -> selectors for WB, src1, src2
        mem_wb_control_signals_in : in std_logic_vector(7 downto 0);

        -- -- flags in
        -- old_negative_flag : in std_logic;
        -- old_zero_flag : in std_logic;
        -- old_overflow_flag : in std_logic;
        -- old_carry_flag : in std_logic;

    -- commented out for now
    -- forwarded stuff
        -- -- alu to alu forwarding
        -- alu_result_forward : in std_logic_vector(31 downto 0);
        -- -- memory to alu forwarding
        -- memory_result_forward : in std_logic_vector(31 downto 0);

        -- -- control signals in that order, 2 for alu, 2 for mem and 2 for wb
        -- alu_mem_wb_control_signals : in std_logic_vector(5 downto 0);

        -- -- forwarding unit signals
        -- forwarding_unit_signals : in std_logic_vector(1 downto 0);

-------------------------outputs-------------------------

        -- alu output
        alu_out : out std_logic_vector(31 downto 0);
        -- mem and wb control signals
        mem_wb_control_signals_out : out std_logic_vector(7 downto 0);
        -- addresses
        address_read1_out : out std_logic_vector(2 downto 0);
        address_read2_out : out std_logic_vector(2 downto 0);
        -- data
        data1_out : out std_logic_vector(31 downto 0);
        data2_out : out std_logic_vector(31 downto 0);
        -- destination address
        destination_address_out : out std_logic_vector(2 downto 0);
        -- pc + 1
        pc_out : out std_logic_vector(15 downto 0)

    );
end execute;

architecture arch_execute of execute is
    component ALU is
        generic (n: integer := 32);
        port (
            A, B: in std_logic_vector(n-1 downto 0); -- A-> data1 , B -> data2
            opcode: in std_logic_vector(2 downto 0); -- operation
            F: out std_logic_vector(n-1 downto 0); -- result
            zero_flag: out std_logic;
            overflow_flag: out std_logic; -- Overflow flag
            carry_flag: out std_logic; -- Carry flag
            negative_flag: out std_logic; -- Negative flag
            old_negative_flag: in std_logic; -- Old negative flag
            old_zero_flag: in std_logic; -- Old zero flag
            old_overflow_flag: in std_logic; -- Old overflow flag
            old_carry_flag: in std_logic -- Old carry flag
        );
    end component ALU;
    
    component mux4x1 is
        generic (n: integer := 16);
        port (
            inputA : in std_logic_vector(n-1 downto 0);
            inputB : in std_logic_vector(n-1 downto 0);
            inputC : in std_logic_vector(n-1 downto 0);
            inputD : in std_logic_vector(n-1 downto 0);
            Sel_lower : in std_logic; 
            Sel_higher : in std_logic; 
            output : out std_logic_vector(n-1 downto 0)
        );
    end component mux4x1;

    -- 4 bit D flip flop for the flags
    COMPONENT my_nDFF IS
        GENERIC ( n : integer := 16);
        PORT(
            Clk, reset : IN std_logic;
            d : IN std_logic_vector(n-1 DOWNTO 0);
            q : OUT std_logic_vector(n-1 DOWNTO 0)
            );
    END COMPONENT;
    
    signal old_negative_flag_temp : std_logic;
    signal old_zero_flag_temp : std_logic;
    signal old_overflow_flag_temp : std_logic;
    signal old_carry_flag_temp : std_logic;

    signal flags_temp_in : std_logic_vector(3 downto 0);
    signal flags_temp_out : std_logic_vector(3 downto 0);

begin
    
    -- flags_temp_out <= old_negative_flag_temp & old_zero_flag_temp & old_overflow_flag_temp & old_carry_flag_temp;

    -- DFF for the flags
    flags_dff : my_nDFF GENERIC MAP(4) PORT MAP(clk, '0', flags_temp_in, flags_temp_out);


    alu_component : ALU
    port map(
        A => data1_in,
        B => data2_in,
        opcode => operation,
        F => alu_out,
        negative_flag => flags_temp_in(0),
        zero_flag => flags_temp_in(1),
        overflow_flag => flags_temp_in(2),
        carry_flag => flags_temp_in(3),
        old_negative_flag => flags_temp_out(0),
        old_zero_flag => flags_temp_out(1),
        old_overflow_flag => flags_temp_out(2),
        old_carry_flag => flags_temp_out(3)
    );

    -- output signals
    pc_out <= pc_in;
    mem_wb_control_signals_out <= mem_wb_control_signals_in;
    address_read1_out <= address_read1_in;
    address_read2_out <= address_read2_in;
    data1_out <= data1_in;
    data2_out <= data2_in;
    destination_address_out <= destination_address;
    

    
        -- forwarding_unit : forwarding_unit
        -- port map(
        --     forwarding_unit_signals => forwarding_unit_signals,
        --     address_read1_in => address_read1_in,
        --     address_read2_in => address_read2_in,
        --     data1_in => data1_in,
        --     data2_in => data2_in,
        --     alu_result_forward => alu_result_forward,
        --     memory_result_forward => memory_result_forward,
        --     alu_mem_wb_control_signals => alu_mem_wb_control_signals,
        --     address_read1_out => address_read1_out,
        --     address_read2_out => address_read2_out,
        --     data1_out => data1_out,
        --     data2_out => data2_out,
        --     destination_address_out => destination_address_out,
        --     mem_wb_control_signals => mem_wb_control_signals
        -- );
    
    end arch_execute;