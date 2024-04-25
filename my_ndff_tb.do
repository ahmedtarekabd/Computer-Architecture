# ModelSim do file
# Close all other instances of ModelSim
quit -sim

# Compile the VHDL files
vcom my_DFF.vhd 
vcom my_nDFF.vhd

# Load the simulation
vsim -gui work.tb_my_ndff

# Add waves
add wave -position end  sim:/tb_my_ndff/*

#this do file doesn't run so i can see every change
run 1000 ns