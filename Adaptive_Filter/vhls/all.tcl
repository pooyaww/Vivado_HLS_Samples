#-----------------------------------------------------------
# all.tcl
#-----------------------------------------------------------

#-----------------------------------------------------------
# User-editable parameters
#-----------------------------------------------------------
# target_board can be: kc705, zc702
set target_board zc702

#-----------------------------------------------------------
# Constant parameters
#-----------------------------------------------------------
set design_name hls_adaptive_filter
set design_ver v1_0
set design_name_full "${design_name}_${design_ver}"
puts "NOTE: This file must be executed from the project's 'tcl' directory"

#-----------------------------------------------------------
# Archive existing design if it already exists
#-----------------------------------------------------------
puts "NOTE: Archive exisitng $design_name_full design if it exists"
set format_date [clock format [clock seconds] -format %Y%m%d]
set format_time [clock format [clock seconds] -format %H%M]
set date_suffix _${format_date}_${format_time}
if { [file exists "./proj/$design_name_full"] == 1 } {
  puts "Moving existing $design_name_full to time-stamped suffix $design_name_full$date_suffix"
  file rename "./proj/$design_name_full" "./proj/$design_name_full$date_suffix"
} else {
  file mkdir ./proj
}
file mkdir ../data/output/vhls
cd ./proj

#-----------------------------------------------------------
# Create project
#-----------------------------------------------------------
puts "Creating project for $design_name_full..."
if { $target_board == "kc705" } {
  set target_part xc7k325tffg900
  set board_property xilinx.com:kc705:part0:1.2
} elseif { $target_board == "zc702" } {
  set target_part xc7z020clg484-1
  set board_property xilinx.com:zc702:part0:1.2
}
open_project "$design_name_full"

#-----------------------------------------------------------
# Add accelerator source
#-----------------------------------------------------------
puts "Adding accelerator source to the design..."
add_files "../step3/adaptive_filter.cpp"
add_files "../step3/adaptive_filter.h"
add_files "../step3/adaptive_filter_top.cpp"
add_files "../step3/adaptive_filter_top.h"
set_top adaptive_filter_top

#-----------------------------------------------------------
# Add testbench source
#-----------------------------------------------------------
puts "Adding testbench source to the design..."
add_files -tb "../step3/tb.cpp"
add_files -tb "../step3/tb_lib.cpp"
add_files -tb "../step3/tb_lib.h"

#-----------------------------------------------------------
# Create/run solution(s)
#-----------------------------------------------------------
puts "Creating baseline solution..."
open_solution "baseline"
set_part $target_part
create_clock -period 10 -name default
source "../directives_baseline.tcl"
csim_design -clean
csynth_design
export_design -format sysgen

puts "Creating max-thoughput solution..."
open_solution "max_throughput"
set_part $target_part
create_clock -period 10 -name default
source "../directives_max_throughput.tcl"
csim_design -clean
csynth_design
export_design -format sysgen

puts "Creating min-area solution..."
open_solution "min_area"
set_part $target_part
create_clock -period 10 -name default
source "../directives_min_area.tcl"
csim_design -clean
csynth_design
export_design -format sysgen
