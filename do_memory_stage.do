# ModelSim do file
# Close all other instances of ModelSim
quit -sim

# Compile the VHDL files
vcom memory_stage.vhd
vcom memory_stage_tb.vhd

# Load the simulation
vsim -gui work.memory_stage_tb

# Add waves
add wave -position insertpoint sim:/memory_stage_tb/uut/*

# doesn't run to see the results manually