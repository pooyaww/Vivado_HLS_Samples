############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 2015 Xilinx Inc. All rights reserved.
############################################################
set_directive_pipeline "adaptive_filter::data_filter"
set_directive_array_partition -type complete -dim 1 "lms_filter_top" lms_filter_inst
set_directive_unroll "adaptive_filter::update_coefs/coef_update_loop"
set_directive_pipeline "adaptive_filter::update_buf"
set_directive_pipeline "adaptive_filter::update_coefs"
