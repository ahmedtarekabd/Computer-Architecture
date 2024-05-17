vsim -gui work.hazard_detection_unit
# vsim -gui work.hazard_detection_unit 
# Start time: 10:25:14 on May 15,2024
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.hazard_detection_unit(hazard_detection_unit_arch)
add wave -position end  sim:/hazard_detection_unit/src_address1_fd
add wave -position end  sim:/hazard_detection_unit/src_address2_fd
add wave -position end  sim:/hazard_detection_unit/dst_address_de
add wave -position end  sim:/hazard_detection_unit/write_back_1_de
add wave -position end  sim:/hazard_detection_unit/memory_read_de
add wave -position end  sim:/hazard_detection_unit/reg_read_controller
add wave -position end  sim:/hazard_detection_unit/PC_enable
add wave -position end  sim:/hazard_detection_unit/enable_fd
add wave -position end  sim:/hazard_detection_unit/reset_de
run
run
force -freeze sim:/hazard_detection_unit/src_address1_fd 001 0
force -freeze sim:/hazard_detection_unit/src_address2_fd 002 0

force -freeze sim:/hazard_detection_unit/src_address2_fd 010 0
force -freeze sim:/hazard_detection_unit/dst_address_de 000 0
force -freeze sim:/hazard_detection_unit/write_back_1_de 1 0
force -freeze sim:/hazard_detection_unit/memory_read_de 1 0
force -freeze sim:/hazard_detection_unit/reg_read_controller 1 0
run
force -freeze sim:/hazard_detection_unit/dst_address_de 001 0
run
force -freeze sim:/hazard_detection_unit/memory_read_de 0 0
run

