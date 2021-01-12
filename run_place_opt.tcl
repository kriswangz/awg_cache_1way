# STEP#3: run placement and logic optimzation, report utilization and timing estimates, write checkpoint design

opt_design
place_design
#report source usage report
report_clock_utilization -file $outputDir/clock_util.rpt    
phys_opt_design
write_checkpoint -force $outputDir/post_place
report_timing_summary -file $outputDir/post_place_timing_summary.rpt