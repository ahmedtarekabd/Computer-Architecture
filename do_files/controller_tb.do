# Close all other instances of ModelSim
quit -sim
# Compile and simulate the controller_tb
vcom controller.vhd
vcom controller_tb.vhd
vsim -t ns controller_tb

## Set the radix to hexadecimal for the simulation
# radix hexadecimal
## Set the radix to hexadecimal for specific signals
# radix signal sim:/controller_tb/input hexadecimal
# radix signal sim:/controller_tb/output1 hexadecimal
# radix signal sim:/controller_tb/output2 hexadecimal

# Add Waves
add wave -position insertpoint sim:/controller_tb/*

# RUN Testbench
run             900 ns
