LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memory_stage_tb IS
END memory_stage_tb;

ARCHITECTURE behavior OF memory_stage_tb IS 

     COMPONENT memory_stage
     PORT(
            clk : IN  std_logic;
            mem_control_signals_in : IN  std_logic_vector (9 downto 0);
            wb_control_signals_in : IN  std_logic_vector (5 downto 0);
            RST : IN  std_logic;
            MW_enable : IN  std_logic;
            MW_flush_from_exception : IN  std_logic;
            PC_in : IN  std_logic_vector (31 downto 0);
            PC_plus_one_in : IN  std_logic_vector (31 downto 0);
            imm_enable_in : IN  std_logic;
            destination_address_in : IN  std_logic_vector (2 downto 0);
            write_address1_in : IN  std_logic_vector (2 downto 0);
            write_address2_in : IN  std_logic_vector (2 downto 0);
            read_data1_in : IN  std_logic_vector (31 downto 0);
            read_data2_in : IN  std_logic_vector (31 downto 0);
            ALU_result_in : IN  std_logic_vector (31 downto 0);
            CCR_in : IN  std_logic_vector (3 downto 0);
            wb_control_signals_out : OUT  std_logic_vector (5 downto 0);
            destination_address_out : OUT  std_logic_vector (2 downto 0);
            write_address1_out : OUT  std_logic_vector (2 downto 0);
            write_address2_out : OUT  std_logic_vector (2 downto 0);
            read_data1_out : OUT  std_logic_vector (31 downto 0);
            read_data2_out : OUT  std_logic_vector (31 downto 0);
            ALU_result_out : OUT  std_logic_vector (31 downto 0);
            mem_read_data : OUT  std_logic_vector (31 downto 0);
            PC_out_to_exception : OUT  std_logic_vector (31 downto 0);
            protected_address_access_to_exception : OUT  std_logic
          );
     END COMPONENT;

    --Inputs
    signal clk : std_logic := '0';
    signal mem_control_signals_in : std_logic_vector (9 downto 0) := (others => '0');
    signal wb_control_signals_in : std_logic_vector (5 downto 0) := (others => '0');
    signal RST : std_logic := '0';
    signal MW_enable : std_logic := '0';
    signal MW_flush_from_exception : std_logic := '0';
    signal PC_in : std_logic_vector (31 downto 0) := (others => '0');
    signal PC_plus_one_in : std_logic_vector (31 downto 0) := (others => '0');
    signal imm_enable_in : std_logic := '0';
    signal destination_address_in : std_logic_vector (2 downto 0) := (others => '0');
    signal write_address1_in : std_logic_vector (2 downto 0) := (others => '0');
    signal write_address2_in : std_logic_vector (2 downto 0) := (others => '0');
    signal read_data1_in : std_logic_vector (31 downto 0) := (others => '0');
    signal read_data2_in : std_logic_vector (31 downto 0) := (others => '0');
    signal ALU_result_in : std_logic_vector (31 downto 0) := (others => '0');
    signal CCR_in : std_logic_vector (3 downto 0) := (others => '0');

     --Outputs
    signal wb_control_signals_out : std_logic_vector (5 downto 0);
    signal destination_address_out : std_logic_vector (2 downto 0);
    signal write_address1_out : std_logic_vector (2 downto 0);
    signal write_address2_out : std_logic_vector (2 downto 0);
    signal read_data1_out : std_logic_vector (31 downto 0);
    signal read_data2_out : std_logic_vector (31 downto 0);
    signal ALU_result_out : std_logic_vector (31 downto 0);
    signal mem_read_data : std_logic_vector (31 downto 0);
    signal PC_out_to_exception : std_logic_vector (31 downto 0);
    signal protected_address_access_to_exception : std_logic;

    -- Clock period definitions
    constant clk_period : time := 10 ns;

BEGIN

     -- Instantiate the Unit Under Test (UUT)
    uut: memory_stage PORT MAP (
             clk => clk,
             mem_control_signals_in => mem_control_signals_in,
             wb_control_signals_in => wb_control_signals_in,
             RST => RST,
             MW_enable => MW_enable,
             MW_flush_from_exception => MW_flush_from_exception,
             PC_in => PC_in,
             PC_plus_one_in => PC_plus_one_in,
             imm_enable_in => imm_enable_in,
             destination_address_in => destination_address_in,
             write_address1_in => write_address1_in,
             write_address2_in => write_address2_in,
             read_data1_in => read_data1_in,
             read_data2_in => read_data2_in,
             ALU_result_in => ALU_result_in,
             CCR_in => CCR_in,
             wb_control_signals_out => wb_control_signals_out,
             destination_address_out => destination_address_out,
             write_address1_out => write_address1_out,
             write_address2_out => write_address2_out,
             read_data1_out => read_data1_out,
             read_data2_out => read_data2_out,
             ALU_result_out => ALU_result_out,
             mem_read_data => mem_read_data,
             PC_out_to_exception => PC_out_to_exception,
             protected_address_access_to_exception => protected_address_access_to_exception
          );

    -- Clock process definitions
    clk_process :process
    begin
          clk <= '0';
          wait for clk_period/2;
          clk <= '1';
          wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
        
        
        RST <= '0';
        mem_control_signals_in <= "1100000000";
        wb_control_signals_in <= "000000";
        MW_enable <= '1';
        MW_flush_from_exception <= '0';
        PC_in <= (OTHERS => '0');
        PC_plus_one_in <= (OTHERS => '0');
        imm_enable_in <= '0';
        destination_address_in <= (OTHERS => '0');
        write_address1_in <= (OTHERS => '0');
        write_address2_in <= (OTHERS => '0');
        read_data1_in <= (OTHERS => '0');
        read_data2_in <= "11111111111111111111111111111111";
        ALU_result_in <= (others => '0') ;
        CCR_in <= (OTHERS => '0');
        WAIT FOR clk_period;
        

        wait;
    end process;

END;



