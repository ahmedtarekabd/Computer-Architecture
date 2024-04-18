# Close all other instances of ModelSim
quit -sim
# Compile and simulate the SignExtend_tb
vcom SignExtend_tb.vhd
vsim -t ns SignExtend_tb

## Set the radix to hexadecimal for the simulation
# radix hexadecimal
## Set the radix to hexadecimal for specific signals
# radix signal sim:/SignExtend_tb/input hexadecimal
# radix signal sim:/SignExtend_tb/output1 hexadecimal
# radix signal sim:/SignExtend_tb/output2 hexadecimal

# Add Waves
add wave -position insertpoint sim:/SignExtend_tb/*

# RUN Testbench
run             500 ns
