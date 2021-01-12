
import os
 
 
# 指定工程xpr文件路径
XprFilePath = 'cache.xpr'
# 指定Tcl脚本路径
SimTclFilePath = 'sim.tcl'
 
 
# 命令-在使用命令行调用Vivado软件前需要运行的批处理文件
SourceSettingsFileCmd = 'call C:/Xilinx/Vivado/2017.2/settings64.bat' 
# 命令-调用Vivado软件的batch mode打开当前工程文件并执行Tcl脚本中的生成仿真脚本命令
VivadoBatchModeScriptsCmd = 'vivado -mode batch -source ' + SimTclFilePath + ' -nojournal -nolog ' + XprFilePath
 
 
# 组合前两条命令并调用系统函数依次执行
os.system(SourceSettingsFileCmd + ' && ' + VivadoBatchModeScriptsCmd)