# ModelSim do file
# Close all other instances of ModelSim
quit -sim

# Compile the VHDL files
vcom fetch.vhd
vcom fetch_tb.vhd

# Load the simulation
vsim -gui work.fetch_tb

# Load the memory
mem load -i {E:/College/year4-2/comp arch/project/Computer-Architecture/instruction_cache.mem} /fetch_tb/uut/inst_cache/instruction

# Add waves
add wave -position 4  sim:/fetch_tb/*
add wave -position end sim:/fetch_tb/uut/*
add wave -position end sim:/fetch_tb/uut/program_counter/*
add wave -position end sim:/fetch_tb/uut/inst_cache/*
add wave -position end sim:/fetch_tb/uut/fetch_decode/*


# RUN Testbench
run             300 ns
