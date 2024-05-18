LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY hazard_detection_unit IS
    PORT (
        -- Input signals==================================

        -- Addresses-------------------------------------
        -- From Fetch/Decode
        src_address1_fd : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        src_address2_fd : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- From Decode/Execute
        dst_address_de : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- Control Signals-------------------------------
        -- From Decode/Execute
        write_back_1_de : IN STD_LOGIC;
        memory_read_de : IN STD_LOGIC;
        -- From control unit
        reg_read_controller : IN STD_LOGIC;

        -- Output signals=================================
        PC_enable : OUT STD_LOGIC;
        enable_fd : OUT STD_LOGIC;
        reset_de : OUT STD_LOGIC
    );
END hazard_detection_unit;

ARCHITECTURE hazard_detection_unit_arch OF hazard_detection_unit IS
BEGIN
    PROCESS (src_address1_fd, src_address2_fd, dst_address_de, write_back_1_de, memory_read_de)
    BEGIN
        -- Default values
        PC_enable <= '0';
        enable_fd <= '0';
        reset_de <= '0';

        -- if write back is enabled in decode/execute stage and memory read is enabled in decode/execute stage then we may have a hazard
        IF (write_back_1_de = '1' AND memory_read_de = '1') THEN
            -- if src_address1_fd is equal to dst_address_de then we have a hazard
            IF (src_address1_fd = dst_address_de) THEN
                PC_enable <= '1';
                enable_fd <= '1';
                reset_de <= '1';
            END IF;
            -- if src_address2_fd is equal to dst_address_de then we have a hazard
            IF (src_address2_fd = dst_address_de) THEN
                PC_enable <= '1';
                enable_fd <= '1';
                reset_de <= '1';
            END IF;
        END IF;

    END PROCESS;
END hazard_detection_unit_arch;