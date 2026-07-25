`ifndef CDN_PCIE_HLS_BRIDGE_SCENARIO_SV
`define CDN_PCIE_HLS_BRIDGE_SCENARIO_SV
  
//------------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_scenario
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_scenario extends cdn_pcie_scenario;

  //----------------------------------------------------------------------------
  // Variables
  //----------------------------------------------------------------------------
  //- control variables ----------------------------------------------------------
       cdn_pcie_hls_bridge_traffic_type_e                    m_traffic_type             ;
       cdn_pcie_hls_bridge_fc_type_e                         m_fc_type                  ;
       cdn_pcie_hls_bridge_ib_target_e                       m_ib_target                ;
  rand cdn_pcie_hls_bridge_backpressure_scenario_e           m_backpressure_scenario    ;    
       bit                                                   m_sanity_test              ;
  rand int unsigned                                          m_number_of_tlp_bursts     ; 
  rand int unsigned                                          m_number_of_tlps           ;
       int unsigned                                          m_num_hard_resets          ;
       int unsigned                                          m_num_link_downs           ;
       bit                                                   m_qos_support              ;
`ifdef DTI_TB_IN_PASSIVE_MODE
  rand int unsigned                                          m_num_ats_inv_reqs         ;
       bit [2:0]                                             m_dti_inv_tc               ;
  rand bit                                                   m_dti_interrupt_scenario   ;
  rand bit                                                   m_force_ats_trans_fault    ;
`endif
  rand bit                                                   en_axi_slv_error_injection ;

  //- k_wire controls ----------------------------------------------------------
  rand bit [1:0]                                             m_strap_port_type          ;
  rand bit                                                   m_k_flit_mode_support      ;
  rand bit [2:0]                                             m_k_hls_dw_alignment       ;

  //- misc controls ------------------------------------------------------------
  rand bit [1:0]                                             m_misc_flit_mode           ;
  rand bit [(parameters_cfg_pkg::NUM_HLS_PORTS*32)-1 : 0]    m_misc_tag_management      ;
  rand bit [8:0]                                             m_lm_segment_num           ;
  rand bit                                                   m_sup_pri                  ;
  rand bit                                                   m_unmapped_reg_access      ;
  rand bit                                                   m_low_power_mode           ;
  rand cdn_pcie_hls_bridge_route_en_s                        m_hls_bridge_route_en      ;

  //- Miscellaneous Variables --------------------------------------------------
       int unsigned                                          m_num_hard_resets_done     ;
       int unsigned                                          m_num_link_downs_done      ;
       int unsigned                                          m_msi_pf                   ;

  //- Credit lmt Variables -------------------------------------------------------
  rand bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD-1:0]  crd_lmt_posted_header  [parameters_cfg_pkg::KMAX_NUM_VCS-1:0]    ;
  rand bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD-1:0] crd_lmt_posted_payload [parameters_cfg_pkg::KMAX_NUM_VCS-1:0]    ;
  rand bit [parameters_cfg_pkg::CRD_IN_LMT_CNTL_WD-1:0]    crd_lmt_posted_cntl    [parameters_cfg_pkg::KMAX_NUM_VCS-1:0]    ;
  
  rand bit [parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD-1:0]  crd_lmt_nonposted_header  [parameters_cfg_pkg::KMAX_NUM_VCS-1:0] ;
  rand bit [parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD-1:0] crd_lmt_nonposted_payload [parameters_cfg_pkg::KMAX_NUM_VCS-1:0] ;
  rand bit [parameters_cfg_pkg::CRD_IN_LMT_CNTL_WD-1:0]    crd_lmt_nonposted_cntl    [parameters_cfg_pkg::KMAX_NUM_VCS-1:0] ;
   
  //- UIO setting ---------------------------------------------------------------
  rand bit [1:0]                                             m_num_uio_vcs;

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------
  constraint c_m_backpressure_scenario {
    m_backpressure_scenario == cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_backpressure_scenario_e'(BACKPRESSURE_NONE);
  }
  
  constraint c_m_number_of_tlp_bursts {
    m_number_of_tlp_bursts dist {[1:5] := 1, [5:10] := 99};
    (m_sanity_test == 1'b1) -> (m_number_of_tlp_bursts == 1);
    (m_backpressure_scenario != cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_backpressure_scenario_e'(BACKPRESSURE_NONE)) -> (m_number_of_tlp_bursts < 5);
    (m_num_hard_resets > 0 || m_num_link_downs > 0) -> (m_number_of_tlp_bursts > 5);
  }

  constraint c_m_number_of_tlps {
    m_number_of_tlps dist {[1:49] :/ 1, [50:199] :/ 200, [200:299] :/ 600, [300:400] :/ 200};
    (m_sanity_test == 1'b1) -> (m_number_of_tlps == 20);
    (m_backpressure_scenario != cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_backpressure_scenario_e'(BACKPRESSURE_NONE)) -> (m_number_of_tlps < 60);
    (m_num_hard_resets > 0 || m_num_link_downs > 0) -> (m_number_of_tlps > 150);
  }

  constraint c_max_number_of_tlps_in_test {
    (m_num_hard_resets > 0 || m_num_link_downs > 0) -> ((m_number_of_tlps * m_number_of_tlp_bursts) <= 1000);
    (m_number_of_tlps * m_number_of_tlp_bursts) <= 2000;
    soft (m_number_of_tlps * m_number_of_tlp_bursts) > 500;
  }

`ifdef DTI_TB_IN_PASSIVE_MODE
  constraint c_m_num_ats_inv_reqs {
    m_num_ats_inv_reqs == 0;
  }

  constraint c_m_dti_interrupt_scenario {
    m_dti_interrupt_scenario == 0;
  }

  constraint c_m_force_ats_trans_fault {
    m_force_ats_trans_fault == 0;
  }
`endif

  constraint c_m_strap_port_type {
    (parameters_cfg_pkg::KMAX_PORT_TYPE < 2) ->  (m_strap_port_type == {1'b0, parameters_cfg_pkg::KMAX_PORT_TYPE[0]});
    (parameters_cfg_pkg::KMAX_PORT_TYPE == 2) -> (m_strap_port_type inside {0, 1, 2, 3});
    (parameters_cfg_pkg::KMAX_DTI_SUPPORT == 1 || parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT == 1) -> (m_strap_port_type == 1);
  }

  constraint c_m_k_flit_mode_support {
    m_k_flit_mode_support == parameters_cfg_pkg::KMAX_FLIT_MODE_SUPPORT;
  }

  constraint c_m_cxl_pbr_mode_sel {
    // EP feature. DTI does not support PBR mode
    (parameters_cfg_pkg::KMAX_DTI_SUPPORT == 1) -> (m_cxl_pbr_mode_sel == 0);
  }

  constraint c_m_k_hls_dw_alignment {
    m_k_hls_dw_alignment >= parameters_cfg_pkg::KMIN_START_ALIGNMENT_IN_DWS;
    m_k_hls_dw_alignment inside {4}; // 2 DW alignment is not supported in the design now so the below constraints don't even matter.
    ((parameters_cfg_pkg::KMAX_DATAPATH_WD == 128) && (parameters_cfg_pkg::KMAX_NUM_TLPS_PER_CLK == 2)) -> (m_k_hls_dw_alignment == 2); // For 128 DP && 2 TLPs per clk, dw_alignment can only be 2.
    ((parameters_cfg_pkg::HLS_PORT_DATA_WIDTH_ARR[(0*32) +: 32] == 128) && (parameters_cfg_pkg::HLS_PORT_TLPS_PER_CLK_ARR[(0*32) +: 32] == 2)) -> (m_k_hls_dw_alignment == 2); // For 128 DP && 2 TLPs per clk, dw_alignment can only be 2.
  }

  constraint c_misc_flit_mode {
    solve m_k_flit_mode_support before m_misc_flit_mode;
    if(m_k_flit_mode_support) {
      m_misc_flit_mode == 2'b10; //TODO: Should m_misc_flit_mode = 2'b00 tested - flitmode negotitation not complete.
    }
    else {
      m_misc_flit_mode == 2'b01;
    }
  }

  constraint c_lm_segment_num {
    m_lm_segment_num dist {[0:'hF] := 1, ['h10:'hFF] := 2, ['h100:'h1FF] := 1};
  }

  constraint c_en_axi_slv_error_injection {
    if(m_traffic_type inside {cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_traffic_type_e'(ALL_TRAFFIC), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_traffic_type_e'(AXI_REG_ACCESS_TRAFFIC_ONLY)})
      en_axi_slv_error_injection inside {0, 1};
    else 
      en_axi_slv_error_injection == 0;
  }
   
  constraint c_crd_lmt_header {
    foreach(crd_lmt_posted_header[i]) {
      crd_lmt_posted_header[i] dist {[0 : 2**parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD/3-1] := 1, 
                                     [2**parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD/3 : 2**parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD/3*2-1] := 2,
                                     [2**parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD/3*2 : 2**parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD-1] := 3};
    }

    foreach(crd_lmt_nonposted_header[i]) {
      crd_lmt_nonposted_header[i] dist {[0 : 2**parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD/3-1] := 1, 
                                        [2**parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD/3 : 2**parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD/3*2-1] := 2,
                                        [2**parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD/3*2 : 2**parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD-1] := 3};
    }
  }
			       
  constraint c_crd_lmt_payload {
    foreach(crd_lmt_posted_payload[i]) {
      crd_lmt_posted_payload[i] dist {[0 : 2**parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD/3-1] := 1, 
                                      [2**parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD/3 : 2**parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD/3*2-1] := 2,
                                      [2**parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD/3*2 : 2**parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD-1] := 3};
    }
     
    foreach(crd_lmt_nonposted_payload[i]) {
      crd_lmt_nonposted_payload[i] dist {[0 : 2**parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD/3-1] := 1, 
                                         [2**parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD/3 : 2**parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD/3*2-1] := 2,
                                         [2**parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD/3*2 : 2**parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD-1] := 3};
    }
  }
   
  constraint c_crd_lmt_cntl {
     foreach(crd_lmt_posted_cntl[i]){
       if(crd_lmt_posted_cntl[i][0] == 1) crd_lmt_posted_cntl[i][3:2] == 0;
       else crd_lmt_posted_cntl[i][3:2] > 0;
     
       if (crd_lmt_posted_cntl[i][1] == 1) crd_lmt_posted_cntl[i][5:4] == 0;
       else crd_lmt_posted_cntl[i][5:4] > 0;
     }
			     
     foreach(crd_lmt_nonposted_cntl[i]){
       if(crd_lmt_nonposted_cntl[i][0] == 1) crd_lmt_nonposted_cntl[i][3:2] == 0;
       else crd_lmt_nonposted_cntl[i][3:2] > 0;
     
       if (crd_lmt_nonposted_cntl[i][1] == 1) crd_lmt_nonposted_cntl[i][5:4] == 0;
       else crd_lmt_nonposted_cntl[i][5:4] > 0;
     }			     
  }

  constraint c_sup_pri {
    m_sup_pri == 1;
  }

  constraint c_unmapped_reg_access {
    m_unmapped_reg_access == 0;
  }

  constraint c_low_power_mode {
    m_low_power_mode == 0;
  }

  // Enabling pkt gaps in a CXS Flits. Only allowed for OB Traffic and not for
  // IB Traffic and only for 2DW Alignment there can be a gap since as per design
  // the TLP should start always at 4 DW Boundary hence for 4 DW Alignment
  // there won't be any gaps.
  constraint m_enable_pkt_gaps_dist_c { m_enable_pkt_gaps inside {0, 1}; }

  constraint c_num_uio_vcs { m_num_uio_vcs == parameters_cfg_pkg::NUM_UIO_VCS; }

  // NUM_UIO_VCS is always > 0 in the HLS bridge project, so unconditionally
  // enable all VCs — ensures all 8 TCs get mapped via the dev_top_config policy.
  constraint c_hlsb_num_vc_enabled { num_vc_enabled == cdn_pcie_scenario_pkg::ALL_VC; }

  // to improve coverage on cxs interfaces
  constraint m_pack_max_tlp_c {
    m_pack_max_tlp dist {0:=20, 1:=80};
  }

  constraint hlsb_ide_support_c {
    parameters_cfg_pkg::KMAX_IDE_SUPPORT -> m_ide_test_mode_sel inside {PCIE_IDE_ENABLE,PCIE_CXL_IDE_ENABLE};
    parameters_cfg_pkg::KMAX_IDE_SUPPORT && parameters_cfg_pkg::KMAX_DTI_SUPPORT -> m_tdisp_test_mode_sel == PCIE_TDISP_ENABLE;
  }

  constraint hlsb_k_pcie_rate_max_c {
    m_k_flit_mode_support -> k_pcie_rate_max >= 5;
    m_k_flit_mode_support -> m_gen_speed_test_mode_sel >= 5;
    parameters_cfg_pkg::KMAX_DTI_SUPPORT -> m_gen_speed_test_mode_sel > 0;
    parameters_cfg_pkg::KMAX_DTI_SUPPORT -> k_pcie_rate_max > 0;
  }

  // hls bridge routing setting
  constraint c_hls_bridge_route_en { $onehot0(m_hls_bridge_route_en);
                                     // TODO: vc_en or tc_en and ro_en only supported now
                                     m_hls_bridge_route_en.axi_force_en == 0;
                                     m_hls_bridge_route_en.tfc_ro_chk_en == 0;
                                     m_hls_bridge_route_en.addr_window_en == 0;
                                     m_hls_bridge_route_en.tfc_en == 0;
                                     m_hls_bridge_route_en.idg_en == 0;
                                     `ifdef HPA2_IDE_GEN7
                                      // TODO: release RO constraint
                                      m_hls_bridge_route_en.ro_en == 1;
                                      m_hls_bridge_route_en.vc_en == 0;
                                      m_hls_bridge_route_en.tc_en == 0;
                                     `else
                                      m_hls_bridge_route_en.ro_en == 0;
                                      m_hls_bridge_route_en.vc_en == 0;
                                      m_hls_bridge_route_en.tc_en == 0;
                                     `endif // HPA2_IDE_GEN7
                                     // reseved fields
                                     m_hls_bridge_route_en.rsvd0 == 0;
                                     m_hls_bridge_route_en.rsvd1 == 0;
                                   }

  //----------------------------------------------------------------------------
  // UVM automation macros
  //----------------------------------------------------------------------------
  `uvm_object_utils_begin(cdn_pcie_hls_bridge_scenario)
    `uvm_field_enum(cdn_pcie_hls_bridge_traffic_type_e         , m_traffic_type         , UVM_DEFAULT          )
    `uvm_field_enum(cdn_pcie_hls_bridge_fc_type_e              , m_fc_type              , UVM_DEFAULT          )
    `uvm_field_enum(cdn_pcie_hls_bridge_ib_target_e            , m_ib_target            , UVM_DEFAULT          )
    `uvm_field_enum(cdn_pcie_hls_bridge_backpressure_scenario_e, m_backpressure_scenario, UVM_DEFAULT          )
    `uvm_field_int(m_sanity_test                                                        , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_number_of_tlp_bursts                                               , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_number_of_tlps                                                     , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_num_hard_resets                                                    , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_num_link_downs                                                     , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_strap_port_type                                                    , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_k_flit_mode_support                                                , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_k_hls_dw_alignment                                                 , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_misc_flit_mode                                                     , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_lm_segment_num                                                     , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_sup_pri                                                            , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_unmapped_reg_access                                                , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_low_power_mode                                                     , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_num_uio_vcs                                                        , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_hls_bridge_route_en                                                , UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_qos_support                                                        , UVM_DEFAULT | UVM_DEC) 
  `uvm_object_utils_end

  //----------------------------------------------------------------------------
  // Function: new
  // Class constructor.
  //----------------------------------------------------------------------------
  function new(string name="cdn_pcie_hls_bridge_scenario");
    string user_defined_traffic_type;
    string user_defined_fc_type;
    string user_defined_ib_target;
    string user_defined_backpressure_scenario;

    super.new(name);
    
    //-- Plus Args -----------------------------
    if($value$plusargs("TRAFFIC_TYPE=%s", user_defined_traffic_type)) begin
      if(!uvm_enum_wrapper#(cdn_pcie_hls_bridge_traffic_type_e)::from_name(user_defined_traffic_type, m_traffic_type))
        `uvm_fatal(get_type_name(), $sformatf("%0s type is not present in cdn_pcie_hls_bridge_traffic_type_e enum. Valid values are: OB_TRAFFIC_ONLY, IB_TRAFFIC_ONLY, HDR2LOG_TRAFFIC_ONLY, ALL_TRAFFIC.", user_defined_traffic_type))
    end
    else begin
      m_traffic_type = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_traffic_type_e'(ALL_TRAFFIC);
    end
    
    if($value$plusargs("FC_TYPE=%s", user_defined_fc_type)) begin
      if(!uvm_enum_wrapper#(cdn_pcie_hls_bridge_fc_type_e)::from_name(user_defined_fc_type, m_fc_type))
        `uvm_fatal(get_type_name(), $sformatf("%0s type is not present in cdn_pcie_hls_bridge_fc_type_e enum. Valid values are: POSTED, NONPOSTED, COMPLETION, ALL_FC_TYPES.", user_defined_fc_type))
    end
    else begin
      m_fc_type = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_fc_type_e'(ALL_FC_TYPES);
    end
    
    if($value$plusargs("IB_TARGET=%s", user_defined_ib_target)) begin
      if(!uvm_enum_wrapper#(cdn_pcie_hls_bridge_ib_target_e)::from_name(user_defined_ib_target, m_ib_target))
        `uvm_fatal(get_type_name(), $sformatf("%0s type is not present in cdn_pcie_hls_bridge_ib_target_e enum. Valid values are: IB_TARGET_AXI, IB_TARGET_MSI, IB_TARGET_DTI, IB_TARGET_AXI_DTI, IB_TARGET_AXI_MSI, IB_TARGET_MSI_DTI, IB_TARGET_ALL.", user_defined_ib_target))
    end
    else begin
      if(parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT == 0 && parameters_cfg_pkg::KMAX_DTI_SUPPORT == 0)
        m_ib_target = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_AXI);
      else if(parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT == 0 && parameters_cfg_pkg::KMAX_DTI_SUPPORT == 1)
        m_ib_target = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_AXI_DTI);
      else if(parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT == 1 && parameters_cfg_pkg::KMAX_DTI_SUPPORT == 0)
        m_ib_target = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_AXI_MSI);
      else if(parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT == 1 && parameters_cfg_pkg::KMAX_DTI_SUPPORT == 1)
        m_ib_target = cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_ALL);
    end

    if($value$plusargs("BACKPRESSURE_SCENARIO=%s", user_defined_backpressure_scenario)) begin
      if(!uvm_enum_wrapper#(cdn_pcie_hls_bridge_backpressure_scenario_e)::from_name(user_defined_backpressure_scenario, m_backpressure_scenario))
        `uvm_fatal(get_type_name(), $sformatf("%0s type is not present in cdn_pcie_hls_bridge_backpressure_scenario_e enum. Valid values are: BACKPRESSURE_OB, BACKPRESSURE_IB, BACKPRESSURE_MSI, BACKPRESSURE_ALL, BACKPRESSURE_NONE", user_defined_backpressure_scenario))
      m_backpressure_scenario.rand_mode(0);
    end

    if(!$value$plusargs("SANITY_TEST=%0d"    , m_sanity_test))                begin m_sanity_test = 0;                                                                  end
    
    if($value$plusargs("STRAP_PORT_TYPE=%0d" , m_strap_port_type))            begin m_strap_port_type.rand_mode(0); c_m_strap_port_type.constraint_mode(0);             end
    
    if($value$plusargs("NUM_TLP_BURSTS=%0d"  , m_number_of_tlp_bursts))       begin m_number_of_tlp_bursts.rand_mode(0); c_m_number_of_tlp_bursts.constraint_mode(0);   end
    
    if($value$plusargs("NUM_TLPS=%0d"        , m_number_of_tlps))             begin m_number_of_tlps.rand_mode(0); c_m_number_of_tlps.constraint_mode(0);               end

`ifdef DTI_TB_IN_PASSIVE_MODE
    if($value$plusargs("NUM_ATS_INV_REQS=%0d", m_num_ats_inv_reqs))           begin m_num_ats_inv_reqs.rand_mode(0); c_m_num_ats_inv_reqs.constraint_mode(0);           end
    if($value$plusargs("FORCE_ATS_TRANS_FAULT=%0d", m_force_ats_trans_fault)) begin m_force_ats_trans_fault.rand_mode(0); c_m_force_ats_trans_fault.constraint_mode(0); end
`endif
    
    if($value$plusargs("SUP_PRI=%0d"         , m_sup_pri))                    begin m_sup_pri.rand_mode(0); c_sup_pri.constraint_mode(0);                               end

    if($value$plusargs("UNMAPPED_REG_ACCESS=%0d"  , m_unmapped_reg_access))   begin m_unmapped_reg_access.rand_mode(0); c_unmapped_reg_access.constraint_mode(0);       end
    
    if($value$plusargs("LOW_POWER_MODE=%0d"         , m_low_power_mode))      begin m_low_power_mode.rand_mode(0); c_low_power_mode.constraint_mode(0);                 end

    if(!$value$plusargs("NUM_HARD_RESETS=%0d", m_num_hard_resets))            begin m_num_hard_resets = 0;                                                              end
    
    if(!$value$plusargs("NUM_LINK_DOWNS=%0d", m_num_link_downs))              begin m_num_link_downs = 0;                                                               end

    if(!$value$plusargs("PERF_MODE=%0d", m_is_perf_mode))                     begin m_is_perf_mode = 0;   							      end
if(!$value$plusargs("QOS_SUPPORT=%0d", m_qos_support))                        begin m_qos_support = 0;
    end
  endfunction : new

  //----------------------------------------------------------------------------
  // Function: pre_randomize
  //----------------------------------------------------------------------------
  function void pre_randomize();
    super.pre_randomize();
  endfunction : pre_randomize

  //----------------------------------------------------------------------------
  // Function: is_flit_mode
  // Overriding base class method.
  //----------------------------------------------------------------------------
  function bit is_flit_mode();
    is_flit_mode = (m_misc_flit_mode == 2);
  endfunction : is_flit_mode
  
  //----------------------------------------------------------------------------
  // Function: post_randomize
  //----------------------------------------------------------------------------
  function void post_randomize();
    super.post_randomize();
  endfunction : post_randomize
  
  //---------------------------------------------------------------------------
  // Method: is_valid_scenario
  //---------------------------------------------------------------------------
  virtual function bit is_valid_scenario();
    is_valid_scenario = super.is_valid_scenario();
    
    if(parameters_cfg_pkg::LTI_SUPPORT == 0) begin
      is_valid_scenario &= (m_traffic_type !== cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_traffic_type_e'(LTI_CTAG_TRAFFIC_ONLY));
      if(!is_valid_scenario) `uvm_error("[SCENARIO_CHECK]", "[INVALID SCENARIO] - Traffic Type chosen is LTI_CTAG_TRAFFIC_ONLY when LTI_SUPPORT = 0");
    end
    
    if(parameters_cfg_pkg::KMAX_MSI_IF_SUPPORT == 0) begin
      is_valid_scenario &= (!(m_ib_target inside {cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_MSI), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_AXI_MSI), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_MSI_DTI), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_ALL)}));
      if(!is_valid_scenario) `uvm_error("[SCENARIO_CHECK]", $sformatf("[INVALID SCENARIO] - IB Target Type chosen as %0s even though KMAX_MSI_IF_SUPPORT = 0", m_ib_target.name()));
    end

    if(parameters_cfg_pkg::KMAX_DTI_SUPPORT == 0) begin
      is_valid_scenario &= (!(m_ib_target inside {cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_DTI), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_AXI_DTI), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_MSI_DTI), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_ALL)}));
      if(!is_valid_scenario) `uvm_error("[SCENARIO_CHECK]", $sformatf("[INVALID SCENARIO] - IB Target Type chosen as %0s even though KMAX_DTI_SUPPORT = 0", m_ib_target.name()));
    end

    is_valid_scenario &= (!(m_ib_target == cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_MSI) && m_fc_type == cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_fc_type_e'(NONPOSTED)));
    if(!is_valid_scenario) `uvm_error("[SCENARIO_CHECK]", $sformatf("[INVALID SCENARIO] - IB Target Type chosen as %0s which are Posted TLPs with FC Type = %0s", m_ib_target.name(), m_fc_type.name()));
    
    is_valid_scenario &= ((m_ib_target inside {cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_MSI), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_DTI), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_AXI_MSI), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_AXI_DTI), cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_ALL)} && m_strap_port_type == 1) || m_ib_target == cdn_pcie_hls_bridge_sv_pkg::cdn_pcie_hls_bridge_ib_target_e'(IB_TARGET_AXI));
    if(!is_valid_scenario) `uvm_error("[SCENARIO_CHECK]", $sformatf("[INVALID SCENARIO] - %0s Type can only be chosen if DUT is not RP.", m_ib_target.name()));
  endfunction : is_valid_scenario
  
  //----------------------------------------------------------------------------
  // Function: rerandomize
  //----------------------------------------------------------------------------
  function void rerandomize();
    m_strap_port_type.rand_mode(0);
    m_k_flit_mode_support.rand_mode(0);
    m_k_hls_dw_alignment.rand_mode(0);

    if(!this.randomize() with {
    }) begin
      `uvm_fatal(get_full_name(), "cdn_pcie_hls_bridge_scenario Re-Randomization failed.");
    end
  endfunction : rerandomize

  //----------------------------------------------------------------------------
  // Function: generate_tag_management
  //----------------------------------------------------------------------------
  function void generate_tag_management();
    string     l_msg_id = "generate_tag_management"           ;
    bit [13:0] tag_range  [parameters_cfg_pkg::NUM_HLS_PORTS] ;
    bit [13:0] tag_offset [parameters_cfg_pkg::NUM_HLS_PORTS] ;

    int number_of_tags = 'h3FFF;

    // Randomize tag range, tag_offset for each Port
    if (!std::randomize(tag_range, tag_offset) with {
      
      tag_range.sum with (int'(item)) <= number_of_tags;
      
      foreach(tag_range[i]) {
        tag_range[i] > 0;
        tag_range[i] <= number_of_tags;
      }
      
      foreach(tag_offset[i]) {
        tag_offset[i] >= 0;
        tag_offset[i] + tag_range[i] <= number_of_tags;
      }

      foreach(tag_offset[i]) {
        foreach(tag_offset[j]) {
          if (i != j) {
            (tag_offset[i] + tag_range[i] <= tag_offset[j]) || (tag_offset[j] + tag_range[j] <= tag_offset[i]);
          }
        }
      }
    }) begin
      `uvm_fatal(l_msg_id, "tag_range, tag_offset randomization fail")
    end
    
    // Generate misc_tag_management signal.
    foreach(tag_range[loop_port]) begin
      m_misc_tag_management[loop_port * 32 +: 32] = {2'b00, tag_range[loop_port], 2'b00, tag_offset[loop_port]};
    end
    
    // Print distribution.
    `uvm_info(l_msg_id, "Tag Distribution Per Port:", UVM_MEDIUM);
    foreach(tag_range[loop_port]) begin
      `uvm_info(l_msg_id, $sformatf("Port: %0d, Tag Offset: %0d, Tag Range: %0d", loop_port, tag_offset[loop_port], tag_range[loop_port]), UVM_MEDIUM);
    end
  endfunction : generate_tag_management

endclass : cdn_pcie_hls_bridge_scenario

`endif // CDN_PCIE_HLS_BRIDGE_SCENARIO_SV
