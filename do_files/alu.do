# ModelSim do file
# Close all other instances of ModelSim
quit -sim

# Compile the VHDL files
vcom alu.vhd
vcom alu_tb.vhd

# Load the simulation
vsim -gui work.alu_tb

# Add waves
add wave -position insertpoint sim:/alu_tb/uut/*

# RUN Testbench
run             1000 ns
