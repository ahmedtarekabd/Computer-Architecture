# ModelSim do file
# Close all other instances of ModelSim
quit -sim

# Compile the VHDL files
vcom write_back.vhd
vcom write_back_tb.vhd

# Load the simulation
vsim -gui work.write_back_tb

# Add waves
add wave -position insertpoint sim:/write_back_tb/uut/*

# RUN Testbench
run             1000 ns
