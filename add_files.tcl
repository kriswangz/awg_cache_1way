# step1 : set up a project

#touch a output file folder.
set outputDir ./bft_output             
file mkdir $outputDir

set device_model xcku040-ffva1156-2-e

#set dev_dir 
set dev_dir [pwd]

cd $dev_dir

puts "The home dir is in dev_dir now!"

# set project name 
set project_name cache 

#create project
create_project -force $project_name $dev_dir -part $device_model

set_property simulator_language Verilog [current_project]


#step 2: add files in project
add_files -fileset sim_1 ./sim/test_ic_dram.v
add_files -fileset sim_1 ./sim/test_ic_fsm_tb.v
add_files -fileset sim_1 ./sim/test_ram.v
add_files -fileset sim_1 ./sim/test_cpu_top.v

read_verilog [glob ./hdl/*.v]

#add xdc files
read_xdc ./xdc/cache.xdc




