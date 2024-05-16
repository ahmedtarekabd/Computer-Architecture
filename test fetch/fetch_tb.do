# Close all other instances of ModelSim
quit -sim
# Compile and simulate the fetch_tb
vcom fetch.vhd
vcom fetch_tb.vhd
vsim -t ns fetch_tb


# Add Waves
add wave  sim:/fetch_tb/*
#add wave  sim:/fetch_tb/uut/pc_mux1/*
#add wave  sim:/fetch_tb/uut/pc_mux2/*
#add wave  sim:/fetch_tb/uut/program_counter/*
#add wave  sim:/fetch_tb/propagated_pc
#add wave  sim:/fetch_tb/propagated_pc_plus_one
#add wave  sim:/fetch_tb/test


mem load -i {C:/Users/Omar/Desktop/Arch_project/Computer-Architecture/test fetch/inst.mem} /fetch_tb/uut/inst_cache/instruction

# RUN Testbench
run             400 ns
