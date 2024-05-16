# Close all other instances of ModelSim
quit -sim
# Compile and simulate the fetch_tb
vcom fetch.vhd
vcom fetch_tb.vhd
vsim -t ns fetch_tb


# Add Waves
add wave -position end  sim:/fetch_tb/*

mem load -i {C:/Users/Omar/Desktop/Arch_project/Computer-Architecture/test fetch/inst.mem} /fetch_tb/uut/inst_cache/instruction

# RUN Testbench
run             200 ns
