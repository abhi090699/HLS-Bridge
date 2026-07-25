`ifndef CDN_PCIE_HLS_BRIDGE_ENV_CONFIG_SV
`define CDN_PCIE_HLS_BRIDGE_ENV_CONFIG_SV

//------------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_env_config
// Sub-agents configuration, and generic environment configuration.
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_env_config extends cdn_pcie_module_env_cfg_base;

  //----------------------------------------------------------------------------
  // Configuration variables
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  // Variable: checks_enable
  // This member variable enables the protocol checks.
  //----------------------------------------------------------------------------
  bit checks_enable = 1;
  
  //----------------------------------------------------------------------------
  // Variable: coverage_enable
  // This member variable enables the protocol coverage.
  //----------------------------------------------------------------------------
  bit coverage_enable = 1;

  //----------------------------------------------------------------------------
  // Variable: m_is_active
  // Active or passive UVC
  //----------------------------------------------------------------------------
  uvm_active_passive_enum m_is_active = UVM_ACTIVE;

  //----------------------------------------------------------------------------
  // Variable: m_env_name
  // Env full path in string format. Used for configDB sets/gets.
  //----------------------------------------------------------------------------
  string m_env_name;
   
  //----------------------------------------------------------------------------
  // Variable: en_backpressure_ob
  // Enable backpressure scenario for the OB Direction.
  //----------------------------------------------------------------------------
  bit en_backpressure_ob = 0;
  
  //----------------------------------------------------------------------------
  // Variable: en_backpressure_ib
  // Enable backpressure scenario for IB Direction.
  //----------------------------------------------------------------------------
  bit en_backpressure_ib = 0;
  
  //----------------------------------------------------------------------------
  // Variable: stop_cxs_driver
  // Control bit to stop the CXS Driver to stop sending the transaction.
  // Useful for linkdown traffic cases.
  //----------------------------------------------------------------------------
  bit stop_cxs_driver;

  //----------------------------------------------------------------------------
  // Variable: performance_mode
  // Control bit to set configuration to max performance
  //----------------------------------------------------------------------------
  bit performance_mode;

   bit                                           m_qos_support = 0;
  

  //----------------------------------------------------------------------------
  // Initial credits variables
  //----------------------------------------------------------------------------
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD-1:0]  initial_crd_lmt_posted_header;
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD-1:0] initial_crd_lmt_posted_payload;
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_CNTL_WD-1:0]    initial_crd_lmt_posted_cntl;
   
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD-1:0]  initial_crd_lmt_nonposted_header;
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD-1:0] initial_crd_lmt_nonposted_payload;
  bit [parameters_cfg_pkg::KMAX_NUM_VCS-1:0][parameters_cfg_pkg::CRD_IN_LMT_CNTL_WD-1:0]    initial_crd_lmt_nonposted_cntl;
   
  //----------------------------------------------------------------------------
  // Config objects for UVCs
  //----------------------------------------------------------------------------
  cdn_clock_config                              m_clk_cfg;
  
  cdn_hls_config                                m_hls_ob_posted_hal_act_cfg;
  cdn_hls_config                                m_hls_ob_posted_hal_psv_cfg;
  cdn_hls_config                                m_hls_ob_nonposted_hal_act_cfg;
  cdn_hls_config                                m_hls_ob_nonposted_hal_psv_cfg;
  cdn_hls_config                                m_hls_ob_compl_hal_act_cfg;
  cdn_hls_config                                m_hls_ob_compl_hal_psv_cfg;

  cdn_hls_config                                m_hls_ib_posted_hal_act_cfg;
  cdn_hls_config                                m_hls_ib_posted_hal_psv_cfg;
  cdn_hls_config                                m_hls_ib_nonposted_hal_act_cfg;
  cdn_hls_config                                m_hls_ib_nonposted_hal_psv_cfg;
  cdn_hls_config                                m_hls_ib_compl_hal_act_cfg;
  cdn_hls_config                                m_hls_ib_compl_hal_psv_cfg;

  cdn_hls_config                                m_hls_ob_posted_axi_act_cfg   [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_config                                m_hls_ob_posted_axi_psv_cfg   [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_config                                m_hls_ob_nonposted_axi_act_cfg[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_config                                m_hls_ob_nonposted_axi_psv_cfg[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_config                                m_hls_ob_compl_axi_act_cfg    [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_config                                m_hls_ob_compl_axi_psv_cfg    [parameters_cfg_pkg::NUM_HLS_PORTS];
  
  cdn_hls_config                                m_hls_ib_posted_axi_act_cfg   [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_config                                m_hls_ib_posted_axi_psv_cfg   [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_config                                m_hls_ib_nonposted_axi_act_cfg[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_config                                m_hls_ib_nonposted_axi_psv_cfg[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_config                                m_hls_ib_compl_axi_act_cfg    [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_hls_config                                m_hls_ib_compl_axi_psv_cfg    [parameters_cfg_pkg::NUM_HLS_PORTS];

`ifdef DTI_TB_IN_PASSIVE_MODE
  cdn_pcie_dti_config                           m_dti_cfg;
`endif

  cdn_cxs_cov_collector_cfg                     m_hls_ob_posted_hal_cov_cfg;
  cdn_cxs_cov_collector_cfg                     m_hls_ob_nonposted_hal_cov_cfg;
  cdn_cxs_cov_collector_cfg                     m_hls_ob_compl_hal_cov_cfg;
  
  cdn_cxs_cov_collector_cfg                     m_hls_ib_posted_hal_cov_cfg;
  cdn_cxs_cov_collector_cfg                     m_hls_ib_nonposted_hal_cov_cfg;
  cdn_cxs_cov_collector_cfg                     m_hls_ib_compl_hal_cov_cfg;
  
  cdn_cxs_cov_collector_cfg                     m_hls_ob_posted_axi_cov_cfg   [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_cxs_cov_collector_cfg                     m_hls_ob_nonposted_axi_cov_cfg[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_cxs_cov_collector_cfg                     m_hls_ob_compl_axi_cov_cfg    [parameters_cfg_pkg::NUM_HLS_PORTS];
  
  cdn_cxs_cov_collector_cfg                     m_hls_ib_posted_axi_cov_cfg   [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_cxs_cov_collector_cfg                     m_hls_ib_nonposted_axi_cov_cfg[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdn_cxs_cov_collector_cfg                     m_hls_ib_compl_axi_cov_cfg    [parameters_cfg_pkg::NUM_HLS_PORTS];
  
  cdnStreamUvmConfig                            m_hdr2log_mst_act_cfg         [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdnStreamUvmConfig                            m_hdr2log_slv_psv_cfg         [parameters_cfg_pkg::NUM_HLS_PORTS];
  
  cdnStreamUvmConfig                            m_hdr2log_slv_act_cfg;
  cdnStreamUvmConfig                            m_hdr2log_mst_psv_cfg;
  
  cdnStreamUvmConfig                            m_axis_msi_slv_act_cfg;
  cdnStreamUvmConfig                            m_axis_msi_mst_psv_cfg;
  
  cdnStreamUvmConfig                            m_dc_mst_act_cfg              [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdnStreamUvmConfig                            m_dc_slv_psv_cfg              [parameters_cfg_pkg::NUM_HLS_PORTS];
  
  cdnStreamUvmConfig                            m_dc_slv_act_cfg;
  cdnStreamUvmConfig                            m_dc_mst_psv_cfg;

  cdnStreamUvmConfig                            m_qos_mst_act_cfg[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdnStreamUvmConfig                            m_qos_slv_psv_cfg[parameters_cfg_pkg::NUM_HLS_PORTS];
  cdnStreamUvmConfig                            m_qos_slv_act_cfg;
  cdnStreamUvmConfig                            m_qos_mst_psv_cfg;

  cdnStreamUvmConfig                            m_lti_c_tx_act_cfg            [parameters_cfg_pkg::NUM_HLS_PORTS];
  cdnStreamUvmConfig                            m_lti_c_rx_psv_cfg            [parameters_cfg_pkg::NUM_HLS_PORTS];
  
  cdnStreamUvmConfig                            m_lti_c_rx_act_cfg;
  cdnStreamUvmConfig                            m_lti_c_tx_psv_cfg;
  
  cdnAxiUvmConfig                               m_axi_lite_mst_act_cfg;
  cdnAxiUvmConfig                               m_axi_lite_slv_psv_cfg;
  
  cdnAxiUvmConfig                               m_axi_lite_slv_act_cfg;
  cdnAxiUvmConfig                               m_axi_lite_mst_psv_cfg;

  //----------------------------------------------------------------------------
  // Config Objects
  //----------------------------------------------------------------------------
  cdn_pcie_hls_bridge_config                    m_hls_bridge_config;

  cdn_hpa_pcie_link_config                      m_link_config;

  cdn_pcie_strap_top_config                     i_cfg;
  
  //----------------------------------------------------------------------------
  // Interface APIs
  //----------------------------------------------------------------------------
  cdn_pcie_hls_bridge_dut_k_if_api_base #(.TOK_INV_BIN_WIDTH                  ( parameters_cfg_pkg::KMAX_DTI_TOK_INV_WIDTH              ),
                                          .RAM_READ_LATENCY_WIDTH             ( parameters_cfg_pkg::KMAX_RAM_READ_LATENCY_WIDTH         ),
                                          .TOK_TRANS_BIN_WIDTH                ( parameters_cfg_pkg::KMAX_DTI_TOK_TRANS_WIDTH            ),
                                          .NUM_HLS_PORTS                      ( parameters_cfg_pkg::NUM_HLS_PORTS                       ),
                                          .KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH( parameters_cfg_pkg::KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH )) m_k_if_api;

  cdn_pcie_hls_bridge_dut_misc_if_api_base #(.NUM_HLS_PORTS( parameters_cfg_pkg::NUM_HLS_PORTS ),
                                             .KMAX_NUM_PFS ( parameters_cfg_pkg::KMAX_NUM_PFS  ),
                                             .NUM_TCS       ( cdn_pcie_hls_bridge_sv_pkg::HLS_BRIDGE_NUM_TCS ),
                                             .NUM_LTI_PORTS ( parameters_cfg_pkg::NUM_LTI_PORTS )) m_misc_if_api;

  cdn_pcie_hls_bridge_crd_lmt_if_api_base #(.INTERFACE_NAME          ( "crd_lmt_posted_if"                       ),
                                            .KMAX_NUM_VCS            ( parameters_cfg_pkg::KMAX_NUM_VCS          ),
                                            .CRD_IN_LMT_HEADER_WIDTH ( parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD  ),
                                            .CRD_IN_LMT_PAYLOAD_WIDTH( parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD ),
                                            .CRD_IN_LMT_CNTL_WIDTH   ( parameters_cfg_pkg::CRD_IN_LMT_CNTL_WD    )) m_crd_lmt_posted_if_api;

  cdn_pcie_hls_bridge_crd_lmt_if_api_base #(.INTERFACE_NAME          ( "crd_lmt_nonposted_if"                    ),
                                            .KMAX_NUM_VCS            ( parameters_cfg_pkg::KMAX_NUM_VCS          ),
                                            .CRD_IN_LMT_HEADER_WIDTH ( parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD  ),
                                            .CRD_IN_LMT_PAYLOAD_WIDTH( parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD ),
                                            .CRD_IN_LMT_CNTL_WIDTH   ( parameters_cfg_pkg::CRD_IN_LMT_CNTL_WD    )) m_crd_lmt_nonposted_if_api;
  
  //----------------------------------------------------------------------------
  // Events
  //----------------------------------------------------------------------------
  uvm_event hard_reset_triggered_e ;
  uvm_event hard_reset_done_e      ;
  uvm_event link_down_triggered_e  ;
  uvm_event link_down_done_e       ;
  uvm_event vseq_completed_e       ;

  //----------------------------------------------------------------------------
  // UVM automation macros
  //----------------------------------------------------------------------------
  `uvm_object_utils_begin(cdn_pcie_hls_bridge_env_config)
    `uvm_field_int(checks_enable,   UVM_ALL_ON)
    `uvm_field_int(coverage_enable, UVM_ALL_ON)
    `uvm_field_enum(uvm_active_passive_enum, m_is_active, UVM_ALL_ON)
    `uvm_field_string(m_env_name, UVM_ALL_ON)
    `uvm_field_int(stop_cxs_driver, UVM_ALL_ON)
  `uvm_object_utils_end

  //----------------------------------------------------------------------------
  // Function: new
  // Class constructor.
  //----------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_env_config");
    super.new(name);
    
    hard_reset_triggered_e = new("hard_reset_triggered_e");
    hard_reset_done_e      = new("hard_reset_done_e");
    link_down_triggered_e  = new("link_down_triggered_e");
    link_down_done_e       = new("link_down_done_e");
    vseq_completed_e       = new("vseq_completed_e");
      if(!$value$plusargs("QOS_SUPPORT=%0d", m_qos_support))  m_qos_support = 0;
  endfunction : new
  
  //---------------------------------------------------------------------------
  // Function: is_active
  // Returns true if env is configured as UVM_ACTIVE
  //---------------------------------------------------------------------------
  function bit is_active();
    return (m_is_active == UVM_ACTIVE);
  endfunction : is_active

  //---------------------------------------------------------------------------
  // Function: reset_control_events
  // Resets the linkdown/reset/vseq events.
  //---------------------------------------------------------------------------
  task reset_control_events();
    `uvm_info("RESET_CONTROL_EVENTS", "Started resetting events.....", UVM_DEBUG)
    hard_reset_triggered_e.reset();
    hard_reset_done_e.reset();
    link_down_triggered_e.reset();
    link_down_done_e.reset();
    vseq_completed_e.reset();
    `uvm_info("RESET_CONTROL_EVENTS", "Completed resetting events.....", UVM_DEBUG)
  endtask : reset_control_events

  //----------------------------------------------------------------------------
  // Function: get_datapath_width
  // Returns Datapath width
  //----------------------------------------------------------------------------
  function int unsigned get_datapath_width();
    return (parameters_cfg_pkg::KMAX_DATAPATH_WD);
  endfunction : get_datapath_width
  
  //----------------------------------------------------------------------------
  // Function: get_datapath_width_per_port
  // Returns Datapath width per HLS Port
  //----------------------------------------------------------------------------
  function int unsigned get_datapath_width_per_port(int unsigned hls_port_num);
    return (parameters_cfg_pkg::HLS_PORT_DATA_WIDTH_ARR[hls_port_num*32 +: 32]);
  endfunction : get_datapath_width_per_port
  
  //----------------------------------------------------------------------------
  // Function: get_num_tlps_per_clk
  // Return MAX TLP per Clock based on DATA Path width
  //----------------------------------------------------------------------------
  function int unsigned get_num_tlps_per_clk();
    return (parameters_cfg_pkg::KMAX_NUM_TLPS_PER_CLK);
  endfunction : get_num_tlps_per_clk
  
  //----------------------------------------------------------------------------
  // Function: get_num_tlps_per_clk_per_port
  // Return MAX TLP per Clock based on DATA Path width per HLS Port
  //----------------------------------------------------------------------------
  function int unsigned get_num_tlps_per_clk_per_port(int unsigned hls_port_num);
    return (parameters_cfg_pkg::HLS_PORT_TLPS_PER_CLK_ARR[hls_port_num*32 +: 32]);
  endfunction : get_num_tlps_per_clk_per_port 

  //----------------------------------------------------------------------------
  // Function: get_tlp_alignment
  // Return TLP Alignment based on DATA Path width
  //----------------------------------------------------------------------------
  function int unsigned get_tlp_alignment();
      return ((get_datapath_width() == 128) ? 8 : (i_cfg.k_hls_dw_alignment * 4)); // VIP supports only 6b & 8Byte granularity on 128b
  endfunction : get_tlp_alignment 

  //----------------------------------------------------------------------------
  // Function: get_tlp_alignment_per_port
  // Return TLP Alignment based on DATA Path width per HLS port
  //----------------------------------------------------------------------------
  function int unsigned get_tlp_alignment_per_port(int unsigned hls_port_num);
      return ((get_datapath_width_per_port(.hls_port_num(hls_port_num)) == 128) ? 8 : (i_cfg.k_hls_dw_alignment * 4)); // VIP supports only 6b & 8Byte granularity on 128b
  endfunction : get_tlp_alignment_per_port

  //----------------------------------------------------------------------------
  // Function: get_cntl_width
  // Return control width based on DATA Path width
  //----------------------------------------------------------------------------
  function int unsigned get_cntl_width();
    int l_start_ptr_wd;
    int l_end_ptr_wd;
    int l_alignment;

    l_alignment      = get_tlp_alignment();
    l_start_ptr_wd   = (((get_datapath_width() / 32) / (l_alignment / 4)) == 1) ? 1 : $clog2((get_datapath_width() / 32) / (l_alignment / 4));
    l_end_ptr_wd     = $clog2(get_datapath_width() / 32);
    
    return ((1 + 1 + 1 + l_start_ptr_wd + l_end_ptr_wd) * get_num_tlps_per_clk());

  endfunction : get_cntl_width
  
  //----------------------------------------------------------------------------
  // Function: get_cntl_width_per_port
  // Return control width based on DATA Path width per HLS Port
  //----------------------------------------------------------------------------
  function int unsigned get_cntl_width_per_port(int unsigned hls_port_num);
    int l_start_ptr_wd;
    int l_end_ptr_wd;
    int l_alignment;

    l_alignment    = get_tlp_alignment_per_port(.hls_port_num(hls_port_num));
    l_start_ptr_wd = (((get_datapath_width_per_port(.hls_port_num(hls_port_num)) / 32) / (l_alignment / 4)) == 1) ? 1 : $clog2((get_datapath_width_per_port(.hls_port_num(hls_port_num)) / 32) / (l_alignment / 4));
    l_end_ptr_wd   = $clog2(get_datapath_width_per_port(.hls_port_num(hls_port_num)) / 32);
    
    return ((1 + 1 + 1 + l_start_ptr_wd + l_end_ptr_wd) * get_num_tlps_per_clk_per_port(.hls_port_num(hls_port_num)));

  endfunction : get_cntl_width_per_port

  //----------------------------------------------------------------------------
  // Function: get_ob_user_cntl_width
  // Return OB User control width.
  //----------------------------------------------------------------------------
  function int unsigned get_ob_user_cntl_width(bit is_pnp_cxs_vip = 0);
    if (is_pnp_cxs_vip) begin
      return get_num_tlps_per_clk() * parameters_cfg_pkg::HLS_TX_PNP_METADATA_WD;
    end
    else begin
      return get_num_tlps_per_clk() * parameters_cfg_pkg::HLS_TX_C_METADATA_WD;
    end
  endfunction : get_ob_user_cntl_width
  
  //----------------------------------------------------------------------------
  // Function: get_ib_user_cntl_width
  // Return IB User control width.
  //----------------------------------------------------------------------------
  function int unsigned get_ib_user_cntl_width(bit is_pnp_cxs_vip = 0);
    if(is_pnp_cxs_vip) begin
      return get_num_tlps_per_clk() * parameters_cfg_pkg::HLS_RX_PNP_METADATA_WD;
    end
    else begin
      return get_num_tlps_per_clk() * parameters_cfg_pkg::HLS_RX_C_METADATA_WD;
    end
  endfunction : get_ib_user_cntl_width
 
  //----------------------------------------------------------------------------
  // Function: get_ob_user_cntl_width_per_port
  // Return OB User control width per HLS Port.
  //----------------------------------------------------------------------------
  function int unsigned get_ob_user_cntl_width_per_port(int unsigned hls_port_num, bit is_pnp_cxs_vip);
    if (is_pnp_cxs_vip) begin
      return get_num_tlps_per_clk_per_port(.hls_port_num(hls_port_num)) * parameters_cfg_pkg::HLS_TX_PNP_METADATA_WD;
    end
    else begin
      return get_num_tlps_per_clk_per_port(.hls_port_num(hls_port_num)) * parameters_cfg_pkg::HLS_TX_C_METADATA_WD;
    end
  endfunction : get_ob_user_cntl_width_per_port
  
  //----------------------------------------------------------------------------
  // Function: get_ib_user_cntl_width_per_port
  // Return IB User control width per HLS Port.
  //----------------------------------------------------------------------------
  function int unsigned get_ib_user_cntl_width_per_port(int unsigned hls_port_num, bit is_pnp_cxs_vip);
    if(is_pnp_cxs_vip) begin
      return get_num_tlps_per_clk_per_port(.hls_port_num(hls_port_num)) * parameters_cfg_pkg::HLS_RX_PNP_METADATA_WD;
    end
    else begin
      return get_num_tlps_per_clk_per_port(.hls_port_num(hls_port_num)) * parameters_cfg_pkg::HLS_RX_C_METADATA_WD;
    end
  endfunction : get_ib_user_cntl_width_per_port

  //---------------------------------------------------------------------------
  // Method: get_ifs_api
  //---------------------------------------------------------------------------
  virtual function void get_ifs_api();
    
    if(!uvm_config_db#(cdn_pcie_hls_bridge_dut_k_if_api_base#(
      .TOK_INV_BIN_WIDTH                  ( parameters_cfg_pkg::KMAX_DTI_TOK_INV_WIDTH              ),
      .RAM_READ_LATENCY_WIDTH             ( parameters_cfg_pkg::KMAX_RAM_READ_LATENCY_WIDTH         ),
      .TOK_TRANS_BIN_WIDTH                ( parameters_cfg_pkg::KMAX_DTI_TOK_TRANS_WIDTH            ),
      .NUM_HLS_PORTS                      ( parameters_cfg_pkg::NUM_HLS_PORTS                       ),
      .KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH( parameters_cfg_pkg::KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH )
    ))::get(null, $sformatf("%0s*", m_env_name), "k_if_api", m_k_if_api)) begin
      `uvm_fatal(get_type_name(), "Could not find k_if_api in ConfigDB Database.");
    end
    
    if(!uvm_config_db#(cdn_pcie_hls_bridge_dut_misc_if_api_base#(
      .NUM_HLS_PORTS ( parameters_cfg_pkg::NUM_HLS_PORTS ),
      .KMAX_NUM_PFS  ( parameters_cfg_pkg::KMAX_NUM_PFS  ),
      .NUM_TCS       ( cdn_pcie_hls_bridge_sv_pkg::HLS_BRIDGE_NUM_TCS ),
      .NUM_LTI_PORTS ( parameters_cfg_pkg::NUM_LTI_PORTS )
    ))::get(null, $sformatf("%0s*", m_env_name), "misc_if_api", m_misc_if_api)) begin
      `uvm_fatal(get_type_name(), "Could not find misc_if_api in ConfigDB Database.");
    end
   
    if(!uvm_config_db#(cdn_pcie_hls_bridge_crd_lmt_if_api_base#(
      .INTERFACE_NAME          ( "crd_lmt_posted_if"                       ),
      .KMAX_NUM_VCS            ( parameters_cfg_pkg::KMAX_NUM_VCS          ),
      .CRD_IN_LMT_HEADER_WIDTH ( parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD  ),
      .CRD_IN_LMT_PAYLOAD_WIDTH( parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD ),
      .CRD_IN_LMT_CNTL_WIDTH   ( parameters_cfg_pkg::CRD_IN_LMT_CNTL_WD    )
    ))::get(null, $sformatf("%0s*", m_env_name), "crd_lmt_posted_if_api", m_crd_lmt_posted_if_api)) begin
      `uvm_fatal(get_type_name(), "Could not find crd_lmt_posted_if_api in ConfigDB Database.");
    end

    if(!uvm_config_db#(cdn_pcie_hls_bridge_crd_lmt_if_api_base#(
      .INTERFACE_NAME          ( "crd_lmt_nonposted_if"                    ),
      .KMAX_NUM_VCS            ( parameters_cfg_pkg::KMAX_NUM_VCS          ),
      .CRD_IN_LMT_HEADER_WIDTH ( parameters_cfg_pkg::CRD_IN_LMT_HEADER_WD  ),
      .CRD_IN_LMT_PAYLOAD_WIDTH( parameters_cfg_pkg::CRD_IN_LMT_PAYLOAD_WD ),
      .CRD_IN_LMT_CNTL_WIDTH   ( parameters_cfg_pkg::CRD_IN_LMT_CNTL_WD    )
    ))::get(null, $sformatf("%0s*", m_env_name), "crd_lmt_nonposted_if_api", m_crd_lmt_nonposted_if_api)) begin
      `uvm_fatal(get_type_name(), "Could not find crd_lmt_nonposted_if_api in ConfigDB Database.");
    end
  endfunction
  
  //---------------------------------------------------------------------------
  // Method: set_clk_cfg
  //---------------------------------------------------------------------------
  virtual function void set_clk_cfg();
    if(is_active()) begin
      m_clk_cfg = cdn_clock_config::type_id::create("m_clk_cfg");
      m_clk_cfg.core_frequency_sel = i_cfg.k_core_frequency_sel;
      
      uvm_config_db#(cdn_clock_config)::set(null, $sformatf("%0s.m_clk_env.agent", m_env_name), "clk_cfg", m_clk_cfg);
    end
  endfunction : set_clk_cfg
  
  //---------------------------------------------------------------------------
  // Method: set_core_rst_cfg
  //---------------------------------------------------------------------------
  virtual function void set_core_rst_cfg();
    uvm_config_db#(int)::set(null, $sformatf("%0s.m_core_rst_env", m_env_name), "number_of_agents", 1);
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_core_rst_env.agents[0]", m_env_name), "is_active", m_is_active);
  endfunction : set_core_rst_cfg
  
  //---------------------------------------------------------------------------
  // Method: set_axi_msi_rst_cfg
  //---------------------------------------------------------------------------
  virtual function void set_axi_msi_rst_cfg();
    uvm_config_db#(int)::set(null, $sformatf("%0s.m_axi_msi_rst_env", m_env_name), "number_of_agents", 1);
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_axi_msi_rst_env.agents[0]", m_env_name), "is_active", m_is_active);
  endfunction : set_axi_msi_rst_cfg
  
  //---------------------------------------------------------------------------
  // Method: set_axi_dti_rst_cfg
  //---------------------------------------------------------------------------
  virtual function void set_axi_dti_rst_cfg();
    uvm_config_db#(int)::set(null, $sformatf("%0s.m_axi_dti_rst_env", m_env_name), "number_of_agents", 1);
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_axi_dti_rst_env.agents[0]", m_env_name), "is_active", m_is_active);
  endfunction : set_axi_dti_rst_cfg


  //---------------------------------------------------------------------------
  // Method: set_axil_rst_cfg
  //---------------------------------------------------------------------------
  virtual function void set_axil_rst_cfg();
    uvm_config_db#(int)::set(null, $sformatf("%0s.m_axil_rst_env", m_env_name), "number_of_agents", 1);
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_axil_rst_env.agents[0]", m_env_name), "is_active", m_is_active);
  endfunction : set_axil_rst_cfg
 
  //---------------------------------------------------------------------------
  // Method: set_hls_ob_posted_hal_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hls_ob_posted_hal_cfg();
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hls_ob_posted_hal_env", m_env_name), "is_active", m_is_active);
    uvm_config_db#(cdn_hls_direction)::set(null, $sformatf("%0s.m_hls_ob_posted_hal_env", m_env_name), "hls_direction", CDN_HLS_RX);

    //- Creating CXS active config --------------------------------------------------
    if(is_active()) begin
      m_hls_ob_posted_hal_act_cfg = cdn_hls_config::type_id::create("m_hls_ob_posted_hal_act_cfg");
    end
    //- Creating CXS Passive config -------------------------------------------------
    m_hls_ob_posted_hal_psv_cfg = cdn_hls_config::type_id::create("m_hls_ob_posted_hal_psv_cfg");

    //- Configuring CXS Configs -----------------------------------------------------
    configure_cxs_hal_agent_cfg(.is_inbound_dir(1'b0), .is_pnp_cxs_vip(1'b1), .passive_cfg(m_hls_ob_posted_hal_psv_cfg), .active_cfg(m_hls_ob_posted_hal_act_cfg));
    
    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ob_posted_hal_env.cxs_env.act_agent", m_env_name), "cfg", m_hls_ob_posted_hal_act_cfg);
    end
    uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ob_posted_hal_env.cxs_env.psv_agent", m_env_name), "cfg", m_hls_ob_posted_hal_psv_cfg);

    if(coverage_enable) begin
      //- Creating CXS Coverage config -------------------------------------------------
      m_hls_ob_posted_hal_cov_cfg = cdn_cxs_cov_collector_cfg::type_id::create("m_hls_ob_posted_hal_cov_cfg");
      
      //- Configuring CXS Coverage config -------------------------------------------------
      configure_cxs_hal_cov_collector_cfg(.is_rx(1'b1), .fc_type(2'b00), .cov_cfg(m_hls_ob_posted_hal_cov_cfg));

      //- Setting configs via ConfigDB ------------------------------------------------
      uvm_config_db#(cdn_cxs_cov_collector_cfg)::set(null, $sformatf("%0s.m_hls_ob_posted_hal_env.cxs_env.psv_agent.m_cxs_cov_collector", m_env_name), "m_cov_cfg", m_hls_ob_posted_hal_cov_cfg);
      uvm_config_int::set(null, $sformatf("%0s.m_hls_ob_posted_hal_env.cxs_env.psv_agent", m_env_name), "m_has_cxs_cov_collector", 1);
      uvm_config_int::set(null, $sformatf("%0s.m_hls_ob_posted_hal_env.cxs_env", m_env_name), "m_has_cxs_native_vip_cov", 1);
    end

  endfunction : set_hls_ob_posted_hal_cfg
  
  //---------------------------------------------------------------------------
  // Method: set_hls_ob_nonposted_hal_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hls_ob_nonposted_hal_cfg();
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hls_ob_nonposted_hal_env", m_env_name), "is_active", m_is_active);
    uvm_config_db#(cdn_hls_direction)::set(null, $sformatf("%0s.m_hls_ob_nonposted_hal_env", m_env_name), "hls_direction", CDN_HLS_RX);

    //- Creating CXS active config --------------------------------------------------
    if(is_active()) begin
      m_hls_ob_nonposted_hal_act_cfg = cdn_hls_config::type_id::create("m_hls_ob_nonposted_hal_act_cfg");
    end
    //- Creating CXS Passive config -------------------------------------------------
    m_hls_ob_nonposted_hal_psv_cfg = cdn_hls_config::type_id::create("m_hls_ob_nonposted_hal_psv_cfg");

    //- Configuring CXS Configs -----------------------------------------------------
    configure_cxs_hal_agent_cfg(.is_inbound_dir(1'b0), .is_pnp_cxs_vip(1'b1), .passive_cfg(m_hls_ob_nonposted_hal_psv_cfg), .active_cfg(m_hls_ob_nonposted_hal_act_cfg));
    
    //- Setting configs via ConfigDB ------------------------------------------------
    if(is_active()) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ob_nonposted_hal_env.cxs_env.act_agent", m_env_name), "cfg", m_hls_ob_nonposted_hal_act_cfg);
    end
    uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ob_nonposted_hal_env.cxs_env.psv_agent", m_env_name), "cfg", m_hls_ob_nonposted_hal_psv_cfg);

    if(coverage_enable) begin
      //- Creating CXS Coverage config -------------------------------------------------
      m_hls_ob_nonposted_hal_cov_cfg = cdn_cxs_cov_collector_cfg::type_id::create("m_hls_ob_nonposted_hal_cov_cfg");
      
      //- Configuring CXS Coverage config -------------------------------------------------
      configure_cxs_hal_cov_collector_cfg(.is_rx(1'b1), .fc_type(2'b01), .cov_cfg(m_hls_ob_nonposted_hal_cov_cfg));

      //- Setting configs via ConfigDB ------------------------------------------------
      uvm_config_db#(cdn_cxs_cov_collector_cfg)::set(null, $sformatf("%0s.m_hls_ob_nonposted_hal_env.cxs_env.psv_agent.m_cxs_cov_collector", m_env_name), "m_cov_cfg", m_hls_ob_nonposted_hal_cov_cfg);
      uvm_config_int::set(null, $sformatf("%0s.m_hls_ob_nonposted_hal_env.cxs_env.psv_agent", m_env_name), "m_has_cxs_cov_collector", 1);
      uvm_config_int::set(null, $sformatf("%0s.m_hls_ob_nonposted_hal_env.cxs_env", m_env_name), "m_has_cxs_native_vip_cov", 1);
    end
  endfunction : set_hls_ob_nonposted_hal_cfg

  //---------------------------------------------------------------------------
  // Method: set_hls_ob_compl_hal_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hls_ob_compl_hal_cfg();
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hls_ob_compl_hal_env", m_env_name), "is_active", m_is_active);
    uvm_config_db#(cdn_hls_direction)::set(null, $sformatf("%0s.m_hls_ob_compl_hal_env", m_env_name), "hls_direction", CDN_HLS_RX);

    //- Creating CXS active config --------------------------------------------------
    if(is_active()) begin
      m_hls_ob_compl_hal_act_cfg = cdn_hls_config::type_id::create("m_hls_ob_compl_hal_act_cfg");
    end
    //- Creating CXS Passive config -------------------------------------------------
    m_hls_ob_compl_hal_psv_cfg = cdn_hls_config::type_id::create("m_hls_ob_compl_hal_psv_cfg");

    //- Configuring CXS Configs -----------------------------------------------------
    configure_cxs_hal_agent_cfg(.is_inbound_dir(1'b0), .is_pnp_cxs_vip(1'b0), .passive_cfg(m_hls_ob_compl_hal_psv_cfg), .active_cfg(m_hls_ob_compl_hal_act_cfg));
    
    //- Setting configs via ConfigDB ------------------------------------------------
    if(is_active()) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ob_compl_hal_env.cxs_env.act_agent", m_env_name), "cfg", m_hls_ob_compl_hal_act_cfg);
    end
    uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ob_compl_hal_env.cxs_env.psv_agent", m_env_name), "cfg", m_hls_ob_compl_hal_psv_cfg);
    
    if(coverage_enable) begin
      //- Creating CXS Coverage config -------------------------------------------------
      m_hls_ob_compl_hal_cov_cfg = cdn_cxs_cov_collector_cfg::type_id::create("m_hls_ob_compl_hal_cov_cfg");
      
      //- Configuring CXS Coverage config -------------------------------------------------
      configure_cxs_hal_cov_collector_cfg(.is_rx(1'b1), .fc_type(2'b10), .cov_cfg(m_hls_ob_compl_hal_cov_cfg));

      //- Setting configs via ConfigDB ------------------------------------------------
      uvm_config_db#(cdn_cxs_cov_collector_cfg)::set(null, $sformatf("%0s.m_hls_ob_compl_hal_env.cxs_env.psv_agent.m_cxs_cov_collector", m_env_name), "m_cov_cfg", m_hls_ob_compl_hal_cov_cfg);
      uvm_config_int::set(null, $sformatf("%0s.m_hls_ob_compl_hal_env.cxs_env.psv_agent", m_env_name), "m_has_cxs_cov_collector", 1);
      uvm_config_int::set(null, $sformatf("%0s.m_hls_ob_compl_hal_env.cxs_env", m_env_name), "m_has_cxs_native_vip_cov", 1);
    end
  endfunction : set_hls_ob_compl_hal_cfg
  
  //---------------------------------------------------------------------------
  // Method: set_hls_ib_posted_hal_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hls_ib_posted_hal_cfg();
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hls_ib_posted_hal_env", m_env_name), "is_active", m_is_active);
    uvm_config_db#(cdn_hls_direction)::set(null, $sformatf("%0s.m_hls_ib_posted_hal_env", m_env_name), "hls_direction", CDN_HLS_TX);

    //- Creating CXS active config ---------------------------------------------------
    if(is_active()) begin
      m_hls_ib_posted_hal_act_cfg = cdn_hls_config::type_id::create("m_hls_ib_posted_hal_act_cfg");
    end
    //- Creating CXS Passive config --------------------------------------------------
    m_hls_ib_posted_hal_psv_cfg = cdn_hls_config::type_id::create("m_hls_ib_posted_hal_psv_cfg");

    //- Configuring CXS Configs ------------------------------------------------------
    configure_cxs_hal_agent_cfg(.is_inbound_dir(1'b1), .is_pnp_cxs_vip(1'b1), .passive_cfg(m_hls_ib_posted_hal_psv_cfg), .active_cfg(m_hls_ib_posted_hal_act_cfg));
    
    //- Setting configs via ConfigDB -------------------------------------------------
    if(is_active()) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ib_posted_hal_env.cxs_env.act_agent", m_env_name), "cfg", m_hls_ib_posted_hal_act_cfg);
    end
    uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ib_posted_hal_env.cxs_env.psv_agent", m_env_name), "cfg", m_hls_ib_posted_hal_psv_cfg);
    
    if(coverage_enable) begin
      //- Creating CXS Coverage config -------------------------------------------------
      m_hls_ib_posted_hal_cov_cfg = cdn_cxs_cov_collector_cfg::type_id::create("m_hls_ib_posted_hal_cov_cfg");
      
      //- Configuring CXS Coverage config -------------------------------------------------
      configure_cxs_hal_cov_collector_cfg(.is_rx(1'b0), .fc_type(2'b00), .cov_cfg(m_hls_ib_posted_hal_cov_cfg));

      //- Setting configs via ConfigDB ------------------------------------------------
      uvm_config_db#(cdn_cxs_cov_collector_cfg)::set(null, $sformatf("%0s.m_hls_ib_posted_hal_env.cxs_env.psv_agent.m_cxs_cov_collector", m_env_name), "m_cov_cfg", m_hls_ib_posted_hal_cov_cfg);
      uvm_config_int::set(null, $sformatf("%0s.m_hls_ib_posted_hal_env.cxs_env.psv_agent", m_env_name), "m_has_cxs_cov_collector", 1);
      uvm_config_int::set(null, $sformatf("%0s.m_hls_ib_posted_hal_env.cxs_env", m_env_name), "m_has_cxs_native_vip_cov", 1);
    end 
  endfunction : set_hls_ib_posted_hal_cfg

  //---------------------------------------------------------------------------
  // Method: set_hls_ib_nonposted_hal_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hls_ib_nonposted_hal_cfg();
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hls_ib_nonposted_hal_env", m_env_name), "is_active", m_is_active);
    uvm_config_db#(cdn_hls_direction)::set(null, $sformatf("%0s.m_hls_ib_nonposted_hal_env", m_env_name), "hls_direction", CDN_HLS_TX);

    //- Creating CXS active config --------------------------------------------------
    if(is_active()) begin
      m_hls_ib_nonposted_hal_act_cfg = cdn_hls_config::type_id::create("m_hls_ib_nonposted_hal_act_cfg");
    end
    //- Creating CXS Passive config -------------------------------------------------
    m_hls_ib_nonposted_hal_psv_cfg = cdn_hls_config::type_id::create("m_hls_ib_nonposted_hal_psv_cfg");

    //- Configuring CXS Configs -----------------------------------------------------
    configure_cxs_hal_agent_cfg(.is_inbound_dir(1'b1), .is_pnp_cxs_vip(1'b1), .passive_cfg(m_hls_ib_nonposted_hal_psv_cfg), .active_cfg(m_hls_ib_nonposted_hal_act_cfg));
    
    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ib_nonposted_hal_env.cxs_env.act_agent", m_env_name), "cfg", m_hls_ib_nonposted_hal_act_cfg);
    end
    uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ib_nonposted_hal_env.cxs_env.psv_agent", m_env_name), "cfg", m_hls_ib_nonposted_hal_psv_cfg);
    
    if(coverage_enable) begin
      //- Creating CXS Coverage config -------------------------------------------------
      m_hls_ib_nonposted_hal_cov_cfg = cdn_cxs_cov_collector_cfg::type_id::create("m_hls_ib_nonposted_hal_cov_cfg");
      
      //- Configuring CXS Coverage config -------------------------------------------------
      configure_cxs_hal_cov_collector_cfg(.is_rx(1'b0), .fc_type(2'b01), .cov_cfg(m_hls_ib_nonposted_hal_cov_cfg));

      //- Setting configs via ConfigDB ------------------------------------------------
      uvm_config_db#(cdn_cxs_cov_collector_cfg)::set(null, $sformatf("%0s.m_hls_ib_nonposted_hal_env.cxs_env.psv_agent.m_cxs_cov_collector", m_env_name), "m_cov_cfg", m_hls_ib_nonposted_hal_cov_cfg);
      uvm_config_int::set(null, $sformatf("%0s.m_hls_ib_nonposted_hal_env.cxs_env.psv_agent", m_env_name), "m_has_cxs_cov_collector", 1);
      uvm_config_int::set(null, $sformatf("%0s.m_hls_ib_nonposted_hal_env.cxs_env", m_env_name), "m_has_cxs_native_vip_cov", 1);
    end

  endfunction : set_hls_ib_nonposted_hal_cfg
 
  //---------------------------------------------------------------------------
  // Method: set_hls_ib_compl_hal_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hls_ib_compl_hal_cfg();
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hls_ib_compl_hal_env", m_env_name), "is_active", m_is_active);
    uvm_config_db#(cdn_hls_direction)::set(null, $sformatf("%0s.m_hls_ib_compl_hal_env", m_env_name), "hls_direction", CDN_HLS_TX);

    //- Creating CXS active config --------------------------------------------------
    if(is_active()) begin
      m_hls_ib_compl_hal_act_cfg = cdn_hls_config::type_id::create("m_hls_ib_compl_hal_act_cfg");
    end
    //- Creating CXS Passive config -------------------------------------------------
    m_hls_ib_compl_hal_psv_cfg = cdn_hls_config::type_id::create("m_hls_ib_compl_hal_psv_cfg");

    //- Configuring CXS Configs -----------------------------------------------------
    configure_cxs_hal_agent_cfg(.is_inbound_dir(1'b1), .is_pnp_cxs_vip(1'b0), .passive_cfg(m_hls_ib_compl_hal_psv_cfg), .active_cfg(m_hls_ib_compl_hal_act_cfg));
    
    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ib_compl_hal_env.cxs_env.act_agent", m_env_name), "cfg", m_hls_ib_compl_hal_act_cfg);
    end
    uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ib_compl_hal_env.cxs_env.psv_agent", m_env_name), "cfg", m_hls_ib_compl_hal_psv_cfg);
   
    if(coverage_enable) begin
      //- Creating CXS Coverage config -------------------------------------------------
      m_hls_ib_compl_hal_cov_cfg = cdn_cxs_cov_collector_cfg::type_id::create("m_hls_ib_compl_hal_cov_cfg");
      
      //- Configuring CXS Coverage config -------------------------------------------------
      configure_cxs_hal_cov_collector_cfg(.is_rx(1'b0), .fc_type(2'b10), .cov_cfg(m_hls_ib_compl_hal_cov_cfg));

      //- Setting configs via ConfigDB ------------------------------------------------
      uvm_config_db#(cdn_cxs_cov_collector_cfg)::set(null, $sformatf("%0s.m_hls_ib_compl_hal_env.cxs_env.psv_agent.m_cxs_cov_collector", m_env_name), "m_cov_cfg", m_hls_ib_compl_hal_cov_cfg);
      uvm_config_int::set(null, $sformatf("%0s.m_hls_ib_compl_hal_env.cxs_env.psv_agent", m_env_name), "m_has_cxs_cov_collector", 1);
      uvm_config_int::set(null, $sformatf("%0s.m_hls_ib_compl_hal_env.cxs_env", m_env_name), "m_has_cxs_native_vip_cov", 1);
    end
  endfunction : set_hls_ib_compl_hal_cfg

  //---------------------------------------------------------------------------
  // Method: set_hls_ob_posted_axi_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hls_ob_posted_axi_cfg();
    
    //- Creating CXS active config --------------------------------------------------
    if(is_active()) begin
      foreach(m_hls_ob_posted_axi_act_cfg[loop_port]) begin
        m_hls_ob_posted_axi_act_cfg[loop_port] = cdn_hls_config::type_id::create($sformatf("m_hls_ob_posted_axi_act_cfg[%0d]", loop_port));
      end
    end
    //- Creating CXS Passive config -------------------------------------------------
    foreach(m_hls_ob_posted_axi_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hls_ob_posted_axi_env[%0d]", m_env_name, loop_port), "is_active", m_is_active);
      uvm_config_db#(cdn_hls_direction)::set(null, $sformatf("%0s.m_hls_ob_posted_axi_env[%0d]", m_env_name, loop_port), "hls_direction", CDN_HLS_TX);
      m_hls_ob_posted_axi_psv_cfg[loop_port] = cdn_hls_config::type_id::create($sformatf("m_hls_ob_posted_axi_psv_cfg[%0d]", loop_port));
    end
    
    //- Configuring CXS Configs -----------------------------------------------------
    configure_cxs_axi_agent_cfg(.is_inbound_dir(1'b0), .is_pnp_cxs_vip(1'b1), .passive_cfg(m_hls_ob_posted_axi_psv_cfg), .active_cfg(m_hls_ob_posted_axi_act_cfg));

    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      foreach(m_hls_ob_posted_axi_act_cfg[loop_port]) begin
        uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ob_posted_axi_env[%0d].cxs_env.act_agent", m_env_name, loop_port), "cfg", m_hls_ob_posted_axi_act_cfg[loop_port]);
      end
    end  
    foreach(m_hls_ob_posted_axi_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ob_posted_axi_env[%0d].cxs_env.psv_agent", m_env_name, loop_port), "cfg", m_hls_ob_posted_axi_psv_cfg[loop_port]);
    end

    if(coverage_enable) begin
      //- Creating CXS Coverage config -------------------------------------------------
      foreach(m_hls_ob_posted_axi_cov_cfg[loop_port]) begin
        m_hls_ob_posted_axi_cov_cfg[loop_port] = cdn_cxs_cov_collector_cfg::type_id::create($sformatf("m_hls_ob_posted_axi_cov_cfg[%0d]", loop_port));
      end
      
      //- Configuring CXS Coverage config -------------------------------------------------
      configure_cxs_axi_cov_collector_cfg(.is_rx(1'b0), .fc_type(2'b00), .cov_cfg(m_hls_ob_posted_axi_cov_cfg));

      //- Setting configs via ConfigDB ------------------------------------------------
      foreach(m_hls_ob_posted_axi_cov_cfg[loop_port]) begin
        uvm_config_db#(cdn_cxs_cov_collector_cfg)::set(null, $sformatf("%0s.m_hls_ob_posted_axi_env[%0d].cxs_env.psv_agent.m_cxs_cov_collector", m_env_name, loop_port), "m_cov_cfg", m_hls_ob_posted_axi_cov_cfg[loop_port]);
        uvm_config_int::set(null, $sformatf("%0s.m_hls_ob_posted_axi_env[%0d].cxs_env.psv_agent", m_env_name, loop_port), "m_has_cxs_cov_collector", 1);
        uvm_config_int::set(null, $sformatf("%0s.m_hls_ob_posted_axi_env[%0d].cxs_env", m_env_name, loop_port), "m_has_cxs_native_vip_cov", 1);
      end
    end

  endfunction : set_hls_ob_posted_axi_cfg
  
  //---------------------------------------------------------------------------
  // Method: set_hls_ob_nonposted_axi_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hls_ob_nonposted_axi_cfg();
    
    //- Creating CXS active config --------------------------------------------------
    if(is_active()) begin
      foreach(m_hls_ob_nonposted_axi_act_cfg[loop_port]) begin
        m_hls_ob_nonposted_axi_act_cfg[loop_port] = cdn_hls_config::type_id::create($sformatf("m_hls_ob_nonposted_axi_act_cfg[%0d]", loop_port));
      end
    end
    //- Creating CXS Passive config -------------------------------------------------
    foreach(m_hls_ob_nonposted_axi_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hls_ob_nonposted_axi_env[%0d]", m_env_name, loop_port), "is_active", m_is_active);
      uvm_config_db#(cdn_hls_direction)::set(null, $sformatf("%0s.m_hls_ob_nonposted_axi_env[%0d]", m_env_name, loop_port), "hls_direction", CDN_HLS_TX);
      m_hls_ob_nonposted_axi_psv_cfg[loop_port] = cdn_hls_config::type_id::create($sformatf("m_hls_ob_nonposted_axi_psv_cfg[%0d]", loop_port));
    end
    
    //- Configuring CXS Configs -----------------------------------------------------
    configure_cxs_axi_agent_cfg(.is_inbound_dir(1'b0), .is_pnp_cxs_vip(1'b1), .passive_cfg(m_hls_ob_nonposted_axi_psv_cfg), .active_cfg(m_hls_ob_nonposted_axi_act_cfg));

    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      foreach(m_hls_ob_nonposted_axi_act_cfg[loop_port]) begin
        uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ob_nonposted_axi_env[%0d].cxs_env.act_agent", m_env_name, loop_port), "cfg", m_hls_ob_nonposted_axi_act_cfg[loop_port]);
      end
    end  
    foreach(m_hls_ob_nonposted_axi_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ob_nonposted_axi_env[%0d].cxs_env.psv_agent", m_env_name, loop_port), "cfg", m_hls_ob_nonposted_axi_psv_cfg[loop_port]);
    end 

    if(coverage_enable) begin
      //- Creating CXS Coverage config -------------------------------------------------
      foreach(m_hls_ob_nonposted_axi_cov_cfg[loop_port]) begin
        m_hls_ob_nonposted_axi_cov_cfg[loop_port] = cdn_cxs_cov_collector_cfg::type_id::create($sformatf("m_hls_ob_nonposted_axi_cov_cfg[%0d]", loop_port));
      end
      
      //- Configuring CXS Coverage config -------------------------------------------------
      configure_cxs_axi_cov_collector_cfg(.is_rx(1'b0), .fc_type(2'b01), .cov_cfg(m_hls_ob_nonposted_axi_cov_cfg));

      //- Setting configs via ConfigDB ------------------------------------------------
      foreach(m_hls_ob_nonposted_axi_cov_cfg[loop_port]) begin
        uvm_config_db#(cdn_cxs_cov_collector_cfg)::set(null, $sformatf("%0s.m_hls_ob_nonposted_axi_env[%0d].cxs_env.psv_agent.m_cxs_cov_collector", m_env_name, loop_port), "m_cov_cfg", m_hls_ob_nonposted_axi_cov_cfg[loop_port]);
        uvm_config_int::set(null, $sformatf("%0s.m_hls_ob_nonposted_axi_env[%0d].cxs_env.psv_agent", m_env_name, loop_port), "m_has_cxs_cov_collector", 1);
        uvm_config_int::set(null, $sformatf("%0s.m_hls_ob_nonposted_axi_env[%0d].cxs_env", m_env_name, loop_port), "m_has_cxs_native_vip_cov", 1);
      end
    end

  endfunction : set_hls_ob_nonposted_axi_cfg

  //---------------------------------------------------------------------------
  // Method: set_hls_ob_compl_axi_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hls_ob_compl_axi_cfg();
    
    //- Creating CXS active config --------------------------------------------------
    if(is_active()) begin
      foreach(m_hls_ob_compl_axi_act_cfg[loop_port]) begin
        m_hls_ob_compl_axi_act_cfg[loop_port] = cdn_hls_config::type_id::create($sformatf("m_hls_ob_compl_axi_act_cfg[%0d]", loop_port));
      end
    end
    //- Creating CXS Passive config -------------------------------------------------
    foreach(m_hls_ob_compl_axi_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hls_ob_compl_axi_env[%0d]", m_env_name, loop_port), "is_active", m_is_active);
      uvm_config_db#(cdn_hls_direction)::set(null, $sformatf("%0s.m_hls_ob_compl_axi_env[%0d]", m_env_name, loop_port), "hls_direction", CDN_HLS_TX);
      m_hls_ob_compl_axi_psv_cfg[loop_port] = cdn_hls_config::type_id::create($sformatf("m_hls_ob_compl_axi_psv_cfg[%0d]", loop_port));
    end
    
    //- Configuring CXS Configs -----------------------------------------------------
    configure_cxs_axi_agent_cfg(.is_inbound_dir(1'b0), .is_pnp_cxs_vip(1'b0), .passive_cfg(m_hls_ob_compl_axi_psv_cfg), .active_cfg(m_hls_ob_compl_axi_act_cfg));

    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      foreach(m_hls_ob_compl_axi_act_cfg[loop_port]) begin
        uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ob_compl_axi_env[%0d].cxs_env.act_agent", m_env_name, loop_port), "cfg", m_hls_ob_compl_axi_act_cfg[loop_port]);
      end
    end  
    foreach(m_hls_ob_compl_axi_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ob_compl_axi_env[%0d].cxs_env.psv_agent", m_env_name, loop_port), "cfg", m_hls_ob_compl_axi_psv_cfg[loop_port]);
    end 
    
    if(coverage_enable) begin
      //- Creating CXS Coverage config -------------------------------------------------
      foreach(m_hls_ob_compl_axi_cov_cfg[loop_port]) begin
        m_hls_ob_compl_axi_cov_cfg[loop_port] = cdn_cxs_cov_collector_cfg::type_id::create($sformatf("m_hls_ob_compl_axi_cov_cfg[%0d]", loop_port));
      end
      
      //- Configuring CXS Coverage config -------------------------------------------------
      configure_cxs_axi_cov_collector_cfg(.is_rx(1'b0), .fc_type(2'b10), .cov_cfg(m_hls_ob_compl_axi_cov_cfg));

      //- Setting configs via ConfigDB ------------------------------------------------
      foreach(m_hls_ob_compl_axi_cov_cfg[loop_port]) begin
        uvm_config_db#(cdn_cxs_cov_collector_cfg)::set(null, $sformatf("%0s.m_hls_ob_compl_axi_env[%0d].cxs_env.psv_agent.m_cxs_cov_collector", m_env_name, loop_port), "m_cov_cfg", m_hls_ob_compl_axi_cov_cfg[loop_port]);
        uvm_config_int::set(null, $sformatf("%0s.m_hls_ob_compl_axi_env[%0d].cxs_env.psv_agent", m_env_name, loop_port), "m_has_cxs_cov_collector", 1);
        uvm_config_int::set(null, $sformatf("%0s.m_hls_ob_compl_axi_env[%0d].cxs_env", m_env_name, loop_port), "m_has_cxs_native_vip_cov", 1);
      end
    end

  endfunction : set_hls_ob_compl_axi_cfg

  //---------------------------------------------------------------------------
  // Method: set_hls_ib_posted_axi_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hls_ib_posted_axi_cfg();
    
    //- Creating CXS active config --------------------------------------------------
    if(is_active()) begin
      foreach(m_hls_ib_posted_axi_act_cfg[loop_port]) begin
        m_hls_ib_posted_axi_act_cfg[loop_port] = cdn_hls_config::type_id::create($sformatf("m_hls_ib_posted_axi_act_cfg[%0d]", loop_port));
      end
    end
    //- Creating CXS Passive config -------------------------------------------------
    foreach(m_hls_ib_posted_axi_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hls_ib_posted_axi_env[%0d]", m_env_name, loop_port), "is_active", m_is_active);
      uvm_config_db#(cdn_hls_direction)::set(null, $sformatf("%0s.m_hls_ib_posted_axi_env[%0d]", m_env_name, loop_port), "hls_direction", CDN_HLS_RX);
      m_hls_ib_posted_axi_psv_cfg[loop_port] = cdn_hls_config::type_id::create($sformatf("m_hls_ib_posted_axi_psv_cfg[%0d]", loop_port));
    end
    
    //- Configuring CXS Configs -----------------------------------------------------
    configure_cxs_axi_agent_cfg(.is_inbound_dir(1'b1), .is_pnp_cxs_vip(1'b1), .passive_cfg(m_hls_ib_posted_axi_psv_cfg), .active_cfg(m_hls_ib_posted_axi_act_cfg));

    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      foreach(m_hls_ib_posted_axi_act_cfg[loop_port]) begin
        uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ib_posted_axi_env[%0d].cxs_env.act_agent", m_env_name, loop_port), "cfg", m_hls_ib_posted_axi_act_cfg[loop_port]);
      end
    end  
    foreach(m_hls_ib_posted_axi_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ib_posted_axi_env[%0d].cxs_env.psv_agent", m_env_name, loop_port), "cfg", m_hls_ib_posted_axi_psv_cfg[loop_port]);
    end 
    
    if(coverage_enable) begin
      //- Creating CXS Coverage config -------------------------------------------------
      foreach(m_hls_ib_posted_axi_cov_cfg[loop_port]) begin
        m_hls_ib_posted_axi_cov_cfg[loop_port] = cdn_cxs_cov_collector_cfg::type_id::create($sformatf("m_hls_ib_posted_axi_cov_cfg[%0d]", loop_port));
      end
      
      //- Configuring CXS Coverage config -------------------------------------------------
      configure_cxs_axi_cov_collector_cfg(.is_rx(1'b1), .fc_type(2'b00), .cov_cfg(m_hls_ib_posted_axi_cov_cfg));

      //- Setting configs via ConfigDB ------------------------------------------------
      foreach(m_hls_ib_posted_axi_cov_cfg[loop_port]) begin
        uvm_config_db#(cdn_cxs_cov_collector_cfg)::set(null, $sformatf("%0s.m_hls_ib_posted_axi_env[%0d].cxs_env.psv_agent.m_cxs_cov_collector", m_env_name, loop_port), "m_cov_cfg", m_hls_ib_posted_axi_cov_cfg[loop_port]);
        uvm_config_int::set(null, $sformatf("%0s.m_hls_ib_posted_axi_env[%0d].cxs_env.psv_agent", m_env_name, loop_port), "m_has_cxs_cov_collector", 1);
        uvm_config_int::set(null, $sformatf("%0s.m_hls_ib_posted_axi_env[%0d].cxs_env", m_env_name, loop_port), "m_has_cxs_native_vip_cov", 1);
      end
    end

  endfunction : set_hls_ib_posted_axi_cfg
  
  //---------------------------------------------------------------------------
  // Method: set_hls_ib_nonposted_axi_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hls_ib_nonposted_axi_cfg();
    
    //- Creating CXS active config --------------------------------------------------
    if(is_active()) begin
      foreach(m_hls_ib_nonposted_axi_act_cfg[loop_port]) begin
        m_hls_ib_nonposted_axi_act_cfg[loop_port] = cdn_hls_config::type_id::create($sformatf("m_hls_ib_nonposted_axi_act_cfg[%0d]", loop_port));
      end
    end
    //- Creating CXS Passive config -------------------------------------------------
    foreach(m_hls_ib_nonposted_axi_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hls_ib_nonposted_axi_env[%0d]", m_env_name, loop_port), "is_active", m_is_active);
      uvm_config_db#(cdn_hls_direction)::set(null, $sformatf("%0s.m_hls_ib_nonposted_axi_env[%0d]", m_env_name, loop_port), "hls_direction", CDN_HLS_RX);
      m_hls_ib_nonposted_axi_psv_cfg[loop_port] = cdn_hls_config::type_id::create($sformatf("m_hls_ib_nonposted_axi_psv_cfg[%0d]", loop_port));
    end
    
    //- Configuring CXS Configs -----------------------------------------------------
    configure_cxs_axi_agent_cfg(.is_inbound_dir(1'b1), .is_pnp_cxs_vip(1'b1), .passive_cfg(m_hls_ib_nonposted_axi_psv_cfg), .active_cfg(m_hls_ib_nonposted_axi_act_cfg));

    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      foreach(m_hls_ib_nonposted_axi_act_cfg[loop_port]) begin
        uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ib_nonposted_axi_env[%0d].cxs_env.act_agent", m_env_name, loop_port), "cfg", m_hls_ib_nonposted_axi_act_cfg[loop_port]);
      end
    end  
    foreach(m_hls_ib_nonposted_axi_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ib_nonposted_axi_env[%0d].cxs_env.psv_agent", m_env_name, loop_port), "cfg", m_hls_ib_nonposted_axi_psv_cfg[loop_port]);
    end 

    if(coverage_enable) begin
      //- Creating CXS Coverage config -------------------------------------------------
      foreach(m_hls_ib_nonposted_axi_cov_cfg[loop_port]) begin
        m_hls_ib_nonposted_axi_cov_cfg[loop_port] = cdn_cxs_cov_collector_cfg::type_id::create($sformatf("m_hls_ib_nonposted_axi_cov_cfg[%0d]", loop_port));
      end
      
      //- Configuring CXS Coverage config -------------------------------------------------
      configure_cxs_axi_cov_collector_cfg(.is_rx(1'b1), .fc_type(2'b01), .cov_cfg(m_hls_ib_nonposted_axi_cov_cfg));

      //- Setting configs via ConfigDB ------------------------------------------------
      foreach(m_hls_ib_nonposted_axi_cov_cfg[loop_port]) begin
        uvm_config_db#(cdn_cxs_cov_collector_cfg)::set(null, $sformatf("%0s.m_hls_ib_nonposted_axi_env[%0d].cxs_env.psv_agent.m_cxs_cov_collector", m_env_name, loop_port), "m_cov_cfg", m_hls_ib_nonposted_axi_cov_cfg[loop_port]);
        uvm_config_int::set(null, $sformatf("%0s.m_hls_ib_nonposted_axi_env[%0d].cxs_env.psv_agent", m_env_name, loop_port), "m_has_cxs_cov_collector", 1);
        uvm_config_int::set(null, $sformatf("%0s.m_hls_ib_nonposted_axi_env[%0d].cxs_env", m_env_name, loop_port), "m_has_cxs_native_vip_cov", 1);
      end
    end

  endfunction : set_hls_ib_nonposted_axi_cfg 

  //---------------------------------------------------------------------------
  // Method: set_hls_ib_compl_axi_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hls_ib_compl_axi_cfg();
    
    //- Creating CXS active config --------------------------------------------------
    if(is_active()) begin
      foreach(m_hls_ib_compl_axi_act_cfg[loop_port]) begin
        m_hls_ib_compl_axi_act_cfg[loop_port] = cdn_hls_config::type_id::create($sformatf("m_hls_ib_compl_axi_act_cfg[%0d]", loop_port));
      end
    end
    //- Creating CXS Passive config -------------------------------------------------
    foreach(m_hls_ib_compl_axi_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hls_ib_compl_axi_env[%0d]", m_env_name, loop_port), "is_active", m_is_active);
      uvm_config_db#(cdn_hls_direction)::set(null, $sformatf("%0s.m_hls_ib_compl_axi_env[%0d]", m_env_name, loop_port), "hls_direction", CDN_HLS_RX);
      m_hls_ib_compl_axi_psv_cfg[loop_port] = cdn_hls_config::type_id::create($sformatf("m_hls_ib_compl_axi_psv_cfg[%0d]", loop_port));
    end
    
    //- Configuring CXS Configs -----------------------------------------------------
    configure_cxs_axi_agent_cfg(.is_inbound_dir(1'b1), .is_pnp_cxs_vip(1'b0), .passive_cfg(m_hls_ib_compl_axi_psv_cfg), .active_cfg(m_hls_ib_compl_axi_act_cfg));

    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      foreach(m_hls_ib_compl_axi_act_cfg[loop_port]) begin
        uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ib_compl_axi_env[%0d].cxs_env.act_agent", m_env_name, loop_port), "cfg", m_hls_ib_compl_axi_act_cfg[loop_port]);
      end
    end  
    foreach(m_hls_ib_compl_axi_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hls_ib_compl_axi_env[%0d].cxs_env.psv_agent", m_env_name, loop_port), "cfg", m_hls_ib_compl_axi_psv_cfg[loop_port]);
    end

    if(coverage_enable) begin
      //- Creating CXS Coverage config -------------------------------------------------
      foreach(m_hls_ib_compl_axi_cov_cfg[loop_port]) begin
        m_hls_ib_compl_axi_cov_cfg[loop_port] = cdn_cxs_cov_collector_cfg::type_id::create($sformatf("m_hls_ib_compl_axi_cov_cfg[%0d]", loop_port));
      end
      
      //- Configuring CXS Coverage config -------------------------------------------------
      configure_cxs_axi_cov_collector_cfg(.is_rx(1'b1), .fc_type(2'b10), .cov_cfg(m_hls_ib_compl_axi_cov_cfg));

      //- Setting configs via ConfigDB ------------------------------------------------
      foreach(m_hls_ib_compl_axi_cov_cfg[loop_port]) begin
        uvm_config_db#(cdn_cxs_cov_collector_cfg)::set(null, $sformatf("%0s.m_hls_ib_compl_axi_env[%0d].cxs_env.psv_agent.m_cxs_cov_collector", m_env_name, loop_port), "m_cov_cfg", m_hls_ib_compl_axi_cov_cfg[loop_port]);
        uvm_config_int::set(null, $sformatf("%0s.m_hls_ib_compl_axi_env[%0d].cxs_env.psv_agent", m_env_name, loop_port), "m_has_cxs_cov_collector", 1);
        uvm_config_int::set(null, $sformatf("%0s.m_hls_ib_compl_axi_env[%0d].cxs_env", m_env_name, loop_port), "m_has_cxs_native_vip_cov", 1);
      end
    end

  endfunction : set_hls_ib_compl_axi_cfg

`ifdef DTI_TB_IN_PASSIVE_MODE
  //---------------------------------------------------------------------------
  // Method: set_dti_cfg
  //---------------------------------------------------------------------------
  virtual function void set_dti_cfg();
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT == 0)
      return;

    m_dti_cfg = cdn_pcie_dti_config::type_id::create("m_dti_cfg");
    m_dti_cfg.set_strap_config(this.i_cfg);
    m_dti_cfg.disable_selective_ide_stream_rid_range_miss = 1'b1;

    if (!(m_dti_cfg.randomize() with {
      i_cfg.k_ide_supported -> (m_dti_cfg.negotiated_version inside {CDN_PCIE_DTI_ATS_VERSION_V3, CDN_PCIE_DTI_ATS_VERSION_V4});
      i_cfg.k_ide_supported -> (m_dti_cfg.granted_sup_t == 1);
    })) begin
      `uvm_error(get_type_name(), "DTI config randomization failure")
    end

    uvm_config_db#(cdn_pcie_dti_config)::set(null, $sformatf("%0s.dti_env", m_env_name), "dti_cfg", m_dti_cfg);
    uvm_config_db#(cdn_pcie_dti_config)::set(null, "*", "hls_bridge_m_dti_cfg", m_dti_cfg);
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.dti_env", m_env_name), "is_active", UVM_PASSIVE);
  endfunction : set_dti_cfg
`endif

  //---------------------------------------------------------------------------
  // Method: set_hdr2log_mst_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hdr2log_mst_cfg();
    
    //- Creating stream active config ---------------------------------------------
    if(is_active()) begin
      foreach(m_hdr2log_mst_act_cfg[loop_port]) begin
        m_hdr2log_mst_act_cfg[loop_port] = cdnStreamUvmConfig::type_id::create($sformatf("m_hdr2log_mst_act_cfg[%0d]", loop_port));
      end
    end
    //- Creating Stream passive config --------------------------------------------
    foreach(m_hdr2log_slv_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hdr2log_mst_env[%0d]", m_env_name, loop_port), "is_active", m_is_active);
      m_hdr2log_slv_psv_cfg[loop_port] = cdnStreamUvmConfig::type_id::create($sformatf("m_hdr2log_slv_psv_cfg[%0d]", loop_port));
    end
    
    //- Configuring Stream Configs -----------------------------------------------------
    foreach(m_hdr2log_slv_psv_cfg[loop_port]) begin
      configure_stream_agent_cfg(.is_master(1'b1), .support_tready(1'b1), .passive_cfg(m_hdr2log_slv_psv_cfg[loop_port]), .active_cfg(m_hdr2log_mst_act_cfg[loop_port]), .is_agent_active(is_active()));
    end

    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      foreach(m_hdr2log_mst_act_cfg[loop_port]) begin
        uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hdr2log_mst_env[%0d].act_agent", m_env_name, loop_port), "cfg", m_hdr2log_mst_act_cfg[loop_port]);
      end
    end
    foreach(m_hdr2log_slv_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hdr2log_mst_env[%0d].psv_agent", m_env_name, loop_port), "cfg", m_hdr2log_slv_psv_cfg[loop_port]);
    end
  endfunction : set_hdr2log_mst_cfg
  
  //---------------------------------------------------------------------------
  // Method: set_hdr2log_slv_cfg
  //---------------------------------------------------------------------------
  virtual function void set_hdr2log_slv_cfg();
    
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_hdr2log_slv_env", m_env_name), "is_active", m_is_active);
    
    //- Creating Stream Active config --------------------------------------------
    if(is_active()) begin
      m_hdr2log_slv_act_cfg = cdnStreamUvmConfig::type_id::create("m_hdr2log_slv_act_cfg");
    end
    //- Creating Stream passive config --------------------------------------------
    m_hdr2log_mst_psv_cfg = cdnStreamUvmConfig::type_id::create("m_hdr2log_mst_psv_cfg");
    
    //- Configuring Stream Configs -----------------------------------------------------
    configure_stream_agent_cfg(.is_master(1'b0), .support_tready(1'b1), .passive_cfg(m_hdr2log_mst_psv_cfg), .active_cfg(m_hdr2log_slv_act_cfg), .is_agent_active(is_active()));
    
    if(is_active()) begin
      // -- As Per PCIE-19682 tready should always be set to 1 as the core is always ready to get the hdr2log data.
      m_hdr2log_slv_act_cfg.always_accept = 1;
    end

    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hdr2log_slv_env.act_agent", m_env_name), "cfg", m_hdr2log_slv_act_cfg);
    end
    uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_hdr2log_slv_env.psv_agent", m_env_name), "cfg", m_hdr2log_mst_psv_cfg);
  endfunction : set_hdr2log_slv_cfg

  //---------------------------------------------------------------------------
  // Method: set_axis_msi_slv_cfg
  //---------------------------------------------------------------------------
  virtual function void set_axis_msi_slv_cfg();
    
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_axis_msi_slv_env", m_env_name), "is_active", UVM_ACTIVE);
    
    //- Creating Stream Active config --------------------------------------------
//    if(is_active()) begin
      m_axis_msi_slv_act_cfg = cdnStreamUvmConfig::type_id::create("m_axis_msi_slv_act_cfg");
//    end
    //- Creating Stream passive config --------------------------------------------
    m_axis_msi_mst_psv_cfg = cdnStreamUvmConfig::type_id::create("m_axis_msi_mst_psv_cfg");
    
    //- Configuring Stream Configs -----------------------------------------------------
    configure_stream_agent_cfg(.is_master(1'b0), .support_tready(1'b1), .passive_cfg(m_axis_msi_mst_psv_cfg), .active_cfg(m_axis_msi_slv_act_cfg), .is_agent_active(1'b1));
    
    //- Setting configs via ConfigDB ------------------------------------------------ 
//    if(is_active()) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_axis_msi_slv_env.act_agent", m_env_name), "cfg", m_axis_msi_slv_act_cfg);
//    end
    uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_axis_msi_slv_env.psv_agent", m_env_name), "cfg", m_axis_msi_mst_psv_cfg);
  endfunction : set_axis_msi_slv_cfg

  //---------------------------------------------------------------------------
  // Method: set_dc_mst_cfg
  //---------------------------------------------------------------------------
  virtual function void set_dc_mst_cfg();
    
    //- Creating stream active config ---------------------------------------------
    if(is_active()) begin
      foreach(m_dc_mst_act_cfg[loop_port]) begin
        m_dc_mst_act_cfg[loop_port] = cdnStreamUvmConfig::type_id::create($sformatf("m_dc_mst_act_cfg[%0d]", loop_port));
      end
    end
    //- Creating Stream passive config --------------------------------------------
    foreach(m_dc_slv_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_dc_mst_env[%0d]", m_env_name, loop_port), "is_active", m_is_active);
      m_dc_slv_psv_cfg[loop_port] = cdnStreamUvmConfig::type_id::create($sformatf("m_dc_slv_psv_cfg[%0d]", loop_port));
    end
    
    //- Configuring Stream Configs -----------------------------------------------------
    foreach(m_dc_slv_psv_cfg[loop_port]) begin
      configure_stream_agent_cfg(.is_master(1'b1), .support_tready(1'b0), .passive_cfg(m_dc_slv_psv_cfg[loop_port]), .active_cfg(m_dc_mst_act_cfg[loop_port]), .is_agent_active(is_active()));
    end

    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      foreach(m_dc_mst_act_cfg[loop_port]) begin
        uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_dc_mst_env[%0d].act_agent", m_env_name, loop_port), "cfg", m_dc_mst_act_cfg[loop_port]);
      end
    end
    foreach(m_dc_slv_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_dc_mst_env[%0d].psv_agent", m_env_name, loop_port), "cfg", m_dc_slv_psv_cfg[loop_port]);
    end
  endfunction : set_dc_mst_cfg

  //---------------------------------------------------------------------------
  // Method: set_dc_slv_cfg
  //---------------------------------------------------------------------------
  virtual function void set_dc_slv_cfg();
    
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_dc_slv_env", m_env_name), "is_active", m_is_active);
    
    //- Creating Stream Active config --------------------------------------------
    if(is_active()) begin
      m_dc_slv_act_cfg = cdnStreamUvmConfig::type_id::create("m_dc_slv_act_cfg");
    end
    //- Creating Stream passive config --------------------------------------------
    m_dc_mst_psv_cfg = cdnStreamUvmConfig::type_id::create("m_dc_mst_psv_cfg");
    
    //- Configuring Stream Configs -----------------------------------------------------
    configure_stream_agent_cfg(.is_master(1'b0), .support_tready(1'b0), .passive_cfg(m_dc_mst_psv_cfg), .active_cfg(m_dc_slv_act_cfg), .is_agent_active(is_active()));
    
    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_dc_slv_env.act_agent", m_env_name), "cfg", m_dc_slv_act_cfg);
    end
    uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_dc_slv_env.psv_agent", m_env_name), "cfg", m_dc_mst_psv_cfg);
  endfunction : set_dc_slv_cfg

  //---------------------------------------------------------------------------
  // Method: set_qos_mst_cfg
  //---------------------------------------------------------------------------
  virtual function void set_qos_mst_cfg();
    if(is_active()) begin
      foreach(m_qos_mst_act_cfg[loop_port]) begin
        m_qos_mst_act_cfg[loop_port] = cdnStreamUvmConfig::type_id::create( $sformatf("m_qos_mst_act_cfg[%0d]", loop_port));
      end
    end

    foreach(m_qos_slv_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_active_passive_enum)::set(null,$sformatf("%0s.m_qos_mst_env[%0d]", m_env_name, loop_port),"is_active", m_is_active);
      m_qos_slv_psv_cfg[loop_port] = cdnStreamUvmConfig::type_id::create($sformatf("m_qos_mst_psv_cfg[%0d]", loop_port));
    end

    foreach(m_qos_slv_psv_cfg[loop_port]) begin
      configure_stream_agent_cfg(.is_master(1'b1),.support_tready (1'b0),.passive_cfg    (m_qos_slv_psv_cfg[loop_port]),.active_cfg     (m_qos_mst_act_cfg[loop_port]),.is_agent_active(is_active()));
    end

    if(is_active()) begin
      foreach(m_qos_mst_act_cfg[loop_port]) begin
        uvm_config_db#(uvm_object)::set(null,$sformatf("%0s.m_qos_mst_env[%0d].act_agent", m_env_name, loop_port),"cfg", m_qos_mst_act_cfg[loop_port]);
      end
    end

    foreach(m_qos_slv_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_object)::set(null,$sformatf("%0s.m_qos_mst_env[%0d].psv_agent", m_env_name, loop_port),"cfg", m_qos_slv_psv_cfg[loop_port]);
    end
  endfunction : set_qos_mst_cfg

  //---------------------------------------------------------------------------
  // Method: set_qos_slv_cfg
  //---------------------------------------------------------------------------
  virtual function void set_qos_slv_cfg();
    uvm_config_db#(uvm_active_passive_enum)::set(null,$sformatf("%0s.m_qos_slv_env", m_env_name),"is_active", m_is_active);

    if(is_active())
      m_qos_slv_act_cfg = cdnStreamUvmConfig::type_id::create("m_qos_slv_act_cfg");

    m_qos_mst_psv_cfg = cdnStreamUvmConfig::type_id::create("m_qos_slv_psv_cfg");

    configure_stream_agent_cfg(.is_master(1'b0),.support_tready (1'b0),.passive_cfg (m_qos_mst_psv_cfg),.active_cfg     (m_qos_slv_act_cfg),.is_agent_active(is_active()));

    if(is_active())
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_qos_slv_env.act_agent", m_env_name),"cfg", m_qos_slv_act_cfg);
    
    uvm_config_db#(uvm_object)::set(null,$sformatf("%0s.m_qos_slv_env.psv_agent", m_env_name),"cfg", m_qos_mst_psv_cfg);

  endfunction : set_qos_slv_cfg

  //---------------------------------------------------------------------------
  // Method: set_lti_c_tx_cfg
  //---------------------------------------------------------------------------
  virtual function void set_lti_c_tx_cfg();
    
    //- Creating stream active config ---------------------------------------------
    if(is_active()) begin
      foreach(m_lti_c_tx_act_cfg[loop_port]) begin
        m_lti_c_tx_act_cfg[loop_port] = cdnStreamUvmConfig::type_id::create($sformatf("m_lti_c_tx_act_cfg[%0d]", loop_port));
      end
    end
    //- Creating Stream passive config --------------------------------------------
    foreach(m_lti_c_rx_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_lti_c_tx_env[%0d]", m_env_name, loop_port), "is_active", m_is_active);
      m_lti_c_rx_psv_cfg[loop_port] = cdnStreamUvmConfig::type_id::create($sformatf("m_lti_c_rx_psv_cfg[%0d]", loop_port));
    end
    
    //- Configuring Stream Configs -----------------------------------------------------
    foreach(m_lti_c_rx_psv_cfg[loop_port]) begin
      configure_stream_agent_cfg(.is_master(1'b1), .support_tready(1'b0), .passive_cfg(m_lti_c_rx_psv_cfg[loop_port]), .active_cfg(m_lti_c_tx_act_cfg[loop_port]), .is_agent_active(is_active()));
    end

    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      foreach(m_lti_c_tx_act_cfg[loop_port]) begin
        uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_lti_c_tx_env[%0d].act_agent", m_env_name, loop_port), "cfg", m_lti_c_tx_act_cfg[loop_port]);
      end
    end
    foreach(m_lti_c_rx_psv_cfg[loop_port]) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_lti_c_tx_env[%0d].psv_agent", m_env_name, loop_port), "cfg", m_lti_c_rx_psv_cfg[loop_port]);
    end
  endfunction : set_lti_c_tx_cfg

  //---------------------------------------------------------------------------
  // Method: set_lti_c_rx_cfg
  //---------------------------------------------------------------------------
  virtual function void set_lti_c_rx_cfg();
    
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_lti_c_rx_env", m_env_name), "is_active", m_is_active);
    
    //- Creating Stream Active config --------------------------------------------
    if(is_active()) begin
      m_lti_c_rx_act_cfg = cdnStreamUvmConfig::type_id::create("m_lti_c_rx_act_cfg");
    end
    //- Creating Stream passive config --------------------------------------------
    m_lti_c_tx_psv_cfg = cdnStreamUvmConfig::type_id::create("m_lti_c_tx_psv_cfg");
    
    //- Configuring Stream Configs -----------------------------------------------------
    configure_stream_agent_cfg(.is_master(1'b0), .support_tready(1'b0), .passive_cfg(m_lti_c_tx_psv_cfg), .active_cfg(m_lti_c_rx_act_cfg), .is_agent_active(is_active()));
    
    //- Setting configs via ConfigDB ------------------------------------------------ 
    if(is_active()) begin
      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_lti_c_rx_env.act_agent", m_env_name), "cfg", m_lti_c_rx_act_cfg);
    end
    uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_lti_c_rx_env.psv_agent", m_env_name), "cfg", m_lti_c_tx_psv_cfg);
  endfunction : set_lti_c_rx_cfg

  //---------------------------------------------------------------------------
  // Method: set_axi_lite_mst_cfg
  //---------------------------------------------------------------------------
  virtual function void set_axi_lite_mst_cfg();
    
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_axi_lite_mst_env", m_env_name), "is_active", m_is_active);

    //- AXI Lite Slave Passive config -----------------------------------------
    m_axi_lite_slv_psv_cfg = cdnAxiUvmConfig::type_id::create("m_axi_lite_slv_psv_cfg");
    m_axi_lite_slv_psv_cfg.is_active                     = UVM_PASSIVE                                                                                                                   ;

    // AW Channel
    m_axi_lite_slv_psv_cfg.pins.awvalid.size             = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.awvalidchk.size          = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.awready.size             = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.awreadychk.size          = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.awaddr.size              = HLS_BRIDGE_AXIL_ADDR_WIDTH                                                                                                    ;
    m_axi_lite_slv_psv_cfg.pins.awaddrchk.size           = HLS_BRIDGE_AXIL_ADDR_PARITY_WIDTH                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.awprot.size              = 3                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.awctlchk0.size           = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.awuser.size              = parameters_cfg_pkg::AXIL_S_AWUSER_WIDTH                                                                                       ;
    m_axi_lite_slv_psv_cfg.pins.awuserchk.size           = parameters_cfg_pkg::AXIL_S_AWUSER_PARITY_WIDTH                                                                                ;
    
    // W Channel
    m_axi_lite_slv_psv_cfg.pins.wvalid.size              = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.wvalidchk.size           = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.wready.size              = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.wreadychk.size           = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.wdata.size               = parameters_cfg_pkg::AXIL_DATA_WIDTH                                                                                           ;
    m_axi_lite_slv_psv_cfg.pins.wdatachk.size            = parameters_cfg_pkg::AXIL_DATA_PARITY_WIDTH                                                                                    ;
    m_axi_lite_slv_psv_cfg.pins.wstrb.size               = parameters_cfg_pkg::AXIL_STRB_WIDTH                                                                                           ;
    m_axi_lite_slv_psv_cfg.pins.wstrbchk.size            = parameters_cfg_pkg::AXIL_STRB_PARITY_WIDTH                                                                                    ;
    m_axi_lite_slv_psv_cfg.pins.wuser.size               = parameters_cfg_pkg::AXIL_S_WUSER_WIDTH                                                                                        ;
    m_axi_lite_slv_psv_cfg.pins.wuserchk.size            = parameters_cfg_pkg::AXIL_S_WUSER_PARITY_WIDTH                                                                                 ;
    
    // B Channel
    m_axi_lite_slv_psv_cfg.pins.bvalid.size              = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.bvalidchk.size           = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.bready.size              = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.breadychk.size           = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.bresp.size               = parameters_cfg_pkg::AXIL_DATA_WIDTH/8                                                                                         ;
    m_axi_lite_slv_psv_cfg.pins.brespchk.size            = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.buser.size               = parameters_cfg_pkg::AXIL_S_BUSER_WIDTH                                                                                        ;
    m_axi_lite_slv_psv_cfg.pins.buserchk.size            = parameters_cfg_pkg::AXIL_S_BUSER_PARITY_WIDTH                                                                                 ;

    // AR Channel
    m_axi_lite_slv_psv_cfg.pins.arvalid.size             = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.arvalidchk.size          = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.arready.size             = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.arreadychk.size          = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.araddr.size              = HLS_BRIDGE_AXIL_ADDR_WIDTH                                                                                                    ;
    m_axi_lite_slv_psv_cfg.pins.araddrchk.size           = HLS_BRIDGE_AXIL_ADDR_PARITY_WIDTH                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.arprot.size              = 3                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.arctlchk0.size           = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.aruser.size              = parameters_cfg_pkg::AXIL_S_ARUSER_WIDTH                                                                                       ;
    m_axi_lite_slv_psv_cfg.pins.aruserchk.size           = parameters_cfg_pkg::AXIL_S_ARUSER_PARITY_WIDTH                                                                                ;
    
    // R Channel
    m_axi_lite_slv_psv_cfg.pins.rvalid.size              = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.rvalidchk.size           = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.rready.size              = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.rreadychk.size           = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.rdata.size               = parameters_cfg_pkg::AXIL_DATA_WIDTH                                                                                           ;
    m_axi_lite_slv_psv_cfg.pins.rdatachk.size            = parameters_cfg_pkg::AXIL_DATA_PARITY_WIDTH                                                                                    ;
    m_axi_lite_slv_psv_cfg.pins.rresp.size               = 4                                                                                                                             ;  //TODO Pass from parameters_cfg_pkg
    m_axi_lite_slv_psv_cfg.pins.rrespchk.size            = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.pins.ruser.size               = parameters_cfg_pkg::AXIL_S_RUSER_WIDTH                                                                                        ;
    m_axi_lite_slv_psv_cfg.pins.ruserchk.size            = parameters_cfg_pkg::AXIL_S_RUSER_PARITY_WIDTH                                                                                 ;
    
    m_axi_lite_slv_psv_cfg.addr_width                    = HLS_BRIDGE_AXIL_ADDR_WIDTH                                                                                                    ;
    m_axi_lite_slv_psv_cfg.write_data_width              = parameters_cfg_pkg::AXIL_DATA_WIDTH                                                                                           ;
    m_axi_lite_slv_psv_cfg.read_data_width               = parameters_cfg_pkg::AXIL_DATA_WIDTH                                                                                           ;
    m_axi_lite_slv_psv_cfg.id_width                      = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.write_id_width                = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.read_id_width                 = 1                                                                                                                             ;

    m_axi_lite_slv_psv_cfg.PortType                      = CDN_AXI_CFG_SLAVE                                                                                                             ;
    m_axi_lite_slv_psv_cfg.spec_ver                      = CDN_AXI_CFG_SPEC_VER_AMBA5                                                                                                    ;
    m_axi_lite_slv_psv_cfg.spec_subtype                  = CDN_AXI_CFG_SPEC_SUBTYPE_BASE                                                                                                 ;
    m_axi_lite_slv_psv_cfg.spec_interface                = CDN_AXI_CFG_SPEC_INTERFACE_LITE                                                                                               ;
    m_axi_lite_slv_psv_cfg.user_signal_array_width_only  = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.coverage_level                = coverage_enable ? CDN_AXI_CFG_COVERAGE_LEVEL_HIGH : CDN_AXI_CFG_COVERAGE_LEVEL_LOW                                            ;
    m_axi_lite_slv_psv_cfg.axi4_lite_user_signals        = 1                                                                                                                             ; //TODO Check if this user signal is needed or not.
    m_axi_lite_slv_psv_cfg.data_check_supported          = (parameters_cfg_pkg::ASF_SUPPORT >= 2) ? CDN_AXI_CFG_DATA_CHECK_SUPPORTED_ODD_PARITY : CDN_AXI_CFG_DATA_CHECK_SUPPORTED_FALSE ;
    m_axi_lite_slv_psv_cfg.check_type                    = (parameters_cfg_pkg::ASF_SUPPORT >= 2) ? CDN_AXI_CFG_CHECK_TYPE_ODD_PARITY_BYTE_ALL  : CDN_AXI_CFG_CHECK_TYPE_FALSE           ;
    m_axi_lite_slv_psv_cfg.reset_signals_sim_start       = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.use_memory                    = 0                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.write_acceptance_capability   = 10                                                                                                                            ;
    m_axi_lite_slv_psv_cfg.read_acceptance_capability    = 10                                                                                                                            ;
    m_axi_lite_slv_psv_cfg.write_issuing_capability      = 10                                                                                                                            ;
    m_axi_lite_slv_psv_cfg.read_issuing_capability       = 10                                                                                                                            ;
    m_axi_lite_slv_psv_cfg.idle_mode_optimization_config = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.idle_mode_optimization        = CDN_AXI_CFG_IDLE_MODE_OPTIMIZATION_OPTIMIZED_CB                                                                               ;
    m_axi_lite_slv_psv_cfg.random_data_when_not_valid    = 1                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.enable_tracker                = 0                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.has_tr_recording              = 0                                                                                                                             ;
    m_axi_lite_slv_psv_cfg.verbosity                     = CDN_AXI_CFG_MESSAGEVERBOSITY_LOW                                                                                              ;

    // addToMemorySegments syntax: (addr_base, addr_limit, non-shareable/non-cacheable)
    
    // -- HLS Bridge Memory Segment -----------------
    m_axi_lite_slv_psv_cfg.addToMemorySegments(64'h01F0_0000, 64'h01F0_FFFF, CDN_AXI_CFG_DOMAIN_NON_SHAREABLE); // Base Address: 0x01F0_0000 and Range: 0x0001_0000.
    
    // -- DTI Memory Segment ------------------------
    if(parameters_cfg_pkg::KMAX_DTI_SUPPORT) begin
      m_axi_lite_slv_psv_cfg.addToMemorySegments(64'h01F2_0000, 64'h01F2_0FFF, CDN_AXI_CFG_DOMAIN_NON_SHAREABLE); // Base Address: 0x01F2_0000 and Range: 0x0000_1000.
    end
    
    // -- AXI MultiBridge(cxl) Memory Segment -------
    m_axi_lite_slv_psv_cfg.addToMemorySegments(64'h0200_0000, 64'h0200_0FFF, CDN_AXI_CFG_DOMAIN_NON_SHAREABLE); // Base Address: 0x0200_0000 and Range: 0x0000_1000.

    // -- AXI MultiBridge(credits) Memory Segment -------
    m_axi_lite_slv_psv_cfg.addToMemorySegments(64'h0200_1000, 64'h0200_1FFF, CDN_AXI_CFG_DOMAIN_NON_SHAREABLE); // Base Address: 0x0200_1000 and Range: 0x0000_1000.
    
    //  -- AXI MultiBridge(common) Memory Segment ----
    m_axi_lite_slv_psv_cfg.addToMemorySegments(64'h0202_0000, 64'h0203_FFFF, CDN_AXI_CFG_DOMAIN_NON_SHAREABLE); // Base Address: 0x0202_0000 and Range: 0x0002_0000.

    //  -- AXI Bridge Memory Segment -----------------
    for (int i = 0 ; i < parameters_cfg_pkg::NUM_AXI_PORTS; i++) begin        
      m_axi_lite_slv_psv_cfg.addToMemorySegments((64'h0300_0000 + i * 64'h0002_0000), ((64'h0300_0000 + (i + 1) * 64'h0002_0000) - 64'h0000_0001), CDN_AXI_CFG_DOMAIN_NON_SHAREABLE); //Base Address: 0x0300_0000 and Range: 0x0002_0000 for each AXI Bridge.
    end

    uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_axi_lite_mst_env.psv_agent", m_env_name), "cfg", m_axi_lite_slv_psv_cfg);

    //- AXI Lite Master Active config -----------------------------------------
    if(is_active()) begin
      m_axi_lite_mst_act_cfg = cdnAxiUvmConfig::type_id::create("m_axi_lite_mst_act_cfg");
      m_axi_lite_mst_act_cfg.copy(m_axi_lite_slv_psv_cfg);
      m_axi_lite_mst_act_cfg.is_active = UVM_ACTIVE        ;
      m_axi_lite_mst_act_cfg.PortType  = CDN_AXI_CFG_MASTER;

      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_axi_lite_mst_env.act_agent", m_env_name), "cfg", m_axi_lite_mst_act_cfg);
    end
  endfunction : set_axi_lite_mst_cfg
  
  //---------------------------------------------------------------------------
  // Method: set_axi_lite_slv_cfg
  //---------------------------------------------------------------------------
  virtual function void set_axi_lite_slv_cfg();
    
    uvm_config_db#(uvm_active_passive_enum)::set(null, $sformatf("%0s.m_axi_lite_slv_env", m_env_name), "is_active", m_is_active);
    
    //- AXI Lite Master Passive config -----------------------------------------
    m_axi_lite_mst_psv_cfg = cdnAxiUvmConfig::type_id::create("m_axi_lite_mst_psv_cfg");
    m_axi_lite_mst_psv_cfg.is_active                     = UVM_PASSIVE                                                                                                                   ;

    // AW Channel
    m_axi_lite_mst_psv_cfg.pins.awvalid.size             = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.awvalidchk.size          = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.awready.size             = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.awreadychk.size          = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.awaddr.size              = HLS_BRIDGE_AXIL_ADDR_WIDTH                                                                                                    ;
    m_axi_lite_mst_psv_cfg.pins.awaddrchk.size           = HLS_BRIDGE_AXIL_ADDR_PARITY_WIDTH                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.awprot.size              = 3                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.awctlchk0.size           = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.awuser.size              = parameters_cfg_pkg::AXIL_S_AWUSER_WIDTH                                                                                       ;
    m_axi_lite_mst_psv_cfg.pins.awuserchk.size           = parameters_cfg_pkg::AXIL_S_AWUSER_PARITY_WIDTH                                                                                ;
    
    // W Channel
    m_axi_lite_mst_psv_cfg.pins.wvalid.size              = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.wvalidchk.size           = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.wready.size              = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.wreadychk.size           = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.wdata.size               = parameters_cfg_pkg::AXIL_DATA_WIDTH                                                                                           ;
    m_axi_lite_mst_psv_cfg.pins.wdatachk.size            = parameters_cfg_pkg::AXIL_DATA_PARITY_WIDTH                                                                                    ;
    m_axi_lite_mst_psv_cfg.pins.wstrb.size               = parameters_cfg_pkg::AXIL_STRB_WIDTH                                                                                           ;
    m_axi_lite_mst_psv_cfg.pins.wstrbchk.size            = parameters_cfg_pkg::AXIL_STRB_PARITY_WIDTH                                                                                    ;
    m_axi_lite_mst_psv_cfg.pins.wuser.size               = parameters_cfg_pkg::AXIL_S_WUSER_WIDTH                                                                                        ;
    m_axi_lite_mst_psv_cfg.pins.wuserchk.size            = parameters_cfg_pkg::AXIL_S_WUSER_PARITY_WIDTH                                                                                 ;
    
    // B Channel
    m_axi_lite_mst_psv_cfg.pins.bvalid.size              = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.bvalidchk.size           = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.bready.size              = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.breadychk.size           = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.bresp.size               = parameters_cfg_pkg::AXIL_DATA_WIDTH/8                                                                                         ;
    m_axi_lite_mst_psv_cfg.pins.brespchk.size            = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.buser.size               = parameters_cfg_pkg::AXIL_S_BUSER_WIDTH                                                                                        ;
    m_axi_lite_mst_psv_cfg.pins.buserchk.size            = parameters_cfg_pkg::AXIL_S_BUSER_PARITY_WIDTH                                                                                 ;

    // AR Channel
    m_axi_lite_mst_psv_cfg.pins.arvalid.size             = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.arvalidchk.size          = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.arready.size             = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.arreadychk.size          = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.araddr.size              = HLS_BRIDGE_AXIL_ADDR_WIDTH                                                                                                    ;
    m_axi_lite_mst_psv_cfg.pins.araddrchk.size           = HLS_BRIDGE_AXIL_ADDR_PARITY_WIDTH                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.arprot.size              = 3                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.arctlchk0.size           = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.aruser.size              = parameters_cfg_pkg::AXIL_S_ARUSER_WIDTH                                                                                       ;
    m_axi_lite_mst_psv_cfg.pins.aruserchk.size           = parameters_cfg_pkg::AXIL_S_ARUSER_PARITY_WIDTH                                                                                ;
    
    // R Channel
    m_axi_lite_mst_psv_cfg.pins.rvalid.size              = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.rvalidchk.size           = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.rready.size              = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.rreadychk.size           = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.rdata.size               = parameters_cfg_pkg::AXIL_DATA_WIDTH                                                                                           ;
    m_axi_lite_mst_psv_cfg.pins.rdatachk.size            = parameters_cfg_pkg::AXIL_DATA_PARITY_WIDTH                                                                                    ;
    m_axi_lite_mst_psv_cfg.pins.rresp.size               = 4                                                                                                                             ;  //TODO Pass from parameters_cfg_pkg
    m_axi_lite_mst_psv_cfg.pins.rrespchk.size            = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.pins.ruser.size               = parameters_cfg_pkg::AXIL_S_RUSER_WIDTH                                                                                        ;
    m_axi_lite_mst_psv_cfg.pins.ruserchk.size            = parameters_cfg_pkg::AXIL_S_RUSER_PARITY_WIDTH                                                                                 ;
    
    m_axi_lite_mst_psv_cfg.addr_width                    = HLS_BRIDGE_AXIL_ADDR_WIDTH                                                                                                    ;
    m_axi_lite_mst_psv_cfg.write_data_width              = parameters_cfg_pkg::AXIL_DATA_WIDTH                                                                                           ;
    m_axi_lite_mst_psv_cfg.read_data_width               = parameters_cfg_pkg::AXIL_DATA_WIDTH                                                                                           ;
    m_axi_lite_mst_psv_cfg.id_width                      = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.write_id_width                = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.read_id_width                 = 1                                                                                                                             ;
    
    m_axi_lite_mst_psv_cfg.PortType                      = CDN_AXI_CFG_MASTER                                                                                                            ;
    m_axi_lite_mst_psv_cfg.spec_ver                      = CDN_AXI_CFG_SPEC_VER_AMBA5                                                                                                    ;
    m_axi_lite_mst_psv_cfg.spec_subtype                  = CDN_AXI_CFG_SPEC_SUBTYPE_BASE                                                                                                 ;
    m_axi_lite_mst_psv_cfg.spec_interface                = CDN_AXI_CFG_SPEC_INTERFACE_LITE                                                                                               ;
    m_axi_lite_mst_psv_cfg.user_signal_array_width_only  = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.coverage_level                = coverage_enable ? CDN_AXI_CFG_COVERAGE_LEVEL_HIGH : CDN_AXI_CFG_COVERAGE_LEVEL_LOW                                            ;
    m_axi_lite_mst_psv_cfg.axi4_lite_user_signals        = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.data_check_supported          = (parameters_cfg_pkg::ASF_SUPPORT >= 2) ? CDN_AXI_CFG_DATA_CHECK_SUPPORTED_ODD_PARITY : CDN_AXI_CFG_DATA_CHECK_SUPPORTED_FALSE ;
    m_axi_lite_mst_psv_cfg.check_type                    = (parameters_cfg_pkg::ASF_SUPPORT >= 2) ? CDN_AXI_CFG_CHECK_TYPE_ODD_PARITY_BYTE_ALL  : CDN_AXI_CFG_CHECK_TYPE_FALSE           ;
    m_axi_lite_mst_psv_cfg.reset_signals_sim_start       = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.use_memory                    = 0                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.write_acceptance_capability   = 10                                                                                                                            ;
    m_axi_lite_mst_psv_cfg.read_acceptance_capability    = 10                                                                                                                            ;
    m_axi_lite_mst_psv_cfg.write_issuing_capability      = 10                                                                                                                            ;
    m_axi_lite_mst_psv_cfg.read_issuing_capability       = 10                                                                                                                            ;
    m_axi_lite_mst_psv_cfg.idle_mode_optimization_config = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.idle_mode_optimization        = CDN_AXI_CFG_IDLE_MODE_OPTIMIZATION_OPTIMIZED_CB                                                                               ;
    m_axi_lite_mst_psv_cfg.random_data_when_not_valid    = 1                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.enable_tracker                = 0                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.has_tr_recording              = 0                                                                                                                             ;
    m_axi_lite_mst_psv_cfg.verbosity                     = CDN_AXI_CFG_MESSAGEVERBOSITY_LOW                                                                                              ;

    // -- AXI MultiBridge(cxl) Memory Segment -------
    m_axi_lite_mst_psv_cfg.addToMemorySegments(64'h0000_0000, 64'h0000_0FFF, CDN_AXI_CFG_DOMAIN_NON_SHAREABLE); // Base Address: 0x0200_0000 and Range: 0x0000_1000.
    
    // -- AXI MultiBridge(credits) Memory Segment -------
    m_axi_lite_mst_psv_cfg.addToMemorySegments(64'h0000_1000, 64'h0000_1FFF, CDN_AXI_CFG_DOMAIN_NON_SHAREABLE); // Base Address: 0x0200_1000 and Range: 0x0000_1000.

    // -- AXI MultiBridge(common) Memory Segment ----
    m_axi_lite_mst_psv_cfg.addToMemorySegments(64'h0002_0000, 64'h0003_FFFF, CDN_AXI_CFG_DOMAIN_NON_SHAREABLE); // Base Address: 0x0202_0000 and Range: 0x0002_0000.

    // -- AXI Bridge Memory Segment -----------------
    for (int i = 0 ; i < parameters_cfg_pkg::NUM_AXI_PORTS; i++) begin        
      m_axi_lite_mst_psv_cfg.addToMemorySegments((64'h0100_0000 + i * 64'h0002_0000), ((64'h0100_0000 + (i + 1) * 64'h0002_0000) - 64'h0000_0001), CDN_AXI_CFG_DOMAIN_NON_SHAREABLE); //Base Address: 0x0300_0000 and Range: 0x0002_0000 for each AXI Bridge.
    end

    uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_axi_lite_slv_env.psv_agent", m_env_name), "cfg", m_axi_lite_mst_psv_cfg);

    //- AXI Lite Slave active config -----------------------------------------
    if(is_active()) begin
      m_axi_lite_slv_act_cfg = cdnAxiUvmConfig::type_id::create("m_axi_lite_slv_act_cfg");
      m_axi_lite_slv_act_cfg.copy(m_axi_lite_mst_psv_cfg);
      m_axi_lite_slv_act_cfg.is_active = UVM_ACTIVE        ;
      m_axi_lite_slv_act_cfg.PortType  = CDN_AXI_CFG_SLAVE ;

      uvm_config_db#(uvm_object)::set(null, $sformatf("%0s.m_axi_lite_slv_env.act_agent", m_env_name), "cfg", m_axi_lite_slv_act_cfg);
    end
  endfunction : set_axi_lite_slv_cfg

  //---------------------------------------------------------------------------
  // Method: configure_cxs_hal_agent_cfg
  // Common method used to configure the CXS VIP for the HAL Side Interfaces.
  //---------------------------------------------------------------------------
  virtual function void configure_cxs_hal_agent_cfg(bit is_inbound_dir = 0, bit is_pnp_cxs_vip = 0, ref cdn_hls_config passive_cfg, ref cdn_hls_config active_cfg);
    
    //- CXS Passive config ---------------------------------------------------
    passive_cfg.is_active                        = UVM_PASSIVE                                                                                      ;
    passive_cfg.pins.CXS_DATA_TX.size            = get_datapath_width()                                                                             ;
    passive_cfg.pins.CXS_DATA_CHK_TX.size        = `CEILMOD8(get_datapath_width())                                                                  ;
    passive_cfg.pins.CXS_CNTL_TX.size            = get_cntl_width()                                                                                 ;
    passive_cfg.pins.CXS_CNTL_CHK_TX.size        = `CEILMOD8(get_cntl_width())                                                                      ;
    if (is_inbound_dir) begin // Inbound
      passive_cfg.pins.CXS_USER_CNTL_TX.size     = get_ib_user_cntl_width(.is_pnp_cxs_vip(is_pnp_cxs_vip))                                          ;
      passive_cfg.pins.CXS_USER_CNTL_CHK_TX.size = `CEILMOD8(get_ib_user_cntl_width(.is_pnp_cxs_vip(is_pnp_cxs_vip)))                               ;
    end
    else begin // Outbound
      passive_cfg.pins.CXS_USER_CNTL_TX.size     = get_ob_user_cntl_width(.is_pnp_cxs_vip(is_pnp_cxs_vip))                                          ;
      passive_cfg.pins.CXS_USER_CNTL_CHK_TX.size = `CEILMOD8(get_ob_user_cntl_width(.is_pnp_cxs_vip(is_pnp_cxs_vip)))                               ;
    end

    passive_cfg.pins.CXS_DATA_RX.size            = get_datapath_width()                                                                             ;
    passive_cfg.pins.CXS_DATA_CHK_RX.size        = `CEILMOD8(get_datapath_width())                                                                  ;
    passive_cfg.pins.CXS_CNTL_RX.size            = get_cntl_width()                                                                                 ;
    passive_cfg.pins.CXS_CNTL_CHK_RX.size        = `CEILMOD8(get_cntl_width())                                                                      ;
    if (is_inbound_dir) begin // Inbound
      passive_cfg.pins.CXS_USER_CNTL_RX.size     = get_ib_user_cntl_width(.is_pnp_cxs_vip(is_pnp_cxs_vip))                                          ;
      passive_cfg.pins.CXS_USER_CNTL_CHK_RX.size = `CEILMOD8(get_ib_user_cntl_width(.is_pnp_cxs_vip(is_pnp_cxs_vip)))                               ;
    end
    else begin // Outbound
      passive_cfg.pins.CXS_USER_CNTL_RX.size     = get_ob_user_cntl_width(.is_pnp_cxs_vip(is_pnp_cxs_vip))                                          ;
      passive_cfg.pins.CXS_USER_CNTL_CHK_RX.size = `CEILMOD8(get_ob_user_cntl_width(.is_pnp_cxs_vip(is_pnp_cxs_vip)))                               ;
    end

    passive_cfg.ActivationMode                   = CDN_CXS_CFG_ACTIVATION_MODE_AUTOMATIC_MODE                                                       ;
    passive_cfg.MaxPktPerFlit                    = get_num_tlps_per_clk()                                                                           ;
    passive_cfg.max_pkts_per_beat                = get_num_tlps_per_clk()                                                                           ;
    passive_cfg.has_user_control                 = 1                                                                                                ;
    passive_cfg.ContinuousData                   = 1                                                                                                ;
    passive_cfg.SopGranularityVal                = get_tlp_alignment()                                                                              ;
    passive_cfg.DataCheck                        = CDN_CXS_CFG_DATA_CHECK_DATA_CHECK_NONE                                                           ;
`ifdef HLS_BRIDGE_TB_IN_PASSIVE_MODE
    passive_cfg.MaxCrdGntAllowed                 = 15                                                                                               ;
`else
    passive_cfg.MaxCrdGntAllowed                 = 7                                                                                                ; // PCIE-21095 AXI/Core can at max gives 7 credits.
`endif

    //- CXS active config ---------------------------------------------------
    if(is_active()) begin
      active_cfg.copy(passive_cfg)                                                                                                                  ;
      active_cfg.is_active = UVM_ACTIVE                                                                                                             ;
      if (performance_mode) begin
        `uvm_info(get_type_name(), $sformatf("Reduced CXS delays due to performance mode test"), UVM_LOW)
        active_cfg.ReqDlyAssert = 0;
        active_cfg.ReqDlyDeassert = 0;
        active_cfg.MinCrdToValidDelay = 1;
        active_cfg.MaxCrdToValidDelay = 1;
        active_cfg.GntAllocation = CDN_CXS_CFG_GNT_ALLOCATION_NO_DISTRIBUTION;
        active_cfg.AckDlyAssert = 0;
        active_cfg.AckDlyDeassert = 0;
        active_cfg.MinCrdGnt = 0;
        active_cfg.MaxCrdGnt = 0;
      end
      else begin
        if (is_inbound_dir) begin
          active_cfg.ReqDlyAssert       = $urandom_range(5, 0)                                                                                        ;
          active_cfg.ReqDlyDeassert     = $urandom_range(5, 0)                                                                                        ;
          active_cfg.MinCrdToValidDelay = 1                                                                                                           ;
          active_cfg.MaxCrdToValidDelay = $urandom_range(3, 1)                                                                                        ; // As per PCIE-21215 max delay can be 3 cycles.
        end
        else begin // Outbound Direction
          active_cfg.GntAllocation      = $urandom_range(1, 0) ? CDN_CXS_CFG_GNT_ALLOCATION_NO_DISTRIBUTION : CDN_CXS_CFG_GNT_ALLOCATION_DISTRIBUTION ;
          active_cfg.AckDlyAssert       = $urandom_range(5, 0)                                                                                        ;
          active_cfg.AckDlyDeassert     = $urandom_range(5, 0)                                                                                        ;
          active_cfg.MinCrdGnt          = 0                                                                                                           ;
          active_cfg.MaxCrdGnt          = $urandom_range(5, 0)                                                                                        ;
        end
      end
    end

  endfunction : configure_cxs_hal_agent_cfg

  //---------------------------------------------------------------------------
  // Method: configure_cxs_axi_agent_cfg
  // Common method used to configure the CXS VIP for the AXI Side Interfaces.
  //---------------------------------------------------------------------------
  virtual function void configure_cxs_axi_agent_cfg(bit is_inbound_dir = 0, bit is_pnp_cxs_vip = 0, ref cdn_hls_config passive_cfg[parameters_cfg_pkg::NUM_HLS_PORTS], ref cdn_hls_config active_cfg[parameters_cfg_pkg::NUM_HLS_PORTS]);

    //- CXS Passive config ---------------------------------------------------
    foreach(passive_cfg[loop_port]) begin
      passive_cfg[loop_port].is_active                        = UVM_PASSIVE                                                                                           ;
      passive_cfg[loop_port].pins.CXS_DATA_TX.size            = get_datapath_width_per_port(.hls_port_num(loop_port))                                                 ;
      passive_cfg[loop_port].pins.CXS_DATA_CHK_TX.size        = `CEILMOD8(get_datapath_width_per_port(.hls_port_num(loop_port)))                                      ;
      passive_cfg[loop_port].pins.CXS_CNTL_TX.size            = get_cntl_width_per_port(.hls_port_num(loop_port))                                                     ;
      passive_cfg[loop_port].pins.CXS_CNTL_CHK_TX.size        = `CEILMOD8(get_cntl_width_per_port(.hls_port_num(loop_port)))                                          ;
      if (is_inbound_dir) begin // Inbound
        passive_cfg[loop_port].pins.CXS_USER_CNTL_TX.size     = get_ib_user_cntl_width_per_port(.hls_port_num(loop_port), .is_pnp_cxs_vip(is_pnp_cxs_vip))            ;
        passive_cfg[loop_port].pins.CXS_USER_CNTL_CHK_TX.size = `CEILMOD8(get_ib_user_cntl_width_per_port(.hls_port_num(loop_port), .is_pnp_cxs_vip(is_pnp_cxs_vip))) ;
      end
      else begin // Outbound
        passive_cfg[loop_port].pins.CXS_USER_CNTL_TX.size     = get_ob_user_cntl_width_per_port(.hls_port_num(loop_port), .is_pnp_cxs_vip(is_pnp_cxs_vip))            ;
        passive_cfg[loop_port].pins.CXS_USER_CNTL_CHK_TX.size = `CEILMOD8(get_ob_user_cntl_width_per_port(.hls_port_num(loop_port), .is_pnp_cxs_vip(is_pnp_cxs_vip))) ;
      end

      passive_cfg[loop_port].pins.CXS_DATA_RX.size            = get_datapath_width_per_port(.hls_port_num(loop_port))                                                 ;
      passive_cfg[loop_port].pins.CXS_DATA_CHK_RX.size        = `CEILMOD8(get_datapath_width_per_port(.hls_port_num(loop_port)))                                      ;
      passive_cfg[loop_port].pins.CXS_CNTL_RX.size            = get_cntl_width_per_port(.hls_port_num(loop_port))                                                     ;
      passive_cfg[loop_port].pins.CXS_CNTL_CHK_RX.size        = `CEILMOD8(get_cntl_width_per_port(.hls_port_num(loop_port)))                                          ;
      if (is_inbound_dir) begin // Inbound
        passive_cfg[loop_port].pins.CXS_USER_CNTL_RX.size     = get_ib_user_cntl_width_per_port(.hls_port_num(loop_port), .is_pnp_cxs_vip(is_pnp_cxs_vip))            ;
        passive_cfg[loop_port].pins.CXS_USER_CNTL_CHK_RX.size = `CEILMOD8(get_ib_user_cntl_width_per_port(.hls_port_num(loop_port), .is_pnp_cxs_vip(is_pnp_cxs_vip))) ;
      end
      else begin // Outbound
        passive_cfg[loop_port].pins.CXS_USER_CNTL_RX.size     = get_ob_user_cntl_width_per_port(.hls_port_num(loop_port), .is_pnp_cxs_vip(is_pnp_cxs_vip))            ;
        passive_cfg[loop_port].pins.CXS_USER_CNTL_CHK_RX.size = `CEILMOD8(get_ob_user_cntl_width_per_port(.hls_port_num(loop_port), .is_pnp_cxs_vip(is_pnp_cxs_vip))) ;
      end

      passive_cfg[loop_port].ActivationMode                   = CDN_CXS_CFG_ACTIVATION_MODE_AUTOMATIC_MODE                                                            ;
      passive_cfg[loop_port].MaxPktPerFlit                    = get_num_tlps_per_clk_per_port(.hls_port_num(loop_port))                                               ;
      passive_cfg[loop_port].max_pkts_per_beat                = get_num_tlps_per_clk_per_port(.hls_port_num(loop_port))                                               ;
      passive_cfg[loop_port].has_user_control                 = 1                                                                                                     ;
      passive_cfg[loop_port].ContinuousData                   = 1                                                                                                     ;
      passive_cfg[loop_port].SopGranularityVal                = get_tlp_alignment_per_port(.hls_port_num(loop_port))                                                  ;
      passive_cfg[loop_port].DataCheck                        = CDN_CXS_CFG_DATA_CHECK_DATA_CHECK_NONE                                                                ;
`ifdef HLS_BRIDGE_TB_IN_PASSIVE_MODE
      passive_cfg[loop_port].MaxCrdGntAllowed                 = 15                                                                                                    ; 
`else
      passive_cfg[loop_port].MaxCrdGntAllowed                 = 7                                                                                                     ; // PCIE-21095 AXI/Core can at max gives 7 credits.
`endif
    end 

    //- CXS active config ---------------------------------------------------
    if(is_active()) begin 
      foreach(active_cfg[loop_port]) begin
        active_cfg[loop_port].copy(passive_cfg[loop_port])                                                                                                            ;
        active_cfg[loop_port].is_active            = UVM_ACTIVE                                                                                                       ;
        if (is_inbound_dir) begin // Inbound
          active_cfg[loop_port].GntAllocation      = $urandom_range(1, 0) ? CDN_CXS_CFG_GNT_ALLOCATION_NO_DISTRIBUTION : CDN_CXS_CFG_GNT_ALLOCATION_DISTRIBUTION      ;
          active_cfg[loop_port].AckDlyAssert       = $urandom_range(5, 0)                                                                                             ;
          active_cfg[loop_port].AckDlyDeassert     = $urandom_range(5, 0)                                                                                             ;
          active_cfg[loop_port].MinCrdGnt          = 0                                                                                                                ;
          active_cfg[loop_port].MaxCrdGnt          = $urandom_range(5, 0)                                                                                             ;
        end
        else begin // Outbound
          active_cfg[loop_port].ReqDlyAssert       = $urandom_range(5, 0)                                                                                             ;
          active_cfg[loop_port].ReqDlyDeassert     = $urandom_range(5, 0)                                                                                             ;
          active_cfg[loop_port].MinCrdToValidDelay = 1                                                                                                                ;
          active_cfg[loop_port].MaxCrdToValidDelay = $urandom_range(3, 1)                                                                                             ; // As per PCIE-21215 max delay can be 3 cycles.
        end
      end
    end

  endfunction : configure_cxs_axi_agent_cfg
  
  //---------------------------------------------------------------------------
  // Method: configure_stream_agent_cfg
  // Common method used to configure the Stream VIP Agents.
  //---------------------------------------------------------------------------
  function void configure_stream_agent_cfg(bit is_agent_active = 'b0 ,bit is_master = 1, bit support_tready = 1, ref cdnStreamUvmConfig passive_cfg, ref cdnStreamUvmConfig active_cfg );
    
    //- Stream passive config --------------------------------------------
    passive_cfg.spec_ver                      = CDN_STREAM_CFG_SPEC_VER_AMBA5STREAM                                                                                      ;
    passive_cfg.PortType                      = is_master == 1 ? CDN_STREAM_CFG_SLAVE : CDN_STREAM_CFG_MASTER                                                            ;
    passive_cfg.is_active                     = UVM_PASSIVE                                                                                                              ;
    passive_cfg.reset_signals_sim_start       = 1                                                                                                                        ;
    passive_cfg.enable_tracker                = 0                                                                                                                        ;
`ifdef VIPSR_46884732_WORKAROUND
    passive_cfg.check_Parity_Byte             = CDN_STREAM_CFG_CHECK_TYPE_FALSE;
`else
    passive_cfg.check_Parity_Byte             = (parameters_cfg_pkg::ASF_SUPPORT >= 2) ? CDN_STREAM_CFG_CHECK_TYPE_ODD_PARITY_BYTE_ALL : CDN_STREAM_CFG_CHECK_TYPE_FALSE ;
`endif
    passive_cfg.data_interleaving_depth       = 1                                                                                                                        ;
    passive_cfg.master_support_tready         = support_tready                                                                                                           ;
    passive_cfg.always_accept                 = !support_tready                                                                                                          ;
    
    //- Stream active config ---------------------------------------------
    if(is_agent_active) begin
      active_cfg.copy(passive_cfg);
      active_cfg.PortType  = is_master == 1 ? CDN_STREAM_CFG_MASTER : CDN_STREAM_CFG_SLAVE ;
      active_cfg.is_active = UVM_ACTIVE                                                    ;     
     end
  endfunction : configure_stream_agent_cfg

  //---------------------------------------------------------------------------
  // Method: configure_cxs_hal_cov_collector_cfg
  // Configures CXS coverage collector configs for HAL Side.
  //---------------------------------------------------------------------------
  function void configure_cxs_hal_cov_collector_cfg(bit is_rx = 0, bit [1:0] fc_type, ref cdn_cxs_cov_collector_cfg cov_cfg);
    cov_cfg.m_is_rx             = is_rx                  ;
    cov_cfg.m_link_ctrl_cov_en  = 1                      ;
    cov_cfg.m_data_width        = get_datapath_width()   ;
    cov_cfg.m_max_data_width    = get_datapath_width()   ;
    cov_cfg.m_max_pkts_per_clk  = 4;
    cov_cfg.m_pkt_alignment     = i_cfg.k_hls_dw_alignment * 4;
    if (fc_type == 2'b00) begin // Posted
      // Posted min MWr32(4DW), MWr64(5DW), Msg(4DW), MsgD(5DW)
      cov_cfg.m_min_pkt_size_dw = 4                      ;
    end 
    else if(fc_type == 2'b01) begin // Non-Posted
      // Non-Posted min MRd32(3DW), MRd64(4DW), IORd(3DW), DMWr(4DW)
      cov_cfg.m_min_pkt_size_dw = 3                      ;
    end
    else begin // Completion
      // Compl min CPL(3DW), CPLD(4DW)
      cov_cfg.m_min_pkt_size_dw = 3                      ;
    end
    cov_cfg.m_alignment_gaps    = 1                      ;
    cov_cfg.m_supports_errs     = 1                      ;
  endfunction : configure_cxs_hal_cov_collector_cfg

  //---------------------------------------------------------------------------
  // Method: configure_cxs_axi_cov_collector_cfg
  // Configures CXS coverage collector configs for AXI Side.
  //---------------------------------------------------------------------------
  function void configure_cxs_axi_cov_collector_cfg(bit is_rx = 0, bit [1:0] fc_type, ref cdn_cxs_cov_collector_cfg cov_cfg[parameters_cfg_pkg::NUM_HLS_PORTS]);
    foreach(cov_cfg[loop_port]) begin
      cov_cfg[loop_port].m_is_rx             = is_rx                                                   ;
      cov_cfg[loop_port].m_link_ctrl_cov_en  = 1                                                       ;
      cov_cfg[loop_port].m_data_width        = get_datapath_width_per_port(.hls_port_num(loop_port))   ;
      cov_cfg[loop_port].m_max_data_width    = get_datapath_width_per_port(.hls_port_num(loop_port))   ;
      cov_cfg[loop_port].m_max_pkts_per_clk  = 4;
      cov_cfg[loop_port].m_pkt_alignment     = i_cfg.k_hls_dw_alignment * 4;
      if (fc_type == 2'b00) begin // Posted
        // Posted min MWr32(4DW), MWr64(5DW), Msg(4DW), MsgD(5DW)
        cov_cfg[loop_port].m_min_pkt_size_dw = 4                                                       ;
      end 
      else if(fc_type == 2'b01) begin // Non-Posted
        // Non-Posted min MRd32(3DW), MRd64(4DW), IORd(3DW), DMWr(4DW)
        cov_cfg[loop_port].m_min_pkt_size_dw = 3                                                       ;
      end
      else begin // Completion
        // Compl min CPL(3DW), CPLD(4DW)
        cov_cfg[loop_port].m_min_pkt_size_dw = 3                                                       ;
      end
      cov_cfg[loop_port].m_alignment_gaps    = 1                                                       ;
      cov_cfg[loop_port].m_supports_errs     = 1                                                       ;
    end
  endfunction : configure_cxs_axi_cov_collector_cfg

endclass : cdn_pcie_hls_bridge_env_config

`endif // CDN_PCIE_HLS_BRIDGE_ENV_CONFIG_SV
