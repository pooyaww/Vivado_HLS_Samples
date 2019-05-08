

all: sg_hwc_data

sg_hwc_data:
	@sysgen -r "run_sg_burst_hwc; exit(0);"
	
clean:
	@rm -f  *.log
	@rm -rf netlist
	@rm -rf .Xil