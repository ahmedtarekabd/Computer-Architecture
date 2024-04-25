library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
    port (
        clk : in std_logic; 
        reset : in std_logic
        
        -- add in port / out port
    );
end entity processor;

architecture arch_processor of processor is

    component fetch is
        port (
            clk : in std_logic; 
            reset : in std_logic;
            selected_instruction_out : out std_logic_vector(15 downto 0)
        );
    end component fetch;

    component execute is
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
            -- propagated from decode stage 1 bit for memread, memwrite (1 bit each), protect & free 1 bit each, 1 regwrite, 1 regRead(i believe no regreads), 2 selectors for (WB, src1, src2), 1 of them is given to the 3rd MUX to know which mode it is in
            -- bit 0 -> memread, bit 1 -> memwrite, bit 2 -> protect, bit 3 -> free, bit 4 -> regwrite, bit 5 -> regread (i believe no regreads), bit 6 & 7 -> selectors for WB, src1, src2
            mem_wb_control_signals_in : in std_logic_vector(6 downto 0);
    
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
            mem_wb_control_signals_out : out std_logic_vector(6 downto 0);
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
    component execute;
    
    component memory_stage is
        port (

            -----------------------------------------inputs-----------------------------------------
            clk : in std_logic;
            -- reset : in std_logic;
    
            -- Propagated stuff innit
            read_data1_in : in std_logic_vector(31 downto 0);
            read_data2_in : in std_logic_vector(31 downto 0);
            read_address1_in : in std_logic_vector(31 downto 0);
            read_address2_in : in std_logic_vector(31 downto 0);
            destination_address_in : in std_logic_vector(2 downto 0);
    
            -- propagated from decode stage 1 bit for memread, memwrite (1 bit each), protect & free 1 bit each, 1 regwrite, 1 regRead(i believe no regreads), 2 selectors for (WB, src1, src2), 1 of them is given to the 3rd MUX to know which mode it is in
            -- bit 0 -> memread, bit 1 -> memwrite, bit 2 -> protect, bit 3 -> free, bit 4 -> regwrite, bit 5 -> regread (i believe no regreads), bit 6 & 7 -> selectors for WB, src1, src2
            mem_wb_control_signals_in : in std_logic_vector(6 downto 0);
    
            -- PC + 1
            pc_in : in std_logic_vector(15 downto 0);
    
            mem_write_data : in std_logic_vector(31 downto 0);
            -- depends on the control signal same as ALU out
            mem_read_or_write_addr : in std_logic_vector(12 downto 0);
            
    
            -----------------------------------------outputs-----------------------------------------
            mem_read_data : out std_logic_vector(31 downto 0);
            read_data1_out : out std_logic_vector(31 downto 0);
            read_data2_out : out std_logic_vector(31 downto 0);
            read_address1_out : out std_logic_vector(31 downto 0);
            read_address2_out : out std_logic_vector(31 downto 0);
            destination_address_out : out std_logic_vector(2 downto 0);
            pc_out : out std_logic_vector(15 downto 0);
            wb_control_signals_out : out std_logic_vector(2 downto 0)
    
            -- for forwarding make another output for the write data
        );
    component memory_stage;

    component write_back is
        port (
            clk : in std_logic;
        
        ------------input signals------------------
        -- Propagated stuff
        read_data1_in : in std_logic_vector(31 downto 0);
        read_data2_in : in std_logic_vector(31 downto 0);
        read_address1_in : in std_logic_vector(31 downto 0);
        read_address2_in : in std_logic_vector(31 downto 0);
        destination_address_in : in std_logic_vector(2 downto 0);
        mem_read_data : in std_logic_vector(31 downto 0);
        pc_in : in std_logic_vector(15 downto 0);
        --bit 0 -> regwrite, bit 3 -> regread (i believe no regreads), bit 1 & 2 -> selectors for WB, src1, src2
        wb_control_signals_in : in std_logic_vector(2 downto 0);

        ------------output signals------------------
        selected_data_out1 : out std_logic_vector(31 downto 0);
        selected_data_out2 : out std_logic_vector(31 downto 0);
        -- selects between read address 1 and destination address
        selected_address_out : out std_logic_vector(31 downto 0);
        read_address2_out : out std_logic_vector(31 downto 0);
        -- from controller
        regWrite_out_control_signal : out std_logic
        );
    component write_back;

    --generic
    signal clk : std_logic;
    signal reset : std_logic;

    --fetch
    signal instruction : std_logic_vector(15 downto 0);
    signal opcode : std_logic_vector(5 downto 0);
    signal src1_address : std_logic_vector(2 downto 0);
    signal src2_address : std_logic_vector(2 downto 0);
    signal dest_address : std_logic_vector(2 downto 0);
    signal imm_flag : std_logic;

    --decode


begin

    ----------Fetch---------- 

    fetch_inst : fetch port map(
        clk => clk,
        reset => reset,
        selected_instruction_out => instruction
    );

    opcode <= instruction(15 downto 10);
    src1_address <= instruction(9 downto 7);
    src2_address <= instruction(6 downto 4);
    dest_address <= instruction(3 downto 1);
    imm_flag <= instruction(0);

    ----------Decode----------

    decode_inst : decode port map(
    

  

end architecture arch_processor;