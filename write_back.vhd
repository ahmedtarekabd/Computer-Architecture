library ieee;
use ieee.std_logic_1164.all;

entity write_back is
    port (
        clk : in std_logic;
        ------------input signals------------------
        -- Propagated stuff
        read_data1_in : in std_logic_vector(31 downto 0);
        read_data2_in : in std_logic_vector(31 downto 0);
        read_address1_in : in std_logic_vector(2 downto 0);
        read_address2_in : in std_logic_vector(2 downto 0);
        destination_address_in : in std_logic_vector(2 downto 0);
        mem_read_data : in std_logic_vector(31 downto 0);
        ALU_result : in std_logic_vector(31 downto 0);
        pc_in : in std_logic_vector(15 downto 0);
        --bit 0 -> regwrite, bit 3 -> regread (i believe no regreads), bit 1 & 2 -> selectors for WB, src1, src2
        control_signals_in : in std_logic_vector(22 downto 0);

        ------------output signals------------------
        -- data
        selected_data_out1 : out std_logic_vector(31 downto 0);
        selected_data_out2 : out std_logic_vector(31 downto 0);
        -- adresses
        selected_address_out1 : out std_logic_vector(2 downto 0);
        selected_address_out2 : out std_logic_vector(2 downto 0);

        -- from controller (enable signals)
        reg_write_enable1 : out std_logic;
        reg_write_enable2 : out std_logic
    );
end write_back;

architecture write_back_arch of write_back is

begin
    -- 00 for ALU 01 for mem 10 for Rsrc2 swap
    selected_data_out1 <= ALU_result when (control_signals_in(2 downto 1) = "00") else
                        mem_read_data when (control_signals_in(2 downto 1) = "01") else
                        read_address2_in when (control_signals_in(2 downto 1) = "10") else
                        (others => '0');

    selected_data_out2 <= (others => '0');
    --TODO:
    -- selected_data_out2 <= read_data1_in when (control_signals_in(2 downto 1) = "00") else
    --                     read_data2_in when (control_signals_in(2 downto 1) = "01") else
    --                     mem_read_data when (control_signals_in(2) = '10') else
    --                     (others => '0');

    -- address regW1

    -- TODO: 
    -- selected_address_out1 <= destination_address_in when (destination_address_in = '0') else
    --                         read_address1_in when (read_address2_in = '1') else
    --                         (others => '0');

    selected_address_out1 <= destination_address_in;

    reg_write_enable1 <= control_signals_in(4);
    -- reg_write_enable2 <= control_signals_in(3);

    -- read_address2_out <= read_address2_in;
    -- regWrite_out_control_signal <= wb_control_signals_in(0);
end write_back_arch;
