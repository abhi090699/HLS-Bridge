`ifndef CDN_PCIE_HLS_BRIDGE_BASE_TEST_SV
`define CDN_PCIE_HLS_BRIDGE_BASE_TEST_SV

class cdn_pcie_hls_bridge_hpa_ide_config extends cdn_pcie_hpa_ide_config;

  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_hpa_ide_config)

  function new(string name="cdn_pcie_hls_bridge_hpa_ide_config");
    super.new(name);
  endfunction : new

  constraint ide_internal_variables_c {
    stream_id.size() ==  (m_num_link_streams_supp + m_num_sel_streams_supp);
    ide_keys.size()  == ((m_num_link_streams_supp + m_num_sel_streams_supp)*3*2*2); //2 set of keys for EP&RP for 3-Sub_streams of each stream
    unique{stream_id};
    //soumitm :: TODO :: disabled for CDNS_IDE until multi key supported :: unique{ide_keys};

    if(!is_cxl_ide) {
      (m_num_link_streams_supp == 0) -> (m_num_link_str_enabled == 0);
      (m_num_sel_streams_supp  == 0) -> (m_num_sel_str_enabled  == 0);
      if(m_num_link_streams_supp > 0) m_num_link_str_enabled dist {[0:(m_num_link_streams_supp-1)]:=30,m_num_link_streams_supp:=70};
      if(m_num_sel_streams_supp  > 0) m_num_sel_str_enabled  dist {[0:(m_num_sel_streams_supp-1)] :=30,m_num_sel_streams_supp :=70};
      if(parameters_cfg_pkg::KMAX_DTI_SUPPORT && m_num_link_streams_supp > 0) m_num_link_str_enabled > 0;
      if((scenario != null) && scenario.is_tdisp_mode() && !scenario.disable_tdisp && (m_num_sel_streams_supp > 0)) m_num_sel_str_enabled > 0;
      if((scenario == null) && (parameters_cfg_pkg::KMAX_TDISP_SUPPORT == 2) /*-*/ && (m_num_sel_streams_supp > 0)) m_num_sel_str_enabled > 0;
      tcs_for_link_streams.sum() with (int'(item)) == m_num_link_str_enabled;
      foreach(m_tc_en[tc]) { (m_tc_en[tc] == 0) -> (tcs_for_link_streams[tc] == 0); }
    }

    if(is_cxl_ide) {
      m_num_link_str_enabled == m_num_link_streams_supp;
      m_num_sel_str_enabled  == m_num_sel_streams_supp;
      tcs_for_link_streams.sum() with (int'(item)) == m_num_link_str_enabled;
    }
  }

endclass : cdn_pcie_hls_bridge_hpa_ide_config

class cdn_pcie_hls_bridge_dev_config_random_policy extends cdn_pcie_dev_config_random_policy;

  //---------------------------------------------------------------------------
  // UVM FACTORY REGISTRATION AND AUTOMATION MACROS
  //---------------------------------------------------------------------------
  `uvm_object_utils(cdn_pcie_hls_bridge_dev_config_random_policy)

  function new(string name="cdn_pcie_hls_bridge_dev_config_random_policy");
    super.new(name);
    c_ext_tag_10_14_bit_requester_tag.constraint_mode(0);
  endfunction : new

  constraint hlsb_bypass_prefix_cfgs_c {
    item.bypass_prefix_cfgs == (item.i_cfg.k_ide_supported ? 0: 1);
    // item.bypass_prefix_cfgs == 1;
    item.m_ext_fmt_field_support == 1;

    // item.m_pasid_enb dist {0:=10, 1:=90};
    // item.m_tph_cpl_support dist {CDN_HPA_PCIE_TPH_AND_EXTTPH_CPL_NOT_SUPPORTED:=10, CDN_HPA_PCIE_TPH_CPL_SUPPORTED :=30 ,CDN_HPA_PCIE_TPH_AND_EXT_TPH_CPL_SUPPORTED:=60};
    // item.m_tph_req_en dist {CDN_HPA_PCIE_TPH_AND_EXTTPH_REQ_NOT_SUPPORTED:=10, CDN_HPA_PCIE_TPH_REQ_SUPPORTED :=30 ,CDN_HPA_PCIE_TPH_AND_EXT_TPH_REQ_SUPPORTED:=60};
  }

  constraint hlsb_acs_disable_c {
    item.acs_source_validation_supp == 0;
    item.acs_translation_blocking_supp == 0;
    item.acs_p2p_req_redirect_supp == 0;
    item.acs_p2p_cpl_redirect_supp == 0;
    item.acs_upstream_forwarding_supp == 0;
    item.acs_p2p_egress_control_supp == 0;
    item.acs_direct_translated_p2p_supp == 0;
    item.acs_enhanced_capability_supp == 0;
  }

  constraint hlsb_dti_ats_en_c {
    if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) {
      item.m_cap_ats_page_req_en == 1;
      item.m_cap_ats_en == 1;
      item.m_cap_ats_supp == 1;
    }
  }

  constraint hlsb_bypass_bar_randomization_c {
    item.bypass_bar_randomization == 1;
  }

  constraint hlsb_uio_req_comp_enable_c {
    (parameters_cfg_pkg::NUM_UIO_VCS > 0) -> (item.m_uio_Mem_RdWr_compl_supp == 1);
    (parameters_cfg_pkg::NUM_UIO_VCS > 0) -> (item.m_uio_Mem_RdWr_req_supp == 1);
  }

  constraint hlsb_uio_dev_ctrl3_c {
    (parameters_cfg_pkg::NUM_UIO_VCS > 0) -> (item.m_uio_Mem_RdWr_req_en == 1);
  }

endclass : cdn_pcie_hls_bridge_dev_config_random_policy

//------------------------------------------------------------------------------
// Class: cdn_pcie_hls_bridge_base_test
// This test sets the base for all the extended tests.
// Common configuration, functions and behavior should be part of this test.
//------------------------------------------------------------------------------
class cdn_pcie_hls_bridge_base_test extends uvm_test;

  //----------------------------------------------------------------------------
  // Config objects
  //----------------------------------------------------------------------------
  // HLS Bridge Environment Scenario.
  cdn_pcie_hls_bridge_scenario               m_scenario;
  
  // HLS Bridge Environment Config.
  cdn_pcie_hls_bridge_env_config             m_env_cfg;

  // HLS Bridge Config for register configuration.
  cdn_pcie_hls_bridge_config                 m_hls_bridge_config;
  
  // Strap Config
  cdn_pcie_strap_top_config                  i_cfg;
  cdn_pcie_strap_random_policy               m_strap_random_pcy;
  
  // Link Config
  cdn_hpa_pcie_link_config                   m_link_config;

  // Dev Top Config for DUT Side
  cdn_pcie_hpa_dev_top_config                m_dev_top_config;
  cdn_pcie_dev_top_config_random_policy      m_dev_top_rand_pcy;

  // Dev Top Config for Remote Side
  cdn_pcie_hpa_dev_top_config                m_remote_dev_top_config;
  cdn_pcie_dev_top_config_random_policy      m_remote_dev_top_rand_pcy;

  // Bar config for DUT and Remote Side
  bars_per_device                            m_bars_per_device;
  cdn_hpa_pcie_ep_bar_cfg                    m_pcie_bar_cfg;
  bars_per_device                            m_remote_bars_per_device;
  cdn_hpa_pcie_ep_bar_cfg                    m_remote_pcie_bar_cfg;

  //----------------------------------------------------------------------------
  // Components
  //----------------------------------------------------------------------------
  // HLS Bridge Environment
  cdn_pcie_hls_bridge_env sve;

  //---------------------------------------------------------------------------
  // Sequences
  //---------------------------------------------------------------------------
  cdn_pcie_hls_bridge_vseq m_vseq;

  //---------------------------------------------------------------------------
  // MEMBER VARIABLES
  //---------------------------------------------------------------------------
  int unsigned m_drain_time = 500;

  //----------------------------------------------------------------------------
  // UVM automation macros
  //----------------------------------------------------------------------------
  `uvm_component_utils(cdn_pcie_hls_bridge_base_test)

  //----------------------------------------------------------------------------
  // Function: new
  // Class constructor.
  //----------------------------------------------------------------------------
  function new(string name = "cdn_pcie_hls_bridge_base_test", uvm_component parent);
    super.new(name, parent);
    
    // CXS Driver for extended functionality to be used in linkdown.
    set_type_override_by_type(cdnCxsUvmDriver::get_type(), cdn_pcie_hls_bridge_cxs_driver::get_type());
    
    // Overriding this seq in order to add the bridge specific metadata and other updates if needed.
    set_type_override_by_type(cdn_pcie_hpa_tlp2cxs_seq::get_type(), cdn_pcie_hls_bridge_tlp2cxs_seq::get_type());

    set_type_override_by_type(cdn_pcie_hpa_ide_config::get_type(),  cdn_pcie_hls_bridge_hpa_ide_config::get_type());

    set_type_override_by_type(cdn_pcie_dev_config_random_policy::get_type(),  cdn_pcie_hls_bridge_dev_config_random_policy::get_type());
    
  endfunction : new

  //----------------------------------------------------------------------------
  // Function: build_phase
  // Builds the all the components
  //----------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    string l_msg_id = {"[", get_type_name(), "]", "[build_phase]"};
    
    super.build_phase(phase);

    //----Create Environment--------------------------------------------
    sve = cdn_pcie_hls_bridge_env::type_id::create("sve", this);

    //---HLS Bridge Virtual Sequencer-----------------------------------
    sve.m_vseqr = cdn_pcie_hls_bridge_vsequencer::type_id::create("m_vseqr", this);
   
    //- Create TLP seqr's--------------- -------------------------------
    sve.m_vseqr.hls_ob_tlp_sqr = cdn_hpa_pcie_tlp_vseqr::type_id::create("hls_ob_tlp_sqr", this);
    sve.m_vseqr.hls_ib_tlp_sqr = cdn_hpa_pcie_tlp_vseqr::type_id::create("hls_ib_tlp_sqr", this);

    //----Create Environment Config-------------------------------------
    m_env_cfg = cdn_pcie_hls_bridge_env_config::type_id::create("m_env_cfg", this);
    m_env_cfg.m_is_active = UVM_ACTIVE;
    m_env_cfg.m_env_name  = sve.get_full_name(); 
`ifdef FUNC_COV
    m_env_cfg.coverage_enable = 1;
`else
    m_env_cfg.coverage_enable = 0;
`endif
    uvm_config_db#(cdn_pcie_hls_bridge_env_config)::set(this, "*", "env_cfg", m_env_cfg);
    
    //--- Create Scenario ----------------------------------------------
    create_scenario(l_msg_id);
    
    //---Create strap config--------------------------------------------
    create_strap_config(l_msg_id);
    
    //--- Create Link Config -------------------------------------------
    create_link_config(l_msg_id);

    //--- Create Dev Top Config for DUT Side ---------------------------
    create_dut_dev_top_config(l_msg_id);
    
    //--- Create Dev Top Config for Remote Side ------------------------
    create_remote_dev_top_config(l_msg_id);

    //--- Fix null handles when kmax_num_pfs=1 ------------------------
    begin
      if (m_link_config.usp_dev_config == null) begin
        m_link_config.usp_dev_config = m_link_config.usp_dev_top_config.pf_config[0];
      end
      if (m_link_config.dsp_dev_config == null) begin
        m_link_config.dsp_dev_config = m_link_config.dsp_dev_top_config.pf_config[0];
      end
    end

    //--- Create bar configuration -------------------------------------
    create_bars_config(l_msg_id);
    
    //--- Fix null m_fun_bar_info after bars are populated ------------
    if (m_link_config.usp_dev_config != null && m_link_config.usp_dev_config.m_fun_bar_info == null) begin
      m_link_config.usp_dev_config.m_fun_bar_info = m_link_config.usp_dev_top_config.pf_config[0].m_fun_bar_info;
    end
    if (m_link_config.dsp_dev_config != null && m_link_config.dsp_dev_config.m_fun_bar_info == null) begin
      m_link_config.dsp_dev_config.m_fun_bar_info =  m_link_config.dsp_dev_top_config.pf_config[0].m_fun_bar_info;
    end

    //--- Create hls bridge configuration ------------------------------
    create_hls_bridge_config(l_msg_id);

  endfunction : build_phase

  //----------------------------------------------------------------------------
  // Function: connect_phase
  //----------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase
  
  //----------------------------------------------------------------------------
  // Function: end_of_elaboration_phase
  //----------------------------------------------------------------------------
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    string l_msg_id = {"[", get_type_name(), "]", "[end_of_elaboration_phase]"};
    super.end_of_elaboration_phase(phase);

    if(m_scenario.en_axi_slv_error_injection) begin
      sve.m_axil_slv_cb_mon.inject_error = m_scenario.en_axi_slv_error_injection; 
      void'(sve.do_demote_axi_error("CDN_AXI_FATAL_ERR_VR_AXI235_WRITE_BURST_MAPPED_ADDRESS_AND_DECERR"));
      void'(sve.do_demote_axi_error("CDN_AXI_FATAL_ERR_VR_AXI231_READ_TRANSFER_MAPPED_ADDRESS_AND_DECERR")); 
    end

    `uvm_info(get_type_name(), $sformatf("Generated scenario is:\n%0s"            , m_scenario.sprint())             , UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("Generated m_link_config:\n%0s"          , m_link_config.sprint())          , UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Generated m_dev_top_config:\n%0s"       , m_dev_top_config.sprint())       , UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Generated m_remote_dev_top_config:\n%0s", m_remote_dev_top_config.sprint()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Generated m_hls_bridge_config:\n%0s"    , m_hls_bridge_config.sprint())    , UVM_LOW)

    //--- Strap Configuration -------------------------------------------------
    do_kwire_config(.msg_id(l_msg_id));

  endfunction : end_of_elaboration_phase
 
  //----------------------------------------------------------------------------
  // Function: pre_reset_phase
  //----------------------------------------------------------------------------
  virtual task pre_reset_phase(uvm_phase phase);
    string l_msg_id = {"[", get_type_name(), "]", "[pre_reset_phase]"};
    super.reset_phase(phase);
    
    phase.raise_objection(this);
    
    //--- Drive Clocks -------------------------------------------------------
    drive_clocks(.msg_id(l_msg_id));

    phase.drop_objection(this);

  endtask : pre_reset_phase

  //----------------------------------------------------------------------------
  // Function: reset_phase
  //----------------------------------------------------------------------------
  virtual task reset_phase(uvm_phase phase);
    string l_msg_id = {"[", get_type_name(), "]", "[reset_phase]"};
    super.reset_phase(phase);
    
    phase.raise_objection(this);
  
    //--- Initial Reset -------------------------------------------------------
    do_reset(l_msg_id);
    
    phase.drop_objection(this);

  endtask : reset_phase
  
  //----------------------------------------------------------------------------
  // Method: main_phase
  //----------------------------------------------------------------------------
  virtual task main_phase(uvm_phase phase);
    super.main_phase(phase);
    
    phase.phase_done.set_drain_time(this, m_drain_time);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), $psprintf("Starting %0s main_phase", get_type_name()), UVM_NONE);
    
    run_simulation();
    
    `uvm_info(get_type_name(), $psprintf("Ending %0s main_phase", get_type_name()), UVM_NONE);
    phase.drop_objection(this);
  endtask : main_phase

  //----------------------------------------------------------------------------
  // Function: report_phase
  //----------------------------------------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    uvm_report_server reporter;

    super.report_phase(phase);

    reporter = uvm_report_server::get_server();
    if (reporter.get_severity_count(UVM_ERROR) > 0) begin
      `uvm_info(get_type_name(), {"Test result:\n",
				  "-----------------------------------------------------------------------\n",
				  "----------------------        TEST FAILED        ----------------------\n",
				  "-----------------------------------------------------------------------"
				  }, UVM_NONE)
    end
    else begin
      `uvm_info(get_type_name(), {"Test result:\n",
				  "-----------------------------------------------------------------------\n",
				  "----------------------        TEST PASSED        ----------------------\n",
				  "-----------------------------------------------------------------------"
				  }, UVM_NONE)
    end
  endfunction : report_phase

  //---------------------------------------------------------------------------
  // Method: create_scenario
  // This method creates the scenario, randomizes it and pass the handle. 
  //---------------------------------------------------------------------------
  virtual function void create_scenario(string msg_id = "");
    string l_msg_id = {msg_id, "[create_scenario]"};
    `uvm_info(l_msg_id, "create_scenario function starting...", UVM_HIGH);
    
    m_scenario = cdn_pcie_hls_bridge_scenario::type_id::create("m_scenario", this);
    if(!m_scenario.randomize()) begin
      `uvm_fatal(l_msg_id, "cdn_pcie_hls_bridge_scenario Randomization failed.");
    end

    m_scenario.use_user_defined_strap   = 1                               ;
    m_scenario.user_defined_strap_is_rc = m_scenario.m_strap_port_type[0] ;
    m_scenario.enable_local_prefix_in_fm = 1;
    sve.m_vseqr.p_scenario              = m_scenario                      ; 
    
    m_scenario.generate_tag_management();

    m_env_cfg.performance_mode = m_scenario.m_is_perf_mode;

    uvm_config_db#(cdn_pcie_scenario_pkg::cdn_pcie_scenario)::set(this, "*", "scenario", m_scenario);

    `uvm_info(l_msg_id, "create_scenario function finished...", UVM_HIGH);
  endfunction : create_scenario

  //---------------------------------------------------------------------------
  // Method: create_strap_config
  // This is creates the strap config, randomizes it and pass handle to the
  // Environment Config.
  //---------------------------------------------------------------------------
  virtual function void create_strap_config(string msg_id = "");
    string l_msg_id = {msg_id, "[create_strap_config]"};
    `uvm_info(l_msg_id, "create_strap_config function starting...", UVM_HIGH);
    
    i_cfg              = cdn_pcie_strap_top_config::type_id::create("i_cfg", this);
    m_strap_random_pcy = cdn_pcie_strap_random_policy::type_id::create($psprintf("%0s.m_strap_random_pcy",get_full_name()), this);
   
    m_strap_random_pcy.dep_strap_port_type_switch_port_c.constraint_mode(0);
    m_strap_random_pcy.valid_k_hls_dw_alignment_c.constraint_mode(0); // To try k_hls_dw_alignment = 2 configuration.
    // Disabling these constraints since they cause randomization issues and are not required at module level.
    m_strap_random_pcy.k_posted_buffer_num_tlp_support_encoded_c.constraint_mode(0);
    m_strap_random_pcy.k_nonposted_buffer_num_tlp_support_encoded_c.constraint_mode(0);
    m_strap_random_pcy.k_compl_buffer_num_tlp_support_encoded_c.constraint_mode(0);
    m_strap_random_pcy.dep_k_axi_s_compl_lut_depth_min1_c.constraint_mode(0);

    //---Pushing strap random policy------------------------------------------
    i_cfg.push_policy(m_strap_random_pcy);

    i_cfg.scenario         = m_scenario;
    i_cfg.enable_ats_in_fm = 1         ;

    if(!i_cfg.randomize() with {
      strap_is_rp           == m_scenario.m_strap_port_type[0]             ;
      strap_port_type       == m_scenario.m_strap_port_type                ;
      k_flit_mode_support   == m_scenario.m_k_flit_mode_support            ;
      k_datapath_wd         == (parameters_cfg_pkg::KMAX_DATAPATH_WD / 32) ;
      k_hls_dw_alignment    == m_scenario.m_k_hls_dw_alignment             ;
      k_rx_num_tlps_per_clk == parameters_cfg_pkg::KMAX_NUM_TLPS_PER_CLK   ;
      k_tx_num_tlps_per_clk == parameters_cfg_pkg::KMAX_NUM_TLPS_PER_CLK   ;
      strap_pcie_rate_max   >= ((m_scenario.m_k_flit_mode_support) ? 5 : 0);
      k_tph_supported       dist {0:=10,1:=90};
      k_ext_tph_supported   dist {0:=10,1:=90};
      k_pasid_supported     dist {0:=10,1:=90};
      if (!m_scenario.m_backpressure_scenario) {
        k_max_read_request_size == 5;
        k_max_payload_size      == 5;
      }
      if (parameters_cfg_pkg::KMAX_DTI_SUPPORT) {
        strap_pcie_rate_max > 0;
        k_pcie_rate_max > 0;
      }
      k_multi_tc_supp == 1;
      k_np_records_table_size >= 32;
    }) begin
      `uvm_fatal(l_msg_id, "cdn_pcie_strap_top_config Randomization failed.");
    end
    
    i_cfg.print();

    //---Pass the strap config handle-------------------------------
    m_env_cfg.i_cfg   = i_cfg;
    sve.m_vseqr.i_cfg = i_cfg;

    //---Pass the configuration down in the environment hierarchy------------
    uvm_config_db #(cdn_pcie_strap_top_config)::set(this, "sve*", "i_cfg", i_cfg);

    `uvm_info(l_msg_id, "create_strap_config function finished...", UVM_HIGH);

  endfunction : create_strap_config
  
  //---------------------------------------------------------------------------
  // Function: create_link_config
  // This function creates link_config, randomizes it and pass the handle to
  // the TLP Seqr.
  //---------------------------------------------------------------------------
  function void create_link_config(string msg_id = "");
    string l_msg_id = {msg_id, "[create_link_config]"};
    
    `uvm_info(l_msg_id, "create_link_config function starting...", UVM_HIGH);
    
    m_link_config = cdn_hpa_pcie_link_config::type_id::create("m_link_config", this);
    
    if (!m_link_config.randomize()) begin
      `uvm_fatal(l_msg_id, "cdn_hpa_pcie_link_config Randomization failed.");
    end

    m_link_config.m_dut_mode = m_scenario.m_strap_port_type[0] ? cdn_dut_mode_e'(CDN_HPA_PCIE_RP) : cdn_dut_mode_e'(CDN_HPA_PCIE_EP);
    
    //---Pass the link config handle-------------------------------
    m_env_cfg.m_link_config = m_link_config;
    sve.m_vseqr.hls_ob_tlp_sqr.m_pcie_link_cfg = m_link_config;
    sve.m_vseqr.hls_ib_tlp_sqr.m_pcie_link_cfg = m_link_config;

    //---Pass the configuration down in the environment hierarchy------------
    uvm_config_db #(cdn_hpa_pcie_link_config)::set(this, "sve*", "link_cfg", m_link_config);
    
    `uvm_info(l_msg_id, "create_link_config function finished...", UVM_HIGH);

  endfunction : create_link_config

  //---------------------------------------------------------------------------
  // Method: create_dut_dev_top_config
  // This is creates the devtop config for dut side, randomizes it and pass handle to the
  // Environment Config.
  //---------------------------------------------------------------------------
  virtual function void create_dut_dev_top_config(string msg_id = "");
    string l_msg_id = {msg_id, "[create_dut_dev_top_config]"} ;
    int    match_idx[$]                                       ;

    `uvm_info(l_msg_id, "create_dut_dev_top_config function starting...", UVM_HIGH);
    
    //Dev top config creation
    m_dev_top_config = cdn_pcie_hpa_dev_top_config::type_id::create("m_dev_top_config", this);
    m_dev_top_config.i_cfg                   = i_cfg;
    m_dev_top_config.is_dut_config           = 1;
    m_dev_top_config.scenario                = m_scenario;
    m_dev_top_config.flit_mode_negotiated    = (m_scenario.m_misc_flit_mode == 2'b10);
    m_dev_top_config.captured_segment_number = 1;
    m_dev_top_config.ecrc_init_done          = $urandom_range(1,0); // For HLS Bridge Module ecrc init doesn't matter.
    m_dev_top_config.l_num_enabled_pfs       = i_cfg.strap_is_rp ? 1 : i_cfg.k_num_pfs;
    m_dev_top_config.ide_init_done           = i_cfg.k_ide_supported ? 1 : 0;
    m_dev_top_config.pr_req_outstanding      = 0;
    m_dev_top_config.enable_segmentation     = $urandom_range(1,0);
    m_dev_top_config.m_build_sel_stream      = 1;
  
    //Dev top config policy creation and pushing
    m_dev_top_rand_pcy = cdn_pcie_dev_top_config_random_policy::type_id::create($psprintf("%0s.m_dev_top_rand_pcy", get_full_name()), this);
    // Disabling these constraints since they cause randomization issues and are not required at module level.
    m_dev_top_rand_pcy.fm_scaled_flow_ctrl_factors.constraint_mode(0);
    m_dev_top_rand_pcy.fm_credit_constr_c.constraint_mode(0);
    m_dev_top_rand_pcy.fm_Max_credit_vc_cif_map_c.constraint_mode(0);
    m_dev_top_rand_pcy.scaled_flow_ctrl_factors.constraint_mode(0);
    m_dev_top_rand_pcy.credit_constr_c.constraint_mode(0);
    m_dev_top_rand_pcy.Max_credit_vc_cif_map_c.constraint_mode(0);
    m_dev_top_rand_pcy.shared_flow_ctrl_constr_when_no_flit_mode.constraint_mode(0);

    m_dev_top_config.pcy_q.push_back(m_dev_top_rand_pcy);

    //Dev top config randomization
    if (!(m_dev_top_config.randomize() with {
      m_port_type == (m_scenario.m_strap_port_type[0] ? CDN_HPA_PCIE_DSP : CDN_HPA_PCIE_USP);
      //-- This m_fccpld_x_scale_vc is not used in module level, however it causes randomization issues in rand_ga_cfg hence setting it to 0.
      m_fccpld_x_scale_vc.size() == i_cfg.k_num_vcs;
      foreach(m_fccpld_x_scale_vc[loop_vc]) {
        m_fccpld_x_scale_vc[loop_vc] == 0;
      }
      is_acs_translation_blocking_en == 0;
    })) begin
      `uvm_fatal(l_msg_id, "cdn_pcie_hpa_dev_top_config randomization failed.")
    end
    
    // Dev top config pf assignments
    foreach(m_dev_top_config.pf_config[i]) begin
      m_dev_top_config.pf_config[i].dev_init_for_10_bit_tag_done = 1;
      m_dev_top_config.pf_config[i].dev_init_for_14_bit_tag_done = 1;
      m_dev_top_config.pf_config[i].en_bus_master                = 1;
      m_dev_top_config.pf_config[i].prReqAlloc                   = 512;
      m_dev_top_config.pf_config[i].m_req_id.bus_num = ((m_dev_top_config.m_port_type == CDN_HPA_PCIE_USP) ? m_dev_top_config.m_ep_req_id.bus_num : m_dev_top_config.m_rp_req_id.bus_num);
	    if(!i_cfg.strap_ari_enable || m_scenario.m_strap_port_type[0]) begin
        m_dev_top_config.pf_config[i].m_req_id.device_num = ((m_dev_top_config.m_port_type == CDN_HPA_PCIE_USP) ? m_dev_top_config.m_ep_req_id.device_num : m_dev_top_config.m_rp_req_id.device_num);
        m_dev_top_config.pf_config[i].m_req_id.function_num = i;
      end
      else begin
        {m_dev_top_config.pf_config[i].m_req_id.device_num, m_dev_top_config.pf_config[i].m_req_id.function_num} = i;
      end
    end
    
    // Remote dev top config vf assignments if present
    foreach(m_dev_top_config.vf_config[i, j]) begin
      m_dev_top_config.vf_config[i][j].dev_init_for_10_bit_tag_done = 1;
      m_dev_top_config.vf_config[i][j].dev_init_for_14_bit_tag_done = 1;
      m_dev_top_config.vf_config[i][j].en_bus_master                = 1;
      m_dev_top_config.vf_config[i][j].prReqAlloc                   = 512;
    end

    // Dev top config vc_tc assignments.
    foreach(m_dev_top_config.vc_tc_map[loop_vc, loop_tc]) begin
      if (m_dev_top_config.vc_tc_map[loop_vc][loop_tc] == 1) begin
        match_idx = m_dev_top_config.m_unmapped_tc_list.find_first_index(item) with (item == loop_tc);
        if(match_idx.size() != 0)
          m_dev_top_config.delete_from_unmapped_tc_list(match_idx[0]);
      end
    end

    if (m_scenario.m_strap_port_type[0]) begin
      sve.m_vseqr.pcie_dsp_dev_cfg = m_dev_top_config.pf_config[0];
      m_link_config.dsp_dev_top_config = m_dev_top_config;
    end  
    else begin
      sve.m_vseqr.pcie_usp_dev_cfg = m_dev_top_config.pf_config[0];
      m_link_config.usp_dev_top_config = m_dev_top_config;
    end

    sve.m_vseqr.dut_top_cfg = m_dev_top_config;
    sve.m_vseqr.hls_ob_tlp_sqr.m_pcie_dev_top_cfg = m_dev_top_config;
    
    //---Pass the configuration down in the environment hierarchy------------
    uvm_config_db #(cdn_pcie_hpa_dev_top_config)::set(this, "sve*", "dev_top_cfg", m_dev_top_config);

    `uvm_info(l_msg_id, "create_dut_dev_top_config function finished...", UVM_HIGH);

  endfunction : create_dut_dev_top_config
  
  //---------------------------------------------------------------------------
  // Method: create_remote_dev_top_config
  // This is creates the devtop config for remote side, randomizes it and pass handle to the
  // Environment Config.
  //---------------------------------------------------------------------------
  virtual function void create_remote_dev_top_config(string msg_id = "");
    string l_msg_id = {msg_id, "[create_remote_dev_top_config]"} ;
    int    match_idx[$]                                          ;

    `uvm_info(l_msg_id, "create_remote_dev_top_config function starting...", UVM_HIGH);
    
    //Remote Dev top config creation
    m_remote_dev_top_config = cdn_pcie_hpa_dev_top_config::type_id::create("m_remote_dev_top_config", this);
    m_remote_dev_top_config.i_cfg                   = i_cfg;
    m_remote_dev_top_config.hls_rx                  = 1;
    m_remote_dev_top_config.scenario                = m_scenario;
    m_remote_dev_top_config.flit_mode_negotiated    = (m_scenario.m_misc_flit_mode == 2'b10);
    m_remote_dev_top_config.captured_segment_number = 1;
    m_remote_dev_top_config.ecrc_init_done          = $urandom_range(1,0); // For HLS Bridge Module ecrc init doesn't matter.
    m_remote_dev_top_config.ib_traffic              = 1;
    m_remote_dev_top_config.l_num_enabled_pfs       = i_cfg.strap_is_rp ? 2 : 1;
    m_remote_dev_top_config.ide_init_done           = i_cfg.k_ide_supported ? 1 : 0;
    m_remote_dev_top_config.pr_req_outstanding      = 0;
    m_remote_dev_top_config.enable_segmentation     = $urandom_range(1,0);
    m_remote_dev_top_config.m_build_sel_stream      = 1;
    
    // Remote Dev top config policy creation and pushing
    m_remote_dev_top_rand_pcy = cdn_pcie_dev_top_config_random_policy::type_id::create($psprintf("%0s.m_remote_dev_top_rand_pcy", get_full_name()), this);
    // Disabling these constraints since they cause randomization issues and are not required at module level.
    m_remote_dev_top_rand_pcy.fm_scaled_flow_ctrl_factors.constraint_mode(0);
    m_remote_dev_top_rand_pcy.fm_credit_constr_c.constraint_mode(0);
    m_remote_dev_top_rand_pcy.fm_Max_credit_vc_cif_map_c.constraint_mode(0);
    m_remote_dev_top_rand_pcy.scaled_flow_ctrl_factors.constraint_mode(0);
    m_remote_dev_top_rand_pcy.credit_constr_c.constraint_mode(0);
    m_remote_dev_top_rand_pcy.Max_credit_vc_cif_map_c.constraint_mode(0);
    m_remote_dev_top_rand_pcy.shared_flow_ctrl_constr_when_no_flit_mode.constraint_mode(0);

    m_remote_dev_top_config.pcy_q.push_back(m_remote_dev_top_rand_pcy);

    // Remote Dev top config randomization
    if (!(m_remote_dev_top_config.randomize() with {
      m_port_type == (m_scenario.m_strap_port_type[0] ? CDN_HPA_PCIE_USP : CDN_HPA_PCIE_DSP);
      //-- This m_fccpld_x_scale_vc is not used in module level, however it causes randomization issues in rand_ga_cfg hence setting it to 0.
      m_fccpld_x_scale_vc.size() == i_cfg.k_num_vcs;
      foreach(m_fccpld_x_scale_vc[loop_vc]) {
        m_fccpld_x_scale_vc[loop_vc] == 0;
      }
      if(m_scenario.m_strap_port_type[0]) {
        m_rp_req_id == m_dev_top_config.m_rp_req_id;
      }
      else {
        m_ep_req_id == m_dev_top_config.m_ep_req_id;
      }
      m_max_payload_size  == m_dev_top_config.m_max_payload_size;
      intx_pin_or_hls == 0; //TODO
      vc_tc_map.size() == m_dev_top_config.vc_tc_map.size();
      foreach(m_dev_top_config.vc_tc_map[i]) {
        vc_tc_map[i] == m_dev_top_config.vc_tc_map[i]; 
      }
      same_segment_in_both_devices == m_dev_top_config.same_segment_in_both_devices;
      destination_segment == m_dev_top_config.requester_segment;
      requester_segment == m_dev_top_config.destination_segment;

      is_acs_translation_blocking_en == 0;
    })) begin
      `uvm_fatal(l_msg_id, "cdn_pcie_hpa_dev_top_config randomization failed.")
    end

    if(m_scenario.m_strap_port_type[0]) begin
      m_dev_top_config.m_ep_req_id = m_remote_dev_top_config.m_ep_req_id;
    end
    else begin
      m_dev_top_config.m_rp_req_id = m_remote_dev_top_config.m_rp_req_id;
    end

    m_remote_dev_top_config.copy_top_cfg(m_dev_top_config);

    // Remote dev top config pf assignments
    foreach(m_remote_dev_top_config.pf_config[i]) begin
      m_remote_dev_top_config.pf_config[i].dev_init_for_10_bit_tag_done = 1;
      m_remote_dev_top_config.pf_config[i].dev_init_for_14_bit_tag_done = 1;
      m_remote_dev_top_config.pf_config[i].en_bus_master                = 1;
      m_remote_dev_top_config.pf_config[i].prReqAlloc                   = 512;
      m_remote_dev_top_config.pf_config[i].m_req_id.bus_num = ((m_remote_dev_top_config.m_port_type == CDN_HPA_PCIE_USP) ? m_dev_top_config.m_ep_req_id.bus_num : m_dev_top_config.m_rp_req_id.bus_num);
	    if(!i_cfg.strap_ari_enable) begin
        m_remote_dev_top_config.pf_config[i].m_req_id.device_num = ((m_remote_dev_top_config.m_port_type == CDN_HPA_PCIE_USP) ? m_dev_top_config.m_ep_req_id.device_num : m_dev_top_config.m_rp_req_id.device_num);
        m_remote_dev_top_config.pf_config[i].m_req_id.function_num = i;
      end
      else begin
        {m_remote_dev_top_config.pf_config[i].m_req_id.device_num,m_remote_dev_top_config.pf_config[i].m_req_id.function_num} = i;
      end
    end
    
    // Remote dev top config vf assignments if present
    foreach(m_remote_dev_top_config.vf_config[i, j]) begin
      m_remote_dev_top_config.vf_config[i][j].dev_init_for_10_bit_tag_done = 1;
      m_remote_dev_top_config.vf_config[i][j].dev_init_for_14_bit_tag_done = 1;
      m_remote_dev_top_config.vf_config[i][j].en_bus_master                = 1;
      m_remote_dev_top_config.vf_config[i][j].prReqAlloc                   = 512;
    end
    
    // Remote Dev top config vc_tc assignments.
    foreach(m_remote_dev_top_config.vc_tc_map[loop_vc, loop_tc]) begin
      if (m_remote_dev_top_config.vc_tc_map[loop_vc][loop_tc] == 1) begin
        match_idx = m_remote_dev_top_config.m_unmapped_tc_list.find_first_index(item) with (item == loop_tc);
        if(match_idx.size() != 0)
          m_remote_dev_top_config.delete_from_unmapped_tc_list(match_idx[0]);
      end
    end

    m_remote_dev_top_config.ide_cfg.copy(m_dev_top_config.ide_cfg);

    m_dev_top_config.initialize_ide_selective_stream();
    m_remote_dev_top_config.initialize_ide_selective_stream();
    m_remote_dev_top_config.tdisp_cfg.copy(m_dev_top_config.tdisp_cfg);
    
    if (m_scenario.m_strap_port_type[0]) begin 
      sve.m_vseqr.pcie_usp_dev_cfg = m_remote_dev_top_config.pf_config[0];
      m_link_config.usp_dev_top_config = m_remote_dev_top_config;
    end
    else begin
      sve.m_vseqr.pcie_dsp_dev_cfg = m_remote_dev_top_config.pf_config[0];
      m_link_config.dsp_dev_top_config = m_remote_dev_top_config;
    end

    sve.m_vseqr.remote_dev_top_cfg = m_remote_dev_top_config;
    sve.m_vseqr.hls_ib_tlp_sqr.m_pcie_dev_top_cfg = m_remote_dev_top_config;
    
    //---Pass the configuration down in the environment hierarchy------------
    uvm_config_db #(cdn_pcie_hpa_dev_top_config)::set(this, "*", "remote_dev_top_cfg", m_remote_dev_top_config);

    `uvm_info(l_msg_id, "create_remote_dev_top_config function finished...", UVM_HIGH);

  endfunction : create_remote_dev_top_config
  
  //---------------------------------------------------------------------------
  // Method: create_bars_config
  // This is creates bars configuration for EP and RP Side.
  //---------------------------------------------------------------------------
  virtual function void create_bars_config(string msg_id = "");
    string       l_msg_id = {msg_id, "[create_bars_config]"};
    int unsigned ep_dev_num_pf                              ; // DUT Side num PFs
    int unsigned ep_remote_num_pf                           ; // Remote Side num PFs

    `uvm_info(l_msg_id, "create_bars_config function starting...", UVM_HIGH);
    
    ep_dev_num_pf    = i_cfg.k_num_pfs;
    if(i_cfg.k_num_pfs > 1)
      ep_remote_num_pf = 2;
    else
      ep_remote_num_pf = 1;

    //-- Bar Config Creation for EP Side ----------------------------------------------------
    if (!i_cfg.strap_is_rp) begin
      m_pcie_bar_cfg                    = new("m_pcie_bar_cfg", ep_dev_num_pf);
      m_pcie_bar_cfg.k_num_pfs          = int'(ep_dev_num_pf);
      m_pcie_bar_cfg.k_rp_bar_enable    = i_cfg.k_rp_bar_enable;
      m_pcie_bar_cfg.k_rp_bar_size      = i_cfg.k_rp_bar_size;
      m_pcie_bar_cfg.k_rp_bar_prefetch  = i_cfg.k_rp_bar_prefetch;
      m_pcie_bar_cfg.k_msi_enable       = i_cfg.k_msi_enable;
      m_pcie_bar_cfg.is_32_bit_msi_bar  = $urandom_range(1, 0);
      
      for (int loop_pf = 0; loop_pf < ep_dev_num_pf; loop_pf++) begin
        m_pcie_bar_cfg.k_bar_enable[loop_pf]         = i_cfg.k_bar_enable[loop_pf];
        m_pcie_bar_cfg.k_bar_type[loop_pf]           = i_cfg.k_bar_type[loop_pf]; 
        m_pcie_bar_cfg.k_bar_size[loop_pf]           = i_cfg.k_bar_size[loop_pf]; 
        m_pcie_bar_cfg.k_bar_prefetch[loop_pf]       = i_cfg.k_bar_prefetch[loop_pf];
        m_pcie_bar_cfg.k_bar_aperture[loop_pf]       = i_cfg.k_bar_aperture[loop_pf];
        m_pcie_bar_cfg.k_sriov_enable[loop_pf]       = i_cfg.k_sriov_enable[loop_pf];
        m_pcie_bar_cfg.k_num_vfs_per_pf[loop_pf]     = m_dev_top_config.pf_config[loop_pf].m_NumVFs;
        m_pcie_bar_cfg.k_vf_bar_enable[loop_pf]      = i_cfg.k_vf_bar_enable[loop_pf];
        m_pcie_bar_cfg.k_vf_bar_size[loop_pf]        = i_cfg.k_vf_bar_size[loop_pf];
        m_pcie_bar_cfg.k_vf_bar_prefetch[loop_pf]    = i_cfg.k_vf_bar_prefetch[loop_pf];
        m_pcie_bar_cfg.m_sys_page_size[loop_pf]      = 1;
        m_pcie_bar_cfg.k_exp_rom_bar_enable[loop_pf] = i_cfg.k_exp_rom_bar_enable[loop_pf];
      end
      // m_pcie_bar_cfg.printEpBarCfg();
      
      m_bars_per_device                   = new("m_bars_per_device", ep_dev_num_pf);
      m_bars_per_device.dut_type          = i_cfg.strap_is_rp ? CDN_HPA_PCIE_RP : CDN_HPA_PCIE_EP;
      m_bars_per_device.m_scenario        = m_scenario;
      m_bars_per_device.k_msi_enable      = i_cfg.k_msi_enable;
      m_bars_per_device.is_msi_32         = m_pcie_bar_cfg.is_32_bit_msi_bar;
      m_bars_per_device.setEpBarCfg(m_pcie_bar_cfg, 1); // TODO Check with Anil what is seq_bar_test.
    end
    //-- Bar Config Creation for RP Side ------------------------------------------------------
    else begin
      m_remote_pcie_bar_cfg                   = new("m_remote_pcie_bar_cfg", ep_remote_num_pf);
      m_remote_pcie_bar_cfg.k_num_pfs         = int'(ep_remote_num_pf);
      m_remote_pcie_bar_cfg.k_rp_bar_enable   = i_cfg.k_rp_bar_enable;
      m_remote_pcie_bar_cfg.k_rp_bar_size     = i_cfg.k_rp_bar_size;
      m_remote_pcie_bar_cfg.k_rp_bar_prefetch = i_cfg.k_rp_bar_prefetch;
      m_remote_pcie_bar_cfg.k_msi_enable      = i_cfg.k_msi_enable;
      m_remote_pcie_bar_cfg.is_32_bit_msi_bar = $urandom_range(1, 0);
      
      for (int loop_pf = 0; loop_pf < ep_remote_num_pf; loop_pf++) begin
        m_remote_pcie_bar_cfg.k_bar_enable[loop_pf]         = i_cfg.k_bar_enable[loop_pf];
        m_remote_pcie_bar_cfg.k_bar_type[loop_pf]           = i_cfg.k_bar_type[loop_pf];
        m_remote_pcie_bar_cfg.k_bar_size[loop_pf]           = i_cfg.k_bar_size[loop_pf];
        m_remote_pcie_bar_cfg.k_bar_prefetch[loop_pf]       = i_cfg.k_bar_prefetch[loop_pf];
        m_remote_pcie_bar_cfg.k_bar_aperture[loop_pf]       = i_cfg.k_bar_aperture[loop_pf];
        m_remote_pcie_bar_cfg.k_sriov_enable[loop_pf]       = i_cfg.k_sriov_enable[loop_pf];
        m_remote_pcie_bar_cfg.k_num_vfs_per_pf[loop_pf]     = m_remote_dev_top_config.pf_config[loop_pf].m_NumVFs;
        m_remote_pcie_bar_cfg.k_vf_bar_enable[loop_pf]      = i_cfg.k_vf_bar_enable[loop_pf];
        m_remote_pcie_bar_cfg.k_vf_bar_size[loop_pf]        = i_cfg.k_vf_bar_size[loop_pf];
        m_remote_pcie_bar_cfg.k_vf_bar_prefetch[loop_pf]    = i_cfg.k_vf_bar_prefetch[loop_pf];
        m_remote_pcie_bar_cfg.m_sys_page_size[loop_pf]      = 1;
        m_remote_pcie_bar_cfg.k_exp_rom_bar_enable[loop_pf] = i_cfg.k_exp_rom_bar_enable[loop_pf];
      end
      // m_remote_pcie_bar_cfg.printEpBarCfg();
      
      m_remote_bars_per_device              = new("m_remote_bars_per_device", ep_remote_num_pf);
      m_remote_bars_per_device.dut_type     = i_cfg.strap_is_rp ? CDN_HPA_PCIE_EP: CDN_HPA_PCIE_RP;
      m_remote_bars_per_device.m_scenario   = m_scenario;
      m_remote_bars_per_device.k_msi_enable = i_cfg.k_msi_enable;
      m_remote_bars_per_device.is_msi_32    = m_remote_pcie_bar_cfg.is_32_bit_msi_bar;
      m_remote_bars_per_device.setEpBarCfg(m_remote_pcie_bar_cfg, 1);  // TODO Check with Anil what is seq_bar_test.
    end

    //-- Bar Config Assignment for EP Side for PFs -----------------------------------------------
    if (!i_cfg.strap_is_rp) begin
      foreach (m_dev_top_config.pf_config[i]) begin
        if (!$cast(m_dev_top_config.pf_config[i].m_fun_bar_info, m_bars_per_device.m_pf[i]))
          `uvm_fatal(l_msg_id, $sformatf("Casting of m_bars_per_device.m_pf[%0d] to m_dev_top_config.pf_config[%0d].m_fun_bar_info failed...", i, i))
      end
      if (!$cast(m_remote_dev_top_config.pf_config[0].m_fun_bar_info, m_bars_per_device.m_rp))
        `uvm_fatal(l_msg_id, "Casting of m_bars_per_device.m_rp to m_remote_dev_top_config.pf_config[0].m_fun_bar_info failed...")
    end
    //-- Bar Config Assignment for RP Side for PFs -----------------------------------------------
    else begin
      foreach (m_remote_dev_top_config.pf_config[i]) begin
        if (!$cast(m_remote_dev_top_config.pf_config[i].m_fun_bar_info, m_remote_bars_per_device.m_pf[i]))
          `uvm_fatal(l_msg_id, $sformatf("Casting of m_remote_bars_per_device.m_pf[%0d] to m_remote_dev_top_config.pf_config[%0d].m_fun_bar_info failed...", i, i))
      end
      if (!$cast(m_dev_top_config.pf_config[0].m_fun_bar_info, m_remote_bars_per_device.m_rp))
        `uvm_fatal(l_msg_id, "Casting of m_remote_bars_per_device.m_rp to m_dev_top_config.pf_config[0].m_fun_bar_info failed...")
    end
    
    // -- Bar Config Creation/Assignment in EP Side for VFs --------------------------------------
    // Note: VFs are only for EP Device
    if (i_cfg.strap_is_rp) begin
      create_vf_bars_config(l_msg_id, m_remote_dev_top_config, m_remote_bars_per_device);
    end
    else begin
      create_vf_bars_config(l_msg_id, m_dev_top_config, m_bars_per_device);
    end

    //--- Bar Info Assignment in case of RP. -----------------------------------------------------
    if (i_cfg.strap_is_rp) begin
      m_dev_top_config.m_ep_dev_bar_info      = new("m_ep_dev_bar_info", ep_remote_num_pf);
      m_dev_top_config.m_rp_dev_bar_info      = new("m_rp_dev_bar_info", 1);
      m_dev_top_config.m_ep_dev_bar_info.m_pf = new[ep_remote_num_pf];
      m_dev_top_config.m_rp_dev_bar_info.m_pf = new[1];
      
      m_remote_dev_top_config.m_ep_dev_bar_info      = new("m_ep_dev_bar_info", ep_remote_num_pf);
      m_remote_dev_top_config.m_rp_dev_bar_info      = new("m_rp_dev_bar_info", 1);
      m_remote_dev_top_config.m_ep_dev_bar_info.m_pf = new[m_remote_dev_top_config.pf_config.size()];
      m_remote_dev_top_config.m_rp_dev_bar_info.m_pf = new[1];

      m_dev_top_config.m_rp_dev_bar_info.m_pf[0]        = m_dev_top_config.pf_config[0].m_fun_bar_info;
      m_remote_dev_top_config.m_rp_dev_bar_info.m_pf[0] = m_dev_top_config.pf_config[0].m_fun_bar_info;
      
      foreach (m_remote_dev_top_config.pf_config[i]) begin 
        m_dev_top_config.m_ep_dev_bar_info.m_pf[i]        = m_remote_dev_top_config.pf_config[i].m_fun_bar_info;
        m_remote_dev_top_config.m_ep_dev_bar_info.m_pf[i] = m_remote_dev_top_config.pf_config[i].m_fun_bar_info;
      end

      if ((i_cfg.k_sriov_enable.sum() with (int'(item))) > 1) begin
        m_remote_dev_top_config.m_ep_dev_bar_info.m_vf = new[ep_remote_num_pf];
        foreach (m_remote_dev_top_config.vf_config[i, j]) begin 
          m_remote_dev_top_config.m_ep_dev_bar_info.m_vf[i] = m_remote_dev_top_config.vf_config[i][j].m_fun_bar_info;
        end
      end

      m_dev_top_config.m_ep_dev_bar_info.k_msi_enable        = m_remote_bars_per_device.k_msi_enable;
      m_dev_top_config.m_ep_dev_bar_info.is_msi_32           = m_remote_bars_per_device.is_msi_32; 
      m_dev_top_config.m_ep_dev_bar_info.msi_bar             = new[m_remote_bars_per_device.msi_bar.size()];
      m_remote_dev_top_config.m_ep_dev_bar_info.k_msi_enable = m_remote_bars_per_device.k_msi_enable;
      m_remote_dev_top_config.m_ep_dev_bar_info.is_msi_32    = m_remote_bars_per_device.is_msi_32; 
      m_remote_dev_top_config.m_ep_dev_bar_info.msi_bar      = new[m_remote_bars_per_device.msi_bar.size()];
      foreach(m_remote_bars_per_device.msi_bar[i]) begin
        m_dev_top_config.m_ep_dev_bar_info.msi_bar[i]        = m_remote_bars_per_device.msi_bar[i];
        m_remote_dev_top_config.m_ep_dev_bar_info.msi_bar[i] = m_remote_bars_per_device.msi_bar[i];
      end
    end
    //--- Bar Info Assignment in case of EP. -----------------------------------------------------
    else begin
      m_dev_top_config.m_ep_dev_bar_info             = new("m_ep_dev_bar_info", ep_dev_num_pf);
      m_dev_top_config.m_rp_dev_bar_info             = new("m_rp_dev_bar_info", 1);
      m_dev_top_config.m_ep_dev_bar_info.m_pf        = new[m_dev_top_config.pf_config.size()];
      m_dev_top_config.m_rp_dev_bar_info.m_pf        = new[1];
      
      m_remote_dev_top_config.m_ep_dev_bar_info      = new("m_ep_dev_bar_info", ep_dev_num_pf);
      m_remote_dev_top_config.m_rp_dev_bar_info      = new("m_rp_dev_bar_info", 1);
      m_remote_dev_top_config.m_ep_dev_bar_info.m_pf = new[i_cfg.k_num_pfs];
      m_remote_dev_top_config.m_rp_dev_bar_info.m_pf = new[1];

      foreach (m_dev_top_config.pf_config[i]) begin 
        m_dev_top_config.m_ep_dev_bar_info.m_pf[i]        = m_dev_top_config.pf_config[i].m_fun_bar_info;
        m_remote_dev_top_config.m_ep_dev_bar_info.m_pf[i] = m_dev_top_config.pf_config[i].m_fun_bar_info;
      end

      m_dev_top_config.m_rp_dev_bar_info.m_pf[0]        = m_remote_dev_top_config.pf_config[0].m_fun_bar_info;
      m_remote_dev_top_config.m_rp_dev_bar_info.m_pf[0] = m_remote_dev_top_config.pf_config[0].m_fun_bar_info;

      if ((i_cfg.k_sriov_enable.sum() with (int'(item))) > 1) begin
        m_dev_top_config.m_ep_dev_bar_info.m_vf = new[ep_dev_num_pf];
        foreach (m_dev_top_config.vf_config[i, j]) begin 
          m_dev_top_config.m_ep_dev_bar_info.m_vf[i] = m_dev_top_config.vf_config[i][j].m_fun_bar_info;
        end
      end
      
      m_dev_top_config.m_ep_dev_bar_info.k_msi_enable        = m_bars_per_device.k_msi_enable;
      m_dev_top_config.m_ep_dev_bar_info.is_msi_32           = m_bars_per_device.is_msi_32; 
      m_dev_top_config.m_ep_dev_bar_info.msi_bar             = new[m_bars_per_device.msi_bar.size()];
      m_remote_dev_top_config.m_ep_dev_bar_info.k_msi_enable = m_bars_per_device.k_msi_enable;
      m_remote_dev_top_config.m_ep_dev_bar_info.is_msi_32    = m_bars_per_device.is_msi_32; 
      m_remote_dev_top_config.m_ep_dev_bar_info.msi_bar      = new[m_bars_per_device.msi_bar.size()];
      foreach(m_bars_per_device.msi_bar[i]) begin
        m_dev_top_config.m_ep_dev_bar_info.msi_bar[i]        = m_bars_per_device.msi_bar[i];
        m_remote_dev_top_config.m_ep_dev_bar_info.msi_bar[i] = m_bars_per_device.msi_bar[i];
      end
    end

    `uvm_info(l_msg_id, "create_bars_config function finished...", UVM_HIGH);
  endfunction : create_bars_config

  //---------------------------------------------------------------------------
  // Method: create_vf_bars_config
  // This method assign bars to the VF Configs.
  //---------------------------------------------------------------------------
  function void create_vf_bars_config(string msg_id = "", ref cdn_pcie_hpa_dev_top_config dev_top_config, ref bars_per_device bars_per_device);
    string l_msg_id = {msg_id, "[create_vf_bars_config]"};
    bit        skip_next_bar       ;
    bit [63:0] start_addr, end_addr;

    `uvm_info(l_msg_id, "create_vf_bars_config function starting...", UVM_HIGH);
    
    //-- If VF is enabled for a PF and Total VF > 1 then assign the bars info. -------
    foreach (dev_top_config.vf_config[i, j]) begin
      if((dev_top_config.pf_config[i].m_vf_en == 1) && (dev_top_config.pf_config[i].m_TotalVFs >= 1)) begin
        if(!$cast(dev_top_config.vf_config[i][j].m_fun_bar_info, bars_per_device.m_vf[i].clone())) begin
          `uvm_fatal(l_msg_id, $sformatf("Casting of bars_per_device.m_vf[%0d] to dev_top_config.vf_config[%0d][%0d].m_fun_bar_info failed...", i, i, j))
        end
        dev_top_config.vf_config[i][j].m_fun_bar_info.copy(bars_per_device.m_vf[i]);
        dev_top_config.vf_config[i][j].m_fun_bar_info.bars = new[6];
        foreach(bars_per_device.m_vf[i].bars[bar_i]) begin
          if(!$cast(dev_top_config.vf_config[i][j].m_fun_bar_info.bars[bar_i], bars_per_device.m_vf[i].bars[bar_i].clone())) begin
            `uvm_fatal(l_msg_id, $sformatf("Casting of bars_per_device.m_vf[%0d].bars[%0d] to dev_top_config.vf_config[%0d][%0d].m_fun_bar_info.bars[%0d] failed...", i, bar_i, i, j, bar_i))
          end
        end
      end  
    end
    
    // Each VF config associated with a parent PF contains start address of VF BAR. But each VF should have start address as per the the actual VF 
    // so new start address has to be calculated and assigned to respective VF_Bar Config.
    // Note : Each VF does not have bar. It use start address & aperture from parent PF's SRIOV Cap's VF Bar For Each VF Conig, start. Here we are changing the start address of each VF config Bar's
    // each dev_top_config.vf_config bar's will have start addresses for same VF Num, this is done so that each dev_top_config.vf_config will have all reavent information including bars
    foreach (dev_top_config.pf_config[i]) begin
      if((dev_top_config.pf_config[i].m_vf_en == 1) && (dev_top_config.pf_config[i].m_TotalVFs >= 1)) begin
        for(int j = 0; j < dev_top_config.pf_config[i].m_NumVFs; j++) begin
          skip_next_bar = 0;
          for(int bar_num = 0; bar_num < 6; bar_num++) begin
            if(skip_next_bar == 1) begin
              skip_next_bar = 0;
              `uvm_info(l_msg_id, $psprintf("VF BAR DEBUG: Skip VF_BAR: %0d For PF[%0d][%0d]", bar_num, i, j), UVM_DEBUG);
              continue;
            end
            dev_top_config.vf_config[i][j].m_fun_bar_info.bars[bar_num].start_addr = bars_per_device.m_vf[i].bars[bar_num].start_addr + ((2**(bars_per_device.m_vf[i].bars[bar_num].get_decoded_bar_aperture()))*j);
            end_addr = dev_top_config.vf_config[i][j].m_fun_bar_info.bars[bar_num].start_addr + ((2**(bars_per_device.m_vf[i].bars[bar_num].get_decoded_bar_aperture()))) - 1;
            if(bars_per_device.m_vf[i].bars[bar_num].bar_type inside {MEM_BAR_64_PREFETCH, MEM_BAR_64_NON_PREFETCH}) begin
              skip_next_bar++;
            end
          end
        end
      end
    end
    
    `uvm_info(l_msg_id, "create_vf_bars_config function finished...", UVM_HIGH);
  endfunction: create_vf_bars_config

  //---------------------------------------------------------------------------
  // Method: create_hls_bridge_config
  //---------------------------------------------------------------------------
  virtual function void create_hls_bridge_config(string msg_id = "");
    string l_msg_id = {msg_id, "[create_hls_bridge_config]"};

    `uvm_info(l_msg_id, "create_hls_bridge_config function starting...", UVM_HIGH);
    
    m_hls_bridge_config = cdn_pcie_hls_bridge_config::type_id::create("m_hls_bridge_config");
    
    if(!m_hls_bridge_config.randomize()) begin
      `uvm_fatal(get_type_name(),"Could not randomize cdn_pcie_hls_bridge_config");
    end
   
    //--- Generate hls_bridge_tf_port_map_value ------------------------------- 
    m_hls_bridge_config.generate_hls_bridge_tf_port_map_value(.link_config(m_link_config));

    //--- Pass the config handle ----------------------------------------------
    m_env_cfg.m_hls_bridge_config = m_hls_bridge_config;
    
    //--- Pass the configuration down in the environment hierarchy ------------
    uvm_config_db #(cdn_pcie_hls_bridge_config)::set(this, "*", "hls_bridge_config", m_hls_bridge_config);
    
    `uvm_info(l_msg_id, "create_hls_bridge_config function ending...", UVM_HIGH);
    
  endfunction : create_hls_bridge_config

  //---------------------------------------------------------------------------
  // Method: run_simulation
  // This is the main task which starts the sequences.
  //---------------------------------------------------------------------------
  virtual task run_simulation(string msg_id = "");
    string     l_msg_id = {msg_id, "[run_simulation]"};
    bit [31:0] l_dti_link_down_ctrl_val;

    forever begin
      fork
        begin : vseq_thread
          //--- Start virtual Seq -----------------------------------------------------
          m_vseq = cdn_pcie_hls_bridge_vseq::type_id::create("vseq");
          if(!m_vseq.randomize()) begin
            `uvm_fatal(l_msg_id, $sformatf("Could not randomize %0s sequence.", m_vseq.get_type_name()))
          end
          m_vseq.start(sve.m_vseqr);

          //--- If reset is deasserted or link down is asserted then wait for it to complete before ending the thread.
          if(m_env_cfg.hard_reset_triggered_e.is_on()) m_env_cfg.hard_reset_done_e.wait_trigger();
          if(m_env_cfg.link_down_triggered_e.is_on())  m_env_cfg.link_down_done_e.wait_trigger();
        end
        begin : hard_reset_thread
          //--- Wait for hard reset trigger -------------------------------------------
          m_env_cfg.hard_reset_triggered_e.wait_trigger();
          
          //--- Stop all the sequences ------------------------------------------------
          sve.m_vseqr.stop_sequences();
          
          //--- Perform reset ---------------------------------------------------------
          do_reset();
          
          //--- Wait for reset manager to complete resetting all the components -------
          sve.m_reset_manager.reset_done_e.wait_on();

          //--- Rerandomize configuration --------------------------------------------
          do_rerandomize_config();
          
          m_env_cfg.hard_reset_done_e.trigger();
        end
        begin : link_down_thread
          //--- Wait for linkdown trigger ---------------------------------------------
          m_env_cfg.link_down_triggered_e.wait_trigger();

          //--- Assert link down handling in progress ---------------------------------
          m_env_cfg.m_misc_if_api.set_link_down_handling_in_progress(.value(1'b1));
          
          //--- Stop CXS Driver -------------------------------------------------------
          m_env_cfg.stop_cxs_driver = 1;
          
          //--- Assert deacthint for the receiver VIPs --------------------------------
          sve.set_cxs_vips_deacthint(.value(1));
          
          //--- Pause Traffic Generation Sequence -------------------------------------
          m_env_cfg.m_misc_if_api.set_pause_traffic(.value(1'b1));
          
          //--- Wait CXS Driver stop sending transactions -----------------------------
          sve.wait_cxs_vips_driver_sending_tr();
          
          //--- Adding buffer time for Sequences to end the current pkt ---------------
          m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(5));

          //--- Stop all the sequences ------------------------------------------------
          sve.m_vseqr.stop_cxs_sequences();

          //--- Set crd_lmt_cntl signals to infinite ----------------------------------    
          for (int vc = 0; vc < parameters_cfg_pkg::KMAX_NUM_VCS; vc++) begin    
            m_env_cfg.m_crd_lmt_posted_if_api.set_crd_m_lmt_cntl(vc, 3);
            m_env_cfg.m_crd_lmt_nonposted_if_api.set_crd_m_lmt_cntl(vc, 3);
          end
	   
          //--- Wait for CXS VIPs to reach STOP State. --------------------------------
          fork
            begin
              fork
                begin
                  sve.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(sve.m_hls_ob_posted_hal_env));
                  sve.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(sve.m_hls_ob_nonposted_hal_env));
                  sve.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(sve.m_hls_ob_compl_hal_env));
                  sve.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(sve.m_hls_ib_posted_hal_env));
                  sve.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(sve.m_hls_ib_nonposted_hal_env));
                  sve.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(sve.m_hls_ib_compl_hal_env));
                  foreach(sve.m_hls_ob_posted_axi_env[loop_port])
                    sve.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(sve.m_hls_ob_posted_axi_env[loop_port]));
                  foreach(sve.m_hls_ob_nonposted_axi_env[loop_port])
                    sve.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(sve.m_hls_ob_nonposted_axi_env[loop_port]));
                  foreach(sve.m_hls_ob_compl_axi_env[loop_port])
                    sve.wait_cxs_vip_reach_stop_state(.is_rx(0), .hls_env(sve.m_hls_ob_compl_axi_env[loop_port]));
                  foreach(sve.m_hls_ib_posted_axi_env[loop_port])
                    sve.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(sve.m_hls_ib_posted_axi_env[loop_port]));
                  foreach(sve.m_hls_ib_nonposted_axi_env[loop_port])
                    sve.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(sve.m_hls_ib_nonposted_axi_env[loop_port]));
                  foreach(sve.m_hls_ib_compl_axi_env[loop_port])
                    sve.wait_cxs_vip_reach_stop_state(.is_rx(1), .hls_env(sve.m_hls_ib_compl_axi_env[loop_port]));
                end
                begin
                  m_env_cfg.m_hpa_timer.wait_for_time(10, "Max wait time for CXS VIP to reach STOP state.", "us");
                  `uvm_fatal(l_msg_id, "CXS VIPs have not reached the STOP state...")
                end
              join_any
              disable fork;
            end
          join

          //--- Deassert link down handling in progress after random delay ------------
          m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles($urandom_range(1000, 500)));
          m_env_cfg.m_misc_if_api.set_link_down_handling_in_progress(.value(1'b0));
         
          //--- Stop rest of the sequences --------------------------------------------
          sve.m_vseqr.stop_sequences();

          //--- Buffer Time post linkdown is deasseted --------------------------------
          m_env_cfg.m_misc_if_api.wait_cb(.clk_cycles(5));
          
          //--- Clear the linkdown ctrl bit -------------------------------------------
`ifdef DTI_TB_IN_PASSIVE_MODE
          sve.dti_env.dti_ats_env.tcu_env.tcu_generator.do_before_link_down_indication_clr();
          sve.dti_regs_model.read_register("link_down_ctrl", l_dti_link_down_ctrl_val);
          l_dti_link_down_ctrl_val[0] = 0;
          sve.dti_regs_model.write_register("link_down_ctrl", l_dti_link_down_ctrl_val);
`endif

          //--- Wait for reset manager to complete resetting all the components ---------
          sve.m_reset_manager.reset_done_e.wait_on();
          
          //--- Resume CXS Driver -------------------------------------------------------
          m_env_cfg.stop_cxs_driver = 0;
          
          //--- Unpause Traffic Generation Sequence -------------------------------------
          m_env_cfg.m_misc_if_api.set_pause_traffic(.value(1'b0));

          //--- Deassert deacthint for the receiver CXS VIPs ----------------------------
          sve.set_cxs_vips_deacthint(.value(0));
         
          //--- Trigger Linkdown Done ---------------------------------------------------
          m_env_cfg.link_down_done_e.trigger();
        end
      join_any
      disable fork;
      
      // ----- Vseq completed hence ending the test -------------------------------------
      if(m_env_cfg.vseq_completed_e.is_on())
        break;
      
      //--- Reset/Linkdown/simulation control events resetting. -------------------------
      m_env_cfg.reset_control_events();
    end
  endtask : run_simulation

  //---------------------------------------------------------------------------
  // Method: drive_clocks
  // This task runs the clock sequence to drive the clocks. 
  //---------------------------------------------------------------------------
  virtual task drive_clocks(string msg_id = "");
    string l_msg_id = {msg_id, "[drive_clocks]"};

    //---Clock Sequences ------------------------------------------------------
    cdn_clock_seq l_clk_seq;
    
    `uvm_info(l_msg_id, "drive_clocks task starting...", UVM_LOW);
   
    l_clk_seq = cdn_clock_seq::type_id::create("l_clk_seq");
    l_clk_seq.start(sve.m_vseqr.clk_sqr);

    `uvm_info(l_msg_id, "drive_clocks task ending...", UVM_LOW);

  endtask : drive_clocks

  //---------------------------------------------------------------------------
  // Method: do_reset
  // This task runs the reset sequences for all the resets and 
  // will set the interfaces to default value. 
  //---------------------------------------------------------------------------
  virtual task do_reset(string msg_id = "");
    string l_msg_id = {msg_id, "[do_reset]"};
    
    //- Reset sequences -------------------------------------------------------
    cdn_pcie_tl_single_reset_seq l_core_rst_seq, l_axi_msi_rst_seq, l_axi_dti_rst_seq, l_axil_rst_seq;
    
    `uvm_info(l_msg_id, "do_reset task starting...", UVM_LOW);
    
    fork
      begin
        l_core_rst_seq = cdn_pcie_tl_single_reset_seq::type_id::create("l_core_rst_seq");
        l_core_rst_seq.start(sve.m_vseqr.core_rst_sqr);
        wait(sve.m_core_rst_env.agents[0].monitor.reset_ended_e.triggered);
      end
      begin
        l_axi_msi_rst_seq = cdn_pcie_tl_single_reset_seq::type_id::create("l_axi_msi_rst_seq");
        l_axi_msi_rst_seq.start(sve.m_vseqr.axi_msi_rst_sqr);
        wait(sve.m_axi_msi_rst_env.agents[0].monitor.reset_ended_e.triggered);
      end
      begin
        l_axi_dti_rst_seq = cdn_pcie_tl_single_reset_seq::type_id::create("l_axi_dti_rst_seq");
        l_axi_dti_rst_seq.start(sve.m_vseqr.axi_dti_rst_sqr);
        wait(sve.m_axi_dti_rst_env.agents[0].monitor.reset_ended_e.triggered);
      end
      begin
        l_axil_rst_seq = cdn_pcie_tl_single_reset_seq::type_id::create("l_axil_rst_seq");
        l_axil_rst_seq.start(sve.m_vseqr.axil_rst_sqr);
        wait(sve.m_axil_rst_env.agents[0].monitor.reset_ended_e.triggered);
      end
      begin
        //-- Interface Reset-----------------------------------
        m_env_cfg.m_misc_if_api.reset();
        m_env_cfg.m_crd_lmt_posted_if_api.reset();
        m_env_cfg.m_crd_lmt_nonposted_if_api.reset();
      end
    join

    m_env_cfg.m_hpa_timer.wait_for_time(10, "Delay for VIP's to reset", "ns");
  
    `uvm_info(l_msg_id, "do_reset task finished...", UVM_LOW);
  endtask : do_reset
  
  //---------------------------------------------------------------------------
  // Method: do_rerandomize_config
  // This task rerandomizes the configs. Used in case of hard_reset post resetting.
  //---------------------------------------------------------------------------
  virtual task do_rerandomize_config(string msg_id = "");
    string l_msg_id = {msg_id, "[do_rerandomize_config]"};

    //--- HLS Bridge Scenario ReRandomize ------------------------------------------
    m_scenario.rerandomize();
    m_scenario.generate_tag_management();

    //--- HLS Bridge Register Config ReRandomize ------------------------------------------
    m_hls_bridge_config.rerandomize();
    m_hls_bridge_config.generate_hls_bridge_tf_port_map_value(.link_config(m_link_config));

    `uvm_info(l_msg_id, $sformatf("Generated scenario is:\n%0s"        , m_scenario.sprint())         , UVM_NONE)
    `uvm_info(l_msg_id, $sformatf("Generated m_hls_bridge_config:\n%0s", m_hls_bridge_config.sprint()), UVM_NONE)

  endtask : do_rerandomize_config

  //-----------------------------------------------------------------------------
  // Task : do_kwire_config
  // Method used to set the kwires of the DUT
  //-----------------------------------------------------------------------------
  virtual function void do_kwire_config(string msg_id = "");
    string l_msg_id = {msg_id, "[do_kwire_config]"};
    bit [parameters_cfg_pkg::NUM_HLS_PORTS * parameters_cfg_pkg::KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH-1 : 0] l_k_axi_m_outstanding_writes_min1;
    
    `uvm_info(l_msg_id, "Starting do_kwire_config to configure the kwires...", UVM_HIGH)
    
    for (int loop_port = 0; loop_port < parameters_cfg_pkg::NUM_HLS_PORTS; loop_port++) begin
      l_k_axi_m_outstanding_writes_min1[(loop_port * parameters_cfg_pkg::KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH) +: parameters_cfg_pkg::KMAX_AXI_M_OUTSTANDING_WRITES_WIDTH] = i_cfg.k_axi_m_outstanding_writes_min1[loop_port];
    end

    m_env_cfg.m_k_if_api.set_k_hls_dw_alignment              ( i_cfg.k_hls_dw_alignment                   ) ;
    m_env_cfg.m_k_if_api.set_k_cxl_io_support                ( i_cfg.k_cxl_support                        ) ;
    m_env_cfg.m_k_if_api.set_k_sync_reset                    ( i_cfg.k_sync_reset                         ) ;
    m_env_cfg.m_k_if_api.set_k_sync_cell_stages              ( i_cfg.k_number_of_flop_stages_in_sync_cell ) ;
    m_env_cfg.m_k_if_api.set_k_flit_mode_support             ( i_cfg.k_flit_mode_support                  ) ;
    m_env_cfg.m_k_if_api.set_k_ide_support                   ( i_cfg.k_ide_supported                      ) ;
    m_env_cfg.m_k_if_api.set_k_pasid_supported               ( i_cfg.k_pasid_supported                    ) ;
    m_env_cfg.m_k_if_api.set_k_dti_tok_inv_min1              ( i_cfg.k_dti_tok_inv_min1                   ) ;
    m_env_cfg.m_k_if_api.set_k_dti_tok_trans_min1            ( i_cfg.k_dti_tok_trans_min1                 ) ;
    m_env_cfg.m_k_if_api.set_k_dti_ram_read_latency          ( i_cfg.k_ram_read_latency                   ) ;
    m_env_cfg.m_k_if_api.set_k_dti_ram_enable                ( i_cfg.k_dti_ram_enable                     ) ;
    m_env_cfg.m_k_if_api.set_k_vendor_prefix_local_support   ( i_cfg.k_vendor_prefix_local_support        ) ;
    m_env_cfg.m_k_if_api.set_k_ecrc_capability_support       ( i_cfg.k_ecrc_capability_support            ) ;
    m_env_cfg.m_k_if_api.set_k_ohc_e_wd                      ( i_cfg.k_ohc_e_wd                           ) ;
    m_env_cfg.m_k_if_api.set_k_axi_m_outstanding_writes_min1 ( l_k_axi_m_outstanding_writes_min1          ) ;
    m_env_cfg.m_k_if_api.set_k_cxl_pbr_flit_support          ( parameters_cfg_pkg::KMAX_PBR_SUPPORT       ) ;
    m_env_cfg.m_k_if_api.set_strap_port_type                 ( m_scenario.m_strap_port_type               ) ;
    
    `uvm_info(l_msg_id, "Finished configuring the kwires...", UVM_HIGH)
  endfunction : do_kwire_config

endclass : cdn_pcie_hls_bridge_base_test

`endif // CDN_PCIE_HLS_BRIDGE_BASE_TEST_SV
