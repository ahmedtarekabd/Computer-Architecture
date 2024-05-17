# ModelSim do file
# Close all other instances of ModelSim
quit -sim

# Compile the VHDL files
vcom memory.vhd
vcom memory_tb.vhd

# Load the simulation
vsim -gui work.memory_tb

# Add waves
add wave -position end  sim:/memory_tb/clk
add wave -position end  sim:/memory_tb/address
add wave -position end  sim:/memory_tb/write_enable
add wave -position end  sim:/memory_tb/write_data
add wave -position end  sim:/memory_tb/read_enable
add wave -position end  sim:/memory_tb/protect_signal
add wave -position end  sim:/memory_tb/free_signal
add wave -position end  sim:/memory_tb/read_data
add wave -position end  sim:/memory_tb/clk_period

#this do file doesn't run so i can see every change