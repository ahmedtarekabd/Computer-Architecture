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
sim:/processor_phase3_tb/dut/decode_inst/*

# RUN Testbench
run             10 ns
