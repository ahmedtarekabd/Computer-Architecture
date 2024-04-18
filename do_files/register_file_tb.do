# Close all other instances of ModelSim
quit -sim
# Compile and simulate the register_file_tb
vcom register_file*.vhd
vsim -t ns register_file_tb

## Set the radix to hexadecimal for the simulation
# radix hexadecimal
## Set the radix to hexadecimal for specific signals
# radix signal sim:/register_file_tb/input hexadecimal
# radix signal sim:/register_file_tb/output1 hexadecimal
# radix signal sim:/register_file_tb/output2 hexadecimal

# Add Waves
add wave -position insertpoint sim:/register_file_tb/*

# RUN Testbench
run             200 ns
