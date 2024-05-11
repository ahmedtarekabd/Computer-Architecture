LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY forwarding_unit_tb IS
END forwarding_unit_tb;

ARCHITECTURE behavior OF forwarding_unit_tb IS

    -- Component declaration for the unit under test (UUT)
    COMPONENT forwarding_unit
    PORT(
        src_address1_de : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        src_address2_de : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        dst_address_em : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        src_address1_em : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        src_address2_em : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        address1_mw : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        address2_mw : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_back_em : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        write_back_mw : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        memory_read_em : IN STD_LOGIC;
        -- memory_read_mw : IN STD_LOGIC;
        -- immediate_em : IN STD_LOGIC;
        -- immediate_mw : IN STD_LOGIC;
        opp1_ALU_MUX_SEL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        opp2_ALU_MUX_SEL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        load_use_hazard : OUT STD_LOGIC
    );
    END COMPONENT;

   -- Inputs
   signal src_address1_de : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0');
   signal src_address2_de : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0');
   signal dst_address_em : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0');
   signal src_address1_em : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0');
   signal src_address2_em : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0');
   signal address1_mw : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0');
   signal address2_mw : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0');
   signal write_back_em : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
   signal write_back_mw : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
   signal memory_read_em : STD_LOGIC := '0';
--    signal memory_read_mw : STD_LOGIC := '0';
--    signal immediate_em : STD_LOGIC := '0';
--    signal immediate_mw : STD_LOGIC := '0';

   -- Outputs
   signal opp1_ALU_MUX_SEL : STD_LOGIC_VECTOR(2 DOWNTO 0);
   signal opp2_ALU_MUX_SEL : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal load_use_hazard : STD_LOGIC;

BEGIN

   -- Instantiate the Unit Under Test (UUT)
   uut: forwarding_unit PORT MAP (
        src_address1_de => src_address1_de,
        src_address2_de => src_address2_de,
        dst_address_em => dst_address_em,
        src_address1_em => src_address1_em,
        src_address2_em => src_address2_em,
        address1_mw => address1_mw,
        address2_mw => address2_mw,
        write_back_em => write_back_em,
        write_back_mw => write_back_mw,
        memory_read_em => memory_read_em,
        -- -- memory_read_mw => memory_read_mw,
        -- -- immediate_em => immediate_em,
        -- -- immediate_mw => immediate_mw,
        opp1_ALU_MUX_SEL => opp1_ALU_MUX_SEL,
        opp2_ALU_MUX_SEL => opp2_ALU_MUX_SEL,
        load_use_hazard => load_use_hazard
   );

   -- Stimulus process
   stim_proc: process
   begin
      -- Test case 1: No forwarding needed because no register write enable
      src_address1_de <= "000";
      src_address2_de <= "001";
      dst_address_em <= "010";
      src_address1_em <= "100";
      src_address2_em <= "101";
      address1_mw <= "110";
      address2_mw <= "111";
      write_back_em <= "00";  -- No write back
      write_back_mw <= "00";  -- No write back
      memory_read_em <= '0';
    --   memory_read_mw <= '0';
    --   immediate_em <= '0';
    --   immediate_mw <= '0';
      wait for 10 ns;

      -- Test case 1.2: No forwarding needed because no matching addresses even tho write enable is set
        src_address1_de <= "000";
        src_address2_de <= "001";
        dst_address_em <= "010";
        src_address1_em <= "100";
        src_address2_em <= "101";
        address1_mw <= "011";
        address2_mw <= "010";
        write_back_em <= "01";  -- Write enable from Execute/Memory
        write_back_mw <= "01";  -- Write enable set for Memory/Writeback
        memory_read_em <= '0';
        -- memory_read_mw <= '0';
        -- immediate_em <= '0';
        -- immediate_mw <= '0';
        wait for 10 ns;

        -- same as 1.2 but with swap (enables = 11)
        -- Test case 1.3: No forwarding needed because no matching addresses even tho write enable is set
        src_address1_de <= "000";
        src_address2_de <= "001";
        dst_address_em <= "010";
        src_address1_em <= "100";
        src_address2_em <= "101";
        address1_mw <= "011";
        address2_mw <= "010";
        write_back_em <= "11";  -- Write enable from Execute/Memory
        write_back_mw <= "11";  -- Write enable set for Memory/Writeback
        memory_read_em <= '0';
        -- memory_read_mw <= '0';
        -- immediate_em <= '0';
        -- immediate_mw <= '0';
        wait for 10 ns;

      -- Test case 2: Forwarding from Execute/Memory to ALU (ALU to ALU forwarding)
      -- writes in data 1
      src_address1_de <= "010";
      src_address2_de <= "011";
      dst_address_em <= "010";
      src_address1_em <= "100";
      src_address2_em <= "101";
      address1_mw <= "110";
      address2_mw <= "111";
      write_back_em <= "01";  -- Write back from Execute/Memory
      write_back_mw <= "00";  -- No write back
      memory_read_em <= '0';
    --   memory_read_mw <= '0';
    --   immediate_em <= '0';
    --   immediate_mw <= '0';
      wait for 10 ns;

      -- Test case 2.2: Forwarding from Execute/Memory to ALU (ALU to ALU forwarding)
      -- this time with data 2
      src_address1_de <= "010";
      src_address2_de <= "011";
      dst_address_em <= "011";
      src_address1_em <= "100";
      src_address2_em <= "101";
      address1_mw <= "110";
      address2_mw <= "111";
      write_back_em <= "01";  -- Write back from Execute/Memory
      write_back_mw <= "01";  -- Write enable set for Memory/Writeback, should ignore it
      memory_read_em <= '0';
    --   memory_read_mw <= '0';
    --   immediate_em <= '0';
    --   immediate_mw <= '0';
      wait for 10 ns;

      -- Test case 2.3: Swapping test from Execute/Memory to ALU (ALU to ALU forwarding)
      src_address1_de <= "010";
      src_address2_de <= "011";
      dst_address_em <= "111";
      src_address1_em <= "010";
      src_address2_em <= "011";
      address1_mw <= "110";
      address2_mw <= "101";
      write_back_em <= "11";  -- Write back from Execute/Memory "11" for swap
      write_back_mw <= "01";  -- Write enable set for Memory/Writeback, should ignore it
      memory_read_em <= '0';
    --   memory_read_mw <= '0';
    --   immediate_em <= '0';
    --   immediate_mw <= '0';
      wait for 10 ns;

    -- Test case 2.4: No swapping as enable is 01 test from Execute/Memory to ALU (ALU to ALU forwarding)
      src_address1_de <= "010";
      src_address2_de <= "011";
      dst_address_em <= "111";
      src_address1_em <= "010";
      src_address2_em <= "011";
      address1_mw <= "110";
      address2_mw <= "101";
      write_back_em <= "01";  -- Write back from Execute/Memory "01" for swap
      write_back_mw <= "01";  -- Write enable set for Memory/Writeback, should ignore it
      memory_read_em <= '0';
    --   memory_read_mw <= '0';
    --   immediate_em <= '0';
    --   immediate_mw <= '0';
      wait for 10 ns;


      -- Test case 3: Forwarding from Memory/Writeback to ALU
      -- in case of conflicting addresses, the data from execute/memory is forwarded
      -- as it has the advantage
      src_address1_de <= "010";
      src_address2_de <= "011";
      dst_address_em <= "010";
      src_address1_em <= "100";
      src_address2_em <= "101";
      address1_mw <= "010";  -- Forwarding data from Memory/Writeback to ALU
      address2_mw <= "111";
      write_back_em <= "01";  
      write_back_mw <= "01";  -- Write back from Memory/Writeback
      memory_read_em <= '0';
    --   memory_read_mw <= '0';
    --   immediate_em <= '0';
    --   immediate_mw <= '0';
      wait for 10 ns;

      -- Test case 3.2: Forwarding from Memory/Writeback to ALU
      -- should ignore the wb from execute/memory and take the data from memory/writeback
      src_address1_de <= "010";
      src_address2_de <= "011";
      dst_address_em <= "010";
      src_address1_em <= "100";
      src_address2_em <= "101";
      address1_mw <= "010";  
      address2_mw <= "111";
      write_back_em <= "00";  
      write_back_mw <= "01";  -- Write back from Memory/Writeback
      memory_read_em <= '0';
    --   memory_read_mw <= '0';
    --   immediate_em <= '0';
    --   immediate_mw <= '0';
      wait for 10 ns;

      -- Test case 3.3: Forwarding from Memory/Writeback to ALU
      -- should ignore the wb from execute/memory and take the data from memory/writeback
      -- same as the one before but with swapping
      src_address1_de <= "010";
      src_address2_de <= "011";
      dst_address_em <= "010";
      src_address1_em <= "100";
      src_address2_em <= "101";
      address1_mw <= "010";  
      address2_mw <= "111";
      write_back_em <= "00";  
      write_back_mw <= "11";  -- Write back from Memory/Writeback
      memory_read_em <= '0';
    --   memory_read_mw <= '0';
    --   immediate_em <= '0';
    --   immediate_mw <= '0';
      wait for 10 ns;

      -- Test case 4: load use hazard
      src_address1_de <= "010";
      src_address2_de <= "011";
      dst_address_em <= "010";
      src_address1_em <= "100";
      src_address2_em <= "101";
      address1_mw <= "010";  
      address2_mw <= "111";
      write_back_em <= "01";  
      write_back_mw <= "00";  
      memory_read_em <= '1';
    --   memory_read_mw <= '0';
      wait for 10 ns;

      -- Test case 4: load use hazard
      src_address1_de <= "010";
      src_address2_de <= "011";
      dst_address_em <= "010";
      src_address1_em <= "100";
      src_address2_em <= "101";
      address1_mw <= "010";  
      address2_mw <= "111";
      write_back_em <= "01";  
      write_back_mw <= "00";  
      memory_read_em <= '0';
    --   memory_read_mw <= '1';
      wait for 10 ns;

      wait;
   end process;

END;
