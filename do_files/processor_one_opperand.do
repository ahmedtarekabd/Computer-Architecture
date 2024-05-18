# Close all other instances of ModelSim
quit -sim
# Compile and simulate the processor_phase3_tb
vcom -2008 *.vhd
vsim -t ns processor_phase3_tb

mem load -i {./testcases_bin/data_memory.mem} /processor_phase3_tb/dut/fetch_inst/inst_cache/instruction
mem load -i {./aregs_one_opperand.mem} /processor_phase3_tb/dut/decode_inst/register_file_instance/registers_array
# //! Data Memory will be initialized with 0s

# radix signal sim:/processor_phase3_tb/dut/program_counter/pc_out unsigned
# radix signal sim:/processor_phase3_tb/dut/fetch_decode/q binary

# Add Waves
add wave -position insertpoint  \
sim:/processor_phase3_tb/*

# Execute
add wave -position insertpoint \
sim:/processor_phase3_tb/dut/excute_inst/overflow_flag_out_exception_handling \
sim:/processor_phase3_tb/dut/excute_inst/zero_flag_out_controller \
sim:/processor_phase3_tb/dut/excute_inst/flag_register_out

#sim:/processor_phase3_tb/dut/excute_inst/forwarding_mux_selector_op2 \
#sim:/processor_phase3_tb/dut/excute_inst/destination_address \
#sim:/processor_phase3_tb/dut/excute_inst/address_read1_in \
#sim:/processor_phase3_tb/dut/excute_inst/ALU_result_before_EM \
#sim:/processor_phase3_tb/dut/excute_inst/data1_in \
#sim:/processor_phase3_tb/dut/excute_inst/alu_selectors \
#sim:/processor_phase3_tb/dut/excute_inst/forwarding_mux_selector_op1 \
#sim:/processor_phase3_tb/dut/excute_inst/alu_out_from_execute \
#sim:/processor_phase3_tb/dut/excute_inst/op1_mux_out \


# RUN Testbench
run             10 ns
