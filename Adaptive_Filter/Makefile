
DESIGN_MAJOR_VERSION=1
DESIGN_MINOR_VERSION=0

DESIGN_ARCHIVE_NAME=hls_adaptive_filter_v${DESIGN_MAJOR_VERSION}.${DESIGN_MINOR_VERSION}.zip

all: matlab_data vhls_data sg_hwc_data analyze_results
	@echo Adaptive filter demonstration complete!

matlab_data:
	make -C matlab

vhls_data:		
	make -C vhls
	
sg_hwc_data:
	make -C sysgen
	
analyze_results:
	make -C analysis
	
release: ${DESIGN_ARCHIVE_NAME}
	$(noop)
	
${DESIGN_ARCHIVE_NAME}: clean
	zip -r ${DESIGN_ARCHIVE_NAME} .git                         \
	                              analysis                     \
	                              doc/hls_adaptive_filter.pptx \
	                              matlab                       \
	                              sysgen                       \
	                              vhls                         \
	                              Makefile                     \
	                              release_notest.txt           \

clean:

	@echo "Warning! You are about to remove all unnecessary files. Make sure you've saved everything from Vivado projects and SDK workspaces."
	@while [ -z "$$CONTINUE" ]; do \
        read -r -p "Are you sure you want to continue? [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	@echo "Okay, cleaning..."

	# Remove stimulus files
	make -C matlab clean
	
	# Extra files created by Vivado HLS
	make -C vhls clean
	
	# Extra files created by sysgen
	make -C sysgen clean

	# Get rid of auto-backups made by editing
	rm -f `find . -name "*~"`

	# Get rid of any existing archive
	rm -f ${DESIGN_ARCHIVE_NAME}
	