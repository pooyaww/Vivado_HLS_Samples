
TARGET_DIR = ../data

ALGOS          = lms nlms selms sdlms sslms llms lnlms
TESTS          = smoke noiseCancellation #echoCancellation
FORMAT         = flt fxd
STIM_SIGNALS   = desired noise
OUTPUT_SIGNALS = output

STIM_FILES := $(addsuffix _,${ALGOS})
STIM_FILES := $(foreach ii, ${TESTS}, $(addsuffix ${ii},${STIM_FILES}))
STIM_FILES := $(addsuffix _,${STIM_FILES})
STIM_FILES := $(foreach ii, ${FORMAT}, $(addsuffix ${ii},${STIM_FILES}))
STIM_FILES := $(addsuffix _,${STIM_FILES})
STIM_FILES := $(foreach ii, ${STIM_SIGNALS}, $(addsuffix ${ii},${STIM_FILES}))
STIM_FILES := $(addsuffix .dat,${STIM_FILES})
STIM_FILES := $(patsubst %, ${TARGET_DIR}/stim/%, ${STIM_FILES})

OUTPUT_FILES := $(addsuffix _,${ALGOS})
OUTPUT_FILES := $(foreach ii, ${TESTS}, $(addsuffix ${ii},${OUTPUT_FILES}))
OUTPUT_FILES := $(addsuffix _,${OUTPUT_FILES})
OUTPUT_FILES := $(foreach ii, ${FORMAT}, $(addsuffix ${ii},${OUTPUT_FILES}))
OUTPUT_FILES := $(addsuffix _,${OUTPUT_FILES})
OUTPUT_FILES := $(foreach ii, ${OUTPUT_SIGNALS}, $(addsuffix ${ii},${OUTPUT_FILES}))
OUTPUT_FILES := $(addsuffix .dat,${OUTPUT_FILES})
OUTPUT_FILES := $(patsubst %, ${TARGET_DIR}/output/matlab/%, ${OUTPUT_FILES})

all: ${STIM_FILES} ${OUTPUT_FILES}

${TARGET_DIR}/stim/%_fxd_desired.dat: # Only need to run once for ALGOS U TESTS, not STIM_SIGNALS
	@cd test;\
	matlab -r "tb('$(notdir $*)'); exit(0);"

${TARGET_DIR}/stim/%_flt_desired.dat:
	$(noop)
	
${TARGET_DIR}/stim/%_noise.dat:
	$(noop)

${TARGET_DIR}/output/matlab/%_output.dat:
	$(noop)

clean:
	@rm -rf ${TARGET_DIR}
