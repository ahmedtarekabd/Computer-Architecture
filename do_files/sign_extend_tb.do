# Close all other instances of ModelSim
quit -sim
# Compile and simulate the sign_extend_tb
vcom sign_extend_tb.vhd
vsim -t ns sign_extend_tb

## Set the radix to hexadecimal for the simulation
# radix hexadecimal
## Set the radix to hexadecimal for specific signals
# radix signal sim:/sign_extend_tb/input hexadecimal
# radix signal sim:/sign_extend_tb/output1 hexadecimal
# radix signal sim:/sign_extend_tb/output2 hexadecimal

# Add Waves
add wave -position insertpoint sim:/sign_extend_tb/*

# RUN Testbench
run             900 ns
