# Close all other instances of ModelSim
quit -sim
# Compile and simulate the processor
vcom processor.vhd
vsim -t ns processor

## Set the radix to hexadecimal for the simulation
#radix hexadecimal
## Set the radix to hexadecimal for specific signals
radix signal sim:/processor/input hexadecimal
radix signal sim:/processor/output1 hexadecimal
radix signal sim:/processor/output2 hexadecimal

# Add Waves
add wave -position insertpoint  \
sim:/processor/clk \
sim:/processor/reset \
sim:/processor/enable \
sim:/processor/register_read_sel1 \
sim:/processor/register_read_sel2 \
sim:/processor/register_write_sel \
sim:/processor/input \
sim:/processor/output1 \
sim:/processor/output2

# RUN Testbench
run             100 ns
