# ModelSim do file
# Close all other instances of ModelSim
quit -sim

# Compile the VHDL files
vcom forwarding_unit.vhd
vcom forwarding_unit_tb.vhd

# Load the simulation
vsim -gui work.forwarding_unit_tb

# Add waves
add wave -position insertpoint sim:/forwarding_unit_tb/uut/*

# RUN Testbench
run -all
