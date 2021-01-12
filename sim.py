import os

project_name = 'cache' 

tb_top_module = 'tb_cpu_top'
 
# 仿真目录路径
SimDirPath = project_name + '.sim/sim_1/behav/'
# compile批处理脚本名称
CompileBatName = 'compile.bat'
# elaborate批处理脚本名称
ElaborateBatName = 'elaborate.bat'
# simulate批处理脚本名称
SimulateBatName = 'simulate.bat'
# 由于所执行的脚本内容里存在一些相对路径，所以在执行脚本前，需要将系统路径切换到所执行脚本所在的目录下
# 执行Compile脚本
os.system('cd ' + SimDirPath + ' && ' + 'call ' + CompileBatName)
# 执行Elaborate脚本
os.system('cd ' + SimDirPath + ' && ' + 'call ' + ElaborateBatName)
 
 
# 修改xxxxxxxx_simulate.do脚本，删除run 1000ns和quit -force，添加log -r ./*
SimulateDoFile = open(SimDirPath + tb_top_module + '_simulate.do', 'r')
SimulateDoFileAllLines = SimulateDoFile.readlines()
SimulateDoFile.close()
SimulateDoFile = open(SimDirPath + tb_top_module + '_simulate.do', 'w')
for EachLine in SimulateDoFileAllLines:
    if EachLine.find('run 1000ns') == -1 and EachLine.find('quit -force') == -1:
        SimulateDoFile.writelines(EachLine)
SimulateDoFile.writelines('\nlog -r ./*\n')
SimulateDoFile.close()
 
 
# 删除simulate.bat脚本中的-c选项内容
SimulateBatFile = open(SimDirPath + SimulateBatName, 'r')
SimulateBatFileAllLines = SimulateBatFile.readlines()
SimulateBatFile.close()
SimulateBatFile = open(SimDirPath + SimulateBatName, 'w')
for EachLine in SimulateBatFileAllLines:
    if EachLine.find('%bin_path%/vsim  -c -do') != -1:
        EachLine = EachLine.replace('%bin_path%/vsim  -c -do', '%bin_path%/vsim  -do')
    SimulateBatFile.writelines(EachLine)
SimulateBatFile.close()
 
 
# 将当前目录下信号文件wave.do中的内容覆写到仿真目录下的xxxxxxxx_wave.do文件中
# SimWaveDoFile = open('wave.do', 'r')
# SimWaveDoFileAllLines = SimWaveDoFile.readlines()
# SimWaveDoFile.close()
# SimWaveDoFile = open(SimDirPath + tb_top_module + '_wave.do', 'w')
# SimWaveDoFile.writelines(SimWaveDoFileAllLines)
# SimWaveDoFile.close()
 
 
# 执行Simulate脚本
os.system('cd ' + SimDirPath + ' && ' + 'call ' + SimulateBatName)