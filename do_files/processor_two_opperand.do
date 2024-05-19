# Close all other instances of ModelSim
quit -sim
# Compile and simulate the processor_phase3_tb
vcom -2008 *.vhd
vsim -t ns processor_phase3_tb

mem load -i {./testcases_bin/data_memory.mem} /processor_phase3_tb/dut/fetch_inst/inst_cache/instruction
mem load -i {./aregs_two_opperand.mem} /processor_phase3_tb/dut/decode_inst/register_file_instance/registers_array
# //! Data Memory will be initialized with 0s

# radix signal sim:/processor_phase3_tb/dut/program_counter/pc_out unsigned
# radix signal sim:/processor_phase3_tb/dut/fetch_decode/q binary

# Add Waves
add wave -position insertpoint  \
sim:/processor_phase3_tb/*

# Fetch
add wave -position insertpoint  \
sim:/processor_phase3_tb/dut/fetch_inst/*

# Decode
add wave -position insertpoint  \
sim:/processor_phase3_tb/dut/decode_inst/*

# Execute
add wave -position insertpoint \
sim:/processor_phase3_tb/dut/excute_inst/*

# Memory
add wave -position insertpoint  \
sim:/processor_phase3_tb/dut/mem_inst/*

#WB
add wave -position insertpoint \
sim:/processor_phase3_tb/dut/write_back_inst/*
# RUN Testbench
run             10 ns
run             10 ns
force -freeze sim:/processor_phase3_tb/in_port_from_processor 00000000000000000000000000000101 0
run             10 ns
force -freeze sim:/processor_phase3_tb/in_port_from_processor 00000000000000000000000000001101 0
run             10 ns
force -freeze sim:/processor_phase3_tb/in_port_from_processor 11111111111111111111111111111111 0
run             10 ns
force -freeze sim:/processor_phase3_tb/in_port_from_processor 11111111111111111111001100100000 0