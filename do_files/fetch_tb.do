# Close all other instances of ModelSim
quit -sim
# Compile and simulate the fetch_tb
vcom fetch_tb.vhd
vsim -t ns fetch_tb

radix signal sim:/fetch_tb/uut/fetch_decode/q binary

# Add Waves
add wave -position insertpoint  \
sim:/fetch_tb/clk \
sim:/fetch_tb/reset

# PC
add wave -position insertpoint  \
sim:/fetch_tb/uut/program_counter/pc_out \
sim:/fetch_tb/uut/program_counter/counter

# Instruction Cache
add wave -position insertpoint  \
sim:/fetch_tb/uut/inst_cache/address_in \
sim:/fetch_tb/uut/inst_cache/data_out

# fetch_decode
add wave -position insertpoint \
sim:/fetch_tb/uut/fetch_decode/d \
sim:/fetch_tb/uut/fetch_decode/q

mem load -i {E:/College/3- Senior 1/Semester 2/Computer Architecture/Labs/Lab4/lab.mem} /fetch_tb/uut/inst_cache/instruction

# RUN Testbench
run             100 ns
