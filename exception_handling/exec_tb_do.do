# Close all other instances of ModelSim
quit -sim
# Compile and simulate the fetch_tb
vcom exception_handling_unit.vhd
vcom exception_handling_tb.vhd
vsim -t ns exception_handling_tb


# Add Waves
add wave  sim:/exception_handling_tb/*


# RUN Testbench
run             400 ns
