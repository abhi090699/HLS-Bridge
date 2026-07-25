`ifndef CDN_PCIE_HLS_BRIDGE_DUT_MISC_IF_SV
`define CDN_PCIE_HLS_BRIDGE_DUT_MISC_IF_SV

//------------------------------------------------------------------------------
// Interface: cdn_pcie_hls_bridge_dut_misc_if
//------------------------------------------------------------------------------
interface cdn_pcie_hls_bridge_dut_misc_if #(
  parameter NUM_HLS_PORTS = 2,
  parameter KMAX_NUM_PFS  = 16,
  parameter NUM_TCS       = 8,
  parameter NUM_LTI_PORTS = 4,
  parameter IDE_NUM_LINK_STREAMS = 8,
  parameter IDE_NUM_SEL_STREAMS = 8
) 
(
  input clk                                                                   ,
  input rst_n                                                                 ,

  inout [1:0]                               misc_flit_mode                    ,
  inout                                     misc_mld_negotiated               ,
  inout                                     misc_pbr_negotiated               ,
  inout                                     misc_10_bit_tag_completer_support ,
  inout                                     misc_14_bit_tag_completer_support ,
  inout [7:0]                               misc_captured_dest_segment        ,
  inout                                     misc_segment_captured             ,
  inout [KMAX_NUM_PFS-1:0]                  misc_ecrc_generation_enable_per_pf,
  inout                                     misc_read_completion_boundary     ,
  inout [4*NUM_TCS-1:0]                     tc_vc_mapping                     ,
  inout [NUM_HLS_PORTS*32-1:0]              misc_tag_management               ,
  inout [8:0]                               lm_segment_num                    ,
  inout                                     link_down_handling_in_progress    ,
  inout [IDE_NUM_LINK_STREAMS*12-1:0]       misc_ide_link_stream_control_reg  ,
  inout [IDE_NUM_SEL_STREAMS*14-1:0]        misc_ide_sel_stream_control_reg   ,
  inout [IDE_NUM_SEL_STREAMS*16-1:0]        misc_ide_sel_stream_rid_assoc1_reg,
  inout [IDE_NUM_SEL_STREAMS*25-1:0]        misc_ide_sel_stream_rid_assoc2_reg,
  
  // Miscellaneous Variables
  input time                                core_clk_period                   ,
  inout                                     pause_traffic                     ,
  inout [31:0]                              misc_hls_bridge_route_en          ,
  inout                                     low_power_mode
);

  //----------------------------------------------------------------------------
  // Package imports
  //----------------------------------------------------------------------------
  import uvm_pkg::*;
  import cdn_pcie_hls_bridge_dut_if_pkg::*;
  `include "uvm_macros.svh"

  // Miscellaneous Local Variables
  logic [($clog2(2 * NUM_LTI_PORTS)-1) : 0] lti_ctag_rr_counter;
  logic clk_gate;
  logic [5:0] lp_hls_active_req;
  
  //----------------------------------------------------------------------------
  // Clocking blocks
  //----------------------------------------------------------------------------
  clocking cb @(posedge clk);
    output misc_flit_mode                    ;
    output misc_mld_negotiated               ;
    output misc_pbr_negotiated               ;
    output misc_10_bit_tag_completer_support ;
    output misc_14_bit_tag_completer_support ;
    output misc_captured_dest_segment        ;
    output misc_segment_captured             ;
    output misc_ecrc_generation_enable_per_pf;
    output misc_read_completion_boundary     ;
    output misc_hls_bridge_route_en          ;
    output tc_vc_mapping                     ;
    output misc_tag_management               ;
    output lm_segment_num                    ;
    output link_down_handling_in_progress    ;
    output misc_ide_link_stream_control_reg  ;
    output misc_ide_sel_stream_control_reg   ;
    output misc_ide_sel_stream_rid_assoc1_reg;
    output misc_ide_sel_stream_rid_assoc2_reg;

    input  core_clk_period                   ;
    output pause_traffic                     ;
    output low_power_mode                    ;
    output clk_gate                          ;
  endclocking : cb

  clocking cb_mon @(posedge clk);
    input misc_flit_mode                    ;
    input misc_mld_negotiated               ;
    input misc_pbr_negotiated               ;
    input misc_10_bit_tag_completer_support ;
    input misc_14_bit_tag_completer_support ;
    input misc_captured_dest_segment        ;
    input misc_segment_captured             ;
    input misc_ecrc_generation_enable_per_pf;
    input misc_read_completion_boundary     ;
    input misc_hls_bridge_route_en          ;
    input tc_vc_mapping                     ;
    input misc_tag_management               ;
    input lm_segment_num                    ;
    input link_down_handling_in_progress    ;
    input misc_ide_link_stream_control_reg  ;
    input misc_ide_sel_stream_control_reg   ;
    input misc_ide_sel_stream_rid_assoc1_reg;
    input misc_ide_sel_stream_rid_assoc2_reg;

    input core_clk_period                   ;
    input lti_ctag_rr_counter               ;
    input pause_traffic                     ;
    input low_power_mode                    ;
    input lp_hls_active_req                 ;
  endclocking : cb_mon

  covergroup cg_misc_ecrc_generation_enable_per_pf (string cg_name) with function sample(bit misc_ecrc_generation_enable_per_pf);
    option.per_instance = 1;
    option.name = cg_name;

    cp_ecrc_generation_enable : coverpoint misc_ecrc_generation_enable_per_pf iff (rst_n == 1) {
      bins LEGAL_VALUES[] = {[1'b0 : 1'b1]};
    }  
  endgroup : cg_misc_ecrc_generation_enable_per_pf

  covergroup cg_misc_tag_management (string cg_name) with function sample(bit [31 : 0] misc_tag_management_per_port);
    option.per_instance = 1;
    option.name = cg_name;

    cp_OFFSET_9_0 : coverpoint misc_tag_management_per_port[9:0] iff (rst_n == 1) {
      bins LEGAL_RANGE[6] = {[10'h000 : 10'h3FF]};
    }

    cp_OFFSET_13_10 : coverpoint misc_tag_management_per_port[13:10] iff (rst_n == 1) {
      bins LEGAL_RANGE[3] = {[4'h0 : 4'hF]};
    }  

    cp_RANGE_9_0 : coverpoint misc_tag_management_per_port[25:16] iff (rst_n == 1) {
      bins LEGAL_RANGE[6] = {[10'h000 : 10'h3FF]};
    }

    cp_RANGE_13_10 : coverpoint misc_tag_management_per_port[29:26] iff (rst_n == 1) {
      bins LEGAL_RANGE[3] = {[4'h0 : 4'hF]};
    }  
  endgroup : cg_misc_tag_management

  covergroup cg_misc_if (string cg_name) with function sample(bit[1:0] misc_flit_mode,
                                                              bit misc_mld_negotiated,
                                                              bit misc_pbr_negotiated,
                                                              bit misc_10_bit_tag_completer_support,
                                                              bit misc_14_bit_tag_completer_support,
                                                              bit[7:0] misc_captured_dest_segment,
                                                              bit misc_segment_captured,
                                                              bit misc_read_completion_boundary,
                                                              bit[8:0] lm_segment_num,
                                                              bit link_down_handling_in_progress
                                                              );
    option.per_instance = 1;
    option.name = cg_name;

    cp_misc_flit_mode : coverpoint misc_flit_mode iff (rst_n == 1) {
      bins FLIT_MODE                          = { 2'b10 } with (parameters_cfg_pkg::CUST_CFG ? (parameters_cfg_pkg::COV_KMAX_FLIT_MODE_SUPPORT == 1) : (parameters_cfg_pkg::KMAX_FLIT_MODE_SUPPORT == 1));
      bins NON_FLIT_MODE                      = { 2'b01 } with (parameters_cfg_pkg::CUST_CFG ? (parameters_cfg_pkg::COV_KMAX_FLIT_MODE_SUPPORT == 0) : (parameters_cfg_pkg::KMAX_FLIT_MODE_SUPPORT == 0));
      bins FLIT_MODE_NEGOTIATION_NOT_COMPLETE = { 2'b00 } with (parameters_cfg_pkg::CUST_CFG ? (parameters_cfg_pkg::COV_KMAX_FLIT_MODE_SUPPORT == 1) : (parameters_cfg_pkg::KMAX_FLIT_MODE_SUPPORT == 1));
      ignore_bins RESERVED                    = { 2'b11 };
    }

    cp_misc_mld_negotiated : coverpoint misc_mld_negotiated iff (rst_n == 1) {
      bins NEGOTIATED     = { 1'b1 } with (parameters_cfg_pkg::CUST_CFG ? (parameters_cfg_pkg::COV_KMAX_CXL_SUPPORT == 1) : 1);
      bins NOT_NEGOTIATED = { 1'b0 } with (parameters_cfg_pkg::CUST_CFG ? (parameters_cfg_pkg::COV_KMAX_CXL_SUPPORT == 0) : 1);
    }

    cp_misc_pbr_negotiated : coverpoint misc_pbr_negotiated iff (rst_n == 1) {
      bins NEGOTIATED     = { 1'b1 } with (parameters_cfg_pkg::CUST_CFG ? (parameters_cfg_pkg::COV_KMAX_PBR_SUPPORT[1] == 1) : 1);
      bins NOT_NEGOTIATED = { 1'b0 } with (parameters_cfg_pkg::CUST_CFG ? (parameters_cfg_pkg::COV_KMAX_PBR_SUPPORT[1] == 0) : 1);
    }

    cp_misc_10_bit_tag_completer_support : coverpoint misc_10_bit_tag_completer_support iff (rst_n == 1) {
      bins TAG_ENABLED  = {1'b1};
      bins TAG_DISABLED = {1'b0};
    }

    cp_misc_14_bit_tag_completer_support : coverpoint misc_14_bit_tag_completer_support iff (rst_n == 1) {
      bins TAG_ENABLED  = {1'b1};
      bins TAG_DISABLED = {1'b0};
    }

    cp_misc_captured_dest_segment : coverpoint misc_captured_dest_segment iff (rst_n == 1) {
      bins CAPTURED_DEST_SEGMENT_LOW    = {[0:50]};
      bins CAPTURED_DEST_SEGMENT_MEDIUM = {[51:150]};
      bins CAPTURED_DEST_SEGMENT_HIGH   = {[151:255]};
    }

    cp_misc_segment_captured : coverpoint misc_segment_captured iff (rst_n == 1) {
      bins SEGMENT_CAPTURED     = {1'b1};
      bins SEGMENT_NOT_CAPTURED = {1'b0};
    }
    
    cp_misc_read_completion_boundary : coverpoint misc_read_completion_boundary iff (rst_n == 1) {
      bins READ_COMPLETION_BOUNDARY_64B  = {1'b0};
      bins READ_COMPLETION_BOUNDARY_128B = {1'b1};
    }

    cp_lm_segment_num : coverpoint lm_segment_num[7:0] iff (rst_n == 1){
      bins LEGAL_VALUES[3] = {[8'h00 : 8'hFF]};
    }

    cp_lm_segment_num_valid : coverpoint lm_segment_num[8] iff (rst_n == 1){
      bins LEGAL_VALUES[] = {[1'b0 : 1'b1]};
    }

    cp_lm_segment_num_X_lm_segment_num_valid : cross cp_lm_segment_num, cp_lm_segment_num_valid;

    cp_link_down_handling_in_progress : coverpoint link_down_handling_in_progress iff(rst_n == 1) {
      bins LINKDOWN_ENTRY = (1'b0 => 1'b1);
      bins LINKDOWN_EXIT  = (1'b1 => 1'b0);
    }
  endgroup : cg_misc_if

  covergroup cg_ide_link_dti_regs (string cg_name) with function sample(bit [11:0] misc_ide_link_stream_control_reg);
    option.per_instance = 1;
    option.name = cg_name;

    // ide_link_stream_control_reg[11:4] //Stream ID
    // ide_link_stream_control_reg[3:1]  //TC
    // ide_link_stream_control_reg[0]    //Link IDE stream Enable
    cp_misc_ide_link_stream_control_reg_str_id: coverpoint misc_ide_link_stream_control_reg[11:4] iff(rst_n == 1 && misc_ide_link_stream_control_reg[0] == 1) {
      bins STREAM_ID[] = {[0:8]};
    }
    cp_misc_ide_link_stream_control_reg_tc : coverpoint misc_ide_link_stream_control_reg[3:1] iff(rst_n == 1 && misc_ide_link_stream_control_reg[0] == 1) {
      bins TC[] = {[0:7]};
    }
    cp_misc_ide_link_stream_control_reg_enable : coverpoint misc_ide_link_stream_control_reg[0] iff(rst_n == 1) {
      bins ENABLE  = {1};
      bins DISABLE = {0};
    }
  endgroup : cg_ide_link_dti_regs

  covergroup cg_ide_sel_dti_regs (string cg_name) with function sample(bit [13:0] misc_ide_sel_stream_control_reg,
                                                                       bit [15:0] misc_ide_sel_stream_rid_assoc1_reg,
                                                                       bit [24:0] misc_ide_sel_stream_rid_assoc2_reg
                                                                      );
    option.per_instance = 1;
    option.name = cg_name;

    // misc_ide_sel_stream_control_reg[13:6] //Stream ID
    // misc_ide_sel_stream_control_reg[5]    //TEE-Limited Stream
    // misc_ide_sel_stream_control_reg[4]    //Default Stream
    // misc_ide_sel_stream_control_reg[3:1]  //TC
    // misc_ide_sel_stream_control_reg[0]    //Selective IDE stream Enable
    cp_misc_ide_sel_stream_control_reg_str_id : coverpoint misc_ide_sel_stream_control_reg[13:6] iff(rst_n == 1 && misc_ide_sel_stream_control_reg[0] == 1) {
      bins STREAM_ID[] = {[0:8]};
    }
    cp_misc_ide_sel_stream_control_reg_tee_lim_str : coverpoint misc_ide_sel_stream_control_reg[5] iff(rst_n == 1 && misc_ide_sel_stream_control_reg[0] == 1) {
      bins TEE_LIMITED_STREAM = {1};
    }
    cp_misc_ide_sel_stream_control_reg_default_str : coverpoint misc_ide_sel_stream_control_reg[4] iff(rst_n == 1 && misc_ide_sel_stream_control_reg[0] == 1) {
      bins DEFAULT_STREAM = {1};
    }
    cp_misc_ide_sel_stream_control_reg_tc : coverpoint misc_ide_sel_stream_control_reg[3:1] iff(rst_n == 1 && misc_ide_sel_stream_control_reg[0] == 1) {
      bins TC[] = {[0:7]};
    }
    cp_misc_ide_sel_stream_control_reg_enable : coverpoint misc_ide_sel_stream_control_reg[0] iff(rst_n == 1) {
      bins ENABLE  = {1};
      bins DISABLE = {0};
    }

    // misc_ide_sel_stream_rid_assoc1_reg // RID Limit
    cp_misc_ide_sel_stream_rid_assoc1_reg_rid_lim : coverpoint misc_ide_sel_stream_rid_assoc1_reg iff(rst_n == 1 && misc_ide_sel_stream_rid_assoc2_reg[0] == 1) {
      bins RID_LIMIT[8] = {[0:'hFFFF]};
    }

    // misc_ide_sel_stream_rid_assoc2_reg[24:17] //Segment Base
    // misc_ide_sel_stream_rid_assoc2_reg[16:1]  //RID Base
    // misc_ide_sel_stream_rid_assoc2_reg[0]     //Valid
    cp_misc_ide_sel_stream_rid_assoc2_reg_seg_base: coverpoint misc_ide_sel_stream_rid_assoc2_reg[24:17] iff(rst_n == 1 && misc_ide_sel_stream_rid_assoc2_reg[0] == 1) {
      bins SEGMENT_BASE[8] = {[0:'hFF]};
    }
    cp_misc_ide_sel_stream_rid_assoc2_reg_rid_base: coverpoint misc_ide_sel_stream_rid_assoc2_reg[16:1] iff(rst_n == 1 && misc_ide_sel_stream_rid_assoc2_reg[0] == 1) {
      bins RID_BASE[8] = {[0:'hFFFF]};
    }
    cp_misc_ide_sel_stream_rid_assoc2_reg_valid: coverpoint misc_ide_sel_stream_rid_assoc2_reg[0] iff(rst_n == 1) {
      bins VALID = {1};
      bins NOT_VALID = {0};
    }
  endgroup : cg_ide_sel_dti_regs

  covergroup cg_tc_vc_mapping (string cg_name) with function sample(bit[31:0] tc_vc_mapping);
    option.per_instance = 1;
    option.name = cg_name;
    cp_TC0_mapped : coverpoint tc_vc_mapping[2:0] iff (rst_n == 1 && tc_vc_mapping[3] == 0) {
      bins VC[] = {0};
    }
    cp_TC1_mapped : coverpoint tc_vc_mapping[6:4] iff (rst_n == 1 && tc_vc_mapping[7] == 0) {
      bins VC[] = {[0:7]} with (item <= parameters_cfg_pkg::COV_KMAX_NUM_VCS);
    }
    cp_TC2_mapped : coverpoint tc_vc_mapping[10:8] iff (rst_n == 1 && tc_vc_mapping[11] == 0) {
      bins VC[] = {[0:7]} with (item <= parameters_cfg_pkg::COV_KMAX_NUM_VCS);
    }
    cp_TC3_mapped : coverpoint tc_vc_mapping[14:12] iff (rst_n == 1 && tc_vc_mapping[15] == 0) {
      bins VC[] = {[0:7]} with (item <= parameters_cfg_pkg::COV_KMAX_NUM_VCS);
    }
    cp_TC4_mapped : coverpoint tc_vc_mapping[18:16] iff (rst_n == 1 && tc_vc_mapping[19] == 0) {
      bins VC[] = {[0:7]} with (item <= parameters_cfg_pkg::COV_KMAX_NUM_VCS);
    }
    cp_TC5_mapped : coverpoint tc_vc_mapping[22:20] iff (rst_n == 1 && tc_vc_mapping[23] == 0) {
      bins VC[] = {[0:7]} with (item <= parameters_cfg_pkg::COV_KMAX_NUM_VCS);
    }
    cp_TC6_mapped : coverpoint tc_vc_mapping[26:24] iff (rst_n == 1 && tc_vc_mapping[27] == 0) {
      bins VC[] = {[0:7]} with (item <= parameters_cfg_pkg::COV_KMAX_NUM_VCS);
    }
    cp_TC7_mapped : coverpoint tc_vc_mapping[30:28] iff (rst_n == 1 && tc_vc_mapping[31] == 0) {
      bins VC[] = {[0:7]} with (item <= parameters_cfg_pkg::COV_KMAX_NUM_VCS);
    }
  endgroup : cg_tc_vc_mapping

  //----------------------------------------------------------------------------
  // Implementation of interface class within the scope of the SV if
  //----------------------------------------------------------------------------
  class cdn_pcie_hls_bridge_dut_misc_api #(
    parameter NUM_HLS_PORTS = 2 ,
    parameter KMAX_NUM_PFS  = 16,
    parameter NUM_TCS       = 8,
    parameter NUM_LTI_PORTS = 4,
    parameter IDE_NUM_LINK_STREAMS = 8,
    parameter IDE_NUM_SEL_STREAMS = 8
  ) extends cdn_pcie_hls_bridge_dut_misc_if_api_base#(.NUM_HLS_PORTS( NUM_HLS_PORTS ),
                                                      .KMAX_NUM_PFS ( KMAX_NUM_PFS  ),
                                                      .NUM_TCS      ( NUM_TCS       ),
                                                      .NUM_LTI_PORTS( NUM_LTI_PORTS ),
                                                      .IDE_NUM_LINK_STREAMS( IDE_NUM_LINK_STREAMS ),
                                                      .IDE_NUM_SEL_STREAMS( IDE_NUM_SEL_STREAMS )
                                                     );

    //----------------------------------------------------------------------------
    // UVM automation macros
    //----------------------------------------------------------------------------
    `uvm_object_param_utils(cdn_pcie_hls_bridge_dut_misc_api #(NUM_HLS_PORTS, KMAX_NUM_PFS, NUM_TCS, NUM_LTI_PORTS, IDE_NUM_LINK_STREAMS, IDE_NUM_SEL_STREAMS))

    cg_misc_ecrc_generation_enable_per_pf cg_misc_ecrc_generation_enable_per_pf_h[KMAX_NUM_PFS];
    cg_misc_tag_management                cg_misc_tag_management_h[NUM_HLS_PORTS];
    cg_misc_if                            cg_misc_if_h;
    cg_tc_vc_mapping                      cg_tc_vc_mapping_h;
    cg_ide_link_dti_regs                  cg_ide_link_dti_regs_h[IDE_NUM_LINK_STREAMS];
    cg_ide_sel_dti_regs                   cg_ide_sel_dti_regs_h[IDE_NUM_SEL_STREAMS];
    
    //--------------------------------------------------------------------------
    // Function: new
    // Class constructor.
    //--------------------------------------------------------------------------
    function new(string name="cdn_pcie_hls_bridge_dut_misc_api");
      super.new(name);
      cg_misc_if_h       = new("cg_misc_if_h");
      cg_tc_vc_mapping_h = new("cg_tc_vc_mapping_h");
      foreach (cg_ide_link_dti_regs_h[i])
        cg_ide_link_dti_regs_h[i] = new($sformatf("cg_ide_link_dti_regs_h_%0d", i));
      foreach (cg_ide_sel_dti_regs_h[i])
        cg_ide_sel_dti_regs_h[i] = new($sformatf("cg_ide_sel_dti_regs_h_%0d", i));
      foreach (cg_misc_ecrc_generation_enable_per_pf_h[i])
        cg_misc_ecrc_generation_enable_per_pf_h[i] = new($sformatf("cg_misc_ecrc_generation_enable_per_pf_h_%0d", i));
      for(int i = 0; i < NUM_HLS_PORTS; i++)      
        cg_misc_tag_management_h[i] = new($sformatf("cg_misc_tag_management_h_%0d", i));
    endfunction : new
    
    //-------------------------------------------------------------------------
    // Method: reset
    //-------------------------------------------------------------------------
    virtual task reset();
      cb.misc_flit_mode                     <= 'd0;
      cb.misc_mld_negotiated                <= 'd0;
      cb.misc_pbr_negotiated                <= 'd0;
      cb.misc_10_bit_tag_completer_support  <= 'd0;
      cb.misc_14_bit_tag_completer_support  <= 'd0;
      cb.misc_captured_dest_segment         <= 'd0;
      cb.misc_segment_captured              <= 'd0;
      cb.misc_ecrc_generation_enable_per_pf <= 'd0;
      cb.misc_read_completion_boundary      <= 'd0;
      cb.tc_vc_mapping                      <= 'd0;
      cb.misc_tag_management                <= 'd0;
      cb.lm_segment_num                     <= 'd0;
      cb.link_down_handling_in_progress     <= 'd0;
      cb.pause_traffic                      <= 'd0;
      cb.low_power_mode                     <= 'd0;
      cb.clk_gate                           <= 'd0;
      cb.misc_hls_bridge_route_en           <= 'd0;
      cb.misc_ide_link_stream_control_reg   <= 'd0;
      cb.misc_ide_sel_stream_control_reg    <= 'd0;
      cb.misc_ide_sel_stream_rid_assoc1_reg <= 'd0;
      cb.misc_ide_sel_stream_rid_assoc2_reg <= 'd0;
    endtask : reset
    
    //-------------------------------------------------------------------------
    // Method: wait_cb
    //-------------------------------------------------------------------------
    virtual task wait_cb(int clk_cycles = 1);
      repeat(clk_cycles) begin
        @(cb_mon);
      end
    endtask : wait_cb
   
    //-------------------------------------------------------------------------
    // Method: cover_if
    //-------------------------------------------------------------------------
    virtual task cover_if();
      forever begin
        @(posedge rst_n or
          cb_mon.misc_flit_mode or
          cb_mon.misc_mld_negotiated or
          cb_mon.misc_pbr_negotiated or
          cb_mon.misc_10_bit_tag_completer_support or
          cb_mon.misc_14_bit_tag_completer_support or
          cb_mon.misc_captured_dest_segment or
          cb_mon.misc_segment_captured or
          cb_mon.misc_ecrc_generation_enable_per_pf or
          cb_mon.misc_read_completion_boundary or
          cb_mon.tc_vc_mapping or 
          cb_mon.misc_tag_management or
          cb_mon.lm_segment_num or
          cb_mon.link_down_handling_in_progress or
          cb_mon.misc_ide_link_stream_control_reg or
          cb_mon.misc_ide_sel_stream_control_reg or
          cb_mon.misc_ide_sel_stream_rid_assoc1_reg or
          cb_mon.misc_ide_sel_stream_rid_assoc2_reg
        );

        cg_misc_if_h.sample(.misc_flit_mode(cb_mon.misc_flit_mode),
                            .misc_mld_negotiated(cb_mon.misc_mld_negotiated),
                            .misc_pbr_negotiated(cb_mon.misc_pbr_negotiated),
                            .misc_10_bit_tag_completer_support(cb_mon.misc_10_bit_tag_completer_support),
                            .misc_14_bit_tag_completer_support(cb_mon.misc_14_bit_tag_completer_support),
                            .misc_captured_dest_segment(cb_mon.misc_captured_dest_segment),
                            .misc_segment_captured(cb_mon.misc_segment_captured),
                            .misc_read_completion_boundary(cb_mon.misc_read_completion_boundary),
                            .lm_segment_num(cb_mon.lm_segment_num),
                            .link_down_handling_in_progress(cb_mon.link_down_handling_in_progress)
                            );
        cg_tc_vc_mapping_h.sample(cb_mon.tc_vc_mapping);

        
        foreach (cg_ide_link_dti_regs_h[i]) begin
          bit [11:0] ide_link_stream_control_reg;
          get_misc_ide_link_stream_control_reg(ide_link_stream_control_reg, i);
          cg_ide_link_dti_regs_h[i].sample(.misc_ide_link_stream_control_reg(ide_link_stream_control_reg));
        end
        foreach (cg_ide_sel_dti_regs_h[i]) begin
          bit [13:0] ide_sel_stream_control_reg;
          bit [15:0] ide_sel_stream_rid_assoc1_reg;
          bit [24:0] ide_sel_stream_rid_assoc2_reg;
          get_misc_ide_sel_stream_control_reg(ide_sel_stream_control_reg, i);
          get_misc_ide_sel_stream_rid_assoc1_reg(ide_sel_stream_rid_assoc1_reg, i);
          get_misc_ide_sel_stream_rid_assoc2_reg(ide_sel_stream_rid_assoc2_reg, i);
          cg_ide_sel_dti_regs_h[i].sample(.misc_ide_sel_stream_control_reg(ide_sel_stream_control_reg),
                                          .misc_ide_sel_stream_rid_assoc1_reg(ide_sel_stream_rid_assoc1_reg),
                                          .misc_ide_sel_stream_rid_assoc2_reg(ide_sel_stream_rid_assoc2_reg)
                                         );
        end
        foreach (cg_misc_ecrc_generation_enable_per_pf_h[i])
          cg_misc_ecrc_generation_enable_per_pf_h[i].sample(cb_mon.misc_ecrc_generation_enable_per_pf[i]);
        for(int i = 0; i < NUM_HLS_PORTS; i++)          
          cg_misc_tag_management_h[i].sample(cb_mon.misc_tag_management[(32 * i) +: 32]);
      end
    endtask : cover_if

    //-------------------
    // API implementation
    //-------------------
    task set_misc_flit_mode(bit [1 : 0] value);
      cb.misc_flit_mode <= value;
    endtask : set_misc_flit_mode

    task set_misc_pbr_negotiated(bit value);
      cb.misc_pbr_negotiated <= value;
    endtask : set_misc_pbr_negotiated

    task set_misc_tag_management(bit [NUM_HLS_PORTS*32-1 : 0] value);
      cb.misc_tag_management <= value;
    endtask : set_misc_tag_management

    task set_misc_10_bit_comp_supp(bit value);
      cb.misc_10_bit_tag_completer_support <= value;
    endtask : set_misc_10_bit_comp_supp

    task set_misc_14_bit_comp_supp(bit value);
      cb.misc_14_bit_tag_completer_support <= value;
    endtask : set_misc_14_bit_comp_supp
    
    task set_lm_segment_num(bit [8 : 0] value);
      cb.lm_segment_num <= value;
    endtask : set_lm_segment_num

    task set_misc_segment_captured(bit value);
      cb.misc_segment_captured <= value;
    endtask : set_misc_segment_captured

    task set_misc_ecrc_generation_enable_per_pf(bit [8:0] value);
      cb.misc_ecrc_generation_enable_per_pf <= value;
    endtask : set_misc_ecrc_generation_enable_per_pf

    task set_tc_vc_mapping(bit [4*NUM_TCS-1:0] value);
      cb.tc_vc_mapping <= value;
    endtask : set_tc_vc_mapping

    task set_misc_read_completion_boundary(bit value);
      cb.misc_read_completion_boundary <= value;
    endtask : set_misc_read_completion_boundary

    task set_misc_captured_dest_segment(bit[7:0] value);
      cb.misc_captured_dest_segment <= value;
    endtask : set_misc_captured_dest_segment

    task set_link_down_handling_in_progress(bit value);
      cb.link_down_handling_in_progress <= value;
    endtask : set_link_down_handling_in_progress

    task set_low_power_mode(bit value);
      cb.low_power_mode <= value;
    endtask : set_low_power_mode

    task set_pause_traffic(bit value);
      cb.pause_traffic <= value;
    endtask : set_pause_traffic

    task set_misc_hls_bridge_route_en(bit[31:0] value);
      cb.misc_hls_bridge_route_en <= value;
    endtask : set_misc_hls_bridge_route_en

    task set_misc_ide_link_stream_control_reg(bit [IDE_NUM_LINK_STREAMS*12-1:0] value);
      cb.misc_ide_link_stream_control_reg <= value;
    endtask : set_misc_ide_link_stream_control_reg

    task set_misc_ide_sel_stream_control_reg(bit [IDE_NUM_SEL_STREAMS*14-1:0] value);
      cb.misc_ide_sel_stream_control_reg <= value;
    endtask : set_misc_ide_sel_stream_control_reg

    task set_misc_ide_sel_stream_rid_assoc1_reg(bit [IDE_NUM_SEL_STREAMS*16-1:0] value);
      cb.misc_ide_sel_stream_rid_assoc1_reg <= value;
    endtask : set_misc_ide_sel_stream_rid_assoc1_reg

    task set_misc_ide_sel_stream_rid_assoc2_reg(bit [IDE_NUM_SEL_STREAMS*25-1:0] value);
      cb.misc_ide_sel_stream_rid_assoc2_reg <= value;
    endtask : set_misc_ide_sel_stream_rid_assoc2_reg

    function void get_misc_flit_mode(ref bit [1 : 0] value);
      value = cb_mon.misc_flit_mode;
    endfunction : get_misc_flit_mode

    function void get_misc_pbr_negotiated(ref bit value);
      value = cb_mon.misc_pbr_negotiated;
    endfunction : get_misc_pbr_negotiated
    
    function void get_misc_tag_management(ref bit [NUM_HLS_PORTS*32-1 : 0] value);
      value = cb_mon.misc_tag_management;
    endfunction : get_misc_tag_management
    
    function void get_link_down_handling_in_progress(ref bit value);
      value = cb_mon.link_down_handling_in_progress;
    endfunction : get_link_down_handling_in_progress

    function void get_lm_segment_num(ref bit [8 : 0] value);
      value = cb_mon.lm_segment_num;
    endfunction : get_lm_segment_num

    function void get_core_clk_period(ref time value);
      value = cb_mon.core_clk_period;
    endfunction : get_core_clk_period

    function void get_lti_ctag_rr_counter(ref bit [($clog2(2 * NUM_LTI_PORTS)-1) : 0] value);
      value = cb_mon.lti_ctag_rr_counter;
    endfunction : get_lti_ctag_rr_counter
    
    task wait_unpause_traffic();
      wait(cb_mon.pause_traffic == 0);
    endtask : wait_unpause_traffic

    task wait_link_down_handling_in_progress(bit wait_value);
      wait(cb_mon.link_down_handling_in_progress == wait_value);
    endtask : wait_link_down_handling_in_progress

    task clk_gate_en(bit value);
      cb.clk_gate <= value;
    endtask : clk_gate_en

    function void get_hls_active_req(ref bit [5:0] value);
      value = cb_mon.lp_hls_active_req;
    endfunction : get_hls_active_req

    function void get_misc_hls_bridge_route_en(ref bit[31:0] value);
      value = cb_mon.misc_hls_bridge_route_en;
    endfunction : get_misc_hls_bridge_route_en

    function void get_misc_ide_link_stream_control_reg(ref bit [11:0] value, input int idx);
      for(int i=0; i<12; i++)
        value[i] = cb_mon.misc_ide_link_stream_control_reg[i+idx*12];
    endfunction : get_misc_ide_link_stream_control_reg

    function void get_misc_ide_sel_stream_control_reg(ref bit [13:0] value, input int idx);
      for(int i=0; i<14; i++)
        value[i] = cb_mon.misc_ide_sel_stream_control_reg[i+idx*14];
    endfunction : get_misc_ide_sel_stream_control_reg

    function void get_misc_ide_sel_stream_rid_assoc1_reg(ref bit [15:0] value, input int idx);
      for(int i=0; i<16; i++)
        value[i] = cb_mon.misc_ide_sel_stream_rid_assoc1_reg[i+idx*16];
    endfunction : get_misc_ide_sel_stream_rid_assoc1_reg

    function void get_misc_ide_sel_stream_rid_assoc2_reg(ref bit [24:0] value, input int idx);
      for(int i=0; i<25; i++)
        value[i] = cb_mon.misc_ide_sel_stream_rid_assoc2_reg[i+idx*25];
    endfunction : get_misc_ide_sel_stream_rid_assoc2_reg

  endclass : cdn_pcie_hls_bridge_dut_misc_api

  // Instance of API class
  cdn_pcie_hls_bridge_dut_misc_api #(.NUM_HLS_PORTS        ( NUM_HLS_PORTS ),
                                     .KMAX_NUM_PFS         ( KMAX_NUM_PFS  ),
                                     .NUM_TCS              ( NUM_TCS       ),
                                     .NUM_LTI_PORTS        ( NUM_LTI_PORTS ),
                                     .IDE_NUM_LINK_STREAMS ( IDE_NUM_LINK_STREAMS ),
                                     .IDE_NUM_SEL_STREAMS  ( IDE_NUM_SEL_STREAMS  )) api = new();

  //------------------------
  // Additional Logic
  //------------------------
  //--- LTI CTag RR Counter ------------------
  always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
      lti_ctag_rr_counter <= '0;
    end
    else begin
      lti_ctag_rr_counter <= lti_ctag_rr_counter + 1'b1;
    end
  end

endinterface : cdn_pcie_hls_bridge_dut_misc_if

`endif // CDN_PCIE_HLS_BRIDGE_DUT_K_IF_SV
