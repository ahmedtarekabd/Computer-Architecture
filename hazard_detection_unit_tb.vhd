LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hazard_detection_unit_tb IS
END hazard_detection_unit_tb;

ARCHITECTURE behavior OF hazard_detection_unit_tb IS

   -- Component Declaration for the Unit Under Test (UUT)
   COMPONENT hazard_detection_unit
      PORT (
         src_address1_fd : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         src_address2_fd : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         dst_address_de : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         write_back_1_de : IN STD_LOGIC;
         memory_read_de : IN STD_LOGIC;
         reg_read_controller : IN STD_LOGIC;
         PC_enable : OUT STD_LOGIC;
         enable_fd : OUT STD_LOGIC;
         reset_de : OUT STD_LOGIC
      );
   END COMPONENT;

   --Inputs
   SIGNAL src_address1_fd : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
   SIGNAL src_address2_fd : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
   SIGNAL dst_address_de : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
   SIGNAL write_back_1_de : STD_LOGIC := '0';
   SIGNAL memory_read_de : STD_LOGIC := '0';
   SIGNAL reg_read_controller : STD_LOGIC := '0';

   --Outputs
   SIGNAL PC_enable : STD_LOGIC;
   SIGNAL enable_fd : STD_LOGIC;
   SIGNAL reset_de : STD_LOGIC;

BEGIN

   -- Instantiate the Unit Under Test (UUT)
   uut : hazard_detection_unit PORT MAP(
      src_address1_fd => src_address1_fd,
      src_address2_fd => src_address2_fd,
      dst_address_de => dst_address_de,
      write_back_1_de => write_back_1_de,
      memory_read_de => memory_read_de,
      reg_read_controller => reg_read_controller,
      PC_enable => PC_enable,
      enable_fd => enable_fd,
      reset_de => reset_de
   );

   -- Stimulus process
   stim_proc : PROCESS
   BEGIN
      -- hold reset state
      WAIT FOR 10 ns;

      -- Test case 1
      src_address1_fd <= "001";
      src_address2_fd <= "010";
      dst_address_de <= "001";
      write_back_1_de <= '1';
      memory_read_de <= '1';
      reg_read_controller <= '1';
      WAIT FOR 20 ns;

      -- Test case 2
      src_address1_fd <= "011";
      src_address2_fd <= "100";
      dst_address_de <= "101";
      write_back_1_de <= '1';
      memory_read_de <= '1';
      reg_read_controller <= '1';
      WAIT FOR 20 ns;

      -- Test case 3
      src_address1_fd <= "111";
      src_address2_fd <= "000";
      dst_address_de <= "111";
      write_back_1_de <= '1';
      memory_read_de <= '0';
      reg_read_controller <= '1';
      WAIT FOR 20 ns;

      -- Test case 4
      src_address1_fd <= "101";
      src_address2_fd <= "010";
      dst_address_de <= "010";
      write_back_1_de <= '1';
      memory_read_de <= '1';
      reg_read_controller <= '1';
      WAIT FOR 20 ns;

      -- Test case 5
      src_address1_fd <= "010";
      src_address2_fd <= "001";
      dst_address_de <= "010";
      write_back_1_de <= '0';
      memory_read_de <= '1';
      reg_read_controller <= '1';
      WAIT FOR 20 ns;

      -- Test case 6
      src_address1_fd <= "111";
      src_address2_fd <= "111";
      dst_address_de <= "111";
      write_back_1_de <= '1';
      memory_read_de <= '1';
      reg_read_controller <= '0';
      WAIT FOR 20 ns;

      -- Test case 7
      src_address1_fd <= "000";
      src_address2_fd <= "000";
      dst_address_de <= "111";
      write_back_1_de <= '0';
      memory_read_de <= '0';
      reg_read_controller <= '0';
      WAIT FOR 20 ns;

      -- Test case 8
      src_address1_fd <= "011";
      src_address2_fd <= "101";
      dst_address_de <= "010";
      write_back_1_de <= '1';
      memory_read_de <= '1';
      reg_read_controller <= '1';
      WAIT FOR 20 ns;

      -- Test case 9
      src_address1_fd <= "100";
      src_address2_fd <= "010";
      dst_address_de <= "001";
      write_back_1_de <= '0';
      memory_read_de <= '1';
      reg_read_controller <= '0';
      WAIT FOR 20 ns;

      -- Test case 10
      src_address1_fd <= "110";
      src_address2_fd <= "011";
      dst_address_de <= "100";
      write_back_1_de <= '1';
      memory_read_de <= '0';
      reg_read_controller <= '1';
      WAIT FOR 20 ns;

      WAIT;
   END PROCESS;

END;