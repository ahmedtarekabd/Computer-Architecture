# Close all other instances of ModelSim
quit -sim
# Compile and simulate the controller_tb
vcom -2008 controller.vhd
vcom -2008 controller_tb.vhd
vsim -t ns controller_tb

## Set the radix to hexadecimal for the simulation
# radix hexadecimal
## Set the radix to hexadecimal for specific signals
# radix signal sim:/controller_tb/input hexadecimal
# radix signal sim:/controller_tb/output1 hexadecimal
# radix signal sim:/controller_tb/output2 hexadecimal

# Add Waves
add wave -position insertpoint sim:/controller_tb/clk
add wave -position insertpoint sim:/controller_tb/opcode
add wave -position insertpoint sim:/controller_tb/isImmediate
add wave -position insertpoint sim:/controller_tb/interrupt_signal
add wave -position insertpoint sim:/controller_tb/uut/interrupt_state
add wave -position insertpoint sim:/controller_tb/zero_flag

add wave -position insertpoint sim:/controller_tb/immediate_stall
add wave -position insertpoint sim:/controller_tb/fetch_pc_mux1
add wave -position insertpoint sim:/controller_tb/fetch_decode_flush

add wave -position insertpoint sim:/controller_tb/decode_reg_read
add wave -position insertpoint sim:/controller_tb/decode_sign_extend
add wave -position insertpoint sim:/controller_tb/decode_execute_flush

add wave -position insertpoint sim:/controller_tb/execute_alu_sel
add wave -position insertpoint sim:/controller_tb/execute_alu_src2
add wave -position insertpoint sim:/controller_tb/decode_branch
add wave -position insertpoint sim:/controller_tb/conditional_jump

add wave -position insertpoint sim:/controller_tb/memory_write
add wave -position insertpoint sim:/controller_tb/memory_read
add wave -position insertpoint sim:/controller_tb/memory_stack_pointer
add wave -position insertpoint sim:/controller_tb/memory_address
add wave -position insertpoint sim:/controller_tb/memory_write_data
add wave -position insertpoint sim:/controller_tb/memory_protected
add wave -position insertpoint sim:/controller_tb/memory_free
add wave -position insertpoint sim:/controller_tb/execute_memory_flush

add wave -position insertpoint sim:/controller_tb/write_back_register_write1
add wave -position insertpoint sim:/controller_tb/write_back_register_write2
add wave -position insertpoint sim:/controller_tb/write_back_register_write_data_1
add wave -position insertpoint sim:/controller_tb/write_back_register_write_address_1
add wave -position insertpoint sim:/controller_tb/outport_enable

# RUN Testbench
run             900 ns
