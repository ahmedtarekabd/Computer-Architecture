LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

-- IN R1 write enable 1

ENTITY forwarding_unit IS
    PORT(
    -- Addresses
        -- From Decode/Execute
        src_address1_de : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        src_address2_de : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        dst_address_de : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- From Execute/Memory
        dst_address_em : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        src_address1_em : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        src_address2_em : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- From Memory/Writeback
        -- address1 is address1 is register file and is either src1 or rdst
        address1_mw : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- address2 is address 2 in register file always src2
        address2_mw : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- Rdst from the Fetch/Decode stage which is Source 1 address in diagram
        dst_address_fd : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- Control Signals
        -- Write back signals
        -- write_back(1) is enable 2
        -- write_back(0) is enable 1
        -- these are the write enable signals for the register file




        -- Memory read signals
        -- used to check for load use hazard
        -- From Execute/Memory
        memory_read_em : IN STD_LOGIC;

        -- FROM Decode/Execute
        memory_read_de : IN STD_LOGIC;

        -- From Memory/Writeback
        -- not needed
        -- memory_read_mw : IN STD_LOGIC;

        -- Immediate flags
        -- From Execute/Memory
        -- immediate_em : IN STD_LOGIC;

        -- -- From Memory/Writeback
        -- immediate_mw : IN STD_LOGIC;

        -- Output signals
        -- 000 for normal data
        -- 001 for ALU result from Execute/Memory
        -- 010 for data 1 from Memory/Writeback
        -- 011 for data 2 from Memory/Writeback
        -- 100 for data 1 from Execute/Memory
        -- 101 for data 2 from Execute/Memory
        opp1_ALU_MUX_SEL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        opp2_ALU_MUX_SEL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        opp_branching_mux_selector : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        opp_branch_or_normal_mux_selector: OUT STD_LOGIC;

        load_use_hazard : OUT STD_LOGIC;

        -- From Execute/Memory
        -- write_back_em : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        write_back_em_enable1 : IN STD_LOGIC;
        write_back_em_enable2 : IN STD_LOGIC;

        -- From Memory/Writeback
        -- write_back_mw : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        write_back_mw_enable1 : IN STD_LOGIC;
        write_back_mw_enable2 : IN STD_LOGIC;

        -- From Decode/Execute
        -- write_back_de : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        write_back_de_enable1 : IN STD_LOGIC;
        write_back_de_enable2 : IN STD_LOGIC;

        -- FOR IN instruction I need reg_write_address1_in_select if it is 11 and src1 in execute is same as address 1 from WB then forwarding happens
        reg_write_address1_in_select_em : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        reg_write_address1_in_select_mw : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        -- add additional check for presence of out port opcode
        -- if true and adresses match then we need to forward
        out_port_enable : IN STD_LOGIC
    );
END forwarding_unit;

ARCHITECTURE forwarding_unit_arch OF forwarding_unit IS

    SIGNAL write_back_de : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL write_back_em : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL write_back_mw : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN

    write_back_de <= write_back_de_enable2 & write_back_de_enable1;
    write_back_em <= write_back_em_enable2 & write_back_em_enable1;
    write_back_mw <= write_back_mw_enable2 & write_back_mw_enable1;
    -- sensitive on only src_address1_de and src_address2_de
    -- because whenever they change we must check if the previous instruction changed their values
    PROCESS (src_address1_de, src_address2_de, dst_address_em, src_address1_em, src_address2_em, address1_mw, address2_mw, write_back_em, write_back_mw, memory_read_em, out_port_enable, reg_write_address1_in_select_em, reg_write_address1_in_select_mw)
    BEGIN
        -- Default values
        opp1_ALU_MUX_SEL <= "000";
        opp2_ALU_MUX_SEL <= "000";
        load_use_hazard <= '0';
        -- IF the write back enables from Execute/Memory and Memory/Writeback are 0 
        -- then no forwarding is needed
        IF (write_back_em(1 DOWNTO 0) = "00" AND write_back_mw(1 DOWNTO 0) = "00" AND out_port_enable = '0' AND reg_write_address1_in_select_em /= "11" AND reg_write_address1_in_select_mw /= "11") THEN
            opp1_ALU_MUX_SEL <= "000";
            opp2_ALU_MUX_SEL <= "000";
            -- load_use_hazard <= '0';
        -- END IF;

    -- Execute/Memory stage
        -- IN instruction in Execute/Memory stage output 110 for takin the destination data from the execute/memory stage
        ELSIF ((reg_write_address1_in_select_em = "11" OR (reg_write_address1_in_select_em = "11" AND out_port_enable = '1'))  AND ((src_address1_de = dst_address_em) OR (src_address2_de = dst_address_em))) THEN
            IF (src_address1_de = dst_address_em) THEN
                opp1_ALU_MUX_SEL <= "110";
            ELSE
                opp1_ALU_MUX_SEL <= "000";
            END IF;

            IF (src_address2_de = dst_address_em) THEN
                opp2_ALU_MUX_SEL <= "110";
            ELSE
                opp2_ALU_MUX_SEL <= "000";
            END IF;

        -- For execute/memory stage, if the write_back_em(0) is 1 and write_back_em(1) is 0
        -- this means there is write back but no swapping
        -- write back can be either alu result or memory read
        -- if memory read is 1 then the data is from memory and we have load use hazard
        -- if memory read is 0 then the data is from alu result
        -- else if write_back_em(1) is 1 and write_back_em(0) is 1 then there is swapping
        -- no other options like 0, 1 or 0, 0 are possible
        ELSIF (((write_back_em(0) = '1' AND write_back_em(1) = '0' AND memory_read_em = '0') OR (out_port_enable = '1'AND write_back_em(0) = '1' AND write_back_em(1) = '0' AND memory_read_em = '0')) AND ((src_address1_de = dst_address_em) OR (src_address2_de = dst_address_em))) THEN
            -- load_use_hazard <= '0';
        -- compare src_address1_de and src_address2_de with dst_address_em
            IF (src_address1_de = dst_address_em) THEN
                opp1_ALU_MUX_SEL <= "001";
            ELSE
                opp1_ALU_MUX_SEL <= "000";
            END IF;

            IF (src_address2_de = dst_address_em) THEN
                opp2_ALU_MUX_SEL <= "001";
            ELSE
                opp2_ALU_MUX_SEL <= "000";
            END IF;
        -- if memory read is 1 then we have load use hazard
        -- ELSIF (write_back_em(0) = '1' AND write_back_em(1) = '0' AND memory_read_em = '1') THEN
            -- load_use_hazard <= '1';
        --     opp1_ALU_MUX_SEL <= "000";
        --     opp2_ALU_MUX_SEL <= "000";
        -- END IF;

        -- If write_back_em(1) is 1 and write_back_em(0) is 1 then there is swapping
        -- compare src_address1_de and src_address2_de with src_address1_em and src_address2_em
        ELSIF (((write_back_em(1) = '1' AND write_back_em(0) = '1') OR (out_port_enable = '1' AND write_back_em(1) = '1' AND write_back_em(0) = '1')) AND ((src_address1_de = src_address1_em) OR (src_address1_de = src_address2_em) OR (src_address2_de = src_address1_em) OR (src_address2_de = src_address2_em))) THEN
            -- load_use_hazard <= '0';
            IF (src_address1_de = src_address1_em) THEN
            -- swapping did not happen yet, but we deduced that there was swapping because enable 1 and 2 are enabled
            -- so we the alu mux should take the swapped value. i.e: if src1 = src1_em then take value in data 2
                opp1_ALU_MUX_SEL <= "101";
            -- if i find out that src1_de is equal to src2_em, given that i swapped the values, 
            -- then i should take the value in data 1
            ELSIF (src_address1_de = src_address2_em) THEN
                opp1_ALU_MUX_SEL <= "100";
            ELSE
                opp1_ALU_MUX_SEL <= "000";
            END IF;

            IF (src_address2_de = src_address1_em) THEN
                opp2_ALU_MUX_SEL <= "101";
            ELSIF (src_address2_de = src_address2_em) THEN
                opp2_ALU_MUX_SEL <= "100";
            ELSE
                opp2_ALU_MUX_SEL <= "000";
            END IF;

            
    -- Memory/Write back
        -- IN instruction in Memory/Writeback stage output 111 for takin the destination data from the memory/writeback stage
        ELSIF ((reg_write_address1_in_select_mw = "11" OR (reg_write_address1_in_select_mw = "11" AND out_port_enable = '1')) AND ((src_address1_de = address1_mw) OR (src_address2_de = address1_mw))) THEN
            IF (src_address1_de = address1_mw) THEN
                opp1_ALU_MUX_SEL <= "111";
            ELSE
                opp1_ALU_MUX_SEL <= "000";
            END IF;

            IF (src_address2_de = address1_mw) THEN
                opp2_ALU_MUX_SEL <= "111";
            ELSE
                opp2_ALU_MUX_SEL <= "000";
            END IF;

        -- For memory/writeback stage, if the write_back_mw(0) is 1 and write_back_mw(1) is 0
        -- this means there is write back but no swapping
        -- write back can be either alu result or memory read
        -- but in this case, both are multiplexed to the same register file
        -- so we only do one check

        -- else if write_back_mw(1) is 1 and write_back_mw(0) is 1 then there is swapping
        -- but in our case data 1 is always going to data 2 in register file 
        -- and data 2 is multiplexed with alu result and memory read
        -- no other options like 0, 1 or 0, 0 are possible

        ELSIF (((write_back_mw(0) = '1' AND write_back_mw(1) = '0') OR (out_port_enable = '1' AND write_back_mw(0) = '1' AND write_back_mw(1) = '0')) AND ((src_address1_de = address1_mw) OR (src_address2_de = address1_mw))) THEN
            -- load_use_hazard <= '0';
            -- we only compare src_address1_de with address1_mw (address1 in register file is destination here)
            -- as no swapping is possible
            IF (src_address1_de = address1_mw) THEN
                -- data 1 multiplexed out of WB mux in designs
                opp1_ALU_MUX_SEL <= "010";
            ELSE
                opp1_ALU_MUX_SEL <= "000";
            END IF;

            IF (src_address2_de = address1_mw) THEN
                -- data 1 multiplexed out of WB mux in designs
                opp2_ALU_MUX_SEL <= "010";
            ELSE
                opp2_ALU_MUX_SEL <= "000";
            END IF;
        -- END IF;

        -- If write_back_mw(1) is 1 and write_back_mw(0) is 1 then there is swapping
        -- compare src_address1_de with address1_mw and address2_mw
        -- no need to check on memory read as forwarding is possible
        ELSIF (((write_back_mw(1) = '1' AND write_back_mw(0) = '1') OR (out_port_enable = '1' AND write_back_mw(1) = '1' AND write_back_mw(0) = '1')) AND ((src_address1_de = address2_mw) OR (src_address1_de = address1_mw) OR (src_address2_de = address2_mw) OR (src_address2_de = address1_mw))) THEN
            -- load_use_hazard <= '0';
            IF (src_address1_de = address2_mw) THEN
            -- swapping happened and we take data 1
                opp1_ALU_MUX_SEL <= "011";
            -- else if src1_de is equal to address1_mw then we take data 2
            ELSIF (src_address1_de = address1_mw) THEN
                opp1_ALU_MUX_SEL <= "010";
            ELSE
                opp1_ALU_MUX_SEL <= "000";
            END IF;

            IF (src_address2_de = address2_mw) THEN
                opp2_ALU_MUX_SEL <= "011";
            ELSIF (src_address2_de = address1_mw) THEN
                opp2_ALU_MUX_SEL <= "010";
            ELSE
                opp2_ALU_MUX_SEL <= "000";
            END IF;
        -- END IF;

        ELSE
            -- load_use_hazard <= '0';
            opp1_ALU_MUX_SEL <= "000";
            opp2_ALU_MUX_SEL <= "000";
        END IF;
    END PROCESS;

    PROCESS (src_address1_de, src_address2_de, dst_address_em, src_address1_em, src_address2_em, address1_mw, address2_mw, write_back_em, write_back_mw, memory_read_em, write_back_de, dst_address_fd, memory_read_de)
    BEGIN
        -- Default values
        opp_branching_mux_selector <= "000";
        opp_branch_or_normal_mux_selector <= '0';

        -- IF the write back enables from Decode/Execute and Execute/Memory and Memory/Writeback are 0 
        -- then no forwarding is needed
        IF (write_back_em(1 DOWNTO 0) = "00" AND write_back_mw(1 DOWNTO 0) = "00" AND write_back_de(1 DOWNTO 0) = "00") THEN
            opp_branching_mux_selector <= "000";
            opp_branch_or_normal_mux_selector <= '0';
        -- END IF;

    -- Decode/Execute stage
        -- For decode/execute stage, if the write_back_de(0) is 1 and write_back_de(1) is 0 
        -- this means there is write back but no swapping
        -- write back can be either alu result or memory read
        -- if memory read is 1 then the data is from memory and we have load use hazard
        -- if memory read is 0 then the data is from alu result
        -- else if write_back_de(1) is 1 and write_back_de(0) is 1 then there is swapping
        -- no other options like 0, 1 or 0, 0 are possible
        ELSIF (write_back_de(0) = '1' AND write_back_de(1) = '0' AND memory_read_de = '0' AND dst_address_fd = dst_address_de) THEN
            -- compare src_address1_de and src_address2_de with dst_address_de
            IF (dst_address_fd = dst_address_de) THEN
                opp_branching_mux_selector <= "000";
                opp_branch_or_normal_mux_selector <= '1';
            END IF;

        -- Swapping case
        ELSIF (write_back_de(0) = '1' AND write_back_de(1) = '1' AND ((dst_address_fd = src_address1_de) OR (dst_address_fd = src_address2_de))) THEN
            IF (dst_address_fd = src_address1_de) THEN
            -- if it is equal to src 1 and there is swapping then we store in it data 2 not 1
            -- here 111 is the address for data 2
                opp_branching_mux_selector <= "111";
                opp_branch_or_normal_mux_selector <= '1';

            ELSIF (dst_address_fd = src_address2_de) THEN
            -- if it is equal to src 2 and there is swapping then we store in it data 1 not 2
            -- here 110 is the address for data 1
                opp_branching_mux_selector <= "110";
                opp_branch_or_normal_mux_selector <= '1';
            ELSE
                opp_branching_mux_selector <= "000";
                opp_branch_or_normal_mux_selector <= '0';
            END IF;

    -- Execute/Memory stage
        -- For execute/memory stage, if the write_back_em(0) is 1 and write_back_em(1) is 0
        -- this means there is write back but no swapping
        -- write back can be either alu result or memory read
        -- if memory read is 1 then the data is from memory and we have load use hazard
        -- if memory read is 0 then the data is from alu result
        -- else if write_back_em(1) is 1 and write_back_em(0) is 1 then there is swapping
        -- no other options like 0, 1 or 0, 0 are possible
        ELSIF (write_back_em(0) = '1' AND write_back_em(1) = '0' AND memory_read_em = '0' AND dst_address_fd = dst_address_em) THEN
            -- compare src_address1_de and src_address2_de with dst_address_em
            IF (dst_address_fd = dst_address_em) THEN
                opp_branching_mux_selector <= "001";
                opp_branch_or_normal_mux_selector <= '1';
            END IF;

        -- Swapping case
        ELSIF (write_back_em(0) = '1' AND write_back_em(1) = '1' AND ((dst_address_fd = src_address1_em) OR (dst_address_fd = src_address2_em))) THEN
            IF (dst_address_fd = src_address1_em) THEN
            -- if it is equal to src 1 and there is swapping then we store in it data 2 not 1
            -- here 111 is the address for data 2
                opp_branching_mux_selector <= "101";
                opp_branch_or_normal_mux_selector <= '1';

            ELSIF (dst_address_fd = src_address2_em) THEN
            -- if it is equal to src 2 and there is swapping then we store in it data 1 not 2
            -- here 110 is the address for data 1
                opp_branching_mux_selector <= "100";
                opp_branch_or_normal_mux_selector <= '1';
            ELSE
                opp_branching_mux_selector <= "000";
                opp_branch_or_normal_mux_selector <= '0';
            END IF;

    -- Memory/Write back
        -- For memory/writeback stage, if the write_back_mw(0) is 1 and write_back_mw(1) is 0
        -- this means there is write back but no swapping
        -- write back can be either alu result or memory read
        -- but in this case, both are multiplexed to the same register file
        -- so we only do one check

        -- else if write_back_mw(1) is 1 and write_back_mw(0) is 1 then there is swapping
        -- but in our case data 1 is always going to data 2 in register file 
        -- and data 2 is multiplexed with alu result and memory read
        -- no other options like 0, 1 or 0, 0 are possible

        ELSIF (write_back_mw(0) = '1' AND write_back_mw(1) = '0' AND dst_address_fd = address1_mw) THEN
            -- we only compare src_address1_de with address1_mw (address1 in register file is destination here)
            -- as no swapping is possible
            IF (dst_address_fd = address1_mw) THEN
                -- data 1 multiplexed out of WB mux in designs
                opp_branching_mux_selector <= "010";
                opp_branch_or_normal_mux_selector <= '1';
            ELSE
                opp_branching_mux_selector <= "000";
                opp_branch_or_normal_mux_selector <= '0';
            END IF;

        -- If write_back_mw(1) is 1 and write_back_mw(0) is 1 then there is swapping
        -- compare src_address1_de with address1_mw and address2_mw
        -- no need to check on memory read as forwarding is possible
        ELSIF (write_back_mw(1) = '1' AND write_back_mw(0) = '1' AND ((dst_address_fd = address2_mw) OR (dst_address_fd = address1_mw))) THEN
            IF (dst_address_fd = address2_mw) THEN
            -- swapping happened and we take data 1
                opp_branching_mux_selector <= "011";
                opp_branch_or_normal_mux_selector <= '1';

            -- else if src1_de is equal to address1_mw then we take data 2
            ELSIF (dst_address_fd = address1_mw) THEN
                opp_branching_mux_selector <= "010";
                opp_branch_or_normal_mux_selector <= '1';

            ELSE
                opp_branching_mux_selector <= "000";
                opp_branch_or_normal_mux_selector <= '0';
            END IF;
        ELSE
            opp_branching_mux_selector <= "000";
            opp_branch_or_normal_mux_selector <= '0';
        END IF;
    END PROCESS;

END forwarding_unit_arch;