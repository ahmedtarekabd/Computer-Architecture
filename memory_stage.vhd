library ieee;
use ieee.std_logic_1164.all;


--  Might need to adjust memory width
entity memory_stage is
    port (
-----------------------------------------inputs-----------------------------------------
        clk : in std_logic;
        -- reset : in std_logic;

        -- Propagated stuff innit
        read_data1_in : in std_logic_vector(31 downto 0);
        read_data2_in : in std_logic_vector(31 downto 0);
        read_address1_in : in std_logic_vector(2 downto 0);
        read_address2_in : in std_logic_vector(2 downto 0);
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
        read_address1_out : out std_logic_vector(2 downto 0);
        read_address2_out : out std_logic_vector(2 downto 0);
        destination_address_out : out std_logic_vector(2 downto 0);
        pc_out : out std_logic_vector(15 downto 0);
        wb_control_signals_out : out std_logic_vector(2 downto 0)

        -- for forwarding make another output for the write data
    );
end memory_stage;

architecture memory_stage_arch of memory_stage is

    COMPONENT memory IS
        GENERIC (n : INTEGER := 16);
        PORT (
            clk : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(12 DOWNTO 0);

            write_enable : IN STD_LOGIC;
            write_data : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);

            read_enable : IN STD_LOGIC;
            read_data : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);

            protect_signal : IN STD_LOGIC;
            free_signal : IN STD_LOGIC

        );
    END COMPONENT memory;

    signal mem_read_data_internal : std_logic_vector(31 downto 0);


begin
    mem: memory
    GENERIC MAP (n => 31)
    PORT MAP (
        clk => clk,
        address => mem_read_or_write_addr,
        write_enable => mem_wb_control_signals_in(1),
        write_data => mem_write_data,
        read_enable => mem_wb_control_signals_in(0),
        read_data => mem_read_data_internal, -- the 7th output
        protect_signal => mem_wb_control_signals_in(2),
        free_signal => mem_wb_control_signals_in(3)
    );

    mem_read_data <= mem_read_data_internal;
    read_data1_out <= read_data1_in;
    read_data2_out <= read_data2_in;
    read_address1_out <= read_address1_in;
    read_address2_out <= read_address2_in;
    destination_address_out <= destination_address_in;
    pc_out <= pc_in;
    wb_control_signals_out <= mem_wb_control_signals_in(6 downto 4);

end memory_stage_arch;
