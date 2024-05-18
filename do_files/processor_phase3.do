# Close all other instances of ModelSim
quit -sim
# Compile and simulate the processor_tb
vcom -2008 processor_tb.vhd
vsim -t ns processor_tb

mem load -i {./instruction_cache_phase3.mem} /processor_tb/processor1/fetch_inst/inst_cache/instruction
mem load -i {./register_file.mem} /processor_tb/processor1/decode_inst/register_file_instance/registers_array

# radix signal sim:/processor_tb/processor1/program_counter/pc_out unsigned
# radix signal sim:/processor_tb/processor1/fetch_decode/q binary

# Add Waves
add wave -position end  sim:/processor_tb/processor1/fetch_inst/selected_instruction_out
add wave -position end  sim:/processor_tb/processor1/execute_inst/alu_component/zero_flag
add wave -position end  sim:/processor_tb/processor1/execute_inst/alu_component/overflow_flag
add wave -position end  sim:/processor_tb/processor1/execute_inst/alu_component/carry_flag
add wave -position end  sim:/processor_tb/processor1/execute_inst/alu_component/negative_flag
add wave -position end  sim:/processor_tb/processor1/execute_inst/alu_component/A
add wave -position end  sim:/processor_tb/processor1/execute_inst/alu_component/B
add wave -position end  sim:/processor_tb/processor1/execute_inst/alu_component/opcode
add wave -position end  sim:/processor_tb/processor1/execute_inst/alu_component/F

# RUN Testbench
run             10 ns
