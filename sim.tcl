
set_property top cpu_top [current_fileset]
update_compile_order -fileset sources_1
set_property top tb_cpu_top [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

set_property target_simulator ModelSim [current_project]

#仅生成仿真脚本
launch_simulation -mode behavioral -scripts_only