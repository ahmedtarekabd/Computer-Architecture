LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY controller IS
	PORT (
		clk : IN STD_LOGIC;

		-- 6-bit opcode
		opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		isImmediate : IN STD_LOGIC;
		interrupt_signal : IN STD_LOGIC;
		zero_flag : IN STD_LOGIC;

		-- fetch signals
		fetch_pc_mux1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := "00";
		immediate_reg_enable : OUT STD_LOGIC := '0';
		fetch_decode_flush : OUT STD_LOGIC := '0';

		-- decode signals
		decode_reg_read : OUT STD_LOGIC := '0';
		decode_sign_extend : OUT STD_LOGIC := '0';
		decode_execute_flush : OUT STD_LOGIC := '0';

		-- execute signals
		execute_alu_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
		execute_alu_src2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
		execute_branch : OUT STD_LOGIC := '0';
		conditional_jump : OUT STD_LOGIC := '0';

		-- memory signals
		memory_write : OUT STD_LOGIC := '0';
		memory_read : OUT STD_LOGIC := '0';
		memory_stack_pointer : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
		memory_address : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
		memory_write_data : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
		memory_protected : OUT STD_LOGIC := '0';
		memory_free : OUT STD_LOGIC := '0';
		execute_memory_flush : OUT STD_LOGIC := '0';

		-- write back signals
		write_back_register_write1 : OUT STD_LOGIC := '0';
		write_back_register_write2 : OUT STD_LOGIC := '0';
		write_back_register_write_data_1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
		write_back_register_write_address_1 : OUT STD_LOGIC := '0';
		outport_enable : OUT STD_LOGIC := '0'

	);
END ENTITY controller;

ARCHITECTURE arch_controller OF controller IS

	TYPE immediate_state_type IS (instruction, waitOnce, immediate);
	SIGNAL immediate_state : immediate_state_type := instruction;

	TYPE interrupt_state_type IS (instruction, push_pc, push_ccr, update_pc);
	SIGNAL interrupt_state : interrupt_state_type := instruction;

	CONSTANT NOP_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
	CONSTANT NOT_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000001";
	CONSTANT NEG_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000010";
	CONSTANT INC_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000011";
	CONSTANT DEC_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000100";
	CONSTANT OUT_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000101";
	CONSTANT IN_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000110";
	CONSTANT MOV_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010000";
	CONSTANT SWAP_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010001";
	CONSTANT ADD_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010010";
	CONSTANT SUB_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010011";
	CONSTANT AND_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010100";
	CONSTANT OR_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010101";
	CONSTANT XOR_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010110";
	CONSTANT CMP_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010111";
	CONSTANT ADDI_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "011000";
	CONSTANT SUBI_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "011001";
	CONSTANT PUSH_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100000";
	CONSTANT POP_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100001";
	CONSTANT PROTECT_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100010";
	CONSTANT FREE_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100011";
	CONSTANT LDM_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100100";
	CONSTANT LDD_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100101";
	CONSTANT STD_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100110";
	CONSTANT JZ_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110000";
	CONSTANT JMP_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110001";
	CONSTANT CALL_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110010";
	CONSTANT RET_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110011";
	CONSTANT RTI_INST : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110100";

BEGIN

	-- Reading Immediate value
	-- Add bubble: by disabling fetch_decode and decode_execute
	-- decode_execute propagates this enable signal
	PROCESS (clk) IS
	BEGIN
		IF falling_edge(clk) THEN
			-- FSM
			CASE immediate_state IS
				WHEN instruction =>
					IF isImmediate = '1' THEN
						immediate_state <= waitOnce;
						immediate_reg_enable <= '0';
					ELSE
						immediate_reg_enable <= '1';
					END IF;
				WHEN waitOnce =>
					immediate_state <= immediate;
					immediate_reg_enable <= '1';
				WHEN immediate =>
					-- check neroh le waitOnce wala la2
					IF isImmediate = '1' THEN
						immediate_state <= waitOnce;
						immediate_reg_enable <= '0';
					ELSE
						immediate_state <= instruction;
						immediate_reg_enable <= '1';
					END IF;
			END CASE;
		END IF;
	END PROCESS;

	-- TODO: interrupt
	-- PUSH PC
	-- PUSH CCR
	-- Ret Data Memory[2]
	PROCESS (clk) IS
	BEGIN
		IF falling_edge(clk) THEN
			-- FSM
			CASE interrupt_state IS
				WHEN instruction =>
					IF interrupt_signal = '1' THEN
						interrupt_state <= push_pc;
					ELSE
					END IF;
				WHEN push_pc =>
					interrupt_state <= push_ccr;
				WHEN push_ccr =>
					interrupt_state <= update_pc;
				WHEN update_pc =>
					interrupt_state <= instruction;
					execute_branch <= '0';
			END CASE;
		END IF;
	END PROCESS;

	opcode_process : PROCESS (opcode) IS
	BEGIN
		IF interrupt_signal = '0' THEN
			CASE opcode IS
				WHEN "000000" => -- NOP
					-- fetch
					fetch_pc_mux1 <= "00";
					immediate_reg_enable <= '0';
					fetch_decode_flush <= '0';
					-- decode
					decode_reg_read <= '0';
					decode_sign_extend <= '0';
					decode_execute_flush <= '0';
					-- execute
					execute_alu_sel <= "000";
					execute_alu_src2 <= "00";
					execute_branch <= '0';
					conditional_jump <= '0';
					-- memory
					memory_write <= '0';
					memory_read <= '0';
					memory_stack_pointer <= "00";
					memory_address <= "00";
					memory_write_data <= "00";
					memory_protected <= '0';
					memory_free <= '0';
					execute_memory_flush <= '0';
					-- write back
					write_back_register_write1 <= '0';
					write_back_register_write2 <= '0';
					write_back_register_write_data_1 <= "00";
					write_back_register_write_address_1 <= '0';
					outport_enable <= '0';
				WHEN "000001" => -- not
				WHEN "000010" => -- neg
				WHEN "000011" => -- inc
				WHEN "000100" => -- dec
				WHEN "000101" => -- out
				WHEN "000110" => -- in
				WHEN "010000" => -- mov
				WHEN "010001" => -- swap
				WHEN "010010" => -- add
				WHEN "010011" => -- sub
				WHEN "010100" => -- and
				WHEN "010101" => -- or
				WHEN "010110" => -- xor
				WHEN "010111" => -- cmp
				WHEN "011000" => -- addi
				WHEN "011001" => -- subi
				WHEN "100000" => -- PUSH Rdst
					-- fetch
					fetch_pc_mux1 <= "00";
					immediate_reg_enable <= '0';
					fetch_decode_flush <= '0';
					-- decode
					decode_reg_read <= '1';
					decode_sign_extend <= '0';
					decode_execute_flush <= '0';
					-- execute
					execute_alu_sel <= "000";
					execute_alu_src2 <= "00";
					execute_branch <= '0';
					conditional_jump <= '0';
					-- memory
					memory_write <= '1';
					memory_read <= '0';
					memory_stack_pointer <= "01";
					memory_address <= "01";
					memory_write_data <= "00";
					memory_protected <= '0';
					memory_free <= '0';
					execute_memory_flush <= '0';
					-- write back
					write_back_register_write1 <= '0';
					write_back_register_write2 <= '0';
					write_back_register_write_data_1 <= "00";
					write_back_register_write_address_1 <= '0';
					outport_enable <= '0';
				WHEN "100001" => -- pop
					-- fetch
					fetch_pc_mux1 <= "00";
					immediate_reg_enable <= '0';
					fetch_decode_flush <= '0';
					-- decode
					decode_reg_read <= '0';
					decode_sign_extend <= '0';
					decode_execute_flush <= '0';
					-- execute
					execute_alu_sel <= "000";
					execute_alu_src2 <= "00";
					execute_branch <= '0';
					conditional_jump <= '0';
					-- memory
					memory_write <= '0';
					memory_read <= '1';
					memory_stack_pointer <= "10";
					memory_address <= "01";
					memory_write_data <= "00";
					memory_protected <= '0';
					memory_free <= '0';
					execute_memory_flush <= '0';
					-- write back
					write_back_register_write1 <= '1';
					write_back_register_write2 <= '0';
					write_back_register_write_data_1 <= "01";
					write_back_register_write_address_1 <= '0';
				WHEN "100010" => -- protect
					-- fetch
					fetch_pc_mux1 <= "00";
					immediate_reg_enable <= '0';
					fetch_decode_flush <= '0';
					-- decode
					decode_reg_read <= '1';
					decode_sign_extend <= '0';
					decode_execute_flush <= '0';
					-- execute
					execute_alu_sel <= "000";
					execute_alu_src2 <= "00";
					execute_branch <= '0';
					conditional_jump <= '0';
					-- memory
					memory_write <= '1';
					memory_read <= '0';
					memory_stack_pointer <= "00";
					memory_address <= "00";
					memory_write_data <= "00";
					memory_protected <= '1';
					memory_free <= '0';
					execute_memory_flush <= '0';
					-- write back
					write_back_register_write1 <= '0';
					write_back_register_write2 <= '0';
					write_back_register_write_data_1 <= "00";
					write_back_register_write_address_1 <= '0';
				WHEN "100011" => -- free
					-- fetch
					fetch_pc_mux1 <= "00";
					immediate_reg_enable <= '0';
					fetch_decode_flush <= '0';
					-- decode
					decode_reg_read <= '1';
					decode_sign_extend <= '0';
					decode_execute_flush <= '0';
					-- execute
					execute_alu_sel <= "000";
					execute_alu_src2 <= "00";
					execute_branch <= '0';
					conditional_jump <= '0';
					-- memory
					memory_write <= '1';
					memory_read <= '0';
					memory_stack_pointer <= "00";
					memory_address <= "00";
					memory_write_data <= "00";
					memory_protected <= '0';
					memory_free <= '1';
					execute_memory_flush <= '0';
					-- write back
					write_back_register_write1 <= '0';
					write_back_register_write2 <= '0';
					write_back_register_write_data_1 <= "00";
					write_back_register_write_address_1 <= '0';
				WHEN "100100" => -- ldm
				WHEN "100101" => -- ldd
				WHEN "100110" => -- std
					-- branching
				WHEN "110000" => -- jz
					-- fetch
					fetch_pc_mux1 <= "01";
					immediate_reg_enable <= '0';
					fetch_decode_flush <= zero_flag;
					-- decode
					decode_reg_read <= '1';
					decode_sign_extend <= '0';
					decode_execute_flush <= zero_flag;
					-- execute
					execute_alu_sel <= "000";
					execute_alu_src2 <= "00";
					execute_branch <= zero_flag;
					conditional_jump <= '0';
					-- memory
					memory_write <= '0';
					memory_read <= '0';
					memory_stack_pointer <= "00";
					memory_address <= "00";
					memory_write_data <= "00";
					memory_protected <= '0';
					memory_free <= '0';
					execute_memory_flush <= '1';
					-- write back
					write_back_register_write1 <= '0';
					write_back_register_write2 <= '0';
					write_back_register_write_data_1 <= "00";
					write_back_register_write_address_1 <= '0';

				WHEN "110001" => -- jmp
				WHEN "110010" => -- call
				WHEN "110011" => -- ret
				WHEN "110100" => -- rti

				WHEN OTHERS =>
			END CASE;
		END IF;
	END PROCESS;

END arch_controller;

-- MOV Rdst, Rsrc	000	1	0	X
-- IN Rdst	000	0	0	X
-- OUT Rdst	000	1	0	X

-- INC Rdst	000	1	0	X
-- ADD Rdst, Rsrc1, Rsrc2	000	1	0	X
-- ADDI Rdst, Rsrc1, Imm	000	1	0	0
-- LDM Rdst, Imm	000	1	0	1
-- LDD Rdst, EA(Rsrc1)	000	1	0	0
-- STD Rdst, EA(Rsrc1)	000	1	0	0

-- DEC Rdst	000	1	0	X
-- NEG Rdst	000	1	0	X
-- SUB Rdst, Rsrc1, Rsrc2	000	1	0	X
-- SUBI Rdst, Rsrc1, Imm	000	1	0	0
-- CMP Rsrc1, Rsrc2	000	1	0	X

-- NOT Rdst	000	1	0	X
-- AND Rdst, Rsrc1, Rsrc2	000	1	0	X
-- OR Rdst, Rsrc1, Rsrc2	000	1	0	X
-- XOR Rdst, Rsrc1, Rsrc2	000	1	0	X
--  
-- Execute & Memory
-- Instruction	ALU Selectors	ALU src2	Reg write	MW
-- enable	MR
-- enable	SP	MW address	MW data
-- NOP	XXX	XX	0	0	0	00	XX	XX
-- PUSH Rdst	XXX	00(src2)	0	1	0	01(-2)	01 (SP)	00 (Src2)
-- POP Rdst	XXX	XX	1	0	1	10(+2)	01 (SP)	XX
-- PROTECT Rsrc	XXX	XX	0	1	0	00	10 (ALU)	XX
-- FREE Rsrc	XXX	XX	0	0	0	00	10 (ALU)	XX
-- JZ Rdst	XXX	00	0	0	0	00	XX	XX
-- JMP Rdst	XXX	00	0	0	0	00	XX	X
-- CALL Rdst	XXX	00	0	1	0	01(-2)	01 (SP)	01 (PC+1)
-- RET	XXX	XX	0	0	1	10(+2)	XX	XX
-- RTI	XXX	XX	0	0	1	10(+2)	XX	XX
-- RESET	XXX	XX	X	X	X	XX	XX	X
-- INTERRUPT	XXX	XX	0	1	0	01(-2)	01 (SP)	X

-- MOV Rdst, Rsrc	011	00(src2)	1	0	0	00	XX	XX
-- IN Rdst	XXX	XX	1	0	0	00		X
-- OUT Rdst	XXX	00	1	0	0	00		X

-- INC Rdst	001	10(1)	1	0	0	00		X
-- ADD Rdst, Rsrc1, Rsrc2	001	00(src2)	1	0	0	00		X
-- ADDI Rdst, Rsrc1, Imm	001	01(Imm)	1	0	0	00		X
-- LDM Rdst, Imm	011	01(Imm)	1	0	0	00	XX	XX
-- LDD Rdst, EA(Rsrc1)	001	01(Imm)	1	0	0	00		X
-- STD Rdst, EA(Rsrc1)	001	01(Imm)	1	1	0	00		0

-- DEC Rdst	010	10(1)	1	0	0	00	XX	XX
-- NEG Rdst	010	XX	1	0	0	00		X
-- SUB Rdst, Rsrc1, Rsrc2	010	00(src2)	1	0	0	00		X
-- SUBI Rdst, Rsrc1, Imm	010	01(Imm)	1	0	0	00		X
-- CMP Rsrc1, Rsrc2	010	00(src2)	0	0	0	00	XX	XX

-- NOT Rdst	111	XX	1	0	0	00	XX	XX
-- AND Rdst, Rsrc1, Rsrc2	100	00(src2)	1	0	0	00		X
-- OR Rdst, Rsrc1, Rsrc2	101	00(src2)	1	0	0	00	XX	XX
-- XOR Rdst, Rsrc1, Rsrc2	110	00(src2)	1	0	0	00		X

--  
-- Write Back
-- Instruction	Rsrc1 Data	RegW1 Enable	RegW2 Enable	RegW1 Address mux
-- NOP	XXX	0	0	0(Rdst)
-- PUSH Rdst	XXX	1	0	0(Rdst)
-- POP Rdst	XXX	0	0	0(Rdst)
-- PROTECT Rsrc	XXX	1	0	0(Rdst)
-- FREE Rsrc	XXX	0	0	0(Rdst)
-- JZ Rdst	XXX	0	0	0(Rdst)
-- JMP Rdst	XXX	0	0	0(Rdst)
-- CALL Rdst	XXX	1	0	0(Rdst)
-- RET	XXX	0	0	0(Rdst)
-- RTI	XXX	0	0	0(Rdst)
-- RESET	XXX	X	0	0(Rdst)
-- INTERRUPT	XXX	1	0	0(Rdst)

-- MOV Rdst, Rsrc	00(ALU)	1	0	0(Rdst)
-- IN Rdst	011	0	0	0(Rdst)
-- OUT Rdst	011	0	0	0(Rdst)

-- INC Rdst	001	0	0	0(Rdst)
-- ADD Rdst, Rsrc1, Rsrc2	001	0	0	0(Rdst)
-- ADDI Rdst, Rsrc1, Imm	001	0	0	0(Rdst)
-- LDM Rdst, Imm	00(ALU)	1	0	0(Rdst)
-- LDD Rdst, EA(Rsrc1)	001	0	0	0(Rdst)
-- STD Rdst, EA(Rsrc1)	001	1	0	0(Rdst)

-- DEC Rdst	00(ALU)	1	0	0(Rdst)
-- NEG Rdst	010	0	0	0(Rdst)
-- SUB Rdst, Rsrc1, Rsrc2	010	0	0	0(Rdst)
-- SUBI Rdst, Rsrc1, Imm	010	0	0	0(Rdst)
-- CMP Rsrc1, Rsrc2	XX	0	0	0(Rdst)

-- NOT Rdst	00(ALU)	1	0	0(Rdst)
-- AND Rdst, Rsrc1, Rsrc2	100	0	0	0(Rdst)
-- OR Rdst, Rsrc1, Rsrc2	00(ALU)	1	0	0(Rdst)
-- XOR Rdst, Rsrc1, Rsrc2	110	0	0	0(Rdst)