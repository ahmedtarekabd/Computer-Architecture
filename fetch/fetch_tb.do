# ModelSim do file
# Close all other instances of ModelSim
quit -sim

# Compile the VHDL files
vcom fetch.vhd
vcom fetch_tb.vhd

# Load the simulation
vsim -gui work.fetch_tb

# Load the memory
mem load -i {E:/College/year4-2/comp arch/project/project/instruction_cache.mem} -update_properties /fetch_tb/uut/inst_cache/instruction

# Add waves
add wave -position end  sim:/fetch_tb/clk
add wave -position end  sim:/fetch_tb/reset
add wave -position end  sim:/fetch_tb/selected_instruction_out
add wave -position end  sim:/fetch_tb/clk_period
add wave -position end sim:/fetch_tb/uut/inst_mux/*
add wave -position end sim:/fetch_tb/uut/inst_cache/*



# RUN Testbench
run             1000 ns
