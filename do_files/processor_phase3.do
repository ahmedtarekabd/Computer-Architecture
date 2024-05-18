# ModelSim do file
# Close all other instances of ModelSim
quit -sim

# Compile the VHDL files
vcom processor_phase3.vhd


# Load the simulation
vsim -gui work.processor_phase3

# Add waves

add wave -position insertpoint sim:/processor_phase3/*

# RUN Testbench
run             1000 ns
