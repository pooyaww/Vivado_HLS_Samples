


.PHONY: all
all: step1 step2 step3

.PHONY: step1
step1:
	$(noop)

.PHONY: step2
step2:
	$(noop)
	
.PHONY: step3
step3:
	@echo Currently only build step 3 using 1 algorithm at a time.
	@echo Step 1 is non-synthesizable and step2 is non-optimal.
	@echo The algorithm to test is set by #define WHICH_ALGO in adaptive_filter.h
	vivado_hls all.tcl

clean:
	@rm -rf proj
	@rm -f  *.log
