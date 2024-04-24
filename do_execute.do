# ModelSim do file
# Close all other instances of ModelSim
quit -sim

# Compile the VHDL files
vcom execute.vhd
vcom execute_tb.vhd

# Load the simulation
vsim -gui work.execute_tb

# Add waves
add wave -position insertpoint sim:/execute_tb/uut/*

# RUN Testbench
run             1000 ns
