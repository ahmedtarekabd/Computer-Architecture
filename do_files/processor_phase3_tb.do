# Close all other instances of ModelSim
quit -sim
# Compile and simulate the processor_phase3_tb
vcom -2008 *.vhd
vsim -t ns processor_phase3_tb

mem load -i {./testcases_bin/data_memory.mem} /processor_phase3_tb/dut/fetch_inst/inst_cache/instruction
mem load -i {./aregs.mem} /processor_phase3_tb/dut/decode_inst/register_file_instance/registers_array
# //! Data Memory will be initialized with 0s

# radix signal sim:/processor_phase3_tb/dut/program_counter/pc_out unsigned
# radix signal sim:/processor_phase3_tb/dut/fetch_decode/q binary

# Add Waves
add wave -position insertpoint  \
sim:/processor_phase3_tb/*

# Fetch
add wave -position insertpoint  \
sim:/processor_phase3_tb/dut/fetch_inst/pc_mux1_selector \
sim:/processor_phase3_tb/dut/fetch_inst/read_data_from_memory \
sim:/processor_phase3_tb/dut/fetch_inst/FD_reg/q \
sim:/processor_phase3_tb/dut/fetch_inst/instruction_out_from_instr_cache_to_pc \
sim:/processor_phase3_tb/dut/fetch_inst/selected_immediate_out \
sim:/processor_phase3_tb/dut/fetch_inst/opcode \
sim:/processor_phase3_tb/dut/fetch_inst/Rsrc1 \
sim:/processor_phase3_tb/dut/fetch_inst/Rsrc2 \
sim:/processor_phase3_tb/dut/fetch_inst/Rdest \
sim:/processor_phase3_tb/dut/fetch_inst/imm_flag \
sim:/processor_phase3_tb/dut/fetch_inst/in_port_out \
sim:/processor_phase3_tb/dut/fetch_inst/propagated_pc \
sim:/processor_phase3_tb/dut/fetch_inst/propagated_pc_plus_one \
sim:/processor_phase3_tb/dut/fetch_inst/pc_instruction_address 

# Decode
add wave -position insertpoint  \
sim:/processor_phase3_tb/dut/decode_inst/interrupt_signal \
sim:/processor_phase3_tb/dut/decode_inst/forwarded_alu_execute \
sim:/processor_phase3_tb/dut/decode_inst/forwarded_data1_mw \
sim:/processor_phase3_tb/dut/decode_inst/forwarded_data2_mw \
sim:/processor_phase3_tb/dut/decode_inst/forwarded_data1_em \
sim:/processor_phase3_tb/dut/decode_inst/forwarded_data2_em \
sim:/processor_phase3_tb/dut/decode_inst/branching_op_mux_selector \
sim:/processor_phase3_tb/dut/decode_inst/branching_or_normal_mux_selector \
sim:/processor_phase3_tb/dut/decode_inst/execute_control_signals \
sim:/processor_phase3_tb/dut/decode_inst/memory_control_signals \
sim:/processor_phase3_tb/dut/decode_inst/wb_control_signals \
sim:/processor_phase3_tb/dut/decode_inst/immediate_out \
sim:/processor_phase3_tb/dut/decode_inst/propagated_Rsrc1 \
sim:/processor_phase3_tb/dut/decode_inst/propagated_Rsrc2 \
sim:/processor_phase3_tb/dut/decode_inst/propagated_Rdest \
sim:/processor_phase3_tb/dut/decode_inst/propagated_read_data1 \
sim:/processor_phase3_tb/dut/decode_inst/read_data1_in \
sim:/processor_phase3_tb/dut/decode_inst/decode_reg_read \
sim:/processor_phase3_tb/dut/decode_inst/Rsrc1 \
sim:/processor_phase3_tb/dut/decode_inst/Rsrc2 \
sim:/processor_phase3_tb/dut/decode_inst/Rdest
add wave -position end sim:/processor_phase3_tb/dut/decode_inst/register_file_instance/*

#sim:/processor_phase3_tb/dut/decode_inst/decode_execute_flush \
#sim:/processor_phase3_tb/dut/decode_inst/branch_prediction_flush \
#sim:/processor_phase3_tb/dut/decode_inst/exception_handling_flush \
#sim:/processor_phase3_tb/dut/decode_inst/hazard_detection_flush \
#sim:/processor_phase3_tb/dut/decode_inst/immediate_stall \

# Execute
add wave -position insertpoint \
sim:/processor_phase3_tb/dut/excute_inst/destination_address \
sim:/processor_phase3_tb/dut/excute_inst/address_read1_in \
sim:/processor_phase3_tb/dut/excute_inst/ALU_result_before_EM \
sim:/processor_phase3_tb/dut/excute_inst/data1_in \
sim:/processor_phase3_tb/dut/excute_inst/alu_selectors \
sim:/processor_phase3_tb/dut/excute_inst/forwarding_mux_selector_op1 \
sim:/processor_phase3_tb/dut/excute_inst/forwarding_mux_selector_op2 \
sim:/processor_phase3_tb/dut/excute_inst/overflow_flag_out_exception_handling \
sim:/processor_phase3_tb/dut/excute_inst/zero_flag_out_controller \
sim:/processor_phase3_tb/dut/excute_inst/flag_register_out
#sim:/processor_phase3_tb/dut/excute_inst/alu_out_from_execute \
sim:/processor_phase3_tb/dut/excute_inst/op1_mux_out \


# Memory
add wave -position insertpoint  \
sim:/processor_phase3_tb/dut/mem_inst/mem_control_signals_in \
sim:/processor_phase3_tb/dut/mem_inst/PC_in \
sim:/processor_phase3_tb/dut/mem_inst/PC_plus_one_in \
sim:/processor_phase3_tb/dut/mem_inst/destination_address_in \
sim:/processor_phase3_tb/dut/mem_inst/write_address1_in \
sim:/processor_phase3_tb/dut/mem_inst/write_address2_in \
sim:/processor_phase3_tb/dut/mem_inst/read_data1_in \
sim:/processor_phase3_tb/dut/mem_inst/read_data2_in \
sim:/processor_phase3_tb/dut/mem_inst/ALU_result_in \
sim:/processor_phase3_tb/dut/mem_inst/CCR_in \
sim:/processor_phase3_tb/dut/mem_inst/mem_read_data \
sim:/processor_phase3_tb/dut/mem_inst/PC_out_to_exception \
sim:/processor_phase3_tb/dut/mem_inst/protected_address_access_to_exception 

#WB
add wave -position insertpoint \
sim:/processor_phase3_tb/dut/write_back_inst/destination_address_in \
sim:/processor_phase3_tb/dut/write_back_inst/ALU_result 



# RUN Testbench
run             10 ns
