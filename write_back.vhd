library ieee;
use ieee.std_logic_1164.all;

entity write_back is
    port (
        clk : in std_logic;
        ------------input signals------------------
        -- Propagated stuff
        read_data1_in : in std_logic_vector(31 downto 0); -- data1 -> R0 (00000000000000000000)
        read_data2_in : in std_logic_vector(31 downto 0);
        read_address1_in : in std_logic_vector(2 downto 0);
        read_address2_in : in std_logic_vector(2 downto 0);
        destination_address_in : in std_logic_vector(2 downto 0);
        mem_read_data : in std_logic_vector(31 downto 0);
        ALU_result : in std_logic_vector(31 downto 0);
        in_port : in std_logic_vector(31 downto 0);
        -- pc_in : in std_logic_vector(15 downto 0);
        --bit 0 -> regwrite, bit 3 -> regread (i believe no regreads), bit 1 & 2 -> selectors for WB, src1, src2
        ---------------- control signals ----------------
        reg_write_enable1_in : in std_logic;
        reg_write_enable2_in : in std_logic;
        Rsrc1_selector_in : in std_logic_vector(1 downto 0);
        reg_write_address1_in_select : in std_logic;        
        ------------output signals------------------
        -- data
        WB_selected_data_out1 : out std_logic_vector(31 downto 0);
        WB_selected_data_out2 : out std_logic_vector(31 downto 0);
        -- adresses
        WB_selected_address_out1 : out std_logic_vector(2 downto 0);
        WB_selected_address_out2 : out std_logic_vector(2 downto 0);

        -- Read data from memory
        mem_read_data_out : out std_logic_vector(31 downto 0);

        -- from controller (enable signals)
        reg_write_enable1_out : out std_logic;
        reg_write_enable2_out : out std_logic
    );
end write_back;

architecture write_back_arch of write_back is

begin
    -- 00 for ALU 01 for mem 10 for data 2 (swap) 11 for in port
    with Rsrc1_selector_in select
        WB_selected_data_out1 <= ALU_result when "00",
                                 mem_read_data when "01",
                                 read_data2_in when "10",
                                 in_port WHEN "11",
                                 (others => '0') when others;

    -- 0 for destination address, 1 for read address
    with reg_write_address1_in_select select
        WB_selected_address_out1 <= destination_address_in when '0',
                                    read_address1_in when '1',
                                    (others => '0') when others;

    -- Sent with the write back to reg file
    WB_selected_address_out2 <= read_address2_in;
    WB_selected_data_out2 <= read_data1_in;

    mem_read_data_out <= mem_read_data;

    reg_write_enable1_out <= reg_write_enable1_in;
    reg_write_enable2_out <= reg_write_enable2_in;


end write_back_arch;
