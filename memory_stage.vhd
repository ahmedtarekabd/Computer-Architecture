library ieee;
use ieee.std_logic_1164.all;

entity memory_stage is
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

        -- Control signals 1 bit for memread/memwrite and 5 bits for wb
        mem_wb_control_signals_in : in std_logic_vector(6 downto 0);

        -- PC + 1
        pc_in : in std_logic_vector(15 downto 0);

        mem_write_data : in std_logic;
        -- depends on the control signal
        mem_read_or_write_addr : in std_logic_vector(31 downto 0);
        

-----------------------------------------outputs-----------------------------------------
        mem_read_data : out std_logic_vector(31 downto 0)
        read_data1_out : out std_logic_vector(31 downto 0);
        read_data2_out : out std_logic_vector(31 downto 0);
        read_address1_out : out std_logic_vector(31 downto 0);
        read_address2_out : out std_logic_vector(31 downto 0);
        destination_address_out : out std_logic_vector(2 downto 0);
        pc_out : out std_logic_vector(15 downto 0);
        wb_control_signals_out : out std_logic_vector(5 downto 0)

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

    signal read_data1 : std_logic_vector(31 downto 0);
    signal read_data2 : std_logic_vector(31 downto 0);
    signal read_address1 : std_logic_vector(31 downto 0);
    signal read_address2 : std_logic_vector(31 downto 0);
    signal destination_address : std_logic_vector(2 downto 0);
    signal pc : std_logic_vector(15 downto 0);
    signal mem_wb_control_signals : std_logic_vector(6 downto 0);
    signal mem_read_data : std_logic_vector(31 downto 0);

    signal mem_wb_control_signals : std_logic_vector(6 downto 0);

    signal mem_read_or_write_addr : std_logic_vector(31 downto 0);

begin

    read_data1 <= read_data1_in;
    read_data2 <= read_data2_in;
    read_address1 <= read_address1_in;
    read_address2 <= read_address2_in;
    destination_address <= destination_address_in;
    mem_wb_control_signals <= mem_wb_control_signals_in;
    pc <= pc_in;

    mem_wb_control_signals <= mem_wb_control_signals_in;

    mem_read_or_write_addr <= mem_read_or_write_addr;

    mem: memory
    GENERIC MAP (n => 32)
    PORT MAP (
        clk => clk,
        address => mem_read_or_write_addr,
        write_enable => mem_wb_control_signals(0),
        write_data => mem_write_data,
        read_enable => mem_wb_control_signals(1),
        read_data => mem_read_data, -- the 7th output
        protect_signal => '0', -- ask desouki and tarek
        free_signal => '0'
    );


    read_data1_out <= read_data1;
    read_data2_out <= read_data2;
    read_address1_out <= read_address1;
    read_address2_out <= read_address2;
    destination_address_out <= destination_address;
    pc_out <= pc;
    wb_control_signals_out <= mem_wb_control_signals(6 downto 2);

end memory_stage_arch;
