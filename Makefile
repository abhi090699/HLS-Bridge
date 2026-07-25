# CMDLINE ARGS
#--------------------------------------------------------------------
# Passed directly to any xrun calls (both compile and simluate) since the flow is single stage

# Required for regressions to work with RH8
export PATH := $(shell bash -c xmroot)/tools/bin/64bit:$(PATH)

# Use the format ARGS='<everything inside the singel quotes goes directly to xrun>'
ARGS ?=

# SEED Arguments
# Set simulation seed used by test if not already set.
ifndef SEED
  # Seed set by default random
  SEED := $(shell bash -c 'echo "$$RANDOM + 1" | bc')
endif
# Set simulation seed used by parameters cfg pkg generation test if not already set.
ifndef CFG_GEN_SEED
  # Seed set by default random
  CFG_GEN_SEED := $(shell bash -c 'echo "$$RANDOM + 1" | bc')
endif
RUN_SEED_ARGS := -seed $(SEED) -snseed $(SEED) -svseed $(SEED) +SEED=$(SEED)
CFG_SEED_ARGS := -seed $(CFG_GEN_SEED) -snseed $(CFG_GEN_SEED) -svseed $(CFG_GEN_SEED) +SEED=$(CFG_GEN_SEED)

# Test Name
TEST ?= cdn_pcie_hls_bridge_base_test

# Configuration
CONFIG ?= ga_config

# DTI Enable in the design as well as the passive DTI Env.
DTI ?= 0

# Set coverage off by default
COV ?= 0

# Enable assertion, on by default
ABV_ON ?= 1

# Generate Xceligen test case from ID. Useful for debugging randomization issues.
UTRACE ?= 0
UTRACE_ID ?= 0

# Turns on Denali trace file (0 by default)
TRACE ?= 0

# Set default verbosity level
VERBOSITY ?= UVM_NONE

# Default UVM_TIMEOUT value 100us
UVM_TIMEOUT ?= 100000000

# Set max error, default to 1
MAX_ERR ?= 1

# HPA Controller Generation selection
HPA_GEN_ARGS ?= +define+HPA_ARCH2

# PCIe Generation selection
PCIE_GEN ?= 6
PCIE_GEN_ARGS ?=
ifeq ($(PCIE_GEN),6)
  PCIE_GEN_ARGS += +define+PCIE_GEN6
endif

# ARGS which passed only through MakeFile and don't need to pass it via test command.
# PM_CLK_FREQ=1 to avoid hanging of PM CLK Generation.
#             +CXL_IDE_SUPP=1                   
USER_ARGS ?=
USER_ARGS += +define+HLS_BRIDGE_MODULE         \
             +define+HLS_MODULE_MODE           \
             +define+VIPSR_46884732_WORKAROUND \
             +define+TODO_UP_TO_4_TLPS_PER_CLK \
             +define+TODO_MULTI_VC             \
             +ALL_TRAFFIC=1                    \
             +ENABLE_ATS_IN_FM=1               \
             +PIPE_IF_TYPE=4                   \
             +ENABLE_PASID=1                   \
             +PCIE_6_1_SUPPORT=1               \
             +ENABLE_OHC_E=1                   \
             +PTM_SUPP=1                       \
             +CXL_SUPP=1                       \
             +PM_CLK_FREQ=1

ifeq ($(DTI),1)
  USER_ARGS += +KMAX_DTI_SUPPORT=1 \
               +define+DTI_TB_IN_PASSIVE_MODE
endif

# temporary switch for QoS Support in HLS Bridge
ifeq ($(QOS_SUPP),1)
  USER_ARGS += +define+HLSB_QOS_SUPP
endif

ifeq ($(CURRENT_BRANCH_NAME),hpa2_ide)
  USER_ARGS += +define+HPA2_IDE_BRANCH \
               +define+HAS_PBR \
               +define+HAS_ARM
endif

ifeq ($(CURRENT_BRANCH_NAME),hpa2_mld)
  USER_ARGS += +define+HPA2_IDE_BRANCH \
               +define+HAS_PBR \
               +define+HAS_ARM
endif


ifeq ($(CURRENT_BRANCH_NAME),hpa2_ide_lbb)
  USER_ARGS += +define+HPA2_IDE_BRANCH \
               +define+HAS_PBR \
               +define+HAS_ARM \
               +define+HAS_UIO
endif

ifeq ($(CURRENT_BRANCH_NAME),hpa2_ide_gen7)
  USER_ARGS += +define+HPA2_IDE_BRANCH \
               +define+HPA2_IDE_GEN7 \
               +define+HAS_GEN7 \
               +define+HAS_PBR \
               +define+HAS_ARM \
               +define+HAS_UIO \
               +define+VIPCAT_08MAY_PLUS
endif

# Regression run log file path used to generate run command from the log file.
REGR_RUN_LOG_PATH ?=

#--------------------------------------------------------------------
# VERSIONS
#--------------------------------------------------------------------
UVM_VERSION = 1.2

#--------------------------------------------------------------------
# Variables
#--------------------------------------------------------------------
ifndef DENALI
  $(fatal DENALI environment variable is not defined)
endif

ifndef CURRENT_PROJECT_PATH
  $(fatal CURRENT_PROJECT_PATH needs to be defined.)
endif

# Name and path of the snapshot_dir
ifndef BRUN_GROUP_DIR
  BUILD_DIR := $(PWD)
else
  BUILD_DIR := $(BRUN_GROUP_DIR)
endif

SIM_DIR = $(PWD)

# Some regressions need >1 snapshot
SNAPSHOT_NAME ?= lib_cdn_pcie_hls_bridge
SIM_LOG := xrun.log
SNAPSHOT_DIR  ?= $(BUILD_DIR)/$(SNAPSHOT_NAME)

VIPCAT_VERSION := `echo $(DENALI) | cut -d '/' -f 7`

ifndef SNAPSHOT_DIR
  SNAPSHOT_DIR := $(BUILD_DIR)/$(SNAPSHOT_NAME)
endif

ifndef UVM_HOME
  UVM_HOME := `xmroot`/tools/methodology/UVM/CDNS-$(UVM_VERSION)/sv
  export $UVM_HOME
endif

#--------------------------------------------------------------------
# Paths
#--------------------------------------------------------------------
UVC_LIB_PATH                     = $(CURRENT_PROJECT_PATH)/verif/uvc_lib
CDN_PCIE_HLS_BRIDGE_PATH         = $(UVC_LIB_PATH)/cdn_pcie_hls_bridge
CDN_PCIE_COMMON_PATH             = $(UVC_LIB_PATH)/cdn_pcie_common
CDN_PCIE_BCL_PATH                = $(UVC_LIB_PATH)/cdn_pcie_bcl
CDN_PCIE_HPA_PATH                = $(UVC_LIB_PATH)/cdn_pcie_hpa
CDN_PCIE_DTI_PATH                = $(UVC_LIB_PATH)/cdn_pcie_dti
TCL_DIR                          = $(CDN_PCIE_HLS_BRIDGE_PATH)/sve/tcl

#--------------------------------------------------------------------
# SOURCE & PATHS
#--------------------------------------------------------------------
RTL_SRC := -F $(CURRENT_PROJECT_PATH)/rtl/hls_bridge/hls_bridge_verif.f \
           -incdir $(CURRENT_PROJECT_PATH)/rtl                          \
           $(CURRENT_PROJECT_PATH)/rtl/hlsif/hlsif_chk_dbg.v

# PCIe BCL args.
PCIE_HPA_BCL_UVC_ARGS := -incdir $(CDN_PCIE_BCL_PATH)/sv         \
                         $(CDN_PCIE_BCL_PATH)/sv/cdnpcie_pkg.svh

# Toplevel parameters config package
TOPLEVEL_CFG_PKG_ARGS := -incdir $(UVC_LIB_PATH)/cdn_pcie_strap/sv/common/cfg                            \
                         $(UVC_LIB_PATH)/cdn_pcie_strap/sv/common/cfg/cdn_pcie_dut_parameters_cfg_pkg.sv

# HLS Bridge parameters config package extended from Toplevel.
PCIE_HLS_BRIDGE_CFG_PKG_ARGS := -incdir $(CDN_PCIE_HLS_BRIDGE_PATH)/cfg                            \
                                $(CDN_PCIE_HLS_BRIDGE_PATH)/cfg/cdn_pcie_hls_bridge_dut_cfg_pkg.sv \
                                $(CDN_PCIE_HLS_BRIDGE_PATH)/cfg/cdn_pcie_hls_bridge_dut_cfg_top.sv

# Set config package paths
DUT_CFG_SRC := $(BUILD_DIR)/pcie_hls_bridge_$(CONFIG)_cfg_pkg.sv
TB_CFG_SRC  := $(BUILD_DIR)/pcie_hls_bridge_$(CONFIG)_tb_cfg_pkg.sv

# Set Denali VIP arguments
DENALI_VIP_ARGS := -loadvpi $(DENALI)/verilog/libcdnsv.so:cdnsvVIP:export                           \
                   -xmsimargs "-loadrun $(CDN_VIP_LIB_PATH)/64bit/libcdnvipcuvm.so"                 \
                   -define DENALI_UVM                                                               \
                   -define DENALI_SV_NC                                                             \
                   +define+CDN_AXI_USING_CLOCKING_BLOCK                                             \
                   +define+CDN_STREAM_USING_CLOCKING_BLOCK                                          \
                   +define+CDN_STREAM_PARITY_INTERFACE                                              \
                   -incdir $(DENALI)/ddvapi/sv                                                      \
                   -incdir $(DENALI)/ddvapi/sv/uvm/cxs                                              \
                   -incdir $(DENALI)/ddvapi/sv/uvm/dti                                              \
                   -incdir $(DENALI)/ddvapi/sv/uvm/stream                                           \
                   -incdir $(DENALI)/ddvapi/sv/uvm/pcie                                             \
                   -incdir $(DENALI)/ddvapi/sv/uvm/cdn_axi                                          \
                   $(DENALI)/ddvapi/sv/hdl_interfaces/cdn_axi/cb_interfaces/cdnAxi5LiteInterface.sv \
                   $(DENALI)/ddvapi/sv/hdl_interfaces/stream/cb_interfaces/cdnStream5Interface.sv   \
                   $(DENALI)/ddvapi/sv/hdl_interfaces/cdn_axi/cb_interfaces/cdnAxi5Interface.sv     \
                   $(DENALI)/ddvapi/sv/denaliMem.sv                                                 \
                   $(DENALI)/ddvapi/sv/denaliCxs.sv                                                 \
                   $(DENALI)/ddvapi/sv/denaliDti.sv                                                 \
                   $(DENALI)/ddvapi/sv/denaliStream.sv                                              \
                   $(DENALI)/ddvapi/sv/denaliPcie.sv                                                \
                   $(DENALI)/ddvapi/sv/denaliCdn_axi.sv                                             \
                   $(DENALI)/ddvapi/sv/uvm/cxs/cdnCxsUvmTop.sv                                      \
                   $(DENALI)/ddvapi/sv/uvm/dti/cdnDtiUvmTop.sv                                      \
                   $(DENALI)/ddvapi/sv/uvm/stream/cdnStreamUvmTop.sv                                \
                   $(DENALI)/ddvapi/sv/uvm/pcie/cdnPcieUvmTop.sv                                    \
                   $(DENALI)/ddvapi/sv/uvm/cdn_axi/cdnAxiUvmTop.sv

# Set Clock & Reset UVC arguments
CLK_RST_UVC_ARGS := -incdir $(UVC_LIB_PATH)/cdn_clock/sv          \
                    $(UVC_LIB_PATH)/cdn_clock/sv/cdn_clock_pkg.sv \
                    $(UVC_LIB_PATH)/cdn_clock/sv/cdn_clock_if.sv  \
                    -F $(UVC_LIB_PATH)/cdn_pcie_reset/sv/cdn_pcie_reset.f \
                    -incdir $(UVC_LIB_PATH)/cdn_reset/sv          \
                    $(UVC_LIB_PATH)/cdn_reset/sv/cdn_reset_pkg.sv \
                    $(UVC_LIB_PATH)/cdn_reset/sv/cdn_reset_if.sv

# AXI Lite UVC arguments
AXIL_UVC_ARGS := -incdir $(UVC_LIB_PATH)/cdn_axi/sv                                       \
                 $(UVC_LIB_PATH)/cdn_axi/sv/cdn_axi_pkg.sv                                \
                 $(UVC_LIB_PATH)/cdn_pcie_axi_bridge/sv/interfaces/axi4_lite_interface.sv

# Set SEQ CFG UVC arguments
SEQ_CFG_UVC_ARGS :=   -incdir $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_common/sv \
                              $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_common/sv/cdn_pcie_seq_conf_pkg.sv

# Needed for register model generation.
CDNS_UVMREG_CONFIG_DATA_DIR := "$(UVC_LIB_PATH)/cdn_regs/sv/$(CURRENT_BRANCH_NAME)"
export CDNS_UVMREG_CONFIG_DATA_DIR

# Register model arguments
CDN_REG_ARGS := -F $(UVC_LIB_PATH)/cdn_regs/sv/cdn_regs_$(CURRENT_BRANCH_NAME).f

# Randomization policy UVC arguments
PCY_UVC_ARGS := -incdir $(UVC_LIB_PATH)/cdns_uvm_rand_policy/sv                     \
                $(UVC_LIB_PATH)/cdns_uvm_rand_policy/sv/cdns_uvm_rand_policy_pkg.sv

# Set HLS UVC extended from CXS VIP arguments
HLS_UVC_ARGS := -incdir $(UVC_LIB_PATH)/cdn_hls/sv         \
                -define HLS_INTERFACE_SIGNALS_AS_PORTS     \
                -F $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_hls/sv/cdn_hls.f

# INTx UVC arguments required for CIF Router.
INTX_UVC_ARGS := -incdir $(UVC_LIB_PATH)/cdn_pcie_intx/sv              \
                 $(UVC_LIB_PATH)/cdn_pcie_intx/sv/cdn_pcie_intx_pkg.sv \
                 $(UVC_LIB_PATH)/cdn_pcie_intx/sv/cdn_pcie_intx_if.sv

# Set msi/msix interrupts UVC arguments required for CIF Router.
MSI_MSIX_UVC_ARGS := -incdir $(UVC_LIB_PATH)/cdn_pcie_msi_msix/sv                  \
                     $(UVC_LIB_PATH)/cdn_pcie_msi_msix/sv/cdn_pcie_msi_msix_pkg.sv \
                     $(UVC_LIB_PATH)/cdn_pcie_msi_msix/sv/cdn_pcie_msi_msix_if.sv

# Set FLR UVC Arguments required for CIF Router.
FLR_UVC_ARGS := -incdir $(UVC_LIB_PATH)/cdn_pcie_flr/sv                     \
                $(UVC_LIB_PATH)/cdn_pcie_flr/sv/cdn_pcie_flr_defines_pkg.sv \
                $(UVC_LIB_PATH)/cdn_pcie_flr/sv/cdn_pcie_flr_pkg.sv         \
                $(UVC_LIB_PATH)/cdn_pcie_flr/sv/cdn_pcie_flr_intf.sv

# Set ASF ERROR INJECTION UVC arguments 
ASF_EI_UVC_ARGS := -F $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_asf_err_inj/sv/cdn_pcie_asf_err_inj.f

ifeq ($(DTI),1)
  # Set DTI UVC Arguments
  DTI_UVC_ARGS := +define+DTI_DUT_MODULE_NAME=cdn_pcie_hls_bridge_tb_top.i_dut.i_dti_hls_wrapper_gen.i_dti_hls_wrapper \
                  -incdir $(UVC_LIB_PATH)/cdn_pcie_dti/sv            \
                  -F $(UVC_LIB_PATH)/cdn_pcie_dti/sv/cdn_pcie_dti.f \
  
  # Set AXI BRIDGE DELIVERED P CHECKER UVC arguments
  DELIVERED_UVC_ARGS := -incdir $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_axi_bridge/sv \
                        $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_axi_bridge/sv/cdn_pcie_axi_bridge_delivered_p_checker.sv
  
  # Set AXI BRIDGE AXI LITE COV COLLECTOR UVC arguments
  AXI_LITE_COV_UVC_ARGS := -incdir $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_axi_bridge/sv/axi \
                         $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_axi_bridge/sv/axi/cdn_axi_lite_cov_collector.sv \
                         $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_axi_bridge/sv/axi/coverage/cdn_axi_lite_cg.sv
  
  
  # Set AXI BRIDGE PCIE CXS UVC arguments
  PCIE_CXS_UVC_ARGS := -incdir $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_axi_bridge/sv/pcie_cxs \
                       $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_axi_bridge/sv/pcie_cxs/cdn_pcie_cxs_alignment_checker.sv
endif

# PCIe Common Arguments
PCIE_COMMON_ARGS := -incdir $(CDN_PCIE_COMMON_PATH)/sv                            \
                    $(CDN_PCIE_COMMON_PATH)/sv/cdn_pessimistic_ram_model.sv       \
                    $(CDN_PCIE_COMMON_PATH)/sv/cdn_ecc_pessimistic_ram_wrapper.sv \
                    $(CDN_PCIE_COMMON_PATH)/sv/cdn_ecc_errors_injection_if.sv     \
                    $(CDN_PCIE_COMMON_PATH)/sv/cdn_pcie_ram_asf_err_inj_if.sv     \
                    $(CDN_PCIE_COMMON_PATH)/sv/cdn_pcie_scenario_pkg.sv

# PCIe HPA Common Arguments
PCIE_HPA_COMMON_ARGS := -incdir $(CDN_PCIE_HPA_PATH)/sv/common/cdn_pcie_hpa_common                    \
                        $(CDN_PCIE_HPA_PATH)/sv/cdn_pcie_hpa_defines_pkg.sv                           \
                        $(CDN_PCIE_HPA_PATH)/sv/common/cdn_pcie_hpa_common/cdn_pcie_hpa_common_pkg.sv \
                        $(CDN_PCIE_HPA_PATH)/sv/common/cdn_pcie_ucie_misc_base.sv                     \
                        $(CDN_PCIE_HPA_PATH)/sv/common/cdn_pcie_hpa_misc_if.sv

# PCIe Strap Arguments
PCIE_STRAP_CFG_ARGS := -incdir $(UVC_LIB_PATH)/cdn_pcie_strap/sv/                             \
                       -incdir $(UVC_LIB_PATH)/cdn_pcie_strap/sv/common/                      \
                       -incdir $(UVC_LIB_PATH)/cdn_pcie_strap/sv/default/                     \
                       -incdir $(UVC_LIB_PATH)/cdn_pcie_strap/sv/random/                      \
                       $(UVC_LIB_PATH)/cdn_pcie_strap/sv/common/cdn_pcie_strap_defines_pkg.sv \
                       $(UVC_LIB_PATH)/cdn_pcie_strap/sv/common/cdn_pcie_strap_intf.sv        \
                       $(UVC_LIB_PATH)/cdn_pcie_strap/sv/cdn_pcie_strap_pkg.sv

# PCIe HPA TLP Coverage Arguments
PCIE_HPA_TLP_COV_ARGS := -incdir $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_hpa/sv/random/coverage                 \
                         $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_hpa/sv/random/coverage/cdn_pcie_hpa_cov_pkg.sv
												 
# PCIe HPA TLP arguments
PCIE_HPA_TLP_ARGS := -incdir $(UVC_LIB_PATH)/cdn_pcie_tlp                 \
                     $(UVC_LIB_PATH)/cdn_pcie_tlp/cdn_hpa_pcie_tlp_pkg.sv

# PCIE HPA Config class arguments
PCIE_HPA_CONFIG_ARGS := -incdir $(CDN_PCIE_HPA_PATH)/sv/config                         \
                        $(CDN_PCIE_HPA_PATH)/sv/config/cdn_pcie_hpa_config_pkg.sv      \
                        $(CDN_PCIE_HPA_PATH)/sv/config/cdn_pcie_hpa_vip_api_cfg_pkg.sv

# Common PCIe TL utils package
PCIE_TL_UTILS_ARGS := -incdir $(UVC_LIB_PATH)/cdn_pcie_tl/sv/utils                   \
                      $(UVC_LIB_PATH)/cdn_pcie_tl/sv/utils/cdn_pcie_tl_utils_pkg.sv  \
                      $(UVC_LIB_PATH)/cdn_pcie_tl/sve/cdn_pcie_tl_cxs_utility_ifs.sv \
                      $(UVC_LIB_PATH)/cdn_pcie_tl/sve/cdn_pcie_rst_cov_if.sv

# Common PCIe TL scoreboard package
PCIE_TL_SCOREBOARD_ARGS := -incdir $(UVC_LIB_PATH)/cdn_pcie_tl/sv/scoreboard                       \
                           $(UVC_LIB_PATH)/cdn_pcie_tl/sv/scoreboard/cdn_pcie_tl_scoreboard_pkg.sv

# Common PCIe TL sequences arguments
PCIE_TL_SEQUENCES_ARGS := -incdir $(UVC_LIB_PATH)/cdn_pcie_tl/sve/sequences                      \
                          $(UVC_LIB_PATH)/cdn_pcie_tl/sve/sequences/cdn_pcie_tl_sequences_pkg.sv

# AXI Stream UVC arguments
AXI_STREAM_UVC_ARGS := -incdir $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_axi_bridge/sv/stream \
                       -incdir $(CDN_PCIE_HLS_BRIDGE_PATH)/sv/stream                               \
                       $(CDN_PCIE_HLS_BRIDGE_PATH)/sv/stream/cdn_axi_stream_vip_pkg.sv            

# HLS Bridge CFG Interfaces
PCIE_HLS_BRIDGE_IF_PKG := -incdir $(CDN_PCIE_HLS_BRIDGE_PATH)/cfg                           \
                          $(CDN_PCIE_HLS_BRIDGE_PATH)/cfg/cdn_pcie_hls_bridge_dut_if_pkg.sv

# Set HLS Bridge UVC Arguments
PCIE_HLS_BRIDGE_UVC_ARGS := -incdir $(CDN_PCIE_HLS_BRIDGE_PATH)/cfg                                          \
                            -incdir $(CDN_PCIE_HLS_BRIDGE_PATH)/sv                                           \
                            -incdir $(CDN_PCIE_HLS_BRIDGE_PATH)/sv/sequences                                 \
                            -incdir $(CDN_PCIE_HLS_BRIDGE_PATH)/sve                                          \
                            -incdir $(CDN_PCIE_HLS_BRIDGE_PATH)/sve/tests                                    \
                            $(CDN_PCIE_HLS_BRIDGE_PATH)/sv/cdn_pcie_hls_bridge_sv_pkg.sv                     \
                            $(CDN_PCIE_HLS_BRIDGE_PATH)/sv/sequences/cdn_pcie_hls_bridge_seq_pkg.sv          \
                            $(CDN_PCIE_HLS_BRIDGE_PATH)/sve/tests/cdn_pcie_hls_bridge_test_pkg.sv            \
                            $(CDN_PCIE_HLS_BRIDGE_PATH)/sve/cdn_pcie_hls_bridge_cxs_bus_converter_wrapper.sv \
                            $(CDN_PCIE_HLS_BRIDGE_PATH)/sve/cdn_pcie_hls_bridge_stream_parity_wrapper.sv     \
                            $(CDN_PCIE_HLS_BRIDGE_PATH)/sve/cdn_pcie_hls_bridge_qactive_clk_gater.sv         \
                            $(CDN_PCIE_HLS_BRIDGE_PATH)/sve/cdn_pcie_hls_bridge_tb_harness.sv                \
                            $(CDN_PCIE_HLS_BRIDGE_PATH)/sve/cdn_pcie_hls_bridge_tb_top.sv           

TB_TOP := cdn_pcie_hls_bridge_tb_top

#--------------------------------------------------------------------
# XRUN ARGUMENTS
#--------------------------------------------------------------------
XRUN_SVLIB_ARGS = -incdir $(UVM_HOME)/src                     \
                  -uvm                                        \
                  -uvmhome $(UVM_HOME)                        \
                  $(UVM_HOME)/../additions/sv/cdns_uvm_pkg.sv \
                  +UVM_MAX_QUIT_COUNT=$(MAX_ERR)              \
                  +PS_MAX_ERROR_COUNT=$(MAX_ERR)              \
                  +UVM_TIMEOUT=$(UVM_TIMEOUT)                 \
                  +UVM_VERBOSITY=$(VERBOSITY)

# Set coverage arguments.
ifeq ($(COV),1)
  ifeq ($(CURRENT_BRANCH_NAME),hpa2_ide)
    COVERAGE_TCL_FILE = $(TCL_DIR)/coverage.tcl
  else
    COVERAGE_TCL_FILE = $(TCL_DIR)/coverage_gen7.tcl
  endif
  XRUN_COV_ARGS = +define+FUNC_COV                                                             \
                  -access +w                                                                   \
                  -coverage all                                                                \
                  -covoverwrite                                                                \
                  -write_metrics                                                               \
                  -covworkdir $(SIM_DIR)/cov_work                                              \
                  -propfile_vlog $(CDN_PCIE_COMMON_PATH)/sv/cdn_pessimistic_ram_model_vunit.sv \
                  -covtest $(TEST)                                                             \
                  -covfile $(CDN_PCIE_HPA_PATH)/sve/tcl/common_ccf.tcl                         \
                  -covfile $(COVERAGE_TCL_FILE)
endif

# SYSFMW, RTSVAV - Standard for UVM
# SVRNDF - Promote ranomdisation failure to an error
# RTSVQO - disable warnings related to queues used in clock gating
XRUN_WARN_ARGS = -nowarn SYSFMW -nowarn RTSVAV -nowarn RTSVQO -xmerror SVRNDF -xmerror LBLMAT -xmerror FUNTSK

# Basic compile arguments
XRUN_BASE_ARGS = -64bit                                                                                                   \
                 -access +r                                                                                               \
                 -xmlibdirname $(SNAPSHOT_DIR)                                                                            \
                 -newperf                                                                                                 \
                 -plusperf                                                                                                \
                 -xceligen dynamic_solve_seq,seed_only_rand,process_alternate_rng,ignore_worklib_name,rewrite_if_clause=0 \
                 -status                                                                                                  \
                 -assert                                                                                                  \
                 -sv                                                                                                      \
                 -nbasync                                                                                                 \
                 -mccodegen                                                                                               \
                 -zlib 5                                                                                                  \
                 -sntimescale "100ps/1ps"                                                                                 \
                 -timescale "100ps/1ps"                                                                                   \
                 -errormax $(MAX_ERR)                                                                                     \
                 $(ARGS)                                                                                                  \
                 $(USER_ARGS)                                                                                             \
                 $(XRUN_WARN_ARGS)                                                                                        \
                 $(XRUN_SVLIB_ARGS)                                                                                       \
                 +CONFIG=$(CONFIG)                                                                                        \
                 $(HPA_GEN_ARGS)                                                                                          \
                 $(PCIE_GEN_ARGS)

# Run the profiler, perf analyszer if required
ifeq ($(PROF),1)
  XRUN_BASE_ARGS += -profile \
                    -perf_stat \
                    -perf_analysis
endif

# Used to debug randomization issues. Add the tc_call_id for more information on the randomization failure.
ifeq ($(UTRACE),1)
  XRUN_BASE_ARGS += -xceligen utrace,trace_single=$(UTRACE_ID)
endif

# Enabled Assertions
ifeq ($(ABV_ON),1)
  XRUN_BASE_ARGS += +define+ABV_ON
endif

# Run coverage if enabled
ifeq ($(IDA),1)
  XRUN_BASE_ARGS += -input $(TCL_DIR)/ida.tcl
endif

# ASF vunit
XRUN_BASE_ARGS += $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_asf_err_inj/vunit/asf_queue_pkg.sv \
                  -propfile_vlog $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_asf_err_inj/vunit/asf_queue_vunit.sv

# Add things that are only required in debug modes here
XRUN_DEBUG_ARGS += -linedebug           \
                   -classlinedebug      \
                   +UVM_CONFIG_DB_TRACE 

# Set configuration generation arguments
CFG_GEN_ARGS := $(XRUN_BASE_ARGS)                              \
                $(CFG_SEED_ARGS)                               \
                +UVM_TESTNAME=cdn_pcie_hls_bridge_dut_cfg_test \
                $(PCIE_HPA_BCL_UVC_ARGS)                       \
                $(TOPLEVEL_CFG_PKG_ARGS)                       \
                $(PCIE_HLS_BRIDGE_CFG_PKG_ARGS)                \
                -top cdn_pcie_hls_bridge_dut_cfg_top

# All verification environment arguments.
ALL_VE_ARGS := $(XRUN_BASE_ARGS)                                                  \
               $(RUN_SEED_ARGS)                                                   \
               +UVM_TESTNAME=$(TEST)                                              \
               +define+CDNS_UVMREG_CONFIG_DATA_DIR=$(CDNS_UVMREG_CONFIG_DATA_DIR) \
               $(PCIE_HPA_BCL_UVC_ARGS)                                           \
               $(DUT_CFG_SRC)                                                     \
               $(TB_CFG_SRC)                                                      \
               $(RTL_SRC)                                                         \
               $(PCIE_TL_UTILS_ARGS)                                              \
               $(PCIE_HLS_BRIDGE_IF_PKG)                                          \
               $(PCY_UVC_ARGS)                                                    \
               $(PCIE_COMMON_ARGS)                                                \
               $(PCIE_STRAP_CFG_ARGS)                                             \
               $(DENALI_VIP_ARGS)                                                 \
               $(CLK_RST_UVC_ARGS)                                                \
               $(SEQ_CFG_UVC_ARGS)                                                \
               $(ASF_EI_UVC_ARGS)                                                 \
               $(AXIL_UVC_ARGS)                                                   \
               $(CDN_REG_ARGS)                                                    \
               $(HLS_UVC_ARGS)                                                    \
               $(PCIE_HPA_CONFIG_ARGS)                                            \
               $(PCIE_HPA_TLP_ARGS)                                               \
               $(INTX_UVC_ARGS)                                                   \
               $(MSI_MSIX_UVC_ARGS)                                               \
               $(FLR_UVC_ARGS)                                                    \
               $(PCIE_TL_SEQUENCES_ARGS)                                          \
               $(PCIE_TL_SCOREBOARD_ARGS)                                         \
               $(PCIE_HPA_COMMON_ARGS)                                            \
               $(PCIE_HPA_TLP_COV_ARGS)                                           \
               $(DTI_UVC_ARGS)                                                    \
               $(AXI_STREAM_UVC_ARGS)                                             \
               $(DELIVERED_UVC_ARGS)                                              \
               $(AXI_LITE_COV_UVC_ARGS)                                           \
               $(PCIE_CXS_UVC_ARGS)                                               \
               $(PCIE_HLS_BRIDGE_UVC_ARGS)                                        \
               -top $(TB_TOP)


#--------------------------------------------------------------------
# TARGETS
#--------------------------------------------------------------------
# Include VIP makefile
include $(UVC_LIB_PATH)/Makefile.vip

#--------------------------------------------------------------------
# TARGET : targets
# List all the interactive targets
#--------------------------------------------------------------------
targets:
	echo "Available interactive targets : " clean, run, run_debug, run_i

#--------------------------------------------------------------------
# TARGET : trace
# Generates or deletes the tracefile
#--------------------------------------------------------------------
trace: 
	@rm -rf $(SIM_DIR)/.denalirc > /dev/null;
	@if [ "$(TRACE)" -eq "1" ]; then \
	  echo "Historyfile denali.his" > $(SIM_DIR)/.denalirc; \
	  echo "Historydebug on" >> $(SIM_DIR)/.denalirc; \
	  echo "Tracefile denali.trc" >> $(SIM_DIR)/.denalirc; \
	fi

denrc_regr:
	@echo "InitMessages Off" > $(SIM_DIR)/.denalirc;
	@echo "WarningMessages Off" >> $(SIM_DIR)/.denalirc;
	@echo "InfoMessages Off" >> $(SIM_DIR)/.denalirc;
	@echo "[make] Finished creating .denalirc."

#------------------------------------------------------------------------------
# Target : cfg_gen
# Brief  : This target runs simulation to generate the configuration package.
#------------------------------------------------------------------------------
cfg_gen:
	@echo "[Makefile] Generating $(CONFIG) configuration in $(BUILD_DIR)."
	@xrun \
	  $(CFG_GEN_ARGS) \
	  -logfile $(BUILD_DIR)/xrun_cfg_gen.log
	@mv $(PWD)/parameters_cfg_pkg.sv $(DUT_CFG_SRC)
	@mv $(PWD)/tb_parameters_cfg_pkg.sv $(TB_CFG_SRC)

#--------------------------------------------------------------------
# TARGET : compile
#--------------------------------------------------------------------
compile: cfg_gen
	@xrun \
	  $(ALL_VE_ARGS) \
	  $(XRUN_COV_ARGS) \
	  -elaborate \
	  -nolog

#--------------------------------------------------------------------
# TARGET : run_i
# Interactive target. Runs GUI with debug switches on.
#--------------------------------------------------------------------
run_i: vip_compile cfg_gen trace
	@xrun                            \
	  -gui                           \
	  $(ALL_VE_ARGS)                 \
	  $(XRUN_COV_ARGS)               \
	  $(XRUN_DEBUG_ARGS)             \
	  -logfile $(SIM_DIR)/$(SIM_LOG) \
	  -input $(TCL_DIR)/waves.tcl    \
	  -input $(TCL_DIR)/startup.tcl


#--------------------------------------------------------------------
# TARGET : run_waves
# Runs in batch but dumps waves for viewing offline.
#--------------------------------------------------------------------
run_waves: vip_compile cfg_gen trace
	@xrun                            \
	  -access +c                     \
	  +fsmdebug                      \
	  $(ALL_VE_ARGS)                 \
	  $(XRUN_COV_ARGS)               \
	  -logfile $(SIM_DIR)/$(SIM_LOG) \
	  -input $(TCL_DIR)/waves.tcl    \
	  -input $(TCL_DIR)/run.tcl

#--------------------------------------------------------------------
# TARGET : run
# Batch mode, no waves. For debugging via logfile.
#--------------------------------------------------------------------
run: vip_compile cfg_gen trace
	@xrun \
	  $(ALL_VE_ARGS) \
	  $(XRUN_COV_ARGS) \
	  -logfile $(SIM_DIR)/$(SIM_LOG) \
	  -input $(TCL_DIR)/run.tcl

#--------------------------------------------------------------------
# TARGET : run_regression
# Used by VManager to run a single test in regression mode.
# Batch mode, max speed, only errors print to log.
# Requires pre-compiled snapshot
# Note the Vmanager produces local_log.log that holds all the screen output
# -nolog is used here to prevent duplication of potentially large logfiles.
#--------------------------------------------------------------------
run_regression: denrc_regr
	@xrun \
	  -R \
	  $(ALL_VE_ARGS) \
	  $(XRUN_COV_ARGS) \
	  +UVM_VERBOSITY=UVM_NONE \
	  +uvm_set_action=uvm_test_top.sve.m_hls_ob_trans_env.tag_manager,_ALL_,UVM_INFO,UVM_NO_ACTION \
	  +uvm_set_action=uvm_test_top.sve.m_hls_ob_trans_env.tag_manager_10_bit,_ALL_,UVM_INFO,UVM_NO_ACTION \
	  +uvm_set_action=uvm_test_top.sve.m_hls_ob_trans_env.tag_manager_14_bit,_ALL_,UVM_INFO,UVM_NO_ACTION \
	  +uvm_set_action=uvm_test_top.m_dev_top_config,uvm_test_top.m_dev_top_config,UVM_WARNING,UVM_NO_ACTION \
	  -nolog \

#--------------------------------------------------------------------
# Utility targets
#--------------------------------------------------------------------
#--------------------------------------------------------------------
# Target : imc_cov_merge
# This target is used to merged the coverage results of a regression
# using IMC since vManager doesn't merge the coverage properly..
#--------------------------------------------------------------------
.phony: imc_cov_merge
imc_cov_merge:
	@rm -rf imc_cov_merge.cmd
	@echo "merge -overwrite -initial_model union_all -out merged_ucds/ \"$(BRUN_SESSION_DIR)/chain_0/run_*/cov_work/scope/*test*\" " > imc_cov_merge.cmd
	@imc -initcmd "config merge.ignore_type_in_class_instance_merge -set true" -64bit -logfile imc_cov_merge.log -exec imc_cov_merge.cmd

#--------------------------------------------------------------------
# Target : unr_regression_run
# This target can be used to run formal UNR using Jasper
# Remember to run imc_cov_merge target first.
#--------------------------------------------------------------------
UNR_LOAD_REFINE ?= 0
UNR_REGRESSION_RUN_ARGS ?=

unr_regression_run:
	xrun                                                                                                           \
    -jg                                                                                                          \
    -unr                                                                                                         \
    -jg_elab_opts "-bbox_a 20000 -procedural_loop_limit 5000 -loop_limit 5000"                                   \
    -64bit                                                                                                       \
    -xmlibdirname $(BRUN_SESSION_DIR)/chain_0/main_group/ide_enable/1024dp/fm/ga_config_msi_dti_1ports/lib_cdn_pcie_hls_bridge          \
    -R                                                                                                           \
    -covdb merged_ucds/                                                                      \
    -covfile $(COVERAGE_TCL_FILE)                      \
    -covfile $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_hpa/sve/tcl/common_ccf.tcl                           \
    -inst_top $(TB_TOP).i_dut                                                                                    \
    -input $(CURRENT_PROJECT_PATH)/verif/uvc_lib/cdn_pcie_hls_bridge/sve/tcl/unr.tcl                             \
    $(UNR_REGRESSION_RUN_ARGS)                                                                                   \
    -jg_coverage all                                                                                             \
    -l unr.log

#--------------------------------------------------------------------
# TARGET : unr_regression_refine
# This target can be used to get a refine file after running UNR
# Remember to run unr_regression_run target first.
#--------------------------------------------------------------------
unr_regression_refine: ./jgproject/sessionLogs/session_0/unr_imc_coverage_merge.cmd
	rm -f imc_unr_batch_report.cmd
	rm -f UNR_refinement_latest.vRefine
	cat ./jgproject/sessionLogs/session_0/unr_imc_coverage_merge.cmd >> imc_unr_batch_report.cmd
	echo "exclude -inst *... -metrics block:expression:toggle:fsm -unr -comment \"IEV UNR\" -reviewer $env(USER)" >> imc_unr_batch_report.cmd
	echo "save -refinement UNR_refinement_latest.vRefine" >> imc_unr_batch_report.cmd
	imc \
    -exec imc_unr_batch_report.cmd \
    -memlimit 32G \
    -64bit \
    -logfile imc_report.log

#--------------------------------------------------------------------
# Target : gen_regr_run_cmd
# This target is used to generate run command from the regression run
# log file.
#--------------------------------------------------------------------
.phony: gen_regr_run_cmd
gen_regr_run_cmd:
	@$(CDN_PCIE_HLS_BRIDGE_PATH)/scripts/generate_run_cmd.py -l $(REGR_RUN_LOG_PATH)

#--------------------------------------------------------------------
# Target : clean_cfg
# This target is used to remove the CFG PKG Files from the 
# run directory.
#--------------------------------------------------------------------
.phony: clean_cfg
clean_cfg:
	-@echo "[Makefile] Cleanup CFG package."
	-@rm -rf $(DUT_CFG_SRC)
	-@rm -rf $(TB_CFG_SRC)
	-@echo "[Makefile] CFG package cleaned."

#--------------------------------------------------------------------
# Target : clean
# This target removes all simulation products (logs, keys, waves, etc)
# from run directory.
#--------------------------------------------------------------------
.phony: clean
clean: clean_cfg
	-@echo "[Makefile] Cleanup run directory."
	-@rm -rf $(SNAPSHOT_NAME)
	-@rm -rf waves*
	-@rm -rf $(SIM_DIR)/cov_work*
	-@rm -rf $(BUILD_DIR)/specman*
	-@rm -rf $(BUILD_DIR)/core*
	-@rm -rf $(BUILD_DIR)/*.out
	-@rm -rf $(BUILD_DIR)/*.vsif
	-@rm -rf $(BUILD_DIR)/*.h
	-@rm -rf $(SIM_DIR)/*.log
	-@rm -rf $(BUILD_DIR)/*.history
	-@rm -rf $(BUILD_DIR)/*.elog
	-@rm -rf $(BUILD_DIR)/*.err
	-@rm -rf $(BUILD_DIR)/*.key
	-@rm -rf $(BUILD_DIR)/*.his
	-@rm -rf $(BUILD_DIR)/*.trc*
	-@rm -rf $(BUILD_DIR)/*.trc*
	-@sleep 1
	-@echo "[Makefile] Run directory cleaned."

.phony: list_tests
list_tests:
	@echo "-----------------------------------------------------------------------------------------------------"
	@echo "-- List of tests:"
	@echo "-----------------------------------------------------------------------------------------------------"
	@cat cdn_pcie_hls_bridge_test_lib.sv | grep 'class ' | cut -d ' ' -f 2

.phony: help
help:
	@echo "-----------------------------------------------------------------------------------------------------"
	@echo "-- Simulation help"
	@echo "-----------------------------------------------------------------------------------------------------"
	@echo ""
	@echo " To compile and simulate : make <run_command> TEST=<testname> SEED=random ARGS=''"
	@echo " run command :"
	@echo "         run        - Batch mode. No waves, low verbosity. For debug by logfile."
	@echo "         run_debug  - Batch mode. Waves + debug + medium verbosity. "
	@echo "         run_i      - Interactive (GUI) mode."
	@echo ""
	@echo "   Default TEST=cdn_pcie_hls_bridge_base_test"
	@echo ""
	@echo " To clean: make clean"
	@echo " 	clean - Removes all build files"
	@echo ""
	@echo " To list all the tests: make list_tests"
	@echo ""
	@echo " Optional Make switches:"
	@echo "         COV=1                   - Turns on coverage (0 by default)"
	@echo "         SEED=random|<integer>   - Specify seed (0 by default)"
	@echo "         TRACE=1                 - Turns on Denali trace file (0 by default)"
	@echo ""
	@echo " ARGS Options: ARGS is passed directly to xrun. Surround in '' quotes"
	@echo "         +UVM_VERBOSITY=<verbosity>                          - Global verbosity"
	@echo "         +UVM_MAX_QUIT_COUNT=<verbosity>                     - Max UVM Errors.(no max by default)"
	@echo "         +PS_MAX_ERROR_COUNT=<verbosity>                     - Max *Denali* Errors.(no max by default)"
	@echo "----------------------------------------------------------------------------------------------------"
	@echo " UVM plusargs:"
	@echo "         +UVM_VERBOSITY=<verbosity>                          - Global verbosity"
	@echo "         +UVM_CONFIG_DB_TRACE                                - Display configuration debug messages"
	@echo "         +UVM_RESOURCE_DB_TRACE                              - Display resource debug messages"
	@echo "         +UVM_OBJECTION_TRACE                                - Displays objection messages"
	@echo "         +UVM_TIMEOUT=<time>                                 - Override global timeout"
	@echo "         +UVM_MAX_QUIT_COUNT=<max_cnt>,1                     - Set max numnber of UVM_ERRORS before quiting"
	@echo "         +uvm_set_verbosity=<comp>,_ALL_,<verbosity>,<phase> - Fine-grain verbosity control"
	@echo "-----------------------------------------------------------------------------------------------------"

#--------------------------------------------------------------------
# END OF FILE
#----------------------------------------------
