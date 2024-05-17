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
		fetch_pc_mux1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
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
	PROCESS (clk) IS -- opcode, interrupt_signal?
	BEGIN
		IF falling_edge(clk) AND interrupt_signal = '1' THEN
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
		ELSIF interrupt_signal = '0' THEN
			-- fetch
			fetch_pc_mux1 <=
				"01" WHEN opcode = JZ_INST OR opcode = JMP_INST OR opcode = CALL_INST ELSE
				"11" WHEN opcode = RET_INST OR opcode = RTI_INST ELSE
				"00";

			fetch_decode_flush <=
				zero_flag WHEN opcode = JZ_INST ELSE
				'1' WHEN opcode = JMP_INST OR opcode = CALL_INST OR opcode = RET_INST OR opcode = RTI_INST ELSE
				'0';

			-- decode
			decode_reg_read <=
				'0' WHEN opcode = NOP_INST OR opcode = POP_INST OR opcode = RET_INST OR opcode = RTI_INST OR opcode = IN_INST ELSE
				'1';

			decode_sign_extend <=
				'1' WHEN opcode = LDM_INST ELSE
				'0';

			decode_execute_flush <=
				zero_flag WHEN opcode = JZ_INST ELSE
				'1' WHEN opcode = JMP_INST OR opcode = CALL_INST OR opcode = RET_INST OR opcode = RTI_INST ELSE
				'0';

			-- execute
			execute_alu_sel <=
				"011" WHEN opcode = MOV_INST OR opcode = LDM_INST ELSE
				"001" WHEN opcode = INC_INST OR opcode = ADD_INST OR opcode = ADDI_INST OR opcode = LDD_INST OR opcode = STD_INST ELSE
				"010" WHEN opcode = DEC_INST OR opcode = NEG_INST OR opcode = SUB_INST OR opcode = SUBI_INST OR opcode = CMP_INST ELSE
				"111" WHEN opcode = NOT_INST ELSE
				"100" WHEN opcode = AND_INST ELSE
				"101" WHEN opcode = OR_INST ELSE
				"110" WHEN opcode = XOR_INST ELSE
				"000";

			execute_alu_src2 <=
				"01" WHEN opcode = LDM_INST OR opcode = ADDI_INST OR opcode = LDD_INST OR opcode = STD_INST OR opcode = SUBI_INST ELSE
				"10" WHEN opcode = INC_INST OR opcode = DEC_INST ELSE
				"00";

			execute_branch <=
				zero_flag WHEN opcode = JZ_INST ELSE
				'1' WHEN opcode = JMP_INST OR opcode = CALL_INST OR opcode = RET_INST OR opcode = RTI_INST ELSE
				'0';

			conditional_jump <=
				'1' WHEN opcode = JZ_INST ELSE
				'0';

			-- memory
			memory_write <=
				'1' WHEN opcode = PUSH_INST OR opcode = PROTECT_INST OR opcode = FREE_INST OR opcode = CALL_INST OR opcode = STD_INST ELSE
				'0';

			memory_read <=
				'1' WHEN opcode = POP_INST OR opcode = RET_INST OR opcode = RTI_INST OR opcode = OUT_INST OR opcode = LDD_INST ELSE
				'0';

			memory_stack_pointer <=
				"01" WHEN opcode = PUSH_INST OR opcode = CALL_INST ELSE
				"10" WHEN opcode = POP_INST OR opcode = RET_INST OR opcode = RTI_INST ELSE
				"00";

			memory_address <=
				"01" WHEN opcode = PUSH_INST OR opcode = POP_INST OR opcode = CALL_INST OR opcode = RET_INST ELSE
				"00";

			memory_write_data <=
				"01" WHEN opcode = CALL_INST ELSE
				"00"; -- el ba2y 3nd el interrupt FSM

			memory_protected <=
				'1' WHEN opcode = PROTECT_INST ELSE
				'0';

			memory_free <=
				'1' WHEN opcode = FREE_INST ELSE
				'0';

			execute_memory_flush <=
				'1' WHEN opcode = JZ_INST OR opcode = JMP_INST OR opcode = CALL_INST OR opcode = RET_INST OR opcode = RTI_INST ELSE
				'0';

			-- write back
			write_back_register_write_data_1 <=
				"01" WHEN opcode = POP_INST OR opcode = LDD_INST ELSE
				"11" WHEN opcode = IN_INST ELSE
				"10" WHEN opcode = SWAP_INST ELSE
				"00";

			write_back_register_write1 <=
				'1' WHEN opcode = POP_INST OR opcode = SWAP_INST OR opcode = MOV_INST OR opcode = LDM_INST OR opcode = INC_INST OR opcode = ADD_INST OR opcode = ADDI_INST OR opcode = LDD_INST OR opcode = DEC_INST OR opcode = NEG_INST OR opcode = SUB_INST OR opcode = SUBI_INST OR opcode = NOT_INST OR opcode = AND_INST OR opcode = OR_INST OR opcode = XOR_INST ELSE
				'0';

			write_back_register_write2 <=
				'1' WHEN opcode = SWAP_INST ELSE
				'0';

			write_back_register_write_address_1 <=
				'1' WHEN opcode = SWAP_INST ELSE
				'0';

			outport_enable <=
				'1' WHEN opcode = OUT_INST ELSE
				'0';
		END IF;
	END PROCESS;

END arch_controller;