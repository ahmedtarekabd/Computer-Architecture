# Close all other instances of ModelSim
quit -sim
# Compile and simulate the processor_tb
vcom processor_tb.vhd
vsim -t ns processor_tb

mem load -i {./lab.mem} /processor_tb/processor1/inst_cache/instruction
mem load -i {./aregs.mem} /processor_tb/processor1/register_file/ram0/registers_array

radix signal sim:/processor_tb/processor1/program_counter/pc_out unsigned
radix signal sim:/processor_tb/processor1/fetch_decode/q binary

# Add Waves
add wave -position insertpoint  \
sim:/processor_tb/clk \
sim:/processor_tb/reset

# PC
add wave -position insertpoint  \
sim:/processor_tb/processor1/program_counter/pc_out
#sim:/processor_tb/processor1/program_counter/counter

# Instruction Cache
# add wave -position insertpoint  \
# sim:/processor_tb/processor1/inst_cache/address_in \
# sim:/processor_tb/processor1/inst_cache/data_out

# fetch_decode
add wave -position insertpoint \
sim:/processor_tb/processor1/fetch_decode/d \
sim:/processor_tb/processor1/fetch_decode/q

# Controller
add wave -position insertpoint \
sim:/processor_tb/processor1/ctrl/operation

# Register File
add wave -position insertpoint \
sim:/processor_tb/processor1/register_file/input \
sim:/processor_tb/processor1/register_file/output1 \
sim:/processor_tb/processor1/register_file/output2
# sim:/processor_tb/processor1/register_file/address_read1 \
# sim:/processor_tb/processor1/register_file/address_read2 \
# sim:/processor_tb/processor1/register_file/address_write \

# decode_execute
add wave -position insertpoint \
sim:/processor_tb/processor1/decode_execute/d \
sim:/processor_tb/processor1/decode_execute/q

# ALU
add wave -position insertpoint \
sim:/processor_tb/processor1/alu0/A \
sim:/processor_tb/processor1/alu0/B \
sim:/processor_tb/processor1/alu0/Sel \
sim:/processor_tb/processor1/alu0/F

# write_back
add wave -position insertpoint \
sim:/processor_tb/processor1/write_back/d \
sim:/processor_tb/processor1/write_back/q



# RUN Testbench
run             10 ns
