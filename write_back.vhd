library ieee;
use ieee.std_logic_1164.all;

entity write_back is
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
        wb_control_signals_in : in std_logic_vector(3 downto 0);

    ------------output signals------------------
    selected_data_out1 : out std_logic_vector(31 downto 0);
    selected_data_out2 : out std_logic_vector(31 downto 0);
    -- selects between read address 1 and destination address
    selected_address_out : out std_logic_vector(31 downto 0);
    read_address2_out : out std_logic_vector(31 downto 0);
    -- from controller
    regWrite_out_control_signal : out std_logic
    );
end write_back;

architecture write_back_arch of write_back is
begin
    selected_data_out1 <= read_data1_in when (wb_control_signals_in(2 downto 1) = "00") else
                        read_data2_in when (wb_control_signals_in(2 downto 1) = "01") else
                        mem_read_data when (wb_control_signals_in(2 downto 1) = "10") else
                        (others => '0');
    -- for swapping we invert the read data 1 and read data 2
    selected_data_out2 <= read_data2_in when (wb_control_signals_in(2 downto 1) = "00") else
                        read_data1_in when (wb_control_signals_in(2 downto 1) = "01") else
                        mem_read_data when (wb_control_signals_in(2 downto 1) = "10") else
                        (others => '0');

    selected_address_out <= read_address1_in when (wb_control_signals_in(2) = '0') else
                            destination_address_in when (wb_control_signals_in(2) = '1') else
                            (others => '0');

    read_address2_out <= read_address2_in;
    regWrite_out_control_signal <= wb_control_signals_in(0);
end write_back_arch;