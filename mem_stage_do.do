# Close all other instances of ModelSim
quit -sim
# Compile and simulate the fetch_tb
vcom memory.vhd
vcom memory_stage.vhd
vcom memory_stage_tb.vhd

vsim -t ns memory_stage_tb


# Add Waves
add wave  sim:/memory_stage_tb/*

# RUN Testbench
run             400 ns
