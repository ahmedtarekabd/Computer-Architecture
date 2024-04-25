LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY controller IS
	PORT (
		clk : IN STD_LOGIC;

		-- 6-bit opcode
		opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);

		-- fetch signals
		fetch_pc_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

		-- decode signals
		decode_reg_read : OUT STD_LOGIC;
		decode_branch : OUT STD_LOGIC; -- later
		decode_sign_extend : OUT STD_LOGIC;

		-- execute signals
		alu_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		alu_src2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		alu_register_write : OUT STD_LOGIC;

		-- memory signals
		memory_write : OUT STD_LOGIC;
		memory_read : OUT STD_LOGIC;
		memory_stack_pointer : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		memory_address : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- alu | sp | 0 (reset) | 2 (interrupt)
		memory_write_data : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

		-- write back signals
		write_back_register_write1 : OUT STD_LOGIC;
		write_back_register_write2 : OUT STD_LOGIC;
		write_back_register_write_data_1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		write_back_register_write_address_1 : OUT STD_LOGIC -- Rdst | Rsrc1
	);
END ENTITY controller;

ARCHITECTURE arch_controller OF controller IS

BEGIN
	PROCESS (clk) IS
	BEGIN
		IF falling_edge(clk) THEN

			CASE opcode IS
				WHEN "000000" =>

				WHEN "000001" => -- not
					-- m3ana
					fetch_pc_sel <= "000";
					decode_reg_read <= '1';
					decode_branch <= '0';
					decode_sign_extend <= 'X';
					alu_sel <= "111";
					alu_src2 <= "XX";
					alu_register_write <= '1';
					memory_write <= '0';
					memory_read <= '0';
					memory_stack_pointer <= "00";
					memory_address <= "XX";
					memory_write_data <= "XX";
					write_back_register_write_data_1 <= "00";
					write_back_register_write1 <= '1';
					write_back_register_write2 <= '0';
					write_back_register_write_address_1 <= '0';
				WHEN "000010" =>
				WHEN "000011" =>
				WHEN "000100" => -- dec
					-- m3ana
					fetch_pc_sel <= "000";
					decode_reg_read <= '1';
					decode_branch <= '0';
					decode_sign_extend <= 'X';
					alu_sel <= "010";
					alu_src2 <= "10";
					alu_register_write <= '1';
					memory_write <= '0';
					memory_read <= '0';
					memory_stack_pointer <= "00";
					memory_address <= "XX";
					memory_write_data <= "XX";
					write_back_register_write_data_1 <= "00";
					write_back_register_write1 <= '1';
					write_back_register_write2 <= '0';
					write_back_register_write_address_1 <= '0';

				WHEN "000101" =>
				WHEN "000110" =>
				WHEN "000111" =>
				WHEN "001000" =>
					-- Continue with the rest of the cases up to "011111"
				WHEN "010000" => -- mov
					fetch_pc_sel <= "000";
					decode_reg_read <= '1';
					decode_branch <= '0';
					decode_sign_extend <= 'X';
					alu_sel <= "011";
					alu_src2 <= "00";
					alu_register_write <= '1';
					memory_write <= '0';
					memory_read <= '0';
					memory_stack_pointer <= "00";
					memory_address <= "XX";
					memory_write_data <= "XX";
					write_back_register_write_data_1 <= "00";
					write_back_register_write1 <= '1';
					write_back_register_write2 <= '0';
					write_back_register_write_address_1 <= '0';
				WHEN "011111" =>
				WHEN "100100" => -- ldm
					fetch_pc_sel <= "000";
					decode_reg_read <= '1';
					decode_branch <= '0';
					decode_sign_extend <= '1';
					alu_sel <= "011";
					alu_src2 <= "01";
					alu_register_write <= '1';
					memory_write <= '0';
					memory_read <= '0';
					memory_stack_pointer <= "00";
					memory_address <= "XX";
					memory_write_data <= "XX";
					write_back_register_write_data_1 <= "00";
					write_back_register_write1 <= '1';
					write_back_register_write2 <= '0';
					write_back_register_write_address_1 <= '0';
				WHEN "010101" => -- or
					-- m3ana
					fetch_pc_sel <= "000";
					decode_reg_read <= '1';
					decode_branch <= '0';
					decode_sign_extend <= 'X';
					alu_sel <= "101";
					alu_src2 <= "00";
					alu_register_write <= '1';
					memory_write <= '0';
					memory_read <= '0';
					memory_stack_pointer <= "00";
					memory_address <= "XX";
					memory_write_data <= "XX";
					write_back_register_write_data_1 <= "00";
					write_back_register_write1 <= '1';
					write_back_register_write2 <= '0';
					write_back_register_write_address_1 <= '0';

				WHEN "010111" => -- cmp
					-- m3ana
					fetch_pc_sel <= "000";
					decode_reg_read <= '1';
					decode_branch <= '0';
					decode_sign_extend <= 'X';
					alu_sel <= "010";
					alu_src2 <= "00";
					alu_register_write <= '0';
					memory_write <= '0';
					memory_read <= '0';
					memory_stack_pointer <= "00";
					memory_address <= "XX";
					memory_write_data <= "XX";
					write_back_register_write_data_1 <= "XX";
					write_back_register_write1 <= '0';
					write_back_register_write2 <= '0';
					write_back_register_write_address_1 <= '0';

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